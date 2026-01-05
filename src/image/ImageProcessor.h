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
