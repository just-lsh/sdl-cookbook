# Packs the complete source of this repository, including all nested
# submodules, into one archive. Attached to every release so the corresponding
# source of the LGPL-2.1 libraries (libgme, mpg123) ships with the binaries.
#
# Usage:
#   cmake -P scripts/source-archive.cmake
#
# Optional:
#   BUILD_DIR  Output directory (default: <repo>/build).
#
# Result: <BUILD_DIR>/sdl3-prebuilt-<version>-src.tar.gz, with every file under
# a top-level sdl3-prebuilt-<version>-src/ directory.

cmake_minimum_required(VERSION 3.19)

get_filename_component(repo_dir "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
if(NOT BUILD_DIR)
    set(BUILD_DIR "${repo_dir}/build")
endif()
get_filename_component(BUILD_DIR "${BUILD_DIR}" ABSOLUTE BASE_DIR "${repo_dir}")

execute_process(
    COMMAND git describe --tags --always --dirty
    WORKING_DIRECTORY "${repo_dir}"
    OUTPUT_VARIABLE version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND_ERROR_IS_FATAL ANY
)
execute_process(
    COMMAND git ls-files --recurse-submodules
    WORKING_DIRECTORY "${repo_dir}"
    OUTPUT_VARIABLE files
    COMMAND_ERROR_IS_FATAL ANY
)

set(package_name "sdl3-prebuilt-${version}-src")
set(stage_dir "${BUILD_DIR}/source-archive")
set(archive "${BUILD_DIR}/${package_name}.tar.gz")

# The archive needs a top-level directory, but the checkout's own directory
# name is arbitrary. Link it into a staging directory under the package name.
file(REMOVE_RECURSE "${stage_dir}")
file(MAKE_DIRECTORY "${stage_dir}")
file(CREATE_LINK "${repo_dir}" "${stage_dir}/${package_name}" SYMBOLIC)

string(REGEX REPLACE "(^|\n)([^\n])" "\\1${package_name}/\\2" files "${files}")
file(WRITE "${stage_dir}/files.txt" "${files}")

file(REMOVE "${archive}")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar czf "${archive}" --format=gnutar "--files-from=${stage_dir}/files.txt"
    WORKING_DIRECTORY "${stage_dir}"
    COMMAND_ERROR_IS_FATAL ANY
)
file(REMOVE_RECURSE "${stage_dir}")
message(STATUS "Wrote ${archive}")
