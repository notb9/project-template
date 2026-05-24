PROJECT_NAME ?= template
CCX64        := clang-19 -target x86_64-w64-mingw32

# Compiler and linker flags
CXXFLAGS    := -std=c++20 -Iinclude -masm=intel

## Strict errors
CXXFLAGS    += -Wall -Wextra -Wpedantic -Werror
CXXFLAGS    += -fms-extensions -Wno-error=nested-anon-types

## Be dependency free
CXXFLAGS    += -fno-builtin -fno-stack-protector
CXXFLAGS    += -fno-exceptions -fno-rtti

## Remove identifying marks
CXXFLAGS    += -fno-ident

## Prepare for optmization
CXXFLAGS    += -ffunction-sections -fdata-sections

# Use the lld linker (permits forward exports by ordinal)
LDFLAGS     := -fuse-ld=lld-19

## Avoid pulling in anything of the runtime
LDFLAGS     += -nostdlib -nostdlib++

# Link to Windows DLLs. Change as needed
LIBRARIES   := -lkernel32 -luser32 -lshell32

# Setup file paths
SRC_DIR   := src
BUILD_DIR := bin
DIST_DIR  := dist
OBJ_DIR   := $(BUILD_DIR)/obj

DEFS      := exports.def
OUTPUT    := $(BUILD_DIR)/$(PROJECT_NAME)

# Collect source and object files
SRC       := $(wildcard $(SRC_DIR)/*.cc)
OBJ       := $(patsubst $(SRC_DIR)/%.cc,$(OBJ_DIR)/%.o,$(SRC))

# Translate paths between WSL and Windows filesystem
WIN_DIR   := $(shell wslpath -w '$(CURDIR)')
WIN_EXE   := $(shell wslpath -w '$(CURDIR)/$(OUTPUT).exe')
WIN_DLL   := $(shell wslpath -w '$(CURDIR)/$(OUTPUT).dll')

exe-windbg:
	/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -c 'windbgx -lsrcpath "$(WIN_DIR)\$(SRC_DIR); $(WIN_DIR)\include" -y "srv*C:\symbols*https://msdl.microsoft.com/download/symbols" -c "bp $(PROJECT_NAME)!ExeMain; g" $(WIN_EXE)'

dll-windbg:
	/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -c 'windbgx -lsrcpath "$(WIN_DIR)\$(SRC_DIR); $(WIN_DIR)\include" -y "srv*C:\symbols*https://msdl.microsoft.com/download/symbols" -c "bp $(PROJECT_NAME)!_ExecPayload; g" C:\Windows\System32\rundll32.exe $(WIN_DLL),EntryFunc'

# Generate PDB for debugging inside WinDbg
%-debug: CXXFLAGS += -g -gcodeview -O0 -DDEBUG
%-debug: LDFLAGS  += -Wl,/debug -Wl,/pdb:$(OUTPUT).pdb
%-debug: %
	@true

# Optimize unused code away and merge identical code
%-release: OUTPUT   := $(DIST_DIR)/$(PROJECT_NAME)
%-release: CXXFLAGS += -Os
%-release: LDFLAGS  += -Wl,--icf=all -fmerge-all-constants -Wl,--gc-sections -Wl,--strip-all -Wl,/map:dist/template.map
%-release: % | $(DIST_DIR)
	@true

exe: LDFLAGS += -Wl,--entry=ExeMain -Wl,-subsystem,windows
exe: $(OBJ)
	$(CCX64) $(LDFLAGS) -o $(OUTPUT).exe $^ $(LIBRARIES)

dll: LDFLAGS += -Wl,--entry=DllMain -shared
dll: $(OBJ) $(DEFS)
	$(CCX64) $(LDFLAGS) -o $(OUTPUT).dll $^ $(LIBRARIES)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cc
	@mkdir -p $(dir $@)
	@echo "  * $< -> $@"
	$(CCX64) $(CXXFLAGS) -c -o $@ $<

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

clean:
	@echo "cleaning object files"
	@rm -rf $(OBJ_DIR)
	@rm -f $(OUTPUT).exe $(OUTPUT).dll $(OUTPUT).pdb
	@rm -f $(DIST_DIR)/$(PROJECT_NAME).dll $(DIST_DIR)/$(PROJECT_NAME).exe $(DIST_DIR)/$(PROJECT_NAME).map
