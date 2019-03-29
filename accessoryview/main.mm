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

// An NSTitlebarAccessoryViewController that controls a programatically created view
@interface ProgramaticViewController : NSTitlebarAccessoryViewController
@end

@implementation ProgramaticViewController
- (id)initWithView: (NSView *)aView
{
    self = [self init];
    self.view = aView;
    return self;
}
@end

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    // Create and configure native window
    NSRect frame = NSMakeRect(200, 200, 640, 300);
    NSWindow *window =
        [[NSWindow alloc] initWithContentRect:frame
                                     styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                                               NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                       backing:NSBackingStoreBuffered
                                         defer:NO];
    window.contentMinSize = NSMakeSize(640, 200);

    // Add toolbar and enable the "streamlined toolbar" look by hiding the title text.
    // An empty toolbar still adds vertical space which the accessory views will use.
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"main"];
    window.toolbar = toolbar;
    window.titleVisibility = NSWindowTitleHidden;

    // Add title bar left (blue) and right (green) Qt content
    std::unique_ptr<CheckeredWindow> checkeredWindowLeft;
    std::unique_ptr<CheckeredWindow> checkeredWindowRight;

    // Left content
    {
        checkeredWindowLeft.reset(new CheckeredWindow());
        checkeredWindowLeft->resize(200, 1); // set width; NSWindow controls the height

        NSView *view = (__bridge NSView *)reinterpret_cast<void *>(checkeredWindowLeft->winId());
        ProgramaticViewController *viewController = [[ProgramaticViewController alloc] initWithView:view];
        viewController.layoutAttribute = NSLayoutAttributeLeft;
        [window addTitlebarAccessoryViewController:viewController];
        checkeredWindowLeft->show();
    }

    // Right content
    {
        checkeredWindowRight.reset(new CheckeredWindow());
        checkeredWindowRight->resize(250, 1);
        checkeredWindowRight->setDrawAlpha(85);
        checkeredWindowRight->setColor(QColor(20, 150, 20));

        NSView *view = (__bridge NSView *)reinterpret_cast<void *>(checkeredWindowRight->winId());
        ProgramaticViewController *viewController = [[ProgramaticViewController alloc] initWithView:view];
        viewController.layoutAttribute = NSLayoutAttributeRight;
        [window addTitlebarAccessoryViewController:viewController];
        checkeredWindowRight->show();
    }

    // Example description
    QString description =
        "This example shows how to embed Qt application content\n"\
        "in the window title bar area. The blue and green areas are\n"\
        "QWindow instances added to the native window as accessory views.";
    std::unique_ptr<QWindow> messageWindow(new MessageWindow(description));
    window.contentView = (__bridge NSView *)reinterpret_cast<void *>(messageWindow->winId());
    messageWindow->show();

    // Show the native window
    [window makeKeyAndOrderFront:nil];
    return app.exec();
}

