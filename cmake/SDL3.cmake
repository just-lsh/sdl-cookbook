# SDL. Any tag or commit of https://github.com/libsdl-org/SDL works as
# COOKBOOK_SDL_GIT_TAG; COOKBOOK_SDL_SOURCE_DIR builds a local checkout instead.

set(COOKBOOK_SDL_GIT_TAG "release-3.4.18" CACHE STRING "SDL git tag or commit to build")
set(COOKBOOK_SDL_SOURCE_DIR "" CACHE PATH "Local SDL checkout to build instead of COOKBOOK_SDL_GIT_TAG")

cookbook_add_library(SDL3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG ${COOKBOOK_SDL_GIT_TAG}
    SOURCE_DIR "${COOKBOOK_SDL_SOURCE_DIR}"
    CMAKE_CACHE_ARGS
        # SDL_TESTS only drops the test programs; the SDL3_test library has
        # its own switch.
        -DSDL_TEST_LIBRARY:BOOL=OFF
        -DSDL_TESTS:BOOL=OFF
        -DSDL_EXAMPLES:BOOL=OFF
        # Package config files without absolute paths, so the install can be moved.
        -DSDL_RELOCATABLE:BOOL=ON
)
