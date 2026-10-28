cmake_minimum_required(VERSION 3.25)

project(consumer LANGUAGES C)

# NO_DEFAULT_PATH: only the cookbook install may satisfy this, not a system copy.
find_package(SDL3 REQUIRED CONFIG
    PATHS ${CMAKE_PREFIX_PATH}
    NO_DEFAULT_PATH
)

add_executable(consumer main.c)
target_link_libraries(consumer PRIVATE SDL3::SDL3)
