Qt for macOS Examples
=====================

This repository contains Qt usage examples that are spesific
to Qt for macOS. This includes exmples for working with native
window types, the MacBook Pro Touch bar, and the Metal graphcis API.

The target Qt branch for the examples contained here is the "5.15"
branch. The examples may use features or rely on bugfixes which
are not present in the released version of Qt.

Native Window Types and Configurations
--------------------------------------
Macos provides several native window types and window configurations
which do not have a corresponding cross-platform API in Qt. The following
examples shows how to create and configure such native windows and
then embed Qt-based application content.

    accessoryview/           Application content in the title bar area.
    fullsizecontentview/     Full-window application content with overlaid window controls
    hudwindow/               Windows with the 'HUD' look
    popover/                 Popover popup/context menus
    visualeffects/           Native blur effect

MacBook Pro Touch Bar
---------------------
This example shows how to populate the MacBook Pro touch bar from
a Qt-based applicaiton.

Normally this is done by creating an NSTouchBarDelegate, and then
implementing the NSTouchBarProvider protocol on for example the
NApplication delegate or NSWindow delegate.

For Qt applcations this becomes a problem since the the application
and window delegates are owned by Qt and are private implementation
objects.

The example shows how the application can install its delegate,
and then forward non-touchbar related messages to the Qt delegate.

    touchbar/                A simple touch bar example

Metal
-----
Two examples demonstrate how to integrate Metal rendering with Qt:

    metalview/                MTKView controlled by QWindow
    metalwindow/              QWindow subclass with QSurface::MetalSurface
    metalwidget/              QWidget::createWindowContainer() with Metal QWindow
    metalquick/               Metal window overlaid on Qt Quick content

In the metalview example, QWindow::fromWinId() is used to "wrap"
and control a native MKMetalView.

In the metalwindow example, a QWindow subclass is configured
to have Metal backing layer.
