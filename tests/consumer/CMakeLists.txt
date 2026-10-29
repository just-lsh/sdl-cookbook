cmake_minimum_required(VERSION 3.25)

# Builds tests/<COOKBOOK_PACKAGE>/main.c against the installed package.
project(consumer LANGUAGES C)

# NO_DEFAULT_PATH: only the cookbook install may satisfy this, not a system
# copy. The satellite package configs expect SDL3 to have been found already.
find_package(SDL3 REQUIRED CONFIG PATHS ${CMAKE_PREFIX_PATH} NO_DEFAULT_PATH)
if(NOT COOKBOOK_PACKAGE STREQUAL "SDL3")
  find_package(${COOKBOOK_PACKAGE} REQUIRED CONFIG PATHS ${CMAKE_PREFIX_PATH} NO_DEFAULT_PATH)
endif()

add_executable(consumer "${CMAKE_CURRENT_SOURCE_DIR}/../${COOKBOOK_PACKAGE}/main.c")
target_link_libraries(consumer PRIVATE ${COOKBOOK_PACKAGE}::${COOKBOOK_PACKAGE} SDL3::SDL3)
