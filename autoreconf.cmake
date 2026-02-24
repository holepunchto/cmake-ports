if(EXISTS "configure")
  return()
endif()

find_program(
  autoreconf
  NAMES autoreconf
  REQUIRED
)

execute_process(
  COMMAND ${autoreconf} -vfi
  WORKING_DIRECTORY "${WORKING_DIRECTORY}"
  RESULT_VARIABLE result
  ERROR_VARIABLE error
)

if(NOT result EQUAL 0)
  message(FATAL_ERROR "Could not configure build system: ${error}")
endif()
