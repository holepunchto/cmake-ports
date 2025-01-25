include_guard(GLOBAL)

find_port(aom)
find_port(libde265)

declare_port(
  "github:strukturag/libheif@1.19.5"
  heif
  BYPRODUCTS lib/libheif.a
  DEPENDS
    aom
    de265
  ARGS
    "-DWITH_LIBDE265=ON"
    "-DLIBDE265_INCLUDE_DIR=${de265_PREFIX}/include"
    "-DLIBDE265_LIBRARY=${de265_PREFIX}/lib/libde265.a"

    "-DWITH_AOM_DECODER=ON"
    "-DAOM_INCLUDE_DIR=${aom_PREFIX}/include"
    "-DAOM_LIBRARY=${aom_PREFIX}/lib/libaom.a"

    "-DWITH_X265=OFF"
    "-DWITH_OpenH264_DECODER=OFF"
    "-DWITH_AOM_ENCODER=OFF"
)

add_library(heif STATIC IMPORTED GLOBAL)

add_dependencies(heif ${heif})

set_target_properties(
  heif
  PROPERTIES
  IMPORTED_LOCATION "${heif_PREFIX}/lib/libheif.a"
)

file(MAKE_DIRECTORY "${heif_PREFIX}/include")

target_include_directories(
  heif
  INTERFACE "${heif_PREFIX}/include"
)

target_link_libraries(
  heif
  INTERFACE
    aom
    de265
)
