cmake_minimum_required(VERSION 3.16)
project(Part_b C)

set(CMAKE_C_STANDARD 11)

add_executable(pipeline pipeline.c)
add_executable(usingpipes usingpipes.c)
add_executable(wrdsh wrdsh.c)