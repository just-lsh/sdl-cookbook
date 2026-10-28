# Fetches SDL and adds it to the build with its install rules enabled.
#
# Any tag or commit of https://github.com/libsdl-org/SDL works as
# COOKBOOK_SDL_GIT_TAG. To build a local checkout instead, set
# FETCHCONTENT_SOURCE_DIR_SDL3 to its path.

include(FetchContent)

set(COOKBOOK_SDL_GIT_TAG "release-3.4.18" CACHE STRING "SDL git tag or commit to build")

FetchContent_Declare(SDL3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG ${COOKBOOK_SDL_GIT_TAG}
    GIT_SHALLOW ON
    GIT_PROGRESS ON
)

# SDL disables its install rules when built as a subproject.
set(SDL_INSTALL ON CACHE BOOL "")

FetchContent_MakeAvailable(SDL3)

# The version of the fetched sources, e.g. 3.4.18.
get_directory_property(COOKBOOK_SDL_VERSION DIRECTORY "${sdl3_SOURCE_DIR}" DEFINITION PROJECT_VERSION)
