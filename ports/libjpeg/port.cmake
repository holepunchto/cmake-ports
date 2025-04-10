include_guard(GLOBAL)

if(WIN32)
  set(lib lib/jpeg.lib)
elseif(LINUX)
  set(lib lib64/libjpeg.a)
else()
  set(lib lib/libjpeg.a)
endif()

declare_port(
  "github:libjpeg-turbo/libjpeg-turbo#3.1.0"
  jpeg
  BYPRODUCTS ${lib}
)

add_library(jpeg STATIC IMPORTED GLOBAL)

add_dependencies(jpeg ${jpeg})

set_target_properties(
  jpeg
  PROPERTIES
  IMPORTED_LOCATION "${jpeg_PREFIX}/${lib}"
)

file(MAKE_DIRECTORY "${jpeg_PREFIX}/include")

target_include_directories(
  jpeg
  INTERFACE "${jpeg_PREFIX}/include"
)
