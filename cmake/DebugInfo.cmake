# Loaded by every library after each of its project() calls, through
# CMAKE_PROJECT_INCLUDE (see cmake/Cookbook.cmake).
#
# Libraries are built as Release, with debug information only for their own
# targets, so a debugger can step into SDL but the vendored dependencies
# (codecs, FreeType, DirectXShaderCompiler, ...) stay small. A library defines
# its own targets in its top-level directory and adds the vendored ones from
# subdirectories, so at the end of configuring, every target of the top-level
# directory gets -g.
#
# TODO(windows): MSVC needs the MSVC_DEBUG_INFORMATION_FORMAT target property
# and /DEBUG when linking instead of -g.

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR AND NOT COMMAND _cookbook_add_debug_info)
  function(_cookbook_add_debug_info)
    get_property(targets DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY BUILDSYSTEM_TARGETS)
    foreach(target IN LISTS targets)
      get_target_property(type ${target} TYPE)
      if(type MATCHES "^(SHARED_LIBRARY|MODULE_LIBRARY|STATIC_LIBRARY|OBJECT_LIBRARY|EXECUTABLE)$")
        target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:C,CXX>:-g>")
      endif()
    endforeach()
  endfunction()
  cmake_language(DEFER DIRECTORY "${CMAKE_SOURCE_DIR}" CALL _cookbook_add_debug_info)
endif()
