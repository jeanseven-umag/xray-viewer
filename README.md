# XRay Viewer

Industrial X-ray image viewer and editor for Linux/Ubuntu with advanced image processing capabilities.

## Features
- GTK and libtiff tools
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
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libgtk-3-dev \
    libtiff5-dev \
    libtiff-tools
```

## Building (on Linux/WSL)

```bash
mkdir build
cd build
cmake ..
make -j$(nproc)
```


## Project Status

**In Development** - Basic structure created, implementation in progress.

## License
under MIT license

## Author
Jeandos Jetibaev
