cmake_minimum_required(VERSION 3.17)

project("libbsarch-delphi" NONE)

include(CTest)
enable_testing()

add_library(${PROJECT_NAME} INTERFACE)

# Finding 32 or 64 bits
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    # 64 bits
    set(LIBBSARCH_DELPHI_DLL_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib64)
    message("Using 64 bits Delphi DLL")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    # 32 bits
    set(LIBBSARCH_DELPHI_DLL_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib32)
    message("Using 32 bits Delphi DLL")
endif()

# Finding debug or release
if(CMAKE_BUILD_TYPE MATCHES DEBUG)
    set(LIBBSARCH_DELPHI_DLL_PATH ${LIBBSARCH_DELPHI_DLL_DIR}/debug/libbsarch.dll)
    message("Using debug Delphi DLL")
else()
    set(LIBBSARCH_DELPHI_DLL_PATH ${LIBBSARCH_DELPHI_DLL_DIR}/release/libbsarch.dll)
    message("Using release Delphi DLL")
endif()

# Actually copying the DLL
add_custom_command(
    COMMENT "Copying Delphi DLL"
    DEPENDS ${LIBBSARCH_DELPHI_DLL_PATH}
    OUTPUT ${CMAKE_BINARY_DIR}/libbsarch.dll
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LIBBSARCH_DELPHI_DLL_PATH} ${CMAKE_BINARY_DIR}/libbsarch.dll
    )

add_custom_target("copy_delphi_dll" ALL DEPENDS ${CMAKE_BINARY_DIR}/libbsarch.dll)

add_dependencies(${PROJECT_NAME} "copy_delphi_dll")

set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
set(CPACK_PROJECT_NAME ${PROJECT_NAME})

include(CPack)