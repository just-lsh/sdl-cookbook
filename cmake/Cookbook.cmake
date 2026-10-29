# cookbook_add_library(<name>
#     GIT_REPOSITORY <url>
#     GIT_TAG <tag-or-commit>
#     [SOURCE_DIR <dir>]
#     [SUBMODULES]
#     [PROGRAMS]
#     [DEPENDS <library>...]
#     [CMAKE_CACHE_ARGS -D<var>:<type>=<value>...]
# )
#
# Builds one library as its own top-level CMake project, the way upstream
# builds it, and installs it into CMAKE_INSTALL_PREFIX. Libraries share
# nothing but that prefix: each one finds its DEPENDS there with
# find_package.
#
# SOURCE_DIR builds an existing checkout instead of cloning GIT_REPOSITORY.
# SUBMODULES also fetches the git submodules (the vendored dependencies) of
# the clone; a SOURCE_DIR checkout must already have them.
# PROGRAMS marks a library that installs programs into bin/: the library is
# built with COOKBOOK_PROGRAM_RPATH on top of CMAKE_INSTALL_RPATH, so its
# programs find lib/.
#
# Each GIT_TAG (or SOURCE_DIR) is built in its own directory,
# <build>/<name>/<ref>/, and never updated from the remote: an unchanged
# library does no work on rebuilds, and a new GIT_TAG starts from a fresh
# clone. Switching back to a previous GIT_TAG reuses its build and only
# installs it again. A SOURCE_DIR checkout is built on every build instead,
# and its own build system decides what changed.
#
# Each library is appended to the global property COOKBOOK_LIBRARIES.

include(ExternalProject)
find_package(Git REQUIRED)

# Settings every library is configured with. Undefined ones are left to the
# library's defaults.
set(_cookbook_forwarded_variables
    CMAKE_BUILD_TYPE
    CMAKE_C_COMPILER
    CMAKE_CXX_COMPILER
    CMAKE_TOOLCHAIN_FILE
    CMAKE_EXPORT_COMPILE_COMMANDS
    CMAKE_INSTALL_LIBDIR
    CMAKE_INSTALL_RPATH)

function(cookbook_add_library name)
  cmake_parse_arguments(PARSE_ARGV 1 arg "SUBMODULES;PROGRAMS" "GIT_REPOSITORY;GIT_TAG;SOURCE_DIR"
                        "DEPENDS;CMAKE_CACHE_ARGS")

  if(arg_SOURCE_DIR)
    set(source_args SOURCE_DIR "${arg_SOURCE_DIR}" BUILD_ALWAYS ON)
    string(SHA1 path_hash "${arg_SOURCE_DIR}")
    string(SUBSTRING "${path_hash}" 0 12 path_hash)
    set(ref "local-${path_hash}")
  else()
    string(REGEX REPLACE "[^A-Za-z0-9._-]" "_" ref "${arg_GIT_TAG}")
    # Keeps refs apart that differ only in replaced characters, such as
    # feature/foo and feature_foo.
    if(NOT ref STREQUAL arg_GIT_TAG)
      string(SHA1 tag_hash "${arg_GIT_TAG}")
      string(SUBSTRING "${tag_hash}" 0 12 tag_hash)
      string(APPEND ref "-${tag_hash}")
    endif()
    # A shallow clone only works for branch and tag names, not commits.
    if(arg_GIT_TAG MATCHES "^[0-9a-fA-F]+$")
      set(shallow OFF)
    else()
      set(shallow ON)
    endif()
    set(source_args
        GIT_REPOSITORY
        "${arg_GIT_REPOSITORY}"
        GIT_TAG
        "${arg_GIT_TAG}"
        GIT_SHALLOW
        ${shallow}
        GIT_PROGRESS
        ON)
    if(arg_SUBMODULES)
      # ExternalProject clones submodules with their full history; this
      # fetches only the pinned commits, halving the download.
      list(
        APPEND
        source_args
        PATCH_COMMAND
        "${GIT_EXECUTABLE}"
        submodule
        update
        --init
        --recursive
        --depth
        1)
    endif()
  endif()

  set(cache_args "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}"
      "-DCMAKE_PREFIX_PATH:PATH=${CMAKE_INSTALL_PREFIX}")
  # Function scope: this only changes the RPATH of this library.
  if(arg_PROGRAMS)
    list(APPEND CMAKE_INSTALL_RPATH ${COOKBOOK_PROGRAM_RPATH})
  endif()
  foreach(var IN LISTS _cookbook_forwarded_variables)
    if(DEFINED ${var})
      # Lists travel with LIST_SEPARATOR, so they stay one argument.
      string(REPLACE ";" "|" value "${${var}}")
      list(APPEND cache_args "-D${var}:STRING=${value}")
    endif()
  endforeach()

  # Submodules, if any, come from the patch step above. To keep the console
  # readable, each step logs to <build>/<name>/<ref>/src/<name>-stamp/ and
  # prints its log only on failure.
  externalproject_add(
    ${name} ${source_args}
    PREFIX "${CMAKE_BINARY_DIR}/${name}/${ref}"
    UPDATE_DISCONNECTED ON
    GIT_SUBMODULES ""
    DEPENDS ${arg_DEPENDS}
    LIST_SEPARATOR "|"
    CMAKE_CACHE_ARGS ${cache_args} ${arg_CMAKE_CACHE_ARGS}
    LOG_DOWNLOAD ON
    LOG_PATCH ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
    LOG_OUTPUT_ON_FAILURE ON)

  # Rewritten only when the ref changes, so switching back to a ref whose
  # build is complete still installs it over the other one.
  set(active_ref "${CMAKE_BINARY_DIR}/${name}/active-ref.txt")
  file(CONFIGURE OUTPUT "${active_ref}" CONTENT "${ref}\n")
  externalproject_add_stepdependencies(${name} install "${active_ref}")

  set_property(GLOBAL APPEND PROPERTY COOKBOOK_LIBRARIES ${name})
endfunction()
