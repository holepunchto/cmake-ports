if(WIN32)
  file(GLOB_RECURSE libraries "lib/lib*.a")

  foreach(library IN LISTS libraries)
    cmake_path(GET library PARENT_PATH library_path)
    cmake_path(GET library FILENAME library_filename)

    string(REGEX REPLACE "^lib([^.]+)\\.a$" "\\1.lib" library_filename "${library_filename}")

    file(CREATE_LINK "${library}" "${library_path}/${library_filename}" COPY_ON_ERROR SYMBOLIC)
  endforeach()
endif()
