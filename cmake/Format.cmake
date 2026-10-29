# Formats the CMake files of this repository with cmakefmt
# (https://cmakefmt.dev), configured by .cmakefmt.toml.
#
# Usage, from anywhere:
#   cmake -P cmake/Format.cmake             format the files in place
#   cmake -DCHECK=ON -P cmake/Format.cmake  only report files that would change
#
# On first use, downloads the pinned cmakefmt release for this host into
# .cache/cmakefmt/ and verifies its checksum. To upgrade, change the version
# and take the new checksums from the release's SHA256SUMS file.

cmake_minimum_required(VERSION 3.25)

set(version "2.3.2")
set(sha256_aarch64-apple-darwin "02011c4c4f8e8b2772628007a2e63b989779f000185874bc4063c0c3e2018169")
set(sha256_x86_64-apple-darwin "287ed33ab15f83226a63b32f9f544bc437bc70bc9da774aa3d5410ae5cc2863f")
set(sha256_aarch64-unknown-linux-gnu
    "e87423702c786603b66559a7046bc5c242777ed8ef9aa9ae697115a073b29c98")
set(sha256_x86_64-unknown-linux-musl
    "aae4fbfa5ee1ac435c20db79d3cb608ecd5fed1f99527dcc3efb87671b8b7564")
set(sha256_x86_64-pc-windows-msvc "8be8515914e0079062419194cfa35c6ba75d7cb6b6c52370eee90ce4c8db21bd"
)

# Pick the release build for this host. On x86_64 Linux the static musl build
# runs everywhere, including distributions without a standard glibc layout.
cmake_host_system_information(RESULT os QUERY OS_NAME)
cmake_host_system_information(RESULT arch QUERY OS_PLATFORM)
if(os STREQUAL "Windows")
  # Windows on ARM runs the x86_64 build through emulation.
  set(target "x86_64-pc-windows-msvc")
  set(archive_ext "zip")
elseif(os STREQUAL "Darwin" AND arch MATCHES "^(arm64|aarch64)$")
  set(target "aarch64-apple-darwin")
elseif(os STREQUAL "Darwin" AND arch STREQUAL "x86_64")
  set(target "x86_64-apple-darwin")
elseif(os STREQUAL "Linux" AND arch MATCHES "^(arm64|aarch64)$")
  set(target "aarch64-unknown-linux-gnu")
elseif(os STREQUAL "Linux" AND arch STREQUAL "x86_64")
  set(target "x86_64-unknown-linux-musl")
else()
  message(FATAL_ERROR "No cmakefmt ${version} release build for ${os} ${arch}")
endif()
if(NOT archive_ext)
  set(archive_ext "tar.gz")
endif()

get_filename_component(repo_dir "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(name "cmakefmt-${version}-${target}")
set(tool_dir "${repo_dir}/.cache/cmakefmt/${name}")

if(NOT EXISTS "${tool_dir}/.complete")
  set(archive "${repo_dir}/.cache/cmakefmt/${name}.${archive_ext}")
  set(url
      "https://github.com/cmakefmt/cmakefmt/releases/download/v${version}/${name}.${archive_ext}")
  message(STATUS "Downloading ${url}")
  file(DOWNLOAD "${url}" "${archive}" EXPECTED_HASH "SHA256=${sha256_${target}}" STATUS status)
  list(GET status 0 code)
  if(NOT code EQUAL 0)
    list(GET status 1 reason)
    message(FATAL_ERROR "Downloading cmakefmt failed: ${reason}")
  endif()
  file(REMOVE_RECURSE "${tool_dir}")
  file(ARCHIVE_EXTRACT INPUT "${archive}" DESTINATION "${tool_dir}")
  file(REMOVE "${archive}")
  file(TOUCH "${tool_dir}/.complete")
endif()

file(GLOB_RECURSE cmakefmt LIST_DIRECTORIES false "${tool_dir}/cmakefmt" "${tool_dir}/cmakefmt.exe")
if(NOT cmakefmt)
  message(FATAL_ERROR "No cmakefmt executable in ${tool_dir}")
endif()

if(CHECK)
  set(mode --check)
else()
  set(mode --in-place)
endif()

# Without paths, cmakefmt formats every CMake file below the working directory
# that git does not ignore.
execute_process(
  COMMAND "${cmakefmt}" ${mode}
  WORKING_DIRECTORY "${repo_dir}"
  RESULT_VARIABLE result)
if(NOT result EQUAL 0)
  message(FATAL_ERROR "cmakefmt ${mode} failed")
endif()
