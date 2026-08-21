# Asserts the ExternalProject arguments each `configure_*_port` macro builds: the
# configure, build and install commands a port of that build system runs.
#
# Nothing here fetches or builds anything. Run through `cmake -P test.cmake`.

include("${CMAKE_CURRENT_LIST_DIR}/../cmake-ports.cmake")

# The macros read `prefix`, `target` and `ARGV_*` from their caller and append to
# `args`, so each case sets that up, calls the macro, and asserts on `args`.
function(expect_contains label haystack needle)
  string(REPLACE ";" " " flat "${haystack}")

  if(NOT flat MATCHES "${needle}")
    message(SEND_ERROR "${label}\n  expected to find: ${needle}\n  in: ${flat}")
  endif()
endfunction()

function(expect_excludes label haystack needle)
  string(REPLACE ";" " " flat "${haystack}")

  if(flat MATCHES "${needle}")
    message(SEND_ERROR "${label}\n  expected NOT to find: ${needle}\n  in: ${flat}")
  endif()
endfunction()

set(prefix "/ports/example")
set(target "example")

# A CMake port drives configure, build and install through cmake itself, out of
# tree, installing into the port's own prefix.
block()
  set(args)
  set(ARGV_ARGS -DEXAMPLE_OPTION=ON)

  configure_cmake_port()

  expect_contains("cmake port" "${args}" "CONFIGURE_COMMAND")
  expect_contains("cmake port" "${args}" "-S /ports/example/src/example")
  expect_contains("cmake port" "${args}" "-B /ports/example/src/example-build")
  expect_contains("cmake port" "${args}" "--build /ports/example/src/example-build")
  expect_contains("cmake port" "${args}" "--install /ports/example/src/example-build --prefix /ports/example")

  # Caller arguments reach the configure step.
  expect_contains("cmake port passes ARGS" "${args}" "-DEXAMPLE_OPTION=ON")
endblock()

# An autotools port runs the entrypoint rather than cmake.
block()
  set(args)
  set(ARGV_ARGS --enable-example)
  set(ARGV_ENTRYPOINT "/src/autogen.sh")

  configure_autotools_port()

  expect_contains("autotools port" "${args}" "CONFIGURE_COMMAND")
  expect_contains("autotools port passes ARGS" "${args}" "--enable-example")
  expect_excludes("autotools port does not configure with cmake" "${args}" "-DCMAKE_INSTALL_PREFIX")
endblock()

message(STATUS "configure: ok")
