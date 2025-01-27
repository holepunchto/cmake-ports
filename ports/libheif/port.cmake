include_guard(GLOBAL)

find_port(dav1d)
find_port(libde265)

declare_port(
  "github:strukturag/libheif@1.19.5"
  heif
  BYPRODUCTS lib/libheif.a
  DEPENDS
    dav1d
    de265
  PATCHES
    patches/01-windows-deprecated-declarations.patch
    patches/02-remove-doxygen.patch
  ARGS
    "-DBUILD_TESTING=OFF"
    "-DENABLE_PLUGIN_LOADING=OFF"

    "-DWITH_DAV1D=ON"
    "-DDAV1D_INCLUDE_DIR=${dav1d_PREFIX}/include"
    "-DDAV1D_LIBRARY=${dav1d_PREFIX}/lib/libdav1d.a"

    "-DWITH_LIBDE265=ON"
    "-DLIBDE265_INCLUDE_DIR=${de265_PREFIX}/include"
    "-DLIBDE265_LIBRARY=${de265_PREFIX}/lib/libde265.a"

    "-DWITH_LIBSHARPYUV=OFF"
    "-DWITH_EXAMPLES=OFF"
    "-DWITH_GDK_PIXBUF=OFF"
    "-DWITH_X265=OFF"
    "-DWITH_OpenH264_ENCODER=OFF"
    "-DWITH_OpenH264_DECODER=OFF"
    "-DWITH_AOM_ENCODER=OFF"
    "-DWITH_AOM_DECODER=OFF"
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
    dav1d
    de265
)
