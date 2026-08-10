#ifdef PORTABLE
#include "global.h"
#include "cgb_audio.h"
#include "cgb_tables.h"

struct AudioCGB gb;
float soundChannelPos[4];

// PSG anti-aliasing: generate the wavetable channels at CGB_OS x the output
// rate, then decimate through this low-pass. See the generation loop below.
#define CGB_OS 16
#define CGB_FIR_TAPS 32
// 32-tap Blackman-windowed sinc, 17kHz cutoff at 16 x 42060Hz. Sums to 1.
static const float cgbFir[CGB_FIR_TAPS] = {
    -0.000000000f, +0.000103001f, +0.000520678f, +0.001464876f,
    +0.003214902f, +0.006095753f, +0.010425547f, +0.016439237f,
    +0.024204427f, +0.033550294f, +0.044030713f, +0.054936988f,
    +0.065365335f, +0.074331732f, +0.080915044f, +0.084401474f,
    +0.084401474f, +0.080915044f, +0.074331732f, +0.065365335f,
    +0.054936988f, +0.044030713f, +0.033550294f, +0.024204427f,
    +0.016439237f, +0.010425547f, +0.006095753f, +0.003214902f,
    +0.001464876f, +0.000520678f, +0.000103001f, -0.000000000f,
};
static float cgbFirBufL[CGB_FIR_TAPS];
static float cgbFirBufR[CGB_FIR_TAPS];
static u32 cgbFirIdx;
// EMERALD_PSG_OVERSAMPLE=n overrides the ratio at runtime; n=1 restores the
// old point-sampled behaviour (no decimation) for A/B comparison.
static int cgbOs = CGB_OS;
const s16 *PU1Table;
const s16 *PU2Table;
u32 apuFrame;
u8 apuCycle;
u32 sampleRate;
u16 lfsrMax[2];
float ch4Samples;

void cgb_audio_init(u32 rate){
    gb.ch1Freq = 0;
    gb.ch1SweepCounter = 0;
    gb.ch1SweepCounterI = 0;
    gb.ch1SweepDir = 0;
    gb.ch1SweepShift = 0;
    for (u8 ch = 0; ch < 4; ch++){
        gb.Vol[ch] = 0;
        gb.VolI[ch] = 0;
        gb.Len[ch] = 0;
        gb.LenI[ch] = 0;
        gb.LenOn[ch] = 0;
        gb.EnvCounter[ch] = 0;
        gb.EnvCounterI[ch] = 0;
        gb.EnvDir[ch] = 0;
        gb.DAC[ch] = 0;
        soundChannelPos[ch] = 0;
    }
    soundChannelPos[1] = 1;
    PU1Table = PU0;
    PU2Table = PU0;
    sampleRate = rate;
    gb.ch4LFSR[0] = 0x8000;
    gb.ch4LFSR[1] = 0x80;
    lfsrMax[0] = 0x8000;
    lfsrMax[1] = 0x80;
    ch4Samples = 0.0f;
    for (u32 t = 0; t < CGB_FIR_TAPS; t++){
        cgbFirBufL[t] = 0.0f;
        cgbFirBufR[t] = 0.0f;
    }
    cgbFirIdx = 0;
    {
        extern char *getenv(const char *);
        const char *o = getenv("EMERALD_PSG_OVERSAMPLE");
        if (o){
            int v = 0;
            while (*o >= '0' && *o <= '9') v = v * 10 + (*o++ - '0');
            if (v >= 1 && v <= 64) cgbOs = v;
        }
    }
}


void cgb_set_sweep(u8 sweep){
    gb.ch1SweepDir = (sweep & 0x08) >> 3;
    gb.ch1SweepCounter = gb.ch1SweepCounterI = (sweep & 0x70) >> 4;
    gb.ch1SweepShift = (sweep & 0x07);
}


void cgb_set_wavram(){
    for(u8 wavi = 0; wavi < 0x10; wavi++){
        gb.WAVRAM[(wavi << 1)] = (((*(REG_ADDR_WAVE_RAM0 + wavi)) & 0xF0) >> 4) / 7.5f - 1.0f;
        gb.WAVRAM[(wavi << 1) + 1] = (((*(REG_ADDR_WAVE_RAM0 + wavi)) & 0x0F)) / 7.5f - 1.0f;
    }
}


void cgb_toggle_length(u8 channel, bool8 state){
    gb.LenOn[channel] = state;
}


void cgb_set_length(u8 channel, u8 length){
    gb.Len[channel] = gb.LenI[channel] = length;
}


void cgb_set_envelope(u8 channel, u8 envelope){
    if(channel == 2){
        switch((envelope & 0xE0)){
            case 0x00:  // mute
                gb.Vol[2] = gb.VolI[2] = 0;
            break;
            case 0x20:  // full
                gb.Vol[2] = gb.VolI[2] = 4;
            break;
            case 0x40:  // half
                gb.Vol[2] = gb.VolI[2] = 2;
            break;
            case 0x60:  // quarter
                gb.Vol[2] = gb.VolI[2] = 1;
            break;
            case 0x80:  // 3 quarters
                gb.Vol[2] = gb.VolI[2] = 3;
            break;
        }
    }else{
        gb.DAC[channel] = (envelope & 0xF8) > 0;
        gb.Vol[channel] = gb.VolI[channel] = (envelope & 0xF0) >> 4;
        gb.EnvDir[channel] = (envelope & 0x08) >> 3;
        gb.EnvCounter[channel] = gb.EnvCounterI[channel] = (envelope & 0x07);
    }
}


void cgb_trigger_note(u8 channel){
    // Triggering a note re-enables the channel, exactly as writing the trigger
    // bit to NRx4 does on hardware. The emulator never modelled that, while two
    // paths *clear* the enable bit: a length counter expiring, and a sweep
    // overflow. Either one therefore silenced that channel permanently for the
    // rest of the session.
    //
    // That is what broke the EXP gain sound. SE_SELECT overflows the sweep on
    // the menu, which disabled square 1; every later note on that channel --
    // SE_EXP among them -- was then programmed with correct frequency and
    // volume into a channel NR52 said was off.
    REG_NR52 |= (1 << channel);
    gb.Vol[channel] = gb.VolI[channel];
    gb.Len[channel] = gb.LenI[channel];
    if(channel != 2) gb.EnvCounter[channel] = gb.EnvCounterI[channel];
    if(channel == 3) {
        gb.ch4LFSR[0] = 0x8000;
        gb.ch4LFSR[1] = 0x80;
    }
}


void cgb_audio_generate(u16 samplesPerFrame){
    float *outBuffer = gb.outBuffer;
    switch(REG_NR11 & 0xC0){
        case 0x00:
            PU1Table = PU0;
        break;
        case 0x40:
            PU1Table = PU1;
        break;
        case 0x80:
            PU1Table = PU2;
        break;
        case 0xC0:
            PU1Table = PU3;
        break;
    }

    switch(REG_NR21 & 0xC0){
        case 0x00:
            PU2Table = PU0;
        break;
        case 0x40:
            PU2Table = PU1;
        break;
        case 0x80:
            PU2Table = PU2;
        break;
        case 0xC0:
            PU2Table = PU3;
        break;
    }

    for (u16 i = 0; i < samplesPerFrame; i++, outBuffer+=2) {
        apuFrame += 512;
        if(apuFrame >= sampleRate){
            apuFrame -= sampleRate;
            apuCycle++;

            if((apuCycle & 1) == 0){  // Length
                for(u8 ch = 0; ch < 4; ch++){
                    if(gb.Len[ch]){
                        if(--gb.Len[ch] == 0 && gb.LenOn[ch]){
                            REG_NR52 &= (0xFF ^ (1 << ch));
                        }
                    }
                }
            }

            if((apuCycle & 7) == 7){  // Envelope
                for(u8 ch = 0; ch < 4; ch++){
                    if(ch == 2) continue;  // Skip wave channel
                    if(gb.EnvCounter[ch]){
                        if(--gb.EnvCounter[ch] == 0){
                            if(gb.Vol[ch] && !gb.EnvDir[ch]){
                                gb.Vol[ch]--;
                                gb.EnvCounter[ch] = gb.EnvCounterI[ch];
                            }else if(gb.Vol[ch] < 0x0F && gb.EnvDir[ch]){
                                gb.Vol[ch]++;
                                gb.EnvCounter[ch] = gb.EnvCounterI[ch];
                            }
                        }
                    }
                }
            }

            if((apuCycle & 3) == 2){  // Sweep
                if(gb.ch1SweepCounterI && gb.ch1SweepShift){
                    if(--gb.ch1SweepCounter == 0){
                        u32 cur = REG_SOUND1CNT_X & 0x7FF;
                        u32 next = gb.ch1SweepDir
                                 ? cur - (cur >> gb.ch1SweepShift)
                                 : cur + (cur >> gb.ch1SweepShift);
                        if(next & 0xF800){
                            // Sweep overflow. Hardware disables the channel and
                            // leaves the frequency registers alone. Writing the
                            // clamped value back instead left NR13/NR14 holding
                            // frequency 0 -- which is 131072/2048 = 64Hz, about
                            // five octaves below a high note, and audible as a
                            // low tone outlasting effects like SE_SELECT.
                            REG_NR52 &= 0xFE;
                            gb.EnvCounter[0] = 0;
                            gb.Vol[0] = 0;
                        }else{
                            gb.ch1Freq = next;
                            REG_NR13 = gb.ch1Freq & 0xFF;
                            REG_NR14 &= 0xF8;
                            REG_NR14 += (gb.ch1Freq >> 8) & 0x07;
                        }
                        gb.ch1SweepCounter = gb.ch1SweepCounterI;
                    }
                }
            }
        }
        // Sound generation loop.
        //
        // The three wavetable channels are generated at CGB_OS times the output
        // rate and decimated through a windowed-sinc low-pass. Point-sampling
        // them directly at the output rate (what this used to do) folds their
        // upper harmonics down into the audible band: for the 3.1kHz menu ping
        // the 27th harmonic landed at 142Hz, which read as a phantom bass note
        // sitting under the ping and outlasting it. Oversampling moves those
        // images above the decimation cutoff so they can actually be removed --
        // a low-pass at the output rate cannot, because by then the offending
        // energy is already at 142Hz. Ratio is the only lever that matters here
        // (8x measured -57dB in the 80-400Hz band, 16x -65dB, vs -32dB before);
        // filter length barely moves it, hence only 32 taps.
        const float stepScale = 1.0f / (sampleRate / 32.0f) / cgbOs;
        float step1 = freqTable[REG_SOUND1CNT_X & 0x7FF] * stepScale;
        float step2 = freqTable[REG_SOUND2CNT_H & 0x7FF] * stepScale;
        float step3 = freqTable[REG_SOUND3CNT_X & 0x7FF] * stepScale;
        bool32 psgOn = (REG_NR52 & 0x80) != 0;
        for(int os = 0; os < cgbOs; os++){
            soundChannelPos[0] += step1;
            soundChannelPos[1] += step2;
            soundChannelPos[2] += step3;
            while(soundChannelPos[0] >= 32) soundChannelPos[0] -= 32;
            while(soundChannelPos[1] >= 32) soundChannelPos[1] -= 32;
            while(soundChannelPos[2] >= 32) soundChannelPos[2] -= 32;
            float sL = 0;
            float sR = 0;
            if(psgOn){
                if((gb.DAC[0]) && (REG_NR52 & 0x01)){
                    if(REG_NR51 & 0x10) sL += gb.Vol[0] * PU1Table[(int)(soundChannelPos[0])] / 15.0f;
                    if(REG_NR51 & 0x01) sR += gb.Vol[0] * PU1Table[(int)(soundChannelPos[0])] / 15.0f;
                }
                if((gb.DAC[1]) && (REG_NR52 & 0x02)){
                    if(REG_NR51 & 0x20) sL += gb.Vol[1] * PU2Table[(int)(soundChannelPos[1])] / 15.0f;
                    if(REG_NR51 & 0x02) sR += gb.Vol[1] * PU2Table[(int)(soundChannelPos[1])] / 15.0f;
                }
                if((REG_NR30 & 0x80) && (REG_NR52 & 0x04)){
                    if(REG_NR51 & 0x40) sL += gb.Vol[2] * gb.WAVRAM[(int)(soundChannelPos[2])] / 4.0f;
                    if(REG_NR51 & 0x04) sR += gb.Vol[2] * gb.WAVRAM[(int)(soundChannelPos[2])] / 4.0f;
                }
            }
            cgbFirBufL[cgbFirIdx] = sL;
            cgbFirBufR[cgbFirIdx] = sR;
            cgbFirIdx = (cgbFirIdx + 1) & (CGB_FIR_TAPS - 1);
        }
        float outputL = 0;
        float outputR = 0;
        if(cgbOs == 1){
            // no oversampling: take the sample as-is, matching the old path
            u32 last = (cgbFirIdx - 1) & (CGB_FIR_TAPS - 1);
            outputL = cgbFirBufL[last];
            outputR = cgbFirBufR[last];
        }else{
            u32 idx = cgbFirIdx;
            for(int t = 0; t < CGB_FIR_TAPS; t++){
                outputL += cgbFir[t] * cgbFirBufL[idx];
                outputR += cgbFir[t] * cgbFirBufR[idx];
                idx = (idx + 1) & (CGB_FIR_TAPS - 1);
            }
        }
        // Noise is broadband and already averages across its sub-steps, so it
        // is generated once per output sample and mixed in after decimation.
        if(psgOn){
        if((gb.DAC[3]) && (REG_NR52 & 0x08)){
                    bool32 lfsrMode = ((REG_NR43 & 0x08) == 8);
                    ch4Samples += freqTableNSE[REG_SOUND4CNT_H & 0xFF] / sampleRate;
                    int ch4Out = 0;
                    if(gb.ch4LFSR[lfsrMode] & 1){
                        ch4Out++;
                    }else{
                        ch4Out--;
                    }
                    int avgDiv = 1;
                    while(ch4Samples >= 1){
                        avgDiv++;
                        bool8 lfsrCarry = 0;
                        if(gb.ch4LFSR[lfsrMode] & 2) lfsrCarry ^= 1;
                        gb.ch4LFSR[lfsrMode] >>= 1;
                        if(gb.ch4LFSR[lfsrMode] & 2) lfsrCarry ^= 1;
                        if(lfsrCarry) gb.ch4LFSR[lfsrMode] |= lfsrMax[lfsrMode];
                        if(gb.ch4LFSR[lfsrMode] & 1){
                            ch4Out++;
                        }else{
                            ch4Out--;
                        }
                        ch4Samples--;
                    }
                    float sample = ch4Out;
                    if(avgDiv > 1) sample /= avgDiv;
                    if(REG_NR51 & 0x80) outputL += gb.Vol[3] * sample / 15.0f;
                    if(REG_NR51 & 0x08) outputR += gb.Vol[3] * sample / 15.0f;
                }
        }
        outputL /= 4.0f;
        outputR /= 4.0f;
        outBuffer[0] = outputL;
        outBuffer[1] = outputR;
    }
}


float *cgb_get_buffer(){
    return gb.outBuffer;
}
#endif //PORTABLE