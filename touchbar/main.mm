/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
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
**
****************************************************************************/

#include <QtWidgets/QtWidgets>
#import <AppKit/AppKit.h>

#include "qtouchbar.h"
#include <qtcontent.h>

@interface ExampleTouchBar: QTouchBarDelegate <NSTouchBarDelegate>

@end

@implementation ExampleTouchBar
    
// Create identifiers for two button items.
static NSTouchBarItemIdentifier Button1Identifier = @"com.myapp.Button1Identifier";
static NSTouchBarItemIdentifier Button2Identifier = @"com.myapp.Button2Identifier";
static NSTouchBarItemIdentifier QtItemIdentifier = @"com.myapp.QtItemIdentifier";

- (NSTouchBar *)makeTouchBar
{
    // Create the touch bar with this instance as its delegate
    NSTouchBar *bar = [[NSTouchBar alloc] init];
    bar.delegate = self;

    // Add touch bar items:
    bar.defaultItemIdentifiers = @[
        // The character (emoji) picker. Note that no further handling of the character
        // picker is needed: its character events are automatically routed to any active
        // text edit
        NSTouchBarItemIdentifierCharacterPicker,
        // Two buttons. Button actions handlers are set up in makeItemForIdentifier below.
        Button1Identifier, Button2Identifier,
        // A custom Qt-based touch-bar item
        QtItemIdentifier
    ];

    return bar;
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier
{
    Q_UNUSED(touchBar);

    NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];

    // Create touch bar items as NSCustomTouchBarItems which can contain any NSView.
    if ([identifier isEqualToString:Button1Identifier]) {
        QString title = QLatin1String("Button 1");
        item.view = [NSButton buttonWithTitle:title.toNSString() target:self action:@selector(button1Pressed)];
    } else if ([identifier isEqualToString:Button2Identifier]) {
        QString title = QLatin1String("Button 2");
        item.view = [NSButton buttonWithTitle:title.toNSString() target:self action:@selector(button2Pressed)];
    } else if ([identifier isEqualToString:QtItemIdentifier]) {
        QWindow *window = new CheckeredWindow();
        item.view = (__bridge NSView *)reinterpret_cast<void *>(window->winId());
    } else {
        item = nil;
    }

   return item;
}

- (void)button1Pressed
{
    qDebug() << "Button 1 pressed";
}

- (void)button2Pressed
{
    qDebug() << "Button 2 pressed";
}

@end

int main(int argc, char **argv)
{
    QApplication app(argc, argv);

    std::unique_ptr<QWidget> rootWidget;

    // Initialize application code after app.exex() has initialized
    // the native platform.
    QTimer::singleShot(0, [&]() {

        // Create root widget / window
        rootWidget.reset(new QTextEdit());
        rootWidget->winId(); // Fully create platform window

        ExampleTouchBar *touchbar = [ExampleTouchBar new];
        [touchbar attachToWindow:rootWidget->windowHandle()];

        rootWidget->show();
    });

    return app.exec();
}

