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

class TopWindow : public QWindow
{
public:
    TopWindow()
    {
        // Create the native effects view
        NSVisualEffectView *effectsView = [[NSVisualEffectView alloc] init];
        effectsView.blendingMode = NSVisualEffectBlendingModeBehindWindow;

        // Wrap effects view in a QWindow which will be used to control it
        m_effectsWindow = QWindow::fromWinId(reinterpret_cast<WId>(effectsView));

        // Add the effects window as a child QWindow.
        m_effectsWindow->setParent(this);
        m_effectsWidth = 150;
        m_effectsWindow->setGeometry(0, 0, m_effectsWidth, this->geometry().height());
        m_effectsWindow->show();
    }

    void resizeEvent(QResizeEvent *ev)
    {
        // Keep effects window geometry in sync on resize.
        m_effectsWindow->setGeometry(0, 0, m_effectsWidth, ev->size().height());
    }

private:
    int m_effectsWidth;
    QWindow *m_effectsWindow;
};

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    TopWindow window;
    window.setTitle("NSVisualEffectView");
    window.resize(300, 300);
    window.show();

    return app.exec();
}
