if(EXISTS "configure")
  return()
endif()

set(env)

if(CMAKE_HOST_WIN32)
  find_path(
    msys2
    NAMES msys2.exe
    PATHS "C:/tools/msys64"
    REQUIRED
  )

  list(APPEND env --modify "PATH=path_list_prepend:${msys2}/usr/bin")

  find_program(
    bash
    NAMES bash
    PATHS "${msys2}/usr/bin"
    REQUIRED
    NO_DEFAULT_PATH
  )

  find_program(
    autoreconf
    NAMES autoreconf
    PATHS "${msys2}/usr/bin"
    REQUIRED
    NO_DEFAULT_PATH
  )

  set(autoreconf ${bash} ${autoreconf})
else()
  find_program(
    autoreconf
    NAMES autoreconf
    REQUIRED
  )
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E env ${env} ${autoreconf} -vfi
  WORKING_DIRECTORY "${WORKING_DIRECTORY}"
  RESULT_VARIABLE result
  ERROR_VARIABLE error
)

if(NOT result EQUAL 0)
  message(FATAL_ERROR "Could not configure build system: ${error}")
endif()
