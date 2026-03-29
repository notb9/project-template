#ifndef _TEMPLATE_DEBUG_H_
#define _TEMPLATE_DEBUG_H_
#include <windows.h>
namespace debug
{
    void dbg_printf_impl( const char* fmt, ... );
}

using vDbgPrintEx = ULONG( NTAPI* )( ULONG, ULONG, const char*, ... );

#if DEBUG

#define dbg_printf( ... ) debug::dbg_printf_impl( __VA_ARGS__ )
#define dbg_panic( fmt, ... )                                                                                          \
    debug::dbg_printf_impl( "PANIC: " fmt, __VA_ARGS__ );                                                              \
    __debugbreak();

#else

#define dbg_printf( ... ) (void)0
#define dbg_panic( ... ) (void)0

#endif

#endif
