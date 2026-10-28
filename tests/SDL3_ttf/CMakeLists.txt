cmake_minimum_required(VERSION 3.25)

project(consumer LANGUAGES C)

# NO_DEFAULT_PATH: only the cookbook install may satisfy this, not a system copy.
# The satellite package configs expect SDL3 to have been found already.
find_package(SDL3 REQUIRED CONFIG PATHS ${CMAKE_PREFIX_PATH} NO_DEFAULT_PATH)
find_package(SDL3_ttf REQUIRED CONFIG
    PATHS ${CMAKE_PREFIX_PATH}
    NO_DEFAULT_PATH
)

add_executable(consumer main.c)
target_link_libraries(consumer PRIVATE SDL3_ttf::SDL3_ttf SDL3::SDL3)
