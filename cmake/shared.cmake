# Shared libraries. Usage: cmake -C cmake/shared.cmake -S <library> -B <build-dir>
include("${CMAKE_CURRENT_LIST_DIR}/common.cmake")

set(BUILD_SHARED_LIBS ON CACHE BOOL "")
set(SDL_SHARED ON CACHE BOOL "")
set(SDL_STATIC OFF CACHE BOOL "")
set(SDLSHADERCROSS_SHARED ON CACHE BOOL "")
set(SDLSHADERCROSS_STATIC OFF CACHE BOOL "")
set(SDLSHADERCROSS_SPIRVCROSS_SHARED ON CACHE BOOL "")

# Vendored dependencies become separate shared libraries next to the SDL
# library that loads them. This is what lets the LGPL-2.1 libgme and mpg123
# ship: users can replace those libraries with their own builds.
set(SDLIMAGE_DEPS_SHARED ON CACHE BOOL "")
set(SDLMIXER_DEPS_SHARED ON CACHE BOOL "")
