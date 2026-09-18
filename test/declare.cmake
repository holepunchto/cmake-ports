# Asserts what `declare_port` hands to ExternalProject, by configuring a fixture
# project and reading the clone script ExternalProject generates from it.
#
# The fixture is only configured, never built, so nothing is fetched. This is the
# one path that cannot be checked in script mode: `declare_port` ends in
# ExternalProject_Add, which needs a project.

set(root "${CMAKE_CURRENT_LIST_DIR}/..")
set(build "${root}/build/test/declare")

file(REMOVE_RECURSE "${build}")

execute_process(
  COMMAND ${CMAKE_COMMAND}
    -S "${CMAKE_CURRENT_LIST_DIR}/fixtures/declare"
    -B "${build}"
    -D "CMAKE_PREFIX_PATH=${root}/node_modules"
  RESULT_VARIABLE result
  OUTPUT_VARIABLE output
  ERROR_VARIABLE output
)

if(NOT result EQUAL 0)
  message(SEND_ERROR "configuring the declare_port fixture failed:\n${output}")
  return()
endif()

file(GLOB_RECURSE clone_scripts "${build}/_ports/*-gitclone.cmake")

if(NOT clone_scripts)
  message(SEND_ERROR "expected ExternalProject to generate clone scripts under ${build}/_ports")
  return()
endif()

# SUBMODULES OFF reaches the clone as config on the clone itself, since an empty
# GIT_SUBMODULES is dropped when the argument list is expanded.
foreach(script IN LISTS clone_scripts)
  file(READ "${script}" contents)

  if(script MATCHES "without-submodules")
    if(NOT contents MATCHES "submodule\\.active=none")
      message(SEND_ERROR "SUBMODULES OFF\n  expected submodule.active=none in ${script}")
    endif()
  else()
    if(contents MATCHES "submodule\\.active=none")
      message(SEND_ERROR "SUBMODULES left default\n  expected no submodule.active=none in ${script}")
    endif()
  endif()
endforeach()

message(STATUS "declare: ok")
