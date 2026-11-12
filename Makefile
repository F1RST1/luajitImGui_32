CPU_CORE_BITS = 64bit

# Compile ok MinGW gcc 14.2.0
#TC ?= gcc

# Compile ok.
# Visual studio 2019 C/C++
#TC ?= msvc

# Compile ok  Clang version 20.1.0 MinGW-ucrt
# Install ex.: pacman -S mingw-w64-ucrt-x86_64-llvm-openmp
TC ?= clang

# Must be abusolute path
INSTALL_DIR = $(abspath $(CURDIR))/bin
#
BUILD_OPT += -DLUAJIT_BIN=$(INSTALL_DIR)  # Install folder

# Select release options
#BUILD_OPT += -DCMAKE_BUILD_TYPE=RelWithDebInfo
BUILD_OPT += -DCMAKE_BUILD_TYPE=Release

# Select libraries
BUILD_OPT  += -DANIMA_BUILD_LUAJIT=yes
BUILD_OPT  += -DANIMA_BUILD_IM=yes
BUILD_OPT  += -DANIMA_BUILD_GLFW=yes
BUILD_OPT  += -DANIMA_BUILD_SDL=yes
BUILD_OPT  += -DANIMA_BUILD_SDL3=yes
BUILD_OPT  += -DANIMA_BUILD_FREETYPE=yes
BUILD_OPT  += -DANIMA_BUILD_IMGUI=yes
BUILD_OPT  += -DANIMA_BUILD_SNDFILE=yes
BUILD_OPT  += -DANIMA_BUILD_RTAUDIO=yes
BUILD_OPT  += -DANIMA_BUILD_RTMIDI=yes
#BUILD_OPT  += -DLUAJIT_WINDOW_ONLY=???
# For CMake 4.x or later
BUILD_OPT  += -DCMAKE_POLICY_VERSION_MINIMUM=3.5
BUILD_OPT  += -DCMAKE_POLICY_DEFAULT_CMP0000=OLD

# Fixed SDL3 compilation error
BUILD_OPT += -DSDL_OPENGLES=no

# Silented warnings
# You should carefully check these slilented warnings.
SILENTED_WARNINGS += -Wno-unused-value     \
										 -Wno-enum-conversion  \
										 -Wno-unused-function  \
										 -Wno-writable-strings \
										 -Wno-deprecated-non-prototype

NINJA_BUILD = false
ifeq ($(TC),msvc)
	# Compile using build/anima.sln on Microsoft Visual Studio 2022 C/C++ IDE.
	#BUILD_INSTALL_CMD =  (msbuild.exe /m  build/anima.sln)
else
	ifeq ($(NINJA_BUILD),true)
		BUILD_OPT += -G"Ninja"
		BUILD_INSTALL_CMD = ( ninja install )
		BUILD_OPT += -DCMAKE_CXX_STANDARD=11
	else
		BUILD_OPT += -G"MSYS Makefiles"
		BUILD_INSTALL_CMD = ( make install )
	endif
	BUILD_OPT += -DCMAKE_C_FLAGS_RELEASE="-O2"
	BUILD_OPT += -DCMAKE_CXX_FLAGS_RELEASE="-O2"
	ifeq ($(TC),clang)
		BUILD_OPT += -C ../clang.cmake
	endif
	# Dismiss warnings
	#BUILD_OPT += $(SILENTED_WARNINGS)
	# It has to be installed 'openmp' on MinGW.
	BUILD_OPT += -DCMAKE_C_FLAGS_RELEASE="-Wno-error  \
							 -Wno-error=implicit-function-declaration \
							 -O2 $(SILENTED_WARNINGS)  "
	# for C++
	BUILD_OPT += -DCMAKE_CXX_FLAGS_RELEASE="-Wno-error  \
							 -Wno-error=implicit-function-declaration \
							 -DIMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS \
							 -DImDrawIdx=\"unsigned int\" \
							 -Wno-register \
							 -O2 $(SILENTED_WARNINGS)"

	DLL_SOURCE_DIR ?= dll/$(CPU_CORE_BITS)
	FREETYPE_DLL_SOURCE_DIR ?= $(DLL_SOURCE_DIR)/freetype
	COPY_DLL1 = cp -f $(DLL_SOURCE_DIR)/*.dll bin/
	ifneq ($(FREETYPE_DLL_SOURCE_DIR),$(DLL_SOURCE_DIR))
		COPY_FREETYPE_DLL = cp -f $(FREETYPE_DLL_SOURCE_DIR)/*.dll bin/
	endif
endif

BUILD_DIR = .build

.PHONY: main_build implot_ffi_bindings tools_build copy_dll build clean $(INSTALL_DIR) update zip patch rpatch luajitw

all: $(INSTALL_DIR) $(BUILD_DIR) main_build tools_build make_luajitw copy_dll

main_build: implot_ffi_bindings
	(cd $(BUILD_DIR); \
	CMAKE_POLICY_DEFAULT_CMP0000=OLD \
	CMAKE_POLICY_VERSION_MINIMUM=3.5 \
	cmake ../anima $(BUILD_OPT) )
	(cd $(BUILD_DIR); $(BUILD_INSTALL_CMD) )
	@-strip bin/*.dll bin/*.exe

implot_ffi_bindings:
	@if [ "$$(grep -Fc 'implot_ffi_shim.cpp' anima/LuaJIT-ImGui/CMakeLists.txt)" -ne 3 ]; then patch --forward --batch -p1 -d anima/LuaJIT-ImGui < implot_ffi_bindings.patch; fi

TOOLS_DIR = examples/tools

tools_build:
	@$(MAKE) -C $(TOOLS_DIR) TC=$(TC)

LUAJIT_DIR = anima/LuaJIT/LuaJIT

make_luajitw: patch luajitw rpatch demo_patch

patch:
	-patch --unified --forward -d $(LUAJIT_DIR)  src/luajit.c  ../../../dll/make_luajitw.patch

# Reverse patch
rpatch:
	-patch --unified --reverse -d $(LUAJIT_DIR)  src/luajit.c  ../../../dll/make_luajitw.patch

DEMO_PATCH_DIR = bin/examples/LuaJIT-ImGui/examples
DEMO_PATCH = demos.diff
demo_patch:
	-patch  -u --forward   $(DEMO_PATCH_DIR)/CTE_Objects_sample.lua $(DEMO_PATCH)
	-patch  -u --forward   $(DEMO_PATCH_DIR)/CTE_sample.lua         $(DEMO_PATCH)
	-patch  -u --forward   $(DEMO_PATCH_DIR)/CTE_windows.lua        $(DEMO_PATCH)
	-rm $(DEMO_PATCH_DIR)/*.rej $(DEMO_PATCH_DIR)/*.orig

luajitw:
	$(MAKE) -C $(LUAJIT_DIR) clean
	$(MAKE) -C $(LUAJIT_DIR) TARGET_LDFLAGS="-mwindows" TARGET_CFLAGS="-O2 -DLUAJIT_ENABLE_LUA52COMPAT"

copy_dll:
	$(COPY_DLL1)
	cp -f $(LUAJIT_DIR)/src/luajit.exe bin/luajitw.exe
	cp -f $(LUAJIT_DIR)/src/lua51.dll bin/lua51.dll
	$(COPY_FREETYPE_DLL)

$(INSTALL_DIR):
	-mkdir -p $@

$(BUILD_DIR):
	-mkdir -p $@

clean:
	-rm -fr $(BUILD_DIR)
	-rm  bin/*.dll bin/*.exe
	-rm -fr bin/examples
	-rm -fr bin/lua/*.lua
	-rm -fr bin/lua/anima
	-rm -fr bin/lua/imgui
	-rm -fr bin/lua/IPOL
	-rm -fr bin/lua/jit
	-rm -fr bin/lua/lj-async

VER ?= 1.90.8.0
#VER ?= 1.89.9.8
GIT_DIR = .

REPO_NAME = $(CURDIR)
#OPT += -v
#OPT += --dry-run
OPT += --force-submodules

update:
	(cd anima;git pull --recurse-submodules)

zip:
	#(cd $(GIT_DIR);git checkout $(VER))
	git-archive-all $(OPT)   $(REPO_NAME)-v$(VER).zip
	#(cd $(GIT_DIR);git checkout main)


# git-archive-all --help
#  Usage: git-archive-all [-v] [-C BASE_REPO] [--prefix PREFIX]
#  [--no-export-ignore] [--force-submodules] [--include EXTRA1 ...]
#  [--dry-run] [-0 | ... | -9] OUTPUT_FILE
#
# Options:
#   --version             show program's version number and exit
#   -h, --help            show this help message and exit
#   --prefix=PREFIX       prepend PREFIX to each filename in the archive;
#                         defaults to OUTPUT_FILE name
#   -C BASE_REPO          use BASE_REPO as the main git repository to archive;
#                         defaults to the current directory when empty
#   -v, --verbose         enable verbose mode
#   --no-export-ignore, --no-exclude
#                         ignore the [-]export-ignore attribute in
#                         .gitattributes
#   --force-submodules    force `git submodule init && git submodule update` at
#                         each level before iterating submodules
#   --include=EXTRA, --extra=EXTRA
#                         additional files to include in the archive
#   --dry-run             show files to be archived without actually creating
#                         the archive
