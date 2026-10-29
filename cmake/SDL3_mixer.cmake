# SDL_mixer. The audio codecs (libFLAC, libogg, libvorbis, libopus, libxmp,
# libgme, mpg123, WavPack, ...) are built from the submodules in SDL_mixer's
# external/ directory and installed as shared libraries that SDL_mixer loads
# at runtime.

set(COOKBOOK_SDL_MIXER_GIT_TAG "release-3.2.4" CACHE STRING "SDL_mixer git tag or commit to build")
set(COOKBOOK_SDL_MIXER_SOURCE_DIR ""
    CACHE PATH "Local SDL_mixer checkout to build instead of COOKBOOK_SDL_MIXER_GIT_TAG")

cookbook_add_library(
  SDL3_mixer
  GIT_REPOSITORY https://github.com/libsdl-org/SDL_mixer.git
  GIT_TAG ${COOKBOOK_SDL_MIXER_GIT_TAG}
  SOURCE_DIR "${COOKBOOK_SDL_MIXER_SOURCE_DIR}"
  SUBMODULES
  DEPENDS SDL3
  CMAKE_CACHE_ARGS
    -DSDLMIXER_VENDORED:BOOL=ON
    # Fail instead of silently dropping a format whose codec is missing.
    -DSDLMIXER_STRICT:BOOL=ON -DSDLMIXER_TESTS:BOOL=OFF -DSDLMIXER_EXAMPLES:BOOL=OFF
    -DSDLMIXER_RELOCATABLE:BOOL=ON)
