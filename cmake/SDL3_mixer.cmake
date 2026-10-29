# SDL_mixer. Cache variables named SDLMIXER_* are SDL_mixer's own options.
# With SDLMIXER_VENDORED, the audio codecs (libFLAC, libogg, libvorbis,
# libopus, libxmp, libgme, mpg123, WavPack, ...) are built from the submodules
# in SDL_mixer's external/ directory and installed as shared libraries that
# SDL_mixer loads at runtime.

set(COOKBOOK_SDL3_MIXER_GIT_TAG "" CACHE STRING "SDL_mixer git tag or commit to build")
set(COOKBOOK_SDL3_MIXER_SOURCE_DIR ""
    CACHE PATH "Local SDL_mixer checkout to build instead of COOKBOOK_SDL3_MIXER_GIT_TAG")

cookbook_add_library(
  SDL3_mixer
  GIT_REPOSITORY https://github.com/libsdl-org/SDL_mixer.git
  GIT_TAG ${COOKBOOK_SDL3_MIXER_GIT_TAG}
  SOURCE_DIR "${COOKBOOK_SDL3_MIXER_SOURCE_DIR}"
  SUBMODULES
  DEPENDS SDL3
  OPTION_PREFIX SDLMIXER_
  CMAKE_CACHE_ARGS
    -DSDLMIXER_TESTS:BOOL=OFF -DSDLMIXER_EXAMPLES:BOOL=OFF -DSDLMIXER_RELOCATABLE:BOOL=ON)
