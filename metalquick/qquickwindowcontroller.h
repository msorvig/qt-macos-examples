/****************************************************************************
**
** Copyright (C) 2019 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the QtWebView module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QQUICKWINDOWCONTROLLER_H
#define QQUICKWINDOWCONTROLLER_H

// Note: this is QQuickViewController from the QWebView module, ported
// to work directly on a QWindow instead of the QNativeViewController
// abstraction which QWebView uses. The class should ideally be upstreamed
// to the qtdeclartive module so that both QWebView and the Metal QWindow
// integration can use it.

#include <QtQuick/QQuickItem>

QT_BEGIN_NAMESPACE

class QWindow;
class QQuickWindowControllerChangeListener;
class QQuickWindowController : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QWindow *controlledWindow READ controlledWindow WRITE setControlledWindow NOTIFY controlledWindowChanged);
public:
    QQuickWindowController(QQuickItem *parent = 0);
    ~QQuickWindowController();
    
    void setControlledWindow(QWindow *window);
    QWindow *controlledWindow() const;

Q_SIGNALS:
    void controlledWindowChanged(QWindow *window);

protected Q_SLOTS:
    void onWindowChanged(QQuickWindow* window);
    void onVisibleChanged();

protected:
    void componentComplete() Q_DECL_OVERRIDE;
    void updatePolish() Q_DECL_OVERRIDE;
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) Q_DECL_OVERRIDE;

private:
    QWindow *m_controlledWindow;
    QScopedPointer<QQuickWindowControllerChangeListener> m_changeListener;

private Q_SLOTS:
    void scheduleUpdatePolish();
    void onSceneGraphInvalidated();
};

QT_END_NAMESPACE

#endif // QTWINDOWCONTROLLERITEM_H
