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
