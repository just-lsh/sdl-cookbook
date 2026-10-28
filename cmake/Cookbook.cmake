# cookbook_add_library(<name>
#     GIT_REPOSITORY <url>
#     GIT_TAG <tag-or-commit>
#     [SOURCE_DIR <dir>]
#     [SUBMODULES]
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
# SUBMODULES also fetches the git submodules (the vendored dependencies).

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
    CMAKE_INSTALL_RPATH
)

function(cookbook_add_library name)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "SUBMODULES"
        "GIT_REPOSITORY;GIT_TAG;SOURCE_DIR"
        "DEPENDS;CMAKE_CACHE_ARGS"
    )

    if(arg_SOURCE_DIR)
        set(source_args SOURCE_DIR "${arg_SOURCE_DIR}")
    else()
        set(source_args
            GIT_REPOSITORY "${arg_GIT_REPOSITORY}"
            GIT_TAG "${arg_GIT_TAG}"
            GIT_SHALLOW ON
            GIT_PROGRESS ON
        )
        if(arg_SUBMODULES)
            # ExternalProject clones submodules with their full history; this
            # fetches only the pinned commits, halving the download.
            list(APPEND source_args
                PATCH_COMMAND "${GIT_EXECUTABLE}" submodule update --init --recursive --depth 1
            )
        endif()
    endif()

    set(cache_args
        "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}"
        "-DCMAKE_PREFIX_PATH:PATH=${CMAKE_INSTALL_PREFIX}"
    )
    foreach(var IN LISTS _cookbook_forwarded_variables)
        if(DEFINED ${var})
            list(APPEND cache_args "-D${var}:STRING=${${var}}")
        endif()
    endforeach()

    ExternalProject_Add(${name}
        PREFIX "${CMAKE_BINARY_DIR}/${name}"
        ${source_args}
        # Submodules, if any, come from the patch step above.
        GIT_SUBMODULES ""
        DEPENDS ${arg_DEPENDS}
        CMAKE_CACHE_ARGS ${cache_args} ${arg_CMAKE_CACHE_ARGS}
        # Keep the console readable: each step logs to
        # <build>/<name>/src/<name>-stamp/ and prints its log only on failure.
        LOG_DOWNLOAD ON
        LOG_PATCH ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        LOG_INSTALL ON
        LOG_OUTPUT_ON_FAILURE ON
    )
endfunction()
