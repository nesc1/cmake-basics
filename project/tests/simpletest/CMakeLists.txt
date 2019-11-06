cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

project(apptest)

# for mylib we can ommit this because the root cmakelists.txt is already been
# called (but for the sample that is external then we required)
find_package(mylibA REQUIRED)

# test information
add_test_executable(${PROJECT_NAME}
                    SOURCES
                        example1.cpp
                        example2.cpp
                    LINK_LIBRARIES
                        ${CMAKE_PROJECT_NAME}::mylibA)
