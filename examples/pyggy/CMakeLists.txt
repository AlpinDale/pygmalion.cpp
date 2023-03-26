#
# pyggy

set(TEST_TARGET pyggy)
add_executable(${TEST_TARGET} pyg.cpp)
target_link_libraries(${TEST_TARGET} PRIVATE ggml ggml_utils)


