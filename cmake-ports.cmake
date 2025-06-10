include_guard()

find_package(cmake-fetch REQUIRED PATHS node_modules/cmake-fetch)
find_package(cmake-meson REQUIRED PATHS node_modules/cmake-meson)
find_package(cmake-zig REQUIRED PATHS node_modules/cmake-zig)

set(ports_module_dir "${CMAKE_CURRENT_LIST_DIR}")

include(ExternalProject)

macro(configure_cmake_port)
  set(cmake_args
    -S "${prefix}/src/${target}"
    -B "${prefix}/src/${target}-build"
    -G ${CMAKE_GENERATOR}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_MESSAGE_LOG_LEVEL=${CMAKE_MESSAGE_LOG_LEVEL}
    "-DCMAKE_TOOLCHAIN_FILE=$<PATH:CMAKE_PATH,${CMAKE_TOOLCHAIN_FILE}>"
    "-DCMAKE_MAKE_PROGRAM=$<PATH:CMAKE_PATH,${CMAKE_MAKE_PROGRAM}>"
  )

  if(ANDROID)
    if(DEFINED ANDROID_PLATFORM)
      list(APPEND cmake_args
        -DANDROID_PLATFORM=${ANDROID_PLATFORM}
      )
    endif()

    if(DEFINED ANDROID_STL)
      list(APPEND cmake_args
        -DANDROID_STL=${ANDROID_STL}
      )
    endif()
  endif()

  if(APPLE)
    list(APPEND cmake_args
      -DCMAKE_MACOSX_BUNDLE=OFF
    )
  endif()

  list(APPEND cmake_args ${ARGV_ARGS})

  list(APPEND args
    CONFIGURE_COMMAND
      ${CMAKE_COMMAND} ${cmake_args}
    BUILD_COMMAND
      ${CMAKE_COMMAND} --build "${prefix}/src/${target}-build"
    INSTALL_COMMAND
      ${CMAKE_COMMAND} --install "${prefix}/src/${target}-build" --prefix "${prefix}"
  )
endmacro()

macro(configure_meson_port)
  meson_cross_file(cross_file)
  meson_buildtype(buildtype)

  file(GENERATE OUTPUT "${prefix}/src/${target}-build/cross-file.txt" CONTENT "${cross_file}")

  set(meson_args
    "${prefix}/src/${target}"
    "${prefix}/src/${target}-build"
    --buildtype ${buildtype}
    --default-library static
    --prefix "${prefix}"
    --cross-file "${prefix}/src/${target}-build/cross-file.txt"
  )

  list(APPEND meson_args ${ARGV_ARGS})

  if(CMAKE_HOST_WIN32)
    find_program(
      meson
      NAMES meson.cmd meson
      REQUIRED
    )
  else()
    find_program(
      meson
      NAMES meson
      REQUIRED
    )
  endif()

  list(APPEND args
    CONFIGURE_COMMAND
      ${meson} setup ${meson_args}
    BUILD_COMMAND
      ${meson} compile -C "${prefix}/src/${target}-build"
    INSTALL_COMMAND
      ${meson} install -C "${prefix}/src/${target}-build"
  )
endmacro()

macro(configure_autotools_port)
  if(CMAKE_HOST_WIN32)
    find_path(
      msys2
      NAMES msys2.exe
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
      make
      NAMES make
      PATHS "${msys2}/usr/bin"
      REQUIRED
      NO_DEFAULT_PATH
    )

    list(TRANSFORM env REPLACE "path_list_(append|prepend):([A-Z]):" "path_list_\\1:/\\2")
  else()
    find_program(
      bash
      NAMES bash
      REQUIRED
    )

    find_program(
      make
      NAMES make
      REQUIRED
    )
  endif()

  if(ARGV_ENTRYPOINT)
    set(configure_script ${ARGV_ENTRYPOINT})
  else()
    set(configure_script ${prefix}/src/${target}/configure)
  endif()

  if(CMAKE_HOST_WIN32)
    string(REGEX REPLACE "^([A-Z]):" "/\\1" configure_script "${configure_script}")
  endif()

  set(configure_prefix "${prefix}")

  if(CMAKE_HOST_WIN32)
    string(REGEX REPLACE "^([A-Z]):" "/\\1" configure_prefix "${configure_prefix}")
  endif()

  set(configure_args "--prefix=${configure_prefix}")

  list(APPEND configure_args ${ARGV_ARGS})

  list(APPEND args
    CONFIGURE_COMMAND
      ${CMAKE_COMMAND} -E env ${env} ${bash} ${configure_script} ${configure_args}
    BUILD_COMMAND
      ${CMAKE_COMMAND} -E env ${env} ${make} --jobs 8
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E env ${env} ${make} --jobs 8 install
  )
endmacro()

macro(configure_zig_port)
  zig_target(zig_target)
  zig_optimize(zig_optimize)

  set(zig_args
    --prefix "${prefix}"
    --build-file "${prefix}/src/${target}/build.zig"
    --cache-dir "${prefix}/src/${target}-build"
    -Dtarget=${zig_target}
    -Doptimize=${zig_optimize}
  )

  if(APPLE)
    list(APPEND zig_args
      --sysroot "${CMAKE_OSX_SYSROOT}"
      --search-prefix "${CMAKE_OSX_SYSROOT}/usr"
    )
  endif()

  if(ANDROID)
    list(APPEND zig_args
      --sysroot "${CMAKE_SYSROOT}"
      --search-prefix "${CMAKE_SYSROOT}/usr"
      --search-prefix "${CMAKE_SYSROOT}/usr/include/${zig_target}"
    )
  endif()

  list(APPEND zig_args ${ARGV_ARGS})

  if(CMAKE_HOST_WIN32)
    find_program(
      zig
      NAMES zig.cmd zig
      REQUIRED
    )
  else()
    find_program(
      zig
      NAMES zig
      REQUIRED
    )
  endif()

  list(APPEND args
    CONFIGURE_COMMAND ${zig} version
    BUILD_COMMAND ${zig} build ${zig_args}
    INSTALL_COMMAND ${zig} zen
  )
endmacro()

function(declare_port specifier result)
  set(option_keywords
    CMAKE
    MESON
    AUTOTOOLS
    ZIG
  )

  set(one_value_keywords
    ENTRYPOINT
  )

  set(multi_value_keywords
    ARGS
    BYPRODUCTS
    DEPENDS
    PATCHES
    ENV
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "${option_keywords}" "${one_value_keywords}" "${multi_value_keywords}"
  )

  parse_fetch_specifier(${specifier} target args)

  set(prefix "${CMAKE_CURRENT_BINARY_DIR}/_ports/${target}")

  set(${result} ${target} PARENT_SCOPE)

  set(${result}_PREFIX "${prefix}" CACHE INTERNAL "The prefix of the ${result} port")
  set(${result}_SOURCE_DIR "${prefix}/src/${target}" CACHE INTERNAL "The source directory of the ${result} port")
  set(${result}_BINARY_DIR "${prefix}/src/${target}-build" CACHE INTERNAL "The binary directory of the ${result} port")
  set(${result}_FEATURES "${features}" CACHE INTERNAL "The list of features of the ${result} port")

  list(TRANSFORM ARGV_BYPRODUCTS PREPEND "${prefix}/")

  list(TRANSFORM ARGV_PATCHES PREPEND "${CMAKE_CURRENT_LIST_DIR}/")

  list(JOIN ARGV_PATCHES "$<SEMICOLON>" patches)

  set(env ${ARGV_ENV})

  if(ARGV_MESON)
    configure_meson_port()
  elseif(ARGV_AUTOTOOLS)
    configure_autotools_port()
  elseif(ARGV_ZIG)
    configure_zig_port()
  else()
    configure_cmake_port()
  endif()

  ExternalProject_Add(
    ${target}
    ${args}
    PREFIX "${prefix}"
    PATCH_COMMAND ${CMAKE_COMMAND} -DPATCHES=${patches} -P "${ports_module_dir}/patch.cmake"
    STEP_TARGETS install
    INSTALL_BYPRODUCTS ${ARGV_BYPRODUCTS}
    DEPENDS ${ARGV_DEPENDS}
    UPDATE_DISCONNECTED ON
    LOG_DOWNLOAD ON
    LOG_UPDATE ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
    LOG_MERGED_STDOUTERR ON
    LOG_OUTPUT_ON_FAILURE ON
  )

  ExternalProject_Add_Step(
    ${target}
    fixup
    COMMAND ${CMAKE_COMMAND} -P "${ports_module_dir}/fixup.cmake"
    WORKING_DIRECTORY "${prefix}"
    ALWAYS TRUE
  )

  ExternalProject_Add_StepDependencies(
    ${target}
    fixup
    ${target}-install
  )
endfunction()

function(find_port name)
  set(multi_value_keywords
    FEATURES
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "" "${multi_value_keywords}"
  )

  set(features ${ARGV_FEATURES})

  include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/ports/${name}/port.cmake" OPTIONAL RESULT_VARIABLE path)

  if(path MATCHES "NOTFOUND")
    include("${ports_module_dir}/ports/${name}/port.cmake")
  endif()

  if(name MATCHES "^lib(.+)")
    set(name "${CMAKE_MATCH_1}")
  endif()

  foreach(feature IN LISTS features)
    if(NOT feature IN_LIST ${name}_FEATURES)
      message(FATAL_ERROR "Feature '${feature}' is not enabled for port '${name}'")
    endif()
  endforeach()
endfunction()
