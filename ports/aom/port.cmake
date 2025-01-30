include_guard(GLOBAL)

if(WIN32)
  set(lib libaom.lib)
else()
  set(lib libaom.a)
endif()

declare_port(
  "git:aomedia.googlesource.com/aom@3.11.0"
  aom
  BYPRODUCTS lib/${lib}
)

add_library(aom STATIC IMPORTED GLOBAL)

add_dependencies(aom ${aom})

set_target_properties(
  aom
  PROPERTIES
  IMPORTED_LOCATION "${aom_PREFIX}/lib/${lib}"
)

file(MAKE_DIRECTORY "${aom_PREFIX}/include")

target_include_directories(
  aom
  INTERFACE "${aom_PREFIX}/include"
)
