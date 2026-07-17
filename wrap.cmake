string(REPLACE "$<SEMICOLON>" ";" wraps "${WRAPS}")

file(MAKE_DIRECTORY "${DESTINATION}")

foreach(wrap IN LISTS wraps)
  file(COPY "${wrap}" DESTINATION "${DESTINATION}")
endforeach()
