#include "debug.h"
#ifdef DEBUG
void debug::dbg_printf_impl( const char* fmt, ... )
{
    auto module_handle = GetModuleHandleA( "ntdll.dll" );
    if ( module_handle )
    {
        auto pfn = reinterpret_cast<void*>( GetProcAddress( module_handle, "vDbgPrintEx" ) );
        if ( pfn )
        {
            va_list args;
            va_start( args, fmt );
            reinterpret_cast<vDbgPrintEx>( pfn )( 0, 0, fmt, args );
            va_end( args );
            return;
        }
    }

    // Congratulations, this should never have happend...
    __debugbreak();
}
#endif
