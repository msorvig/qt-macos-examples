#include <QtGui>

#include <hellotriangle/AAPLRenderer.h>

class MetalWindow : public QWindow
{
public:
    MetalWindow()
    {
        setSurfaceType(QSurface::MetalSurface);
    }

    void exposeEvent(QExposeEvent *) override
    {
        initMetal();

        [m_renderer drawFrame];

//        requestUpdate() // request new animation frame
    }

    void updateEvent()
    {
        [m_renderer drawFrame];
    }

    bool event(QEvent *ev) override
    {
        if (ev->type() == QEvent::UpdateRequest) {
            updateEvent();
            return false;
        } else {
            return QWindow::event(ev);
        }
    }

    void initMetal()
    {
        if (m_metalDevice != nil)
            return;

        m_metalDevice = MTLCreateSystemDefaultDevice();
        if (!m_metalDevice)
            qFatal("Metal is not supported");

        // Load shaders from Qt resources
        QFile shadersFile(":/hellotriangleshaders.metallib");
        shadersFile.open(QIODevice::ReadOnly);
        QByteArray shaders = shadersFile.readAll();
        dispatch_data_t data = dispatch_data_create(shaders.constData(), shaders.size(),
                               dispatch_get_main_queue(), DISPATCH_DATA_DESTRUCTOR_DEFAULT);

        NSError *error = nil;
        id <MTLLibrary> library = [m_metalDevice newLibraryWithData:data error:&error];
        dispatch_release(data);
        if (error)
            qWarning() << "Shader Error" << error;

        // Extract NSView and Metal layer via winId()
        CAMetalLayer *metalLayer = reinterpret_cast<CAMetalLayer *>(reinterpret_cast<NSView *>(winId()).layer);

        // Create Renderer
        metalLayer.device = m_metalDevice;
        m_renderer = [[AAPLRenderer alloc] initWithMetalLayer:metalLayer library:library];
    }
private:
    id<MTLDevice> m_metalDevice;
    AAPLRenderer *m_renderer;
};

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    MetalWindow metalWindow;
    metalWindow.setTitle("QSurface::MetalSurface");
    metalWindow.resize(640, 480);
    metalWindow.show();

    return app.exec();
}
