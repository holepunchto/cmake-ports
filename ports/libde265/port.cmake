include_guard(GLOBAL)

declare_port(
  "github:strukturag/libde265@1.0.15"
  de265
  BYPRODUCTS lib/libde265${CMAKE_STATIC_LIBRARY_SUFFIX}
  PATCHES
    patches/01-windows-clang.patch
    patches/02-getopt-const-pointer.patch
    patches/03-clang-sse-flags.patch
  ARGS
    "-DENABLE_SDL=OFF"
)

add_library(de265 STATIC IMPORTED GLOBAL)

add_dependencies(de265 ${de265})

set_target_properties(
  de265
  PROPERTIES
  IMPORTED_LOCATION "${de265_PREFIX}/lib/libde265${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

file(MAKE_DIRECTORY "${de265_PREFIX}/include")

target_include_directories(
  de265
  INTERFACE "${de265_PREFIX}/include"
)

target_compile_definitions(
  de265
  INTERFACE
    LIBDE265_STATIC_BUILD=1
    LIBDE265_EXPORTS=0
)
