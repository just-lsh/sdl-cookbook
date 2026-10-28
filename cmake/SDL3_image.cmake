# SDL_image. The image codecs (libpng, libjpeg, libwebp, libavif with aom and
# dav1d, libtiff, ...) are built from the submodules in SDL_image's external/
# directory and installed as shared libraries that SDL_image loads at runtime.

set(COOKBOOK_SDL_IMAGE_GIT_TAG "release-3.4.8" CACHE STRING "SDL_image git tag or commit to build")
set(COOKBOOK_SDL_IMAGE_SOURCE_DIR ""
    CACHE PATH "Local SDL_image checkout to build instead of COOKBOOK_SDL_IMAGE_GIT_TAG")

cookbook_add_library(
  SDL3_image
  GIT_REPOSITORY https://github.com/libsdl-org/SDL_image.git
  GIT_TAG ${COOKBOOK_SDL_IMAGE_GIT_TAG}
  SOURCE_DIR "${COOKBOOK_SDL_IMAGE_SOURCE_DIR}"
  SUBMODULES
  DEPENDS SDL3
  CMAKE_CACHE_ARGS
    -DSDLIMAGE_VENDORED:BOOL=ON
    # Fail instead of silently dropping a format whose codec is missing.
    -DSDLIMAGE_STRICT:BOOL=ON -DSDLIMAGE_SAMPLES:BOOL=OFF -DSDLIMAGE_TESTS:BOOL=OFF
    -DSDLIMAGE_RELOCATABLE:BOOL=ON)
