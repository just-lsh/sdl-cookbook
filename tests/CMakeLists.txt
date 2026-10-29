# Each library added with cookbook_add_library gets a test that builds
# tests/<library>/main.c against the install prefix and runs it. The
# superbuild installs while it builds, so build before testing.

get_property(libraries GLOBAL PROPERTY COOKBOOK_LIBRARIES)
foreach(library IN LISTS libraries)
  add_test(
    NAME ${library}
    COMMAND
      "${CMAKE_CTEST_COMMAND}"
      --build-and-test
      "${CMAKE_CURRENT_SOURCE_DIR}/consumer"
      "${CMAKE_CURRENT_BINARY_DIR}/consumer/${library}"
      --build-generator
      "${CMAKE_GENERATOR}"
      --build-options
      "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
      "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
      "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
      "-DCOOKBOOK_PACKAGE=${library}"
      --test-command
      consumer)
endforeach()

if("SDL3_shadercross" IN_LIST libraries)
  # The installed command line tool must find its libraries in lib/.
  add_test(
    NAME shadercross-cli
    COMMAND
      "${CMAKE_INSTALL_PREFIX}/bin/shadercross"
      "${CMAKE_CURRENT_SOURCE_DIR}/SDL3_shadercross/compute.hlsl"
      --source
      HLSL
      --dest
      MSL
      --stage
      compute
      --output
      "${CMAKE_CURRENT_BINARY_DIR}/compute.msl")
endif()
