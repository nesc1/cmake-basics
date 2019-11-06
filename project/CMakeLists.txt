# Minimum version is the one shipping with Ubuntu 16.04 LTS
cmake_minimum_required(VERSION 3.0.2 FATAL_ERROR)

# define the version
set(LibAppTestProject_MAJOR_VERSION 1)
set(LibAppTestProject_MINOR_VERSION 0)
set(LibAppTestProject_PATCH_VERSION 0)
set(
  LibAppTestProject_VERSION
  ${LibAppTestProject_MAJOR_VERSION}.${LibAppTestProject_MINOR_VERSION}.${LibAppTestProject_PATCH_VERSION}
  )
project(LibAppTestProject VERSION ${LibAppTestProject_VERSION} LANGUAGES CXX)

# specify if the unit tests are to build
option(BUILD_TESTS "Build the unit tests" OFF)
option(RUN_TESTS_ON_COMPILE "Run the unit tests during compilation" OFF)
# code coverage support
include(cmake/code-coverage.cmake)
if(CODE_COVERAGE)
  message(STATUS "Building with coverage...")
  add_code_coverage() # Adds instrumentation to all targets
endif()

# Offer the user the choice of overriding the installation directories
set(INSTALL_LIB_DIR lib CACHE PATH "Installation directory for libraries")
set(INSTALL_BIN_DIR bin CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDE_DIR
    include
    CACHE PATH "Installation directory for header files")
set(INSTALL_CMAKE_DIR
    "lib/cmake"
    CACHE PATH "Installation directory for CMake files")

# define our sub projects that will not require to use the find_package
# functionality
set(SUBPROJECTS mylibA mylibB)
# find_package override
if(POLICY CMP0057)
  cmake_policy(SET CMP0057 NEW)
endif()
# this is disencourage due to: https://crascit.com/2018/09/14/do-not-redefine-
# cmake-commands/
macro(find_package)
  if(NOT "${ARGV0}" IN_LIST SUBPROJECTS)
    _find_package(${ARGV})
  endif()
endmacro()

# it is advised to call find_package on the root diretory because find_package
# will always do a search on the file system, doing this avoid several finds,
# but not allways the libraries are known at root level
find_package(mylibA REQUIRED)
find_package(mylibB REQUIRED)

add_subdirectory(src)
if(BUILD_TESTS)
  message(STATUS "Build test modules...")
  # Note: testing must be enabled at top script level
  enable_testing()
  if(CODE_COVERAGE)
    message(STATUS "Building tests with coverage...")
    add_code_coverage_all_targets() # Adds instrumentation to all targets
  endif()
  add_subdirectory(tests)
else()
  message(STATUS "Unit tests will not be built")
endif()
