cmake_minimum_required(VERSION 3.25)

# A superbuild: it compiles nothing itself. Each library is configured, built
# and installed as its own project (see cmake/Cookbook.cmake), and all of them
# install into CMAKE_INSTALL_PREFIX.
project(sdl-cookbook LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Nothing is built by default: a recipe preset (cmake/presets/recipe/) turns
# on the libraries it wants and sets their versions and options.
option(COOKBOOK_SDL3 "Build SDL" OFF)
option(COOKBOOK_SDL3_IMAGE "Build SDL_image" OFF)
option(COOKBOOK_SDL3_MIXER "Build SDL_mixer" OFF)
option(COOKBOOK_SDL3_TTF "Build SDL_ttf" OFF)
option(COOKBOOK_SDL3_NET "Build SDL_net" OFF)
option(COOKBOOK_SDL3_SHADERCROSS "Build SDL_shadercross" OFF)
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

# In dependency order: a library finds its dependencies in the install prefix.
# Each one checks its own COOKBOOK_<LIBRARY> switch.
include(SDL3)
include(SDL3_image)
include(SDL3_mixer)
include(SDL3_ttf)
include(SDL3_net)
include(SDL3_shadercross)

get_property(_libraries GLOBAL PROPERTY COOKBOOK_LIBRARIES)
if(NOT _libraries)
  message(
    FATAL_ERROR
      "No library is turned on. Configure with a preset (cmake --list-presets), "
      "or set COOKBOOK_SDL3=ON and the version of each library.")
endif()

if(COOKBOOK_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()
