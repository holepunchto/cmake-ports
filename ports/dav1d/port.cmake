include_guard(GLOBAL)

if(WIN32)
  set(enable_asm false)
else()
  set(enable_asm true)
endif()

declare_port(
  "git:code.videolan.org/videolan/dav1d#1.5.1"
  dav1d
  MESON
  BYPRODUCTS lib/libdav1d.a
  ARGS
    -Denable_tests=false
    -Denable_tools=false
    -Denable_asm=${enable_asm}
)

add_library(dav1d STATIC IMPORTED GLOBAL)

add_dependencies(dav1d ${dav1d})

set_target_properties(
  dav1d
  PROPERTIES
  IMPORTED_LOCATION "${dav1d_PREFIX}/lib/libdav1d.a"
)

file(MAKE_DIRECTORY "${dav1d_PREFIX}/include")

target_include_directories(
  dav1d
  INTERFACE "${dav1d_PREFIX}/include"
)
