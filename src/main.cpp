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
