# Asserts how `find_port` resolves a port: it is included from the consuming
# project, and declared features are validated against it.
#
# Nothing here declares a real port, so nothing is fetched or built.

include("${CMAKE_CURRENT_LIST_DIR}/../cmake-ports.cmake")

set(fixtures "${CMAKE_CURRENT_LIST_DIR}/fixtures")

# A port is included from the consuming project's cmake/ports.
block()
  set(CMAKE_CURRENT_SOURCE_DIR "${fixtures}/project")

  find_port(example)

  if(NOT example_INCLUDED_FROM STREQUAL "project")
    message(SEND_ERROR "find_port(example)\n  expected the project's own port to be included\n  got: ${example_INCLUDED_FROM}")
  endif()
endblock()

# Features the port declares are accepted.
block()
  set(CMAKE_CURRENT_SOURCE_DIR "${fixtures}/project")

  find_port(example FEATURES threads)
endblock()

message(STATUS "find: ok")
