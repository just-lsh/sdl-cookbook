cmake_minimum_required(VERSION 3.25)

# A superbuild: it compiles nothing itself. Each library is configured, built
# and installed as its own project (see cmake/Cookbook.cmake), and all of them
# install into CMAKE_INSTALL_PREFIX.
project(sdl-cookbook LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

option(COOKBOOK_SDL_IMAGE "Build SDL_image" ON)
option(COOKBOOK_SDL_MIXER "Build SDL_mixer" ON)
option(COOKBOOK_SDL_TTF "Build SDL_ttf" ON)
option(COOKBOOK_SDL_NET "Build SDL_net" ON)
option(COOKBOOK_TESTS "Test the installed libraries with consumer projects" ON)

# Installed libraries find each other in their own directory, so the install
# prefix can be moved. This also covers the codecs that SDL loads at runtime.
if(APPLE)
    set(CMAKE_INSTALL_RPATH "@loader_path")
elseif(UNIX)
    set(CMAKE_INSTALL_RPATH "$ORIGIN")
endif()

include(Cookbook)

include(SDL3)
if(COOKBOOK_SDL_IMAGE)
    include(SDL3_image)
endif()
if(COOKBOOK_SDL_MIXER)
    include(SDL3_mixer)
endif()
if(COOKBOOK_SDL_TTF)
    include(SDL3_ttf)
endif()
if(COOKBOOK_SDL_NET)
    include(SDL3_net)
endif()

if(COOKBOOK_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
