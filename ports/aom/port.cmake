include_guard(GLOBAL)

declare_port(
  "git:aomedia.googlesource.com/aom@3.11.0"
  aom
  BYPRODUCTS lib/libaom.$<IF:${WIN32},lib,a>
)

add_library(aom STATIC IMPORTED GLOBAL)

add_dependencies(aom ${aom})

set_target_properties(
  aom
  PROPERTIES
  IMPORTED_LOCATION "${aom_PREFIX}/lib/libaom.$<IF:${WIN32},lib,a>"
)

file(MAKE_DIRECTORY "${aom_PREFIX}/include")

target_include_directories(
  aom
  INTERFACE "${aom_PREFIX}/include"
)
