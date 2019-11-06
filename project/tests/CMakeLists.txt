cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
# include
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/add_test_executable.cmake)
# find packages
find_package(GTest REQUIRED)
find_package(GMock REQUIRED)
# tests (can be added or discarded easily here)
add_subdirectory(simpletest)
