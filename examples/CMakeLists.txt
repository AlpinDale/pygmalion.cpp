add_library(ggml_utils STATIC utils.cpp)
target_include_directories(ggml_utils PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(pyggy)
