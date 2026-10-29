# cmake -DBUILD_DIR=<SDL build dir> -DREQUIRE_FILE=<file> -P CheckSDLBuildConfig.cmake
#
# Fails unless the SDL_build_config.h that SDL generated in BUILD_DIR defines
# every name in REQUIRE_FILE, one per line. Run by the SDL3 require step
# (cmake/SDL3.cmake).

file(STRINGS "${REQUIRE_FILE}" required)
file(GLOB headers "${BUILD_DIR}/include-config-*/build_config/SDL_build_config.h")
if(NOT headers)
  message(FATAL_ERROR "No SDL_build_config.h in ${BUILD_DIR}")
endif()

foreach(header IN LISTS headers)
  file(STRINGS "${header}" defines REGEX "^#define [A-Za-z0-9_]+")
  list(TRANSFORM defines REPLACE "^#define ([A-Za-z0-9_]+).*" "\\1")
  set(missing)
  foreach(name IN LISTS required)
    if(NOT name IN_LIST defines)
      list(APPEND missing ${name})
    endif()
  endforeach()
  if(missing)
    list(JOIN missing "\n  " missing)
    message(
      FATAL_ERROR
        "SDL was configured without features that COOKBOOK_SDL3_REQUIRE requires:\n"
        "  ${missing}\n" "Usually their development packages are missing. SDL's configure log "
        "(SDL3-configure-out.log next to this step's stamp files) lists what it found.\n"
        "Checked: ${header}")
  endif()
endforeach()
