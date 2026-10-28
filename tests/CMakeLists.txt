# Each test builds tests/<package> against the install prefix and runs it.
# The superbuild installs while it builds, so build before testing.

function(cookbook_add_consumer_test package)
    add_test(NAME ${package}
        COMMAND "${CMAKE_CTEST_COMMAND}"
            --build-and-test
                "${CMAKE_CURRENT_SOURCE_DIR}/${package}"
                "${CMAKE_CURRENT_BINARY_DIR}/${package}"
            --build-generator "${CMAKE_GENERATOR}"
            --build-options
                "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
                "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
                "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
            --test-command consumer
    )
endfunction()

cookbook_add_consumer_test(SDL3)
if(COOKBOOK_SDL_IMAGE)
    cookbook_add_consumer_test(SDL3_image)
endif()
if(COOKBOOK_SDL_MIXER)
    cookbook_add_consumer_test(SDL3_mixer)
endif()
if(COOKBOOK_SDL_TTF)
    cookbook_add_consumer_test(SDL3_ttf)
endif()
if(COOKBOOK_SDL_NET)
    cookbook_add_consumer_test(SDL3_net)
endif()
if(COOKBOOK_SDL_SHADERCROSS)
    cookbook_add_consumer_test(SDL3_shadercross)

    # The installed command line tool must find its libraries in lib/.
    add_test(NAME shadercross-cli
        COMMAND "${CMAKE_INSTALL_PREFIX}/bin/shadercross"
            "${CMAKE_CURRENT_SOURCE_DIR}/SDL3_shadercross/compute.hlsl"
            --source HLSL --dest MSL --stage compute
            --output "${CMAKE_CURRENT_BINARY_DIR}/compute.msl"
    )
endif()
