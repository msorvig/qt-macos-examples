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

class NativeDialogWidget : public QWidget
{
public:
    NativeDialogWidget() {
        QVBoxLayout *layout = new QVBoxLayout();
        setLayout(layout);
        layout->addWidget(new QLabel("Click to open file dialog"));
    }
    
    void mouseReleaseEvent(QMouseEvent *event) override
    {
        NSOpenPanel* openPanel = [NSOpenPanel openPanel];
        auto status = [openPanel runModal];
        if (status == NSModalResponseOK) {
            qDebug() << "dialog accepted";
            NSArray* urls = [openPanel URLs];
            for (NSUInteger i = 0; i < [urls count]; i++) {
                QUrl fileUrl = QUrl::fromNSURL([urls objectAtIndex:i]);
                qDebug() << "selected file" << fileUrl.toLocalFile();
            }
        } else {
            qDebug() << "dialog rejected";
        }
    }
};

int main(int argc, char **argv)
{
    QApplication app(argc, argv);

    std::unique_ptr<QWidget> rootWidget;

    // Initialize application code after app.exex() has initialized the native platform.
    QTimer::singleShot(0, [&]() {
        rootWidget.reset(new NativeDialogWidget());
        rootWidget->resize(640, 480);
        rootWidget->show();
    });

    return app.exec();
}

