# SDL. Any tag or commit of https://github.com/libsdl-org/SDL works as
# COOKBOOK_SDL3_GIT_TAG; COOKBOOK_SDL3_SOURCE_DIR builds a local checkout
# instead. Cache variables named SDL_* are SDL's own options.

set(COOKBOOK_SDL3_GIT_TAG "" CACHE STRING "SDL git tag or commit to build")
set(COOKBOOK_SDL3_SOURCE_DIR ""
    CACHE PATH "Local SDL checkout to build instead of COOKBOOK_SDL3_GIT_TAG")
set(COOKBOOK_SDL3_REQUIRE ""
    CACHE STRING "Defines that SDL's SDL_build_config.h must contain, or the build fails")

cookbook_add_library(
  SDL3
  GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
  GIT_TAG ${COOKBOOK_SDL3_GIT_TAG}
  SOURCE_DIR "${COOKBOOK_SDL3_SOURCE_DIR}"
  OPTION_PREFIX SDL_
  CMAKE_CACHE_ARGS
    # SDL_TESTS only drops the test programs; the SDL3_test library has
    # its own switch.
    -DSDL_TEST_LIBRARY:BOOL=OFF
    -DSDL_TESTS:BOOL=OFF
    -DSDL_EXAMPLES:BOOL=OFF
    # Package config files without absolute paths, so the install can be moved.
    -DSDL_RELOCATABLE:BOOL=ON)

# SDL compiles in a backend only if it finds its headers, and silently drops
# it otherwise. SDL_build_config.h records what it compiled in, so this step
# fails the build when a backend the recipe requires is missing.
if(COOKBOOK_SDL3 AND COOKBOOK_SDL3_REQUIRE)
  externalproject_get_property(SDL3 BINARY_DIR)
  set(require_file "${CMAKE_BINARY_DIR}/SDL3/require.txt")
  string(REPLACE ";" "\n" require_lines "${COOKBOOK_SDL3_REQUIRE}")
  file(CONFIGURE OUTPUT "${require_file}" CONTENT "${require_lines}\n")
  externalproject_add_step(
    SDL3 require
    COMMAND
      "${CMAKE_COMMAND}" "-DBUILD_DIR=${BINARY_DIR}" "-DREQUIRE_FILE=${require_file}" -P
      "${CMAKE_CURRENT_LIST_DIR}/CheckSDLBuildConfig.cmake"
    DEPENDEES configure
    DEPENDERS build
    DEPENDS "${require_file}")
endif()
