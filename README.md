# CMake Library Application and Test Sample

## Introduction

This tutorial will help you understand how CMake works with a live example, but the best way to learn CMake is by reading CMake documentation: [CMake Homepage](https://cmake.org/cmake/help/latest/)

This live sample has 90% of what a real world project normally have:

- executable project using libraries
- external application using the created libraries
- test projects to test the code (available on next release :))

This tutorial is split into 3 steps:

1. cmake usage (project, libraries and external libraries)
2. unit test integration
3. code coverage integration

Current version only focus on first point

## Overview

This CMake tutorial contains the following sub-projects:

- library B that do the math functionality (a+b)
- library (A that uses library B)
- application (that uses library A)
- test application (that tests the library A)
- external application that uses the library A by find_package

_On top of this the install process is also presented using the desired way._

## CMake Usage

### Default usage

_(starting from root folder)_
_on windows with default compiler (visual studio by default)_

#### Build application that uses the library A

```
cd <root>
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="../install"
cmake --build . --config Release --target install
```

#### Build external application that uses library A

_(previous step with installation is required)_

```
cd <root>
cd external-application
mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH="../install"
cmake --build . --config Release
```

### Explanation

#### Configuration Phase

- normal configure

```
cmake ..
```

- defining the instal location (important for install process withou this an error will happear on windows due to permissions) or defining other settings

```
cmake .. -DCMAKE_INSTALL_PREFIX="./bin" -DCMAKE_BUILD_TYPE=Release
```

_Note_: that some CMake-generated build trees can have multiple build configurations in the same tree, like Visual Studio, so on this configurations setting -DCMAKE_BUILD_TYPE=<build_type> does nothing and you must explicit set on build, install and test phase the configuration to use or default will be used

#### Build Phase

- simple build (without install)

```
cmake --build .
```

- simple build (in debug for build trees that support it)

```
cmake --build . --config Debug
```

- run specific targets (example of install)

```
cmake --build . --target install
```

#### Install Phase

- default install

```
cmake --build . --target install
```

- default install in release (if compiler supports it)

```
cmake --build . --target install --config Release
```

## Using other compilers and generators

- msys gcc (in windows and assuming that the msys is installed on c:\\)

```batch
cmake .. -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX=../install -DCMAKE_MAKE_PROGRAM=C:/msys64/mingw64/bin/mingw32-make.exe -DCMAKE_CXX_COMPILER=C:/msys64/mingw64/bin/g++.exe -DCMAKE_C_COMPILER=C:/msys64/mingw64/bin/gcc.exe -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
cmake --build .
ctest -VV
cmake --build . --target install
```

- Visual Studio 2017

```batch
cmake .. -G "Visual Studio 15 2017 Win64" -DCMAKE_INSTALL_PREFIX=../install -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
cmake --build . --config Release
ctest -VV -C Release
cmake --build . --config Release --target install
```

- Visual Studio 2019 and Ninja

to compile with Ninja, it is necessary to run cmake with MSVC environment loaded

```batch
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
cmake .. -G "Ninja" -DCMAKE_INSTALL_PREFIX=../install -DBUILD_SHARED_LIBS=ON
cmake --build . --config Release --target install
```

- Using clang with ninja

to compile with clang-cl, it is necessary to run cmake with MSVC environment loaded (use vcvarsall.bat - setted in the settings.json file of vs code). Otherwise it tries to use GCC compatibility options.
It is enought to install just the [Build Tools vs2017](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=BuildTools&rel=15) or [Build Tools vs2019](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=BuildTools&rel=16).

```batch
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
cmake -G Ninja -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_LINKER=lld-link -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install ..
cmake --build . --target install
```

to build the external app (external-application) simple use (note the use of the full path on -DCMAKE_PREFIX_PATH or if relative then the relative path must be from where the CMakeLists.txt root is):

```batch
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
cmake -GNinja -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_LINKER=lld-link -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=../install -DCMAKE_INSTALL_PREFIX=../install ..
cmake --build . --target install
```

Another interesting feature that the library project is prepared to do is to easily create the library as static (default) or as shared. To do this simple specify the BUILD_SHARED_LIBS=ON on the configuration step, example:

```batch
cmake .. -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=../install
cmake --build . --config Release --target install
```

(this will build and install the shared library and app project and install the .dll and .exe in install/bin folder - this on windows and using MSVC)

## CMake Notes

### find_package

CMake use the following variables to find packages (calling find_package(XXX)):

- CMAKE_MODULE_PATH - find the findXXX.cmake scripts
- CMAKE_PREFIX_PATH - where the findXXX.cmake scripts will find for

### Good practices

Extended cpp or c flags should not be added on the CMakeLists.txt files, instead they should be added on the scripts that call the cmake, example:

```batch
cmake .. -DCMAKE_CXX_FLAGS_DEBUG="-D_DEBUG" -DCMAKE_C_FLAGS_DEBUG="-D_DEBUG"
```

### CMake debug

- to see what cmake is doing you can activate the verbose mode ON by:

```batch
cmake .. -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DCMAKE_RULE_MESSAGES:BOOL=ON
```

or

```batch
cmake --build . -- VERBOSE=1 --no-print-directory
```

### Install

#### In CMake install we can do the following

- install the target in a specific location:

```cmake
install(TARGETS ${PROJECT_NAME} DESTINATION lib)
```

- install include files

```cmake
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/include/mylibheader.h DESTINATION include)
```

- and we can also do things like:

```cmake
#install directory with patterns example
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
        DESTINATION include
        USE_SOURCE_PERMISSIONS FILES_MATCHING PATTERN "*.h")
    or
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION "include"
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN ".svn" EXCLUDE
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
```

## CMake Quick Help

| CMake Variables          | Meaning                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| PROJECT_SOURCE_DIR       | the project source dir                                                                                                 |
| CMAKE_SOURCE_DIR         | directory which contains the top-level CMakeLists.txt, i.e. the top level source directory                             |
| CMAKE_CURRENT_SOURCE_DIR | this is the directory where the currently processed CMakeLists.txt is located in                                       |
| PROJECT_BINARY_DIR       | contains the full path to the top level directory of your build tree - home/nuno/workspace/tests/grpctest/build        |
| CMAKE_BINARY_DIR         | the build dir /home/nuno/workspace/tests/grpctest/build                                                                |
| CMAKE_CURRENT_BINARY_DIR | on the build project the same dir structure where the CMakeLists.txt - /home/nuno/workspace/tests/grpctest/build/proto |

## Bugs, Suggestions or Improvements:

-
