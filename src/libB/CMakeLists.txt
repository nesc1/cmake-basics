cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

set(PROJ_MAJOR_VERSION 1)
set(PROJ_MINOR_VERSION 0)
set(PROJ_PATCH_VERSION 0)
set(PROJ_VERSION
    ${PROJ_MAJOR_VERSION}.${PROJ_MINOR_VERSION}.${PROJ_PATCH_VERSION})

project(mylibB VERSION ${PROJ_VERSION} LANGUAGES CXX)

message(STATUS "Building ${CMAKE_PROJECT_NAME}::${PROJECT_NAME} project...")

# do not define neither static nor shared mode, this must be set by
# -DBUILD_SHARED_LIBS=ON|OFF
add_library(${PROJECT_NAME} mylibB_headerimpl.cpp)
# define alias
add_library(${CMAKE_PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

# little helper to generate exports/imports defines used by visual studio
include(GenerateExportHeader)
# generates the export header shared_EXPORTS.h automatically
generate_export_header(${PROJECT_NAME}
                       BASE_NAME
                       ${PROJECT_NAME}_base_name
                       EXPORT_MACRO_NAME
                       ${PROJECT_NAME}_EXPORTS_DEFINE
                       EXPORT_FILE_NAME
                       definitions/mylibB-shared-exports.h
                       STATIC_DEFINE
                       SHARED_EXPORTS_BUILT_AS_STATIC)

# instruct the target to know how to find the include files (the generated one
# above and the lib header)
target_include_directories(
  ${PROJECT_NAME}
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include>
         $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/definitions>)

# install information
set_target_properties(${PROJECT_NAME}
                      PROPERTIES VERSION
                                 ${PROJ_VERSION}
                                 SOVERSION
                                 ${PROJ_MAJOR_VERSION}.${PROJ_MINOR_VERSION}
                                 INTERFACE_${PROJECT_NAME}_MAJOR_VERSION
                                 ${PROJ_MAJOR_VERSION})
# install target
install(TARGETS ${PROJECT_NAME}
        EXPORT ${PROJECT_NAME}Targets
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INCLUDE_DIR})
# Install the export set for use with the install-tree
install(EXPORT ${PROJECT_NAME}Targets
        FILE ${PROJECT_NAME}Targets.cmake
        NAMESPACE ${CMAKE_PROJECT_NAME}::
        DESTINATION "${INSTALL_CMAKE_DIR}/${PROJECT_NAME}")

# ##############################################################################
# exporting, configuring and installing of cmake files

# Add all targets to the build-tree export set
export(TARGETS ${PROJECT_NAME}
       FILE "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake")
# ... for the build tree
configure_file(${CMAKE_SOURCE_DIR}/cmake/InputConfig.cmake.in
               "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake" @ONLY)
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  VERSION ${PROJ_VERSION}
  COMPATIBILITY AnyNewerVersion)
# Install the ${PROJECT_NAME}Config.cmake and ${PROJECT_NAME}ConfigVersion.cmake
install(FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
              "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION "${INSTALL_CMAKE_DIR}/${PROJECT_NAME}")

# install files
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/include/mylibB/mylibB_header.h
              ${CMAKE_CURRENT_BINARY_DIR}/definitions/mylibB-shared-exports.h
        DESTINATION ${INSTALL_INCLUDE_DIR}/${PROJECT_NAME}
        COMPONENT Devel)
