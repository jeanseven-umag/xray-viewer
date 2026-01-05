# XRay Viewer Project Setup Script for Windows
# Run this in PowerShell: .\setup_project.ps1

Write-Host "Creating XRay Viewer project structure..." -ForegroundColor Green

# Create directory structure
Write-Host "Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "src\ui" | Out-Null
New-Item -ItemType Directory -Force -Path "src\image" | Out-Null
New-Item -ItemType Directory -Force -Path "src\filters" | Out-Null
New-Item -ItemType Directory -Force -Path "src\utils" | Out-Null
New-Item -ItemType Directory -Force -Path "include" | Out-Null
New-Item -ItemType Directory -Force -Path "tests" | Out-Null
New-Item -ItemType Directory -Force -Path "docs" | Out-Null

# Create .gitignore
Write-Host "Creating .gitignore..." -ForegroundColor Yellow
@"
# Build directories
build/
cmake-build-*/
bin/
lib/

# CMake
CMakeCache.txt
CMakeFiles/
cmake_install.cmake
Makefile
*.cmake
!CMakeLists.txt

# Compiled Object files
*.o
*.obj
*.so
*.dylib
*.dll
*.a
*.lib

# Executables
*.exe
*.out
*.app
xray-viewer

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Temporary files
*.log
*.tmp
*.bak

# Test images (optional, if large)
test_images/*.tiff
test_images/*.tif

# Core dumps
core
core.*

# Package files
*.deb
*.rpm
*.tar.gz
*.zip
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# Create CMakeLists.txt
Write-Host "Creating CMakeLists.txt..." -ForegroundColor Yellow
@"
cmake_minimum_required(VERSION 3.16)
project(XRayViewer VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "`${CMAKE_CXX_FLAGS} -Wall -Wextra -O3 -march=native")

# Find required packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
pkg_check_modules(TIFF REQUIRED libtiff-4)

# Include directories
include_directories(
    `${CMAKE_SOURCE_DIR}/include
    `${GTK3_INCLUDE_DIRS}
    `${TIFF_INCLUDE_DIRS}
)

# Link directories
link_directories(
    `${GTK3_LIBRARY_DIRS}
    `${TIFF_LIBRARY_DIRS}
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
add_executable(xray-viewer `${SOURCES})

# Link libraries
target_link_libraries(xray-viewer
    `${GTK3_LIBRARIES}
    `${TIFF_LIBRARIES}
    pthread
)

# Compiler definitions
add_definitions(
    `${GTK3_CFLAGS_OTHER}
)

# Installation
install(TARGETS xray-viewer DESTINATION bin)
"@ | Out-File -FilePath "CMakeLists.txt" -Encoding UTF8

# Create src/main.cpp
Write-Host "Creating src/main.cpp..." -ForegroundColor Yellow
@"
#include <gtk/gtk.h>
#include <iostream>
#include "ui/MainWindow.h"

int main(int argc, char* argv[]) {
    // Initialize GTK
    gtk_init(&argc, &argv);
    
    std::cout << "XRay Viewer - Medical Image Viewer" << std::endl;
    std::cout << "Version 1.0.0" << std::endl;
    
    // Create main window
    MainWindow* mainWindow = new MainWindow();
    
    // If filename provided as argument, load it
    if (argc > 1) {
        std::string filename = argv[1];
        std::cout << "Loading image: " << filename << std::endl;
        mainWindow->loadImage(filename);
    }
    
    // Show window
    mainWindow->show();
    
    // Start GTK main loop
    gtk_main();
    
    // Cleanup
    delete mainWindow;
    
    return 0;
}
"@ | Out-File -FilePath "src\main.cpp" -Encoding UTF8

# Create src/image/ImageBuffer.h
Write-Host "Creating src/image/ImageBuffer.h..." -ForegroundColor Yellow
@"
#ifndef IMAGE_BUFFER_H
#define IMAGE_BUFFER_H

#include <cstdint>
#include <cstddef>

/**
 * ImageBuffer - Manual memory management for large X-ray images
 * Handles 16-bit grayscale image data with explicit allocation/deallocation
 */
class ImageBuffer {
public:
    ImageBuffer();
    ~ImageBuffer();
    
    // Disable copy to prevent accidental duplication of large buffers
    ImageBuffer(const ImageBuffer&) = delete;
    ImageBuffer& operator=(const ImageBuffer&) = delete;
    
    // Enable move semantics for efficient transfer
    ImageBuffer(ImageBuffer&& other) noexcept;
    ImageBuffer& operator=(ImageBuffer&& other) noexcept;
    
    /**
     * Allocate buffer for 16-bit image data
     * @param width Image width in pixels
     * @param height Image height in pixels
     * @return true if allocation successful
     */
    bool allocate(uint32_t width, uint32_t height);
    
    /**
     * Free allocated memory explicitly
     */
    void deallocate();
    
    /**
     * Get pointer to raw 16-bit data
     */
    uint16_t* getData() { return data_; }
    const uint16_t* getData() const { return data_; }
    
    /**
     * Get pixel value at coordinates
     */
    uint16_t getPixel(uint32_t x, uint32_t y) const;
    
    /**
     * Set pixel value at coordinates
     */
    void setPixel(uint32_t x, uint32_t y, uint16_t value);
    
    // Getters
    uint32_t getWidth() const { return width_; }
    uint32_t getHeight() const { return height_; }
    size_t getDataSize() const { return data_size_; }
    bool isAllocated() const { return data_ != nullptr; }
    
private:
    uint16_t* data_;      // Raw 16-bit pixel data
    uint32_t width_;      // Image width
    uint32_t height_;     // Image height
    size_t data_size_;    // Total size in bytes
    
    void cleanup();
};

#endif // IMAGE_BUFFER_H
"@ | Out-File -FilePath "src\image\ImageBuffer.h" -Encoding UTF8

# Create src/image/ImageBuffer.cpp
Write-Host "Creating src/image/ImageBuffer.cpp..." -ForegroundColor Yellow
@"
#include "ImageBuffer.h"
#include <cstring>
#include <iostream>

ImageBuffer::ImageBuffer() 
    : data_(nullptr), width_(0), height_(0), data_size_(0) {
}

ImageBuffer::~ImageBuffer() {
    deallocate();
}

ImageBuffer::ImageBuffer(ImageBuffer&& other) noexcept
    : data_(other.data_), 
      width_(other.width_), 
      height_(other.height_),
      data_size_(other.data_size_) {
    other.data_ = nullptr;
    other.width_ = 0;
    other.height_ = 0;
    other.data_size_ = 0;
}

ImageBuffer& ImageBuffer::operator=(ImageBuffer&& other) noexcept {
    if (this != &other) {
        deallocate();
        data_ = other.data_;
        width_ = other.width_;
        height_ = other.height_;
        data_size_ = other.data_size_;
        other.data_ = nullptr;
        other.width_ = 0;
        other.height_ = 0;
        other.data_size_ = 0;
    }
    return *this;
}

bool ImageBuffer::allocate(uint32_t width, uint32_t height) {
    if (width == 0 || height == 0) {
        std::cerr << "ImageBuffer: Invalid dimensions" << std::endl;
        return false;
    }
    
    deallocate();
    
    data_size_ = static_cast<size_t>(width) * height * sizeof(uint16_t);
    data_ = static_cast<uint16_t*>(malloc(data_size_));
    
    if (!data_) {
        std::cerr << "ImageBuffer: Failed to allocate " << data_size_ << " bytes" << std::endl;
        return false;
    }
    
    width_ = width;
    height_ = height;
    
    std::memset(data_, 0, data_size_);
    
    std::cout << "ImageBuffer: Allocated " << data_size_ / (1024 * 1024) 
              << " MB for " << width_ << "x" << height_ << " image" << std::endl;
    
    return true;
}

void ImageBuffer::deallocate() {
    if (data_) {
        free(data_);
        data_ = nullptr;
        width_ = 0;
        height_ = 0;
        data_size_ = 0;
    }
}

uint16_t ImageBuffer::getPixel(uint32_t x, uint32_t y) const {
    if (!data_ || x >= width_ || y >= height_) {
        return 0;
    }
    return data_[y * width_ + x];
}

void ImageBuffer::setPixel(uint32_t x, uint32_t y, uint16_t value) {
    if (!data_ || x >= width_ || y >= height_) {
        return;
    }
    data_[y * width_ + x] = value;
}

void ImageBuffer::cleanup() {
    deallocate();
}
"@ | Out-File -FilePath "src\image\ImageBuffer.cpp" -Encoding UTF8

# Create src/image/TiffLoader.h
Write-Host "Creating src/image/TiffLoader.h..." -ForegroundColor Yellow
@"
#ifndef TIFF_LOADER_H
#define TIFF_LOADER_H

#include "ImageBuffer.h"
#include <string>
#include <tiffio.h>

/**
 * TiffLoader - Loads 16-bit TIFF X-ray images using libtiff
 * Optimized for large medical images (up to 200MB)
 */
class TiffLoader {
public:
    TiffLoader();
    ~TiffLoader();
    
    /**
     * Load 16-bit TIFF image from file
     * @param filename Path to TIFF file
     * @param buffer Output buffer (will be allocated)
     * @return true if successful
     */
    bool load(const std::string& filename, ImageBuffer& buffer);
    
    /**
     * Get last error message
     */
    const std::string& getError() const { return error_message_; }
    
    /**
     * Validate if file is a supported 16-bit TIFF
     */
    bool validate(const std::string& filename);
    
private:
    std::string error_message_;
    
    // Helper methods
    bool readTiffData(TIFF* tif, ImageBuffer& buffer);
    void setError(const std::string& msg);
};

#endif // TIFF_LOADER_H
"@ | Out-File -FilePath "src\image\TiffLoader.h" -Encoding UTF8

# Create src/image/TiffLoader.cpp (stub)
Write-Host "Creating src/image/TiffLoader.cpp..." -ForegroundColor Yellow
@"
#include "TiffLoader.h"
#include <iostream>

TiffLoader::TiffLoader() {
}

TiffLoader::~TiffLoader() {
}

bool TiffLoader::load(const std::string& filename, ImageBuffer& buffer) {
    // TODO: Implement TIFF loading
    setError("TiffLoader::load not yet implemented");
    return false;
}

bool TiffLoader::validate(const std::string& filename) {
    // TODO: Implement validation
    return false;
}

bool TiffLoader::readTiffData(TIFF* tif, ImageBuffer& buffer) {
    // TODO: Implement reading
    return false;
}

void TiffLoader::setError(const std::string& msg) {
    error_message_ = msg;
    std::cerr << "TiffLoader error: " << msg << std::endl;
}
"@ | Out-File -FilePath "src\image\TiffLoader.cpp" -Encoding UTF8

# Create src/image/ImageProcessor.h
Write-Host "Creating src/image/ImageProcessor.h..." -ForegroundColor Yellow
@"
#ifndef IMAGE_PROCESSOR_H
#define IMAGE_PROCESSOR_H

#include "ImageBuffer.h"
#include <cstdint>

/**
 * ImageProcessor - Real-time 16-bit to 8-bit conversion for display
 * Uses window/level adjustments and multi-threading for performance
 */
class ImageProcessor {
public:
    ImageProcessor();
    ~ImageProcessor();
    
    /**
     * Convert 16-bit buffer to 8-bit RGB for display
     * @param input 16-bit source buffer
     * @param output Pre-allocated 8-bit RGB buffer (width * height * 3)
     * @param window Window width for contrast
     * @param level Center level for contrast
     */
    void convert16to8bit(const ImageBuffer& input, 
                         uint8_t* output,
                         uint16_t window = 4096,
                         uint16_t level = 2048);
    
    /**
     * Apply window/level adjustment (medical imaging standard)
     * @param input Source pixel value (16-bit)
     * @param window Window width
     * @param level Window center
     * @return Adjusted 8-bit value
     */
    static uint8_t applyWindowLevel(uint16_t input, 
                                    uint16_t window, 
                                    uint16_t level);
    
    /**
     * Calculate optimal window/level from image statistics
     */
    void calculateAutoWindowLevel(const ImageBuffer& input,
                                   uint16_t& window,
                                   uint16_t& level);
    
    /**
     * Set number of threads for parallel processing
     */
    void setThreadCount(int count);
    
private:
    int thread_count_;
    
    // Helper for parallel conversion
    void convertRegion(const uint16_t* input,
                      uint8_t* output,
                      uint32_t start_row,
                      uint32_t end_row,
                      uint32_t width,
                      uint16_t window,
                      uint16_t level);
};

#endif // IMAGE_PROCESSOR_H
"@ | Out-File -FilePath "src\image\ImageProcessor.h" -Encoding UTF8

# Create src/image/ImageProcessor.cpp (stub)
Write-Host "Creating src/image/ImageProcessor.cpp..." -ForegroundColor Yellow
@"
#include "ImageProcessor.h"

ImageProcessor::ImageProcessor() : thread_count_(4) {
}

ImageProcessor::~ImageProcessor() {
}

void ImageProcessor::convert16to8bit(const ImageBuffer& input, 
                                      uint8_t* output,
                                      uint16_t window,
                                      uint16_t level) {
    // TODO: Implement conversion
}

uint8_t ImageProcessor::applyWindowLevel(uint16_t input, 
                                         uint16_t window, 
                                         uint16_t level) {
    // TODO: Implement window/level
    return 0;
}

void ImageProcessor::calculateAutoWindowLevel(const ImageBuffer& input,
                                               uint16_t& window,
                                               uint16_t& level) {
    // TODO: Implement auto calculation
}

void ImageProcessor::setThreadCount(int count) {
    thread_count_ = count;
}

void ImageProcessor::convertRegion(const uint16_t* input,
                                   uint8_t* output,
                                   uint32_t start_row,
                                   uint32_t end_row,
                                   uint32_t width,
                                   uint16_t window,
                                   uint16_t level) {
    // TODO: Implement region conversion
}
"@ | Out-File -FilePath "src\image\ImageProcessor.cpp" -Encoding UTF8

# Create stub files for UI
Write-Host "Creating UI stub files..." -ForegroundColor Yellow
@"
#ifndef MAIN_WINDOW_H
#define MAIN_WINDOW_H

#include <gtk/gtk.h>
#include <string>

class MainWindow {
public:
    MainWindow();
    ~MainWindow();
    
    void show();
    void loadImage(const std::string& filename);
    
private:
    GtkWidget* window_;
};

#endif
"@ | Out-File -FilePath "src\ui\MainWindow.h" -Encoding UTF8

@"
#include "MainWindow.h"

MainWindow::MainWindow() : window_(nullptr) {
    window_ = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window_), "XRay Viewer");
    gtk_window_set_default_size(GTK_WINDOW(window_), 800, 600);
    g_signal_connect(window_, "destroy", G_CALLBACK(gtk_main_quit), NULL);
}

MainWindow::~MainWindow() {
}

void MainWindow::show() {
    gtk_widget_show_all(window_);
}

void MainWindow::loadImage(const std::string& filename) {
    // TODO: Implement image loading
}
"@ | Out-File -FilePath "src\ui\MainWindow.cpp" -Encoding UTF8

# Create empty stub files
Write-Host "Creating remaining stub files..." -ForegroundColor Yellow
"" | Out-File -FilePath "src\ui\ImageCanvas.h" -Encoding UTF8
"" | Out-File -FilePath "src\ui\ImageCanvas.cpp" -Encoding UTF8
"" | Out-File -FilePath "src\ui\ToolBar.h" -Encoding UTF8
"" | Out-File -FilePath "src\ui\ToolBar.cpp" -Encoding UTF8
"" | Out-File -FilePath "src\filters\ContrastFilter.h" -Encoding UTF8
"" | Out-File -FilePath "src\filters\ContrastFilter.cpp" -Encoding UTF8
"" | Out-File -FilePath "src\filters\CropTool.h" -Encoding UTF8
"" | Out-File -FilePath "src\filters\CropTool.cpp" -Encoding UTF8
"" | Out-File -FilePath "src\filters\RulerTool.h" -Encoding UTF8
"" | Out-File -FilePath "src\filters\RulerTool.cpp" -Encoding UTF8
"" | Out-File -FilePath "src\utils\MemoryManager.h" -Encoding UTF8
"" | Out-File -FilePath "src\utils\MemoryManager.cpp" -Encoding UTF8

# Create README
Write-Host "Creating README.md..." -ForegroundColor Yellow
@"
# XRay Viewer

Medical X-ray image viewer and editor for Linux/Ubuntu with advanced image processing capabilities.

## Features

- Load and display large 16-bit TIFF X-ray images (up to 200MB)
- Real-time dynamic conversion from 16-bit to screen bitmap without lag
- Manual memory management for optimal performance
- Image processing filters:
  - Contrast adjustment
  - Crop tool
  - Linear ruler measurement
  - Additional editing tools
- GTK-based user interface
- Optimized for Ubuntu/Linux

## Requirements

### System Dependencies (Ubuntu/Linux)
``````bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libgtk-3-dev \
    libtiff5-dev \
    libtiff-tools
``````

## Building (on Linux/WSL)

``````bash
mkdir build
cd build
cmake ..
make -j`$(nproc)
``````

## Running

``````bash
./xray-viewer [path-to-xray-image.tiff]
``````

## Project Status

🚧 **In Development** - Basic structure created, implementation in progress.

## License

[Choose appropriate license]

## Author

Your Name
"@ | Out-File -FilePath "README.md" -Encoding UTF8

Write-Host "`nProject structure created successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Initialize git repository: git init" -ForegroundColor White
Write-Host "2. Add files to git: git add ." -ForegroundColor White
Write-Host "3. Create first commit: git commit -m 'Initial project structure'" -ForegroundColor White
Write-Host "4. Create repository on GitHub" -ForegroundColor White
Write-Host "5. Add remote: git remote add origin https://github.com/YOUR_USERNAME/xray-viewer.git" -ForegroundColor White
Write-Host "6. Push to GitHub: git push -u origin main" -ForegroundColor White
Write-Host "`nNote: This project is designed for Linux. To build and test, use WSL2 or a Linux VM." -ForegroundColor Yellow