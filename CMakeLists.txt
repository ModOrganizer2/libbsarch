cmake_minimum_required(VERSION 3.16)

# Project
project(libbsarch CXX)

# Add library to build.
add_library(libbsarch SHARED
    src/libbsarch.h
    src/libbsarch.cpp
    src/libbsarch.def
)
set_target_properties(libbsarch PROPERTIES DEBUG_POSTFIX "d")
target_include_directories(libbsarch PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/dds)
target_compile_features(libbsarch PRIVATE cxx_std_11)

# preprocessor definitions
if(MSVC)
    target_compile_options(libbsarch PRIVATE
        /W3 /EHsc /MP
        $<$<CONFIG:DEBUG>:/MDd /Od>
        $<$<CONFIG:RELEASE>:/Zi>
    )
endif()

target_compile_definitions(libbsarch PRIVATE BSARCH_DLL_EXPORT)

#We only want the lib file. The DLL will be provided by Delphi
#Removing the generated DLL
add_custom_command(TARGET libbsarch POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove
    ${CMAKE_CURRENT_BINARY_DIR}/libbsarch.dll)

############################################################
# libbsarch_OOP                                            #
############################################################

find_package(Qt6 COMPONENTS Core REQUIRED)

add_library(libbsarch_OOP STATIC
    src/base_types.hpp
    src/bs_archive_auto.cpp
    src/bs_archive_auto.hpp
    src/bs_archive.cpp
    src/bs_archive.h
    src/bs_archive_entries.cpp
    src/bs_archive_entries.h

    src/libbsarch.hpp
    src/libbsarch.h

    src/utils/convertible_string.cpp
    src/utils/convertible_string.hpp
    src/utils/convertible_ostream.cpp
    src/utils/convertible_ostream.hpp
    src/utils/string_convert.cpp
    src/utils/string_convert.hpp
)
set_target_properties(libbsarch_OOP PROPERTIES
    DEBUG_POSTFIX "d"
    CXX_STANDARD 17
)
target_include_directories(libbsarch_OOP PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/dds)

if (MSVC)
    target_compile_options(libbsarch_OOP PRIVATE /MP)
endif()

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

#Adding Qt support
if(Qt6_FOUND)
    message("libbsarch: Qt6 found, enabling Qt support")
    target_link_libraries(libbsarch_OOP PUBLIC Qt::Core)
    target_compile_definitions(libbsarch PUBLIC "LIBBSARCH_QT_SUPPORT")
    target_compile_definitions(libbsarch_OOP PUBLIC "LIBBSARCH_QT_SUPPORT")
endif()

target_link_libraries(libbsarch_OOP PUBLIC libbsarch)
