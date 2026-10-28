# Builds tests/consumer against the install prefix and runs it, so the test
# needs the install target to have been built first (the build presets do).

add_test(NAME consumer
    COMMAND "${CMAKE_CTEST_COMMAND}"
        --build-and-test
            "${CMAKE_CURRENT_SOURCE_DIR}/consumer"
            "${CMAKE_CURRENT_BINARY_DIR}/consumer"
        --build-generator "${CMAKE_GENERATOR}"
        --build-options
            "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
            "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
            "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
            "-DEXPECTED_SDL_VERSION=${COOKBOOK_SDL_VERSION}"
        --test-command consumer
)
