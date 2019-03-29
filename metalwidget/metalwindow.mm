#include "metalwindow.h"
#include <QtCore>
#include <hellotriangle/AAPLRenderer.h>
@import MetalKit;

// Simple private class for the purpose of moving the Objective-C
// bits out of the header.
class MetalWindowPrivate
{
public:
    id<MTLDevice> m_metalDevice;
    AAPLRenderer *m_renderer;
};

MetalWindow::MetalWindow()
:d(new MetalWindowPrivate())
{
    setSurfaceType(QSurface::MetalSurface);
}

MetalWindow::~MetalWindow()
{
    delete d;
}

void MetalWindow::exposeEvent(QExposeEvent *)
{
    initMetal();

    [d->m_renderer drawFrame];

    requestUpdate(); // request new animation frame
}

void MetalWindow::updateEvent()
{
    [d->m_renderer drawFrame];
}

bool MetalWindow::event(QEvent *ev)
{
    if (ev->type() == QEvent::UpdateRequest) {
        updateEvent();
        return false;
    } else {
        return QWindow::event(ev);
    }
}

void MetalWindow::initMetal()
{
    if (d->m_metalDevice != nil)
        return;

    d->m_metalDevice = MTLCreateSystemDefaultDevice();
    if (!d->m_metalDevice)
        qFatal("Metal is not supported");

    // Load shaders from Qt resources
    QFile shadersFile(":/hellotriangleshaders.metallib");
    shadersFile.open(QIODevice::ReadOnly);
    QByteArray shaders = shadersFile.readAll();
    dispatch_data_t data = dispatch_data_create(shaders.constData(), shaders.size(),
                           dispatch_get_main_queue(), DISPATCH_DATA_DESTRUCTOR_DEFAULT);

    NSError *error = nil;
    id <MTLLibrary> library = [d->m_metalDevice newLibraryWithData:data error:&error];
    dispatch_release(data);
    if (error)
        qWarning() << "Shader Error" << error;

    // Extract NSView and Metal layer via winId()
    CAMetalLayer *metalLayer = reinterpret_cast<CAMetalLayer *>(reinterpret_cast<NSView *>(winId()).layer);

    // Create Renderer
    metalLayer.device = d->m_metalDevice;
    d->m_renderer = [[AAPLRenderer alloc] initWithMetalLayer:metalLayer library:library];
}

