if(CMAKE_HOST_WIN32)
  find_program(
    git
    NAMES git.cmd git
    REQUIRED
  )
else()
  find_program(
    git
    NAMES git
    REQUIRED
  )
endif()

foreach(patch IN LISTS PATCHES)
  get_filename_component(patch "${patch}" REALPATH)

  execute_process(
    COMMAND ${git} apply --ignore-whitespace "${patch}"
    RESULT_VARIABLE result
    ERROR_VARIABLE error
  )

  if(NOT result EQUAL 0)
    execute_process(
      COMMAND ${git} apply --ignore-whitespace --check --reverse "${patch}"
      RESULT_VARIABLE result
      ERROR_VARIABLE error
    )

    if(NOT result EQUAL 0)
      message(FATAL_ERROR "Patch ${patch} was not applied: ${error}")
    endif()
  endif()
endforeach()
