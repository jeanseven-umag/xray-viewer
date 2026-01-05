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
