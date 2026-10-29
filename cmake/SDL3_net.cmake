# SDL_net. Cache variables named SDLNET_* are SDL_net's own options.

set(COOKBOOK_SDL3_NET_GIT_TAG "" CACHE STRING "SDL_net git tag or commit to build")
set(COOKBOOK_SDL3_NET_SOURCE_DIR ""
    CACHE PATH "Local SDL_net checkout to build instead of COOKBOOK_SDL3_NET_GIT_TAG")

cookbook_add_library(
  SDL3_net
  GIT_REPOSITORY https://github.com/libsdl-org/SDL_net.git
  GIT_TAG ${COOKBOOK_SDL3_NET_GIT_TAG}
  SOURCE_DIR "${COOKBOOK_SDL3_NET_SOURCE_DIR}"
  DEPENDS SDL3
  OPTION_PREFIX SDLNET_
  CMAKE_CACHE_ARGS -DSDLNET_SAMPLES:BOOL=OFF -DSDLNET_RELOCATABLE:BOOL=ON)
