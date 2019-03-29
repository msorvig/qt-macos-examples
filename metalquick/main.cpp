#include <QtGui>
#include <QtQuick>
#include "qquickwindowcontroller.h"
#include "metalwindow.h"

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    
    // QQuickWindowController is not (yet) a built-in API, register the
    // implementation provided with this example.
    qmlRegisterType<QQuickWindowController>("WindowController", 1, 0, "WindowController");
    
    QQuickView toplevel;
    toplevel.resize(800, 600);
    toplevel.setResizeMode(QQuickView::SizeRootObjectToView);

    // Create and export a MetalWindow instance to QML
    QWindow *metalWindow = new MetalWindow();
    toplevel.engine()->rootContext()->setContextProperty("metalWindow", metalWindow);

    toplevel.setSource(QUrl("qrc:/main.qml"));
    toplevel.show();
    
    return app.exec();
}
