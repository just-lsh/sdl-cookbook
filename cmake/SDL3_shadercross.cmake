# SDL_shadercross: the SDL3_shadercross library and the shadercross command
# line tool. SPIRV-Cross and DirectXShaderCompiler (DXC) are built from the
# submodules in SDL_shadercross's external/ directory. DXC is a fork of LLVM
# and takes longer to build than all other libraries together.
#
# SDL_shadercross has no releases yet, so the default is a commit on main.

set(COOKBOOK_SDL_SHADERCROSS_GIT_TAG "1ff05bec573988a98ef9e0260b4da44f512b8367" CACHE STRING "SDL_shadercross git tag or commit to build")
set(COOKBOOK_SDL_SHADERCROSS_SOURCE_DIR "" CACHE PATH "Local SDL_shadercross checkout to build instead of COOKBOOK_SDL_SHADERCROSS_GIT_TAG")

cookbook_add_library(SDL3_shadercross
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_shadercross.git
    GIT_TAG ${COOKBOOK_SDL_SHADERCROSS_GIT_TAG}
    SOURCE_DIR "${COOKBOOK_SDL_SHADERCROSS_SOURCE_DIR}"
    SUBMODULES
    # The shadercross command line tool.
    PROGRAMS
    DEPENDS SDL3
    CMAKE_CACHE_ARGS
        -DSDLSHADERCROSS_VENDORED:BOOL=ON
        -DSDLSHADERCROSS_TESTS:BOOL=OFF
        # SPIRV-Tools builds with -Werror by default, which turns warnings of
        # newer compilers (e.g. GCC 16's -Warray-bounds in util/timer.h) into
        # build failures.
        -DSPIRV_WERROR:BOOL=OFF
)
