#include <QtGui>
#include <QtWidgets>
#include "metalwindow.h"

int main(int argc, char **argv)
{
    QApplication app(argc, argv);
    
    // Create a top-level widget
    QWidget toplevel;
    toplevel.resize(640, 480);
    toplevel.setWindowTitle("QWidget with createWindowContainer-managed Metal Window");
    toplevel.setStyleSheet("background-color:darkblue;");

    // Create a Metal QWindow, use createWindowContainer() to create a
    // wrapper/controller widget which is added as a child widget.
    QHBoxLayout *layout = new QHBoxLayout();
    toplevel.setLayout(layout);
    layout->addWidget(QWidget::createWindowContainer(new MetalWindow()));

    toplevel.show();
    return app.exec();
}
