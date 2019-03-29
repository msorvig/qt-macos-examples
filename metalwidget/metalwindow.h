#ifndef METALWINDOW_H
#define METALWINDOW_H

#include <QWindow>
#include <memory>

class MetalWindowPrivate;
class MetalWindow : public QWindow
{
public:
    MetalWindow();
    ~MetalWindow();
    void exposeEvent(QExposeEvent *) override;
    void updateEvent();
    bool event(QEvent *ev) override;
    void initMetal();
private:
    MetalWindowPrivate *d;
};

#endif
