#ifndef GUARD_PLATFORM_H
#define GUARD_PLATFORM_H

#include "global.h"
#include "siirtc.h"

void Platform_StoreSaveFile(void);
void Platform_ReadFlash(u16 sectorNum, u32 offset, u8 *dest, u32 size);
void Platform_QueueAudio(float *audioBuffer, s32 samplesPerFrame);
u16 Platform_GetKeyInput(void);
void Platform_GetStatus(struct SiiRtcInfo *rtc);
void Platform_SetStatus(struct SiiRtcInfo *rtc);
static void UpdateInternalClock(void);
void Platform_GetDateTime(struct SiiRtcInfo *rtc);
void Platform_SetDateTime(struct SiiRtcInfo *rtc);
void Platform_GetTime(struct SiiRtcInfo *rtc);
void Platform_SetTime(struct SiiRtcInfo *rtc);
void Platform_SetAlarm(u8 *alarmData);


// Rebindable input, implemented by the SDL3 platform layer. Bindings persist to
// a config file beside the save rather than the save block, so the .sav stays
// interchangeable with real hardware.
u8 Platform_GetBindCount(void);
const char *Platform_GetBindName(u8 index);
void Platform_GetBindLabel(u8 index, char *out, int outSize);
void Platform_BeginRebind(u8 index);
bool8 Platform_IsRebinding(void);
void Platform_CancelRebind(void);
void Platform_ResetBindings(void);
void Platform_SaveBindings(void);
bool8 Platform_HasBindConflict(void);
void Platform_GetConflictText(char *out, int outSize);
void Platform_ResolveBindConflict(bool8 replace);

#endif