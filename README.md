# cmake-ports

Simple build recipe manager for CMake based on [`ExternalProject`](https://cmake.org/cmake/help/latest/module/ExternalProject.html). Inspired by <https://learn.microsoft.com/en-us/vcpkg/concepts/ports>.

```
npm i cmake-ports
```

```cmake
find_package(cmake-ports REQUIRED PATHS node_modules/cmake-ports)
```

## API

#### `declare_port(<specifier> <result> [CMAKE | MESON | AUTOTOOLS | ZIG] [ENTRYPOINT <script>] [SUBMODULES <ON|OFF>] [ARGS <arg...>] [BYPRODUCTS <path...>] [DEPENDS <target...>] [PATCHES <path...>] [WRAPS <path...>] [ENV <key=value...>])`

Declare a port that fetches, builds, and installs an external project into a private prefix. A port is realized as an [`ExternalProject`](https://cmake.org/cmake/help/latest/module/ExternalProject.html) target named after the resolved package.

`<specifier>` is the package to fetch, given as `<protocol>:<location>`:

| Specifier               | Example                                      |
| :---------------------- | :------------------------------------------- |
| `github:<owner>/<repo>` | `github:libvips/libvips@8.18.4`              |
| `gitlab:<owner>/<repo>` | `gitlab:<owner>/<repo>@1.0.0`                |
| `git:<host>/<repo>`     | `git:code.videolan.org/videolan/dav1d#1.5.1` |
| `https://<url>`         | `https://.../libfoo-1.0.tar.gz`              |

For the Git-based protocols, append `@<major>.<minor>.<patch>` to check out the `v<major>.<minor>.<patch>` tag, or `#<ref>` to check out an arbitrary branch, tag, or commit. When neither is given, the default branch is used.

`<result>` is the name of a variable set in the calling scope to the resolved port target. The following cache variables are also set for use by the port's consumers:

| Variable              | Description                                 |
| :-------------------- | :------------------------------------------ |
| `<result>_PREFIX`     | The install prefix of the port              |
| `<result>_SOURCE_DIR` | The source directory of the port            |
| `<result>_BINARY_DIR` | The build directory of the port             |
| `<result>_STAMP_DIR`  | The timestamp directory of the port         |
| `<result>_FEATURES`   | The list of features requested for the port |

The build system is selected with one of `CMAKE` (the default), `MESON`, `AUTOTOOLS`, or `ZIG`. Each is driven with the toolchain, build type, and install prefix that the consuming project was configured with, so ports cross compile the same way as the rest of the build.

The remaining options are:

- `ENTRYPOINT <script>` (`AUTOTOOLS` only) selects a configure script other than `./configure`. The tokens `<SOURCE_DIR>` and `<BINARY_DIR>` are substituted with the port's source and build directories. When omitted, `autoreconf` is run before the default `./configure`.
- `ARGS <arg...>` are passed to the configure step of the selected build system, e.g. `-D<key>=<value>` for CMake and Meson, `--<flag>` for Autotools, or `-D<key>=<value>` build options for Zig.
- `BYPRODUCTS <path...>` lists the files produced by the install step, relative to `<result>_PREFIX`, so that the generator can track them as dependencies.
- `DEPENDS <target...>` lists other targets, such as ports declared for dependencies, that must be built first.
- `PATCHES <path...>` lists patch files, relative to the port, applied to the source before it is configured. Patches are applied with `git apply` and are tolerated if already applied.
- `WRAPS <path...>` lists [Meson wrap files](https://mesonbuild.com/Wrap-dependency-system-manual.html), relative to the port, copied into the `subprojects/` directory of the fetched source before it is configured. This lets a Meson port build its dependencies from source as subprojects without having to patch them in. Pair it with `--wrap-mode=forcefallback` (or `--force-fallback-for=<name...>`) in `ARGS` to force the wraps to be used in place of any system packages.
- `ENV <key=value...>` sets environment variables for the configure, build, and install steps.

#### `find_port(<name> [FEATURES <feature...>])`

Locate and include the port named `<name>`, which declares its targets by calling `declare_port()`. The port is first looked up at `cmake/ports/<name>/port.cmake` within the consuming project, allowing projects to provide their own ports, and otherwise resolved from the ports bundled with `cmake-ports`.

`FEATURES <feature...>` requests optional features from the port. The requested features are exposed to the port's `port.cmake` through the `features` variable, which the port reads to conditionally enable functionality, for example an extra dependency or codec. A port with a `lib` prefix, such as `libheif`, is matched against features by its unprefixed name, such as `heif`.

## License

Apache-2.0
