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
