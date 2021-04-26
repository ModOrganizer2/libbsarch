cmake_minimum_required(VERSION 3.5..3.20)

option(copy_dll_to_binary_dir "Will copy libbsarch DLL to the binary directory. May not work if libbsarch is used as a subproject" ON)

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
## Copying the corresponding DLL ##

#Finding 32 or 64bits
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    # 64 bits
    set(lib_delphi "${CMAKE_CURRENT_SOURCE_DIR}/delphi/lib64")
    message("libbsarch: using 64bits DLL")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    # 32 bits
    set(lib_delphi "${CMAKE_CURRENT_SOURCE_DIR}/delphi/lib")
    message("libbsarch: using 32bits DLL")
endif()

if(copy_dll_to_binary_dir)
    #Finding debug or release
    if(CMAKE_BUILD_TYPE MATCHES DEBUG)
        set(libbsarch_dll_path "${lib_delphi}/libbsarchd.dll")
    else()
        set(libbsarch_dll_path "${lib_delphi}/libbsarch.dll")
    endif()

    #Actually copying the DLL
    add_custom_command(TARGET libbsarch POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${libbsarch_dll_path}
        ${CMAKE_BINARY_DIR}/libbsarch.dll)
    message("libbsarch: Copying the DLL to ${CMAKE_BINARY_DIR}/libbsarch.dll")
endif()
