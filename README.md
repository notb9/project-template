# Template
Template for developing and debugging Windows C++ executables and DLLs that only rely on the Win32 api.

The template provides the following:
  - A VSCode setup with intellisense inside WSL2
  - Debugging through WinDbg
  - Simple building via Makefile
  - Formatting through clang-format
  - Pre-configured .vscode directory
  - Debug print facilities
  - Removal of unused code (the release build produces `dist/template.map` to inspect what code was included)

## Usage
This template uses a Makfile for building your project and debugging it with WinDbg. Your project can  live either on your `C:` drive or inside WSL2, but you must be running vscode from inside WSL2.

> [!IMPORTANT]
> In order to be able to place breakpoints inside the source code view in windbg, the paths in the PDB must match with what windbg is expecting. To this end, `subst.exe` is used to map the WSL folder unto the `Y` drive letter. Ensure you change the `WIN_DRIVE` variable in the Makefile if you are already using it.

```bash
# To produce a debugable build
make <dll|exe>-debug

# To start a debugable exe in windbg
make exe-windbg

# To produce an optimized release build
make <dll|exe>-release
```

For debugging the following facilities are provided:
  - `dbg_printf`: Prints a format string to the WinDbg console.
  - `dbg_panic`: Prints a format string to the WinDbg console and then triggers a breakpoint.

To build the project and start debugging inside windbg select `Tasks: Run Test Task` via `CTRL + SHIFT + p` (consider creating a shortcut).

> [!IMPORTANT]
> Make sure to run `make clean` or the `Clean` task when swapping between release and debug builds.
> The debugging facilities use preprocessor macro's for conditional compiling!

## VSCode extension
The following VSCode extensions are used:
  - ms-vscode.cpptools-extension-pack
  - xaver.clang-format

## Required Software
You must have the following installed inside WSL2 for the template to work:
  - mingw-w64
  - clang-19
  - lld-19
  - clang-format
  - make

If you want to build inside docker rather than WSL2. Then you still need to have the following installed on WSL2:
  - make (for running the Makefile)
  - mingw-w64 (for autocompletion)

> [!NOTE]
> LLVM version 19 is not a hard requirement. Is was chosen as it supports forwarding exports by ordinal  `ld.lld-19`.
> View syntax [on MSDN](https://learn.microsoft.com/en-us/cpp/build/reference/exports?view=msvc-170)


On the Windows host you need to have the following software installed:
  - Visual Studio Code
  - WSL2
  - WinDbg
