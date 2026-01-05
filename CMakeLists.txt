cmake_minimum_required(VERSION 3.16)
project(XRayViewer VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -O3 -march=native")

# Find required packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
pkg_check_modules(TIFF REQUIRED libtiff-4)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${GTK3_INCLUDE_DIRS}
    ${TIFF_INCLUDE_DIRS}
)

# Link directories
link_directories(
    ${GTK3_LIBRARY_DIRS}
    ${TIFF_LIBRARY_DIRS}
)

# Source files
set(SOURCES
    src/main.cpp
    src/ui/MainWindow.cpp
    src/ui/ImageCanvas.cpp
    src/ui/ToolBar.cpp
    src/image/TiffLoader.cpp
    src/image/ImageProcessor.cpp
    src/image/ImageBuffer.cpp
    src/filters/ContrastFilter.cpp
    src/filters/CropTool.cpp
    src/filters/RulerTool.cpp
    src/utils/MemoryManager.cpp
)

# Executable
add_executable(xray-viewer ${SOURCES})

# Link libraries
target_link_libraries(xray-viewer
    ${GTK3_LIBRARIES}
    ${TIFF_LIBRARIES}
    pthread
)

# Compiler definitions
add_definitions(
    ${GTK3_CFLAGS_OTHER}
)

# Installation
install(TARGETS xray-viewer DESTINATION bin)
