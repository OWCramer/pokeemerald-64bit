// Persistent diagnostic log for the native port.
//
// The crashes worth chasing are minutes into gameplay, past the intro, and
// cannot be reached reliably by scripted input -- so diagnostics have to
// outlive the process rather than be watched on a console. Every line is
// flushed immediately: a segfault must not take the last (most interesting)
// line with it.
//
// The log is truncated on first write, so each run stands alone.
#ifdef NATIVE_BUILD

#include <stdio.h>
#include <stdarg.h>

#define EMERALD_LOG_PATH "emerald_debug.log"

void EmeraldLog(const char *fmt, ...)
{
    static FILE *f;
    static int tried;

    if (!tried)
    {
        tried = 1;
        f = fopen(EMERALD_LOG_PATH, "w");
    }
    if (f == NULL)
        return;

    va_list ap;
    va_start(ap, fmt);
    vfprintf(f, fmt, ap);
    va_end(ap);
    fputc('\n', f);
    fflush(f);
}

#endif // NATIVE_BUILD
