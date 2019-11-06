# CMake Library Application and Test Sample

## Introduction

This tutorial will help you understand how CMake works with a live example, but the best way to learn CMake is by reading CMake documentation: [CMake Homepage](https://cmake.org/cmake/help/latest/)

This live sample has 90% of what a real world project normally have:

- executable project using libraries
- external application using the created libraries
- test projects to test the code

This tutorial is split into 3 steps:

1. cmake usage (project, libraries and external libraries)
2. unit test integration
3. code coverage integration

Current version currently focus on all of them.

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

### Default Usage - With Tests (GTest)

#### Small Introdution on CONAN Package Manager

To compile the unit tests an external dependency is required, the gtest library.

Using conan package manager we can request to the package manager to handle the compilation and installation of gtest library.
For that we only need to do the following:

- create the conanfile.txt on the root project containing the following (for example):

```txt
[requires]
gtest/1.8.1@hmi/stable

[generators]
cmake_paths
```

- in the build folder call

```batch
conan install .. -s build_type=Release
```

(this will create the file conan_paths.cmake that will have instructions where to find the dependendt libraries)

- after this we do the same to configure and build the project but supply the conan_paths.cmake to the cmake toolchain:

```batch
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_paths.cmake -DBUILD_TESTS=ON
```

or you can also use the CMAKE*PROJECT\_<_PROJECT-NAME*>\_INCLUDE to specify a file to be included by the project() command)

```batch
cmake .. -DCMAKE_PROJECT_LibAppTestProject_INCLUDE=./build/conan_paths.cmake -DBUILD_TESTS=ON ..
```

#### Compile Tests With CMake

- _on windows with default compiler (visual studio by default)_

```
mkdir build
cd build
conan install .. -s build_type=Release
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_paths.cmake -DBUILD_TESTS=ON
cmake --build . --config Release
ctest -VV -C Release
```

- _on linux with default compiler (gcc by default)_

```
mkdir build
cd build
conan install .. -s build_type=Release
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=conan_paths.cmake -DBUILD_TESTS=ON
cmake --build .
ctest -VV
```

### Default Usage - With Tests and Coverage

#### Generate Coverage

- _on windows with default compiler (visual studio by default)_

The Visual Studio code coverage feature is available only on Visual Studio Enterprise edition.

Also because I don't own a Visual Studio Enterprise edition license and because the desired goal of this tutorial is to perform the same steps in any operating system to acomplish the desired objectives we are using custom tools to mimic the same functionality accomplished in linux system with lcov and grcov. This tools can be found on:

- grcov: https://github.com/mozilla/grcov
- lcov: https://github.com/valbok/lcov

So starting from begining we need to make a new directory where to build the project:

Note: that we will need to run our unit tests to validate the coverage acomplished in our project:

```
mkdir build
cd build
conan install .. -s build_type=Release
```

Next we need to compile the project, lcov and grcov only support gcc or clang, so because we are on windows we will use clang to compile our project (please note that you need to have a clang installation on your system in order to execute the next command)

```
λ clang --version
clang version 9.0.0 (tags/RELEASE_900/final)
Target: x86_64-pc-windows-msvc
Thread model: posix
InstalledDir: C:\Program Files\LLVM\bin
```

As you can see my clang installation is located in: `C:\Program Files\LLVM\bin`, this is important to know because cmake will require that clang binaries to be in path. Another thing that cmake will try to find is the ninja executable, in my case I have it on `c:\PortableApps`.

So in order to compile the project using clang and ninja execute:

```
cmake -E env LDFLAGS="-fuse-ld=lld-link" PATH="%PATH%;c:/PortableApps/;C:/PROGRA~1/LLVM/lib/clang/9.0.0/lib/windows;C:/PROGRA~1/LLVM/bin/" cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER:PATH="clang.exe" -DCMAKE_CXX_COMPILER:PATH="clang++.exe" -DCMAKE_RC_COMPILER:PATH="llvm-rc.exe" -DCMAKE_TOOLCHAIN_FILE=conan_paths.cmake -DBUILD_TESTS=ON -DRUN_TESTS_ON_COMPILE=ON -DCODE_COVERAGE=ON -DCMAKE_PREFIX_PATH=./tools

cmake --build .
```

Note that we request that build process run with tests automatically (`-DRUN_TESTS_ON_COMPILE=ON`) and we enable the support for code coverage: `-DCODE_COVERAGE=ON` (please see cmake code for more details).

Next we generate the coverage information.

Note that the coverage process will try to look into all the source files, including the system ones, and normally we don't want that. So we need to list all the source files affected by the coverage tools and then ignore the files that we don't want in our report, example:

To list all files affected:

```
..\tools\grcov.exe --llvm -s . -t files .
```

And now call `grcov` ignoring all the files not desired on the final report:

```
..\tools\grcov.exe --llvm --ignore "C:/Users/Nuno/.conan/data/gtest/1.8.1/bincrafters/stable/package/3f7b6d42d6c995a23d193db1f844ed23ae943226/include/gtest/_" --ignore "C:/Program Files (x86)/Windows Kits/10/Include/10.0.17763.0/ucrt/_" --ignore "C:/git/tutorials/cmake-basics/src/app/_" --ignore "C:/Program Files (x86)/Microsoft Visual Studio/2019/Professional/VC/Tools/MSVC/14.23.28105/include/_" --ignore "C:/Program Files (x86)/Microsoft Visual Studio/2019/Professional/VC/Tools/MSVC/14.23.28105/include/\*" -s c:\git\tutorials\cmake-basics\build\ -t lcov c:\git\tutorials\cmake-basics\build\ > lcov.info
```

In the end we will generate a nice html report with all information (this also assume that the pearl tool is installed on the system):

```
perl ..\tools\genhtml.perl -o report --show-details --highlight --legend --title "LibAppTestProject" --num-spaces 4 lcov.info
```

This last command will generate a new folder called `report` with html files inside containing the coverage of your project (`report/index.html`).

Source of information was: https://marco-c.github.io/2018/01/09/code-coverage-with-clang-on-windows.html

- _on linux with default compiler (gcc by default)_

On linux the process is much more simpler and we use lcov functionlity to achieve the desired goal.

##### Requirements:

```
sudo apt install lcov
```

Make a new build folder and configure the project dependencies with conan:

```
mkdir build
cd build
conan install .. -s build_type=Release
```

The configure as no special handling only enabling our project flags:

- BUILD_TESTS
- RUN_TESTS_ON_COMPILE
- CODE_COVERAGE

Please see cmake code in for more details.

Note that is desired to use debug build to have a better view of coverage.

```
cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=conan_paths.cmake -DBUILD_TESTS=ON -DRUN_TESTS_ON_COMPILE=ON -DCODE_COVERAGE=ON
cmake --build .
```

The next command will capture the coverage information into the `lcov.info` file:

```
lcov --capture --base-directory . --directory . --output-file lcov.info
```

In the same way as in windows we need to remove the code that we don't want to happear in the coverage, example of the system code. To see all the affected code by the coverage execute the following:

```
lcov -l lcov.info
```

But unlike windows we can only include what we want, that is our source project files, for this we can execute the following comand:

```
lcov --extract lcov.info <your path>/cmake-basics/src/libA/*  --extract lcov.info <your path>/cmake-basics/src/libB/* --extract lcov.info <your path>/cmake-basics/tests/simpletest/* -o lcov.info
```

This extract our source code information from `lcov.info` and generate a new file (`lcov.info`) with only that information.

In the end we generate the html report by executing:

```
genhtml lcov.info --show-details --highlight --legend --title "LibAppTestProject" --num-spaces 4 --output-directory report
firefox report/index.html &
```

Alternatively you can also restart everything by:

```
lcov --base-directory . --directory . --zerocounters
ctest -V
lcov --capture --base-directory . --directory . --output-file lcov.info
...
```

_(don't know why but using clang with lcov failed)_

### CMake Explanation Commands

#### Configuration Phase

- normal configure

```

cmake ..

```

- defining the instal location (important for install process withou this an error will happear on windows due to permissions) or defining other settings

```

cmake .. -DCMAKE_INSTALL_PREFIX="./bin" -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=ON

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

#### Test Phase

- default test

```

ctest -VV

```

_Note:_ -VV stands for extra verbose (see more on [ctest](https://cmake.org/cmake/help/latest/manual/ctest.1.html#options))

- test in release (if build tree supports it)

```

ctest -VV -C Release

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

to build the tests we can do:

```batch
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
cmake -GNinja -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_LINKER=lld-link -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=<path for gtest installation> -DCMAKE_INSTALL_PREFIX=../install -DBUILD_TESTS=ON ..
cmake --build . --target install
```

to run tests outside the project structure also works, we only need to specify the install folder of our library and gtest installation dir on CMAKE_PREFIX_PATH

```batch
cmake -GNinja -DCMAKE_MAKE_PROGRAM=C:/PortableApps/ninja.exe -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_LINKER=lld-link -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="../install;<path for gtest installation>" -DCMAKE_INSTALL_PREFIX=../install -DBUILD_TESTS=ON ..
cmake --build . --target install
```

_Note: if you want to run tests while compilation is being run then add _-DRUN_TESTS_ON_COMPILE=ON\_\_

to build on linux the same is performed (note that the build tree used does not support multiple configurations so you really need to specify the CMAKE_BUILD_TYPE):

```batch
cmake -GNinja -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_LINKER=lld -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=<path for gtest installation> -DCMAKE_INSTALL_PREFIX=../install -DBUILD_TESTS=ON ..
cmake --build . --target install
ctest -VV
```

_Note_: that we use clang++ to compile the c++ project as we can also use the g++ (in this we do not required MSVC environment to use clang and for that the linker and compiler are different)

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
