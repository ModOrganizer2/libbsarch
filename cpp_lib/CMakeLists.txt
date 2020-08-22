cmake_minimum_required(VERSION 3.17)

project("libbsarch-c99")

include(CTest)
enable_testing()

add_library(${PROJECT_NAME} INTERFACE)

add_subdirectory(../delphi .)

target_include_directories(${PROJECT_NAME} INTERFACE .)

target_link_libraries(${PROJECT_NAME} INTERFACE "libbsarch-delphi")

set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
set(CPACK_PROJECT_NAME ${PROJECT_NAME})

include(CPack)
