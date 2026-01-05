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
