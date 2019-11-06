# ##############################################################################
# add test functionality

# override IN_LIST new CMP0057: Support new IN_LIST if() operator.
if(POLICY CMP0057)
  cmake_policy(SET CMP0057 NEW)
endif()
# CMP0074: find_package uses PackageName_ROOT variables.
if(POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif()

# add_test_executable sets a new test project first argument is the target name
# and then the following should be specify SOURCES - list of file sources to be
# used LINK_LIBRARIES - list of libs to link to
#
# Note: new list can be added to have another special treatments
macro(add_test_executable)
  set(options)
  set(oneValueArgs)
  set(multiValueArgs "SOURCES;LINK_LIBRARIES")
  cmake_parse_arguments(PARSED_ARGS
                        "${options}"
                        "${oneValueArgs}"
                        "${multiValueArgs}"
                        ${ARGN})

  # anouce it
  message(STATUS "Building ${ARGV0}...")

  add_executable(${ARGV0} ${PARSED_ARGS_SOURCES})
  target_link_libraries(${ARGV0}
                        PUBLIC GTest::Main
                               GTest::GTest
                               GMock::GMock
                               ${PARSED_ARGS_LINK_LIBRARIES})

  # add test
  add_test(NAME ${ARGV0} COMMAND ${ARGV0})

  # coverage
  if(CODE_COVERAGE)
    message(STATUS "Building ${ARGV0} with coverage...")
    target_code_coverage(${ARGV0} AUTO ALL) # Adds instrumentation to all
                                            # targets
  endif()

  # automatic run
  if(RUN_TESTS_ON_COMPILE)
    # automatic test execution sample...
    add_custom_command(TARGET ${ARGV0} POST_BUILD
                       COMMAND ${ARGV0}
                       WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                       COMMENT "Running ${ARGV0}"
                       VERBATIM)
  endif()

  # install information
  install(TARGETS ${ARGV0} DESTINATION tests)
endmacro()
