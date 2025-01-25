include_guard()

find_package(cmake-fetch REQUIRED PATHS node_modules/cmake-fetch)

set(ports_module_dir "${CMAKE_CURRENT_LIST_DIR}")

include(ExternalProject)

function(declare_port specifier result)
  set(multi_value_keywords
    ARGS
    BYPRODUCTS
    DEPENDS
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "" "${multi_value_keywords}"
  )

  parse_fetch_specifier(${specifier} target args)

  set(prefix "${CMAKE_CURRENT_BINARY_DIR}/_ports/${target}")

  set(${result} ${target} PARENT_SCOPE)
  set(${result}_PREFIX "${prefix}" PARENT_SCOPE)

  list(TRANSFORM ARGV_BYPRODUCTS PREPEND "${prefix}/")

  ExternalProject_Add(
    ${target}
    ${args}
    PREFIX "${prefix}"
    CMAKE_ARGS
      "-DBUILD_SHARED_LIBS=OFF"
      "-DCMAKE_INSTALL_PREFIX=${prefix}"
      "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
      "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
      "-DCMAKE_MESSAGE_LOG_LEVEL=${CMAKE_MESSAGE_LOG_LEVEL}"
      "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
      ${ARGV_ARGS}
    BUILD_BYPRODUCTS
      ${ARGV_BYPRODUCTS}
    DEPENDS
      ${ARGV_DEPENDS}
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
