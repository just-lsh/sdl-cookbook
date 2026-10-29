# SDL_ttf. Cache variables named SDLTTF_* are SDL_ttf's own options. With
# SDLTTF_VENDORED, FreeType, HarfBuzz and PlutoSVG are built from the
# submodules in SDL_ttf's external/ directory.

set(COOKBOOK_SDL3_TTF_GIT_TAG "" CACHE STRING "SDL_ttf git tag or commit to build")
set(COOKBOOK_SDL3_TTF_SOURCE_DIR ""
    CACHE PATH "Local SDL_ttf checkout to build instead of COOKBOOK_SDL3_TTF_GIT_TAG")

cookbook_add_library(
  SDL3_ttf
  GIT_REPOSITORY https://github.com/libsdl-org/SDL_ttf.git
  GIT_TAG ${COOKBOOK_SDL3_TTF_GIT_TAG}
  SOURCE_DIR "${COOKBOOK_SDL3_TTF_SOURCE_DIR}"
  SUBMODULES
  DEPENDS SDL3
  OPTION_PREFIX SDLTTF_
  CMAKE_CACHE_ARGS -DSDLTTF_SAMPLES:BOOL=OFF -DSDLTTF_RELOCATABLE:BOOL=ON)
