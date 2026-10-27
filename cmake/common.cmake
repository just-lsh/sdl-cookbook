# Options shared by every build flavour. Load through cmake/shared.cmake or
# cmake/static.cmake with `cmake -C`, never on its own.
#
# One cache file is passed to every library; each project only reads the
# variables carrying its own prefix.

# Build third-party dependencies from the nested submodules instead of
# looking for system packages, and fail instead of silently dropping a format.
set(SDLIMAGE_VENDORED ON CACHE BOOL "")
set(SDLMIXER_VENDORED ON CACHE BOOL "")
set(SDLTTF_VENDORED ON CACHE BOOL "")
set(SDLSHADERCROSS_VENDORED ON CACHE BOOL "")
set(SDLIMAGE_STRICT ON CACHE BOOL "")
set(SDLMIXER_STRICT ON CACHE BOOL "")
set(SDLTTF_STRICT ON CACHE BOOL "")

# Only the libraries (and the shadercross CLI) are shipped.
set(SDL_TESTS OFF CACHE BOOL "")
set(SDL_EXAMPLES OFF CACHE BOOL "")
set(SDLIMAGE_SAMPLES OFF CACHE BOOL "")
set(SDLIMAGE_TESTS OFF CACHE BOOL "")
set(SDLMIXER_TESTS OFF CACHE BOOL "")
set(SDLMIXER_EXAMPLES OFF CACHE BOOL "")
set(SDLTTF_SAMPLES OFF CACHE BOOL "")
set(SDLNET_SAMPLES OFF CACHE BOOL "")
set(SDLSHADERCROSS_TESTS OFF CACHE BOOL "")

# Same layout in every archive; GNUInstallDirs would pick lib64 on some distros.
set(CMAKE_INSTALL_LIBDIR "lib" CACHE PATH "")

# Relocatable packages, so the CMake config files work wherever users unpack them.
set(SDL_RELOCATABLE ON CACHE BOOL "")
set(SDLIMAGE_RELOCATABLE ON CACHE BOOL "")
set(SDLMIXER_RELOCATABLE ON CACHE BOOL "")
set(SDLTTF_RELOCATABLE ON CACHE BOOL "")
set(SDLNET_RELOCATABLE ON CACHE BOOL "")

# libgme's MAME YM2612 emulator is GPLv2+; Nuked keeps libgme LGPL-2.1.
set(GME_YM2612_EMU "Nuked" CACHE STRING "")
