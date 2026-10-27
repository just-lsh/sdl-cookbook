# Builds every SDL library for one target and flavour into a single install
# prefix and packs it as a release archive.
#
# Usage:
#   cmake -DTARGET=x86_64-linux-gnu -DFLAVOUR=shared -P scripts/package.cmake
#
# Required:
#   TARGET                 Target name used in the archive name, e.g.
#                          x86_64-linux-gnu, aarch64-windows-msvc,
#                          aarch64-apple-darwin, x86_64-w64-mingw32.
#                          Names containing "windows" or "mingw" produce a .zip,
#                          all others a .tar.gz.
#   FLAVOUR                shared or static (selects cmake/<FLAVOUR>.cmake).
#
# Optional:
#   GENERATOR              CMake generator (-G), e.g. Ninja.
#   PLATFORM               Generator platform (-A), e.g. ARM64 for Visual Studio.
#   TOOLCHAIN_FILE         Toolchain file, relative to the repository root or
#                          absolute, e.g.
#                          SDL/build-scripts/cmake-toolchain-mingw64-x86_64.cmake.
#   OSX_ARCHITECTURES      macOS architectures. Only needed to cross-compile;
#                          native builds target the host architecture.
#   OSX_DEPLOYMENT_TARGET  Minimum macOS version.
#   CONFIGURE_ARGS         Extra arguments for every configure step (a list).
#   BUILD_DIR              Work directory (default: <repo>/build).
#   PARALLEL               Parallel build jobs (default: number of logical cores).
#
# Result: <BUILD_DIR>/sdl3-prebuilt-<TARGET>-<FLAVOUR>.{tar.gz,zip}

cmake_minimum_required(VERSION 3.21)

foreach(var TARGET FLAVOUR)
    if(NOT DEFINED ${var} OR "${${var}}" STREQUAL "")
        message(FATAL_ERROR "${var} is required, e.g. cmake -DTARGET=x86_64-linux-gnu -DFLAVOUR=shared -P scripts/package.cmake")
    endif()
endforeach()
if(NOT FLAVOUR MATCHES "^(shared|static)$")
    message(FATAL_ERROR "FLAVOUR must be shared or static, got '${FLAVOUR}'")
endif()

get_filename_component(repo_dir "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
if(NOT BUILD_DIR)
    set(BUILD_DIR "${repo_dir}/build")
endif()
get_filename_component(BUILD_DIR "${BUILD_DIR}" ABSOLUTE BASE_DIR "${repo_dir}")
if(NOT PARALLEL)
    cmake_host_system_information(RESULT PARALLEL QUERY NUMBER_OF_LOGICAL_CORES)
endif()

set(package_name "sdl3-prebuilt-${TARGET}-${FLAVOUR}")
set(work_dir "${BUILD_DIR}/${TARGET}-${FLAVOUR}")
set(prefix "${work_dir}/${package_name}")

# SDL must come first: the other libraries find it in the install prefix.
set(libraries SDL SDL_image SDL_mixer SDL_ttf SDL_net SDL_shadercross)

# Licenses of vendored dependencies whose upstream install rules don't ship
# them. Installed next to the ones SDL_image and SDL_mixer install themselves:
# share/licenses/<project>/optional/LICENSE.<name>.txt
set(extra_licenses_SDL_ttf
    freetype external/freetype/LICENSE.TXT
    harfbuzz external/harfbuzz/COPYING
    plutosvg external/plutosvg/LICENSE
    plutovg external/plutovg/LICENSE
)
set(extra_licenses_SDL_shadercross
    spirv-cross external/SPIRV-Cross/LICENSE
    spirv-headers external/SPIRV-Headers/LICENSE
    spirv-tools external/SPIRV-Tools/LICENSE
    dxc external/DirectXShaderCompiler/LICENSE.TXT
    dxc-thirdpartynotices external/DirectXShaderCompiler/ThirdPartyNotices.txt
    directx-headers external/DirectXShaderCompiler/external/DirectX-Headers/LICENSE
)

foreach(lib IN LISTS libraries)
    if(NOT EXISTS "${repo_dir}/${lib}/CMakeLists.txt")
        message(FATAL_ERROR "${lib} is not checked out. Run: git submodule update --init --recursive --depth 1")
    endif()
endforeach()

set(configure_args
    -C "${repo_dir}/cmake/${FLAVOUR}.cmake"
    -DCMAKE_BUILD_TYPE=Release
    "-DCMAKE_PREFIX_PATH=${prefix}"
    "-DCMAKE_INSTALL_PREFIX=${prefix}"
)
if(GENERATOR)
    list(APPEND configure_args -G "${GENERATOR}")
endif()
if(PLATFORM)
    list(APPEND configure_args -A "${PLATFORM}")
endif()
if(TOOLCHAIN_FILE)
    get_filename_component(TOOLCHAIN_FILE "${TOOLCHAIN_FILE}" ABSOLUTE BASE_DIR "${repo_dir}")
    list(APPEND configure_args "-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}")
endif()
# Quoted so the architecture list stays a single argument.
if(OSX_ARCHITECTURES)
    list(APPEND configure_args "-DCMAKE_OSX_ARCHITECTURES=${OSX_ARCHITECTURES}")
endif()
if(OSX_DEPLOYMENT_TARGET)
    list(APPEND configure_args "-DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}")
endif()
list(APPEND configure_args ${CONFIGURE_ARGS})

# Start from an empty prefix so nothing from an earlier run ends up in the archive.
file(REMOVE_RECURSE "${prefix}")

foreach(lib IN LISTS libraries)
    set(lib_build_dir "${work_dir}/${lib}")
    message(STATUS "[${package_name}] Building ${lib}")
    execute_process(
        COMMAND "${CMAKE_COMMAND}" ${configure_args} -S "${repo_dir}/${lib}" -B "${lib_build_dir}"
        COMMAND_ERROR_IS_FATAL ANY
    )
    execute_process(
        COMMAND "${CMAKE_COMMAND}" --build "${lib_build_dir}" --config Release --parallel ${PARALLEL}
        COMMAND_ERROR_IS_FATAL ANY
    )
    execute_process(
        COMMAND "${CMAKE_COMMAND}" --install "${lib_build_dir}" --config Release
        COMMAND_ERROR_IS_FATAL ANY
    )

    string(REPLACE "SDL_" "SDL3_" project_name "${lib}")
    set(extra_licenses ${extra_licenses_${lib}})
    while(extra_licenses)
        list(POP_FRONT extra_licenses license_name license_file)
        file(MAKE_DIRECTORY "${prefix}/share/licenses/${project_name}/optional")
        file(COPY_FILE "${repo_dir}/${lib}/${license_file}"
            "${prefix}/share/licenses/${project_name}/optional/LICENSE.${license_name}.txt")
    endwhile()
endforeach()

file(COPY "${repo_dir}/THIRD_PARTY_NOTICES.md" DESTINATION "${prefix}")

# Record the exact sources this archive was built from.
execute_process(
    COMMAND git describe --tags --always --dirty
    WORKING_DIRECTORY "${repo_dir}"
    OUTPUT_VARIABLE repo_version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND_ERROR_IS_FATAL ANY
)
execute_process(
    COMMAND git submodule status
    WORKING_DIRECTORY "${repo_dir}"
    OUTPUT_VARIABLE submodule_status
    COMMAND_ERROR_IS_FATAL ANY
)
file(WRITE "${prefix}/VERSIONS.txt"
    "sdl3-prebuilt ${repo_version}\n"
    "target: ${TARGET}\n"
    "flavour: ${FLAVOUR}\n"
    "\n"
    "${submodule_status}"
)

if(TARGET MATCHES "windows|mingw")
    set(archive "${BUILD_DIR}/${package_name}.zip")
    set(tar_flags cf --format=zip)
else()
    set(archive "${BUILD_DIR}/${package_name}.tar.gz")
    set(tar_flags czf --format=gnutar)
endif()
file(REMOVE "${archive}")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar ${tar_flags} "${archive}" "${package_name}"
    WORKING_DIRECTORY "${work_dir}"
    COMMAND_ERROR_IS_FATAL ANY
)
message(STATUS "[${package_name}] Wrote ${archive}")
