#include <windows.h>

#include "debug.h"

HMODULE module_handle;

extern "C" int ExeMain()
{
    const wchar_t* msg;
    int            argc = 0;
    wchar_t**      argv = CommandLineToArgvW( GetCommandLineW(), &argc );

    module_handle = nullptr;

    dbg_printf( "Received %d arguments\n", argc );

    if ( argc == 1 )
    {
        msg = argv[ 0 ];
    }
    else
    {
        msg = argv[ 1 ];
    }
    MessageBoxW( nullptr, msg, L"It works", MB_OKCANCEL );
    return 0;
}

BOOL WINAPI DllMain( HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved )
{
    switch ( fdwReason )
    {
    case DLL_PROCESS_ATTACH:
        module_handle = hinstDLL;
        dbg_printf( "Dll is loaded at: 0x%p\n", module_handle );
        break;

    case DLL_THREAD_ATTACH:
        break;

    case DLL_THREAD_DETACH:
        break;

    case DLL_PROCESS_DETACH:
        if ( lpvReserved != nullptr )
        {
            break;
        }
        break;
    }
    return TRUE;
}

extern "C" void _ExecPayload()
{
    MessageBoxW( nullptr, L"Called", L"Exported Function", MB_OKCANCEL );
}
