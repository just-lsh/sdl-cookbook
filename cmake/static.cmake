# Static libraries. Usage: cmake -C cmake/static.cmake -S <library> -B <build-dir>
include("${CMAKE_CURRENT_LIST_DIR}/common.cmake")

set(BUILD_SHARED_LIBS OFF CACHE BOOL "")
set(SDL_SHARED OFF CACHE BOOL "")
set(SDL_STATIC ON CACHE BOOL "")
set(SDLSHADERCROSS_SHARED OFF CACHE BOOL "")
set(SDLSHADERCROSS_STATIC ON CACHE BOOL "")
set(SDLSHADERCROSS_SPIRVCROSS_SHARED OFF CACHE BOOL "")

set(SDLIMAGE_DEPS_SHARED OFF CACHE BOOL "")
set(SDLMIXER_DEPS_SHARED OFF CACHE BOOL "")

# libgme and mpg123 are LGPL-2.1, so static linking would oblige us to ship
# relinkable object files. Drop them: MP3 still plays through the built-in
# dr_mp3; only the GME chiptune formats (NSF, SPC, VGM, ...) go away.
set(SDLMIXER_GME OFF CACHE BOOL "")
set(SDLMIXER_MP3_MPG123 OFF CACHE BOOL "")
