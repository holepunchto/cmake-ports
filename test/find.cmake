# Asserts how `find_port` resolves a port: a project's own port wins over the
# bundled one, and declared features are validated against it.
#
# Nothing here declares a real port, so nothing is fetched or built.

include("${CMAKE_CURRENT_LIST_DIR}/../cmake-ports.cmake")

set(fixtures "${CMAKE_CURRENT_LIST_DIR}/fixtures")

# A port under the consuming project's cmake/ports takes precedence, so a project
# can override a bundled recipe.
block()
  set(CMAKE_CURRENT_SOURCE_DIR "${fixtures}/project")

  find_port(example)

  if(NOT example_INCLUDED_FROM STREQUAL "project")
    message(SEND_ERROR "find_port(example)\n  expected the project's own port to win\n  got: ${example_INCLUDED_FROM}")
  endif()
endblock()

# Features the port declares are accepted.
block()
  set(CMAKE_CURRENT_SOURCE_DIR "${fixtures}/project")

  find_port(example FEATURES threads)
endblock()

message(STATUS "find: ok")
