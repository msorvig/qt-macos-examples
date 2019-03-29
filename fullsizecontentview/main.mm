/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#import <AppKit/AppKit.h>
#include <QtGui>
#include <qtcontent.h>

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    // Create and configure a native window. Specify the NSWindowStyleMaskFullSizeContentView
    // flag to make its content view cover the entire window area.
    NSRect frame = NSMakeRect(200, 200, 320, 200);
    NSWindow *window =
        [[NSWindow alloc] initWithContentRect:frame
                                    styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                                              NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable |
                                              NSWindowStyleMaskFullSizeContentView
                                      backing:NSBackingStoreBuffered
                                        defer:NO];

    // Hide the title bar
    window.titlebarAppearsTransparent = YES;
    window.movableByWindowBackground = YES;
    
    // Create Qt content window, get its native view, and
    // set it as the content view for the window.
    std::unique_ptr<QWindow> checkeredWindow(new CheckeredWindow());
    NSView *checkeredView =  (__bridge NSView *)reinterpret_cast<void *>(checkeredWindow->winId());
    window.contentView = checkeredView;
    checkeredWindow->show();

    // The QWindow content will cover the entire window area,
    // but parts of it will have window controls overlaid.
    // Use NSWidnow API to get the content offset.
    QRectF contentRect = QRectF::fromCGRect(window.contentLayoutRect);
    qreal contentOffset = window.frame.size.height - contentRect.height();
    Q_UNUSED(contentOffset)

    // Show the native window
    [window makeKeyAndOrderFront:nil];

    // Run application; clean up on exit
    int ret = app.exec();
    return ret;
}
