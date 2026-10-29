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
option(COOKBOOK_SDL_SHADERCROSS "Build SDL_shadercross" ON)
option(COOKBOOK_TESTS "Test the installed libraries with consumer projects" ON)

# Presets can only check the host system name, so the host presets also set
# the processor they are for.
if(COOKBOOK_HOST_PROCESSOR AND NOT CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL COOKBOOK_HOST_PROCESSOR)
  message(
    FATAL_ERROR
      "This preset is for ${COOKBOOK_HOST_PROCESSOR} hosts, "
      "but this host is ${CMAKE_HOST_SYSTEM_PROCESSOR}.")
endif()

# Installed libraries find each other in their own directory, so the install
# prefix can be moved. This also covers the codecs that SDL loads at runtime.
# Libraries that install programs into bin/ (cookbook_add_library(PROGRAMS))
# are additionally built with COOKBOOK_PROGRAM_RPATH, the library directory
# next to bin/.
if(DEFINED CMAKE_INSTALL_LIBDIR)
  set(_libdir "${CMAKE_INSTALL_LIBDIR}")
else()
  set(_libdir "lib")
endif()
if(APPLE)
  set(CMAKE_INSTALL_RPATH "@loader_path")
  set(COOKBOOK_PROGRAM_RPATH "@loader_path/../${_libdir}")
elseif(UNIX)
  set(CMAKE_INSTALL_RPATH "$ORIGIN")
  set(COOKBOOK_PROGRAM_RPATH "$ORIGIN/../${_libdir}")
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
if(COOKBOOK_SDL_SHADERCROSS)
  include(SDL3_shadercross)
endif()

if(COOKBOOK_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()
