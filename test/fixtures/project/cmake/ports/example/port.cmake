# Stands in for a port a consuming project provides itself. It records that it
# was the one included and declares a feature, the way `declare_port` exports
# them - through the cache - without declaring a real port.
set(example_INCLUDED_FROM "project" CACHE INTERNAL "Which port.cmake was included")

set(example_FEATURES threads CACHE INTERNAL "The list of features of the example port")
