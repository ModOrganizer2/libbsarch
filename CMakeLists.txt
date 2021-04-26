cmake_minimum_required(VERSION 3.5..3.20)

set(libbsarch_version 1.0)

# Project
project(libbsarch C)

# Add library to build.
add_library(libbsarch SHARED
    src/DDS.h
    src/libbsarch.h
    src/libbsarch.c
    src/libbsarch.def
    )

target_compile_definitions(libbsarch PRIVATE BSARCH_DLL_EXPORT)

target_include_directories(libbsarch PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include>)

## INSTALL

# Finding 32 or 64bits
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    # 64 bits
    set(lib_delphi "${CMAKE_CURRENT_SOURCE_DIR}/delphi/lib64")
    message("libbsarch: using 64bits DLL")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    # 32 bits
    set(lib_delphi "${CMAKE_CURRENT_SOURCE_DIR}/delphi/lib")
    message("libbsarch: using 32bits DLL")
endif()

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  ${PROJECT_BINARY_DIR}/cmake/libbsarch-config-version.cmake
  VERSION ${libbsarch_version}
  COMPATIBILITY AnyNewerVersion)

install(TARGETS libbsarch
  EXPORT libbsarch-targets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/libbsarch-config.cmake.in
  ${PROJECT_BINARY_DIR}/cmake/libbsarch-config.cmake
  INSTALL_DESTINATION cmake/})

install(FILES
    $<$<CONFIG:Debug>:${lib_delphi}/Debug/libbsarch.dll>
    $<$<NOT:$<CONFIG:Debug>>:${lib_delphi}/Release/libbsarch.dll>
    DESTINATION bin)

install(FILES
    src/libbsarch.h
    src/dds.h
    DESTINATION include)

install(EXPORT libbsarch-targets
  FILE libbsarch-targets.cmake
  DESTINATION cmake/)

install(FILES
    ${PROJECT_BINARY_DIR}/cmake/libbsarch-config.cmake
    ${PROJECT_BINARY_DIR}/cmake/libbsarch-config-version.cmake
  DESTINATION cmake/)
