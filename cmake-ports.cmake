include_guard()

find_package(cmake-fetch REQUIRED PATHS node_modules/cmake-fetch)
find_package(cmake-meson REQUIRED PATHS node_modules/cmake-meson)

set(ports_module_dir "${CMAKE_CURRENT_LIST_DIR}")

include(ExternalProject)

macro(configure_cmake_port)
  set(cmake_args
    -S ${prefix}/src/${target}
    -B ${prefix}/src/${target}-build
    -G ${CMAKE_GENERATOR}
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_INSTALL_PREFIX=${prefix}"
    "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
    "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
    "-DCMAKE_MESSAGE_LOG_LEVEL=${CMAKE_MESSAGE_LOG_LEVEL}"
    "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
  )

  if(ANDROID)
    if(DEFINED ANDROID_PLATFORM)
      list(APPEND cmake_args
        "-DANDROID_PLATFORM=${ANDROID_PLATFORM}"
      )
    endif()

    if(DEFINED ANDROID_STL)
      list(APPEND cmake_args
        "-DANDROID_STL=${ANDROID_STL}"
      )
    endif()
  endif()

  if(APPLE)
    list(APPEND cmake_args
      "-DCMAKE_MACOSX_BUNDLE=OFF"
    )
  endif()

  list(APPEND cmake_args ${ARGV_ARGS})

  list(APPEND args
    CONFIGURE_COMMAND
      ${CMAKE_COMMAND} ${cmake_args}
    BUILD_COMMAND
      ${CMAKE_COMMAND} --build ${prefix}/src/${target}-build
    INSTALL_COMMAND
      ${CMAKE_COMMAND} --install ${prefix}/src/${target}-build --prefix ${prefix}
  )
endmacro()

macro(configure_meson_port)
  meson_cross_file(cross)

  file(GENERATE OUTPUT "${prefix}/src/${target}-build/cross-file.txt" CONTENT "${cross}")

  set(meson_args
    ${prefix}/src/${target}
    ${prefix}/src/${target}-build
    --prefix=${prefix}
    --default-library=static
    --cross-file=${prefix}/src/${target}-build/cross-file.txt
  )

  list(APPEND meson_args ${ARGV_ARGS})

  list(APPEND args
    CONFIGURE_COMMAND
      meson setup ${meson_args}
    BUILD_COMMAND
      meson compile -C ${prefix}/src/${target}-build
    INSTALL_COMMAND
      meson install -C ${prefix}/src/${target}-build
  )
endmacro()

function(declare_port specifier result)
  set(option_keywords
    CMAKE
    MESON
  )

  set(multi_value_keywords
    ARGS
    BYPRODUCTS
    DEPENDS
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "${option_keywords}" "" "${multi_value_keywords}"
  )

  parse_fetch_specifier(${specifier} target args)

  set(prefix "${CMAKE_CURRENT_BINARY_DIR}/_ports/${target}")

  set(${result} ${target} PARENT_SCOPE)
  set(${result}_PREFIX "${prefix}" PARENT_SCOPE)
  set(${result}_SOURCE_DIR "${prefix}/src/${target}" PARENT_SCOPE)
  set(${result}_BINARY_DIR "${prefix}/src/${target}-build" PARENT_SCOPE)

  list(TRANSFORM ARGV_BYPRODUCTS PREPEND "${prefix}/")

  if(ARGV_MESON)
    configure_meson_port()
  else()
    configure_cmake_port()
  endif()

  ExternalProject_Add(
    ${target}
    ${args}
    PREFIX "${prefix}"
    UPDATE_DISCONNECTED ON
    INSTALL_BYPRODUCTS ${ARGV_BYPRODUCTS}
    DEPENDS ${ARGV_DEPENDS}
  )
endfunction()

function(find_port name)
  include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/ports/${name}/port.cmake" OPTIONAL RESULT_VARIABLE path)

  if(path MATCHES "NOTFOUND")
    include("${ports_module_dir}/ports/${name}/port.cmake")
  endif()

  if(name MATCHES "^lib(.+)")
    set(name "${CMAKE_MATCH_1}")
  endif()

  set(${name}_PREFIX "${${name}_PREFIX}" PARENT_SCOPE)
endfunction()
