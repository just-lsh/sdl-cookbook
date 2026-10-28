cmake_minimum_required(VERSION 3.25)

project(sdl-cookbook LANGUAGES C)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

option(COOKBOOK_TESTS "Test the installed libraries with a consumer project" ON)

include(SDL3)

if(COOKBOOK_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
