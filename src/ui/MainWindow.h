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
