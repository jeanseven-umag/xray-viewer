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
