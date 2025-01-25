# cmake-ports

Simple build recipe manager for CMake based on [`ExternalProject`](https://cmake.org/cmake/help/latest/module/ExternalProject.html). Inspired by <https://learn.microsoft.com/en-us/vcpkg/concepts/ports>.

```
npm i cmake-ports
```

```cmake
find_package(cmake-ports REQUIRED PATHS node_modules/cmake-ports)
```

## API

#### `declare_port(<specifier> <result> [ARGS <key=value...>] [BYPRODUCTS <path...>] [DEPENDS <target...>])`

#### `find_port(<name>)`

## License

Apache-2.0
