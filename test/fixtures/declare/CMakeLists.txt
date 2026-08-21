# Declares two git-backed ports so the generated clone scripts can be compared:
# one that opts out of submodules and one that leaves the default alone.
#
# Only configured, never built, so nothing is ever fetched.

cmake_minimum_required(VERSION 3.25)

project(declare_port_fixture NONE)

find_package(cmake-ports REQUIRED PATHS "${CMAKE_CURRENT_LIST_DIR}/../../..")

declare_port(
  "github:example/without-submodules#main"
  without_submodules
  CMAKE
  SUBMODULES OFF
)

declare_port(
  "github:example/with-submodules#main"
  with_submodules
  CMAKE
)
