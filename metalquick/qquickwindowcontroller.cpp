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

#include "qquickwindowcontroller.h"

#include <QtGui/QWindow>

#include <QtQuick/qquickrendercontrol.h>
#include <QtQuick/private/qquickitem_p.h>
#include <QtQuick/private/qquickitemchangelistener_p.h>

QT_BEGIN_NAMESPACE

static const QQuickItemPrivate::ChangeTypes changeMask = QQuickItemPrivate::Geometry
                                                         | QQuickItemPrivate::Children
                                                         | QQuickItemPrivate::Parent;

class QQuickWindowControllerChangeListener : public QQuickItemChangeListener
{
public:
    explicit QQuickWindowControllerChangeListener(QQuickWindowController *item);
    ~QQuickWindowControllerChangeListener();

    inline void itemGeometryChanged(QQuickItem *,
                                    QQuickGeometryChange,
                                    const QRectF &) Q_DECL_OVERRIDE;
    void itemChildRemoved(QQuickItem *item, QQuickItem *child) Q_DECL_OVERRIDE;
    void itemParentChanged(QQuickItem *item, QQuickItem *parent) Q_DECL_OVERRIDE;

private:
    Q_DISABLE_COPY(QQuickWindowControllerChangeListener)
    QQuickWindowController *m_item;
    void addAncestorListeners(QQuickItem *item, QQuickItemPrivate::ChangeTypes changeType);
    void removeAncestorListeners(QQuickItem *item, QQuickItemPrivate::ChangeTypes changeType);
    bool isAncestor(QQuickItem *item);
};

QQuickWindowControllerChangeListener::QQuickWindowControllerChangeListener(QQuickWindowController *item)
    : m_item(item)
{
    // Only listen for parent changes on the window controller item.
    QQuickItemPrivate::get(item)->addItemChangeListener(this, QQuickItemPrivate::Parent);
    // Listen to all changes, that are relevant, on all ancestors.
    addAncestorListeners(item->parentItem(), changeMask);
}

QQuickWindowControllerChangeListener::~QQuickWindowControllerChangeListener()
{
    if (m_item == 0)
        return;

    QQuickItemPrivate::get(m_item)->removeItemChangeListener(this, QQuickItemPrivate::Parent);
    removeAncestorListeners(m_item->parentItem(), changeMask);
}

void QQuickWindowControllerChangeListener::itemGeometryChanged(QQuickItem *, QQuickGeometryChange, const QRectF &)
{
    m_item->polish();
}

void QQuickWindowControllerChangeListener::itemChildRemoved(QQuickItem *item, QQuickItem *child)
{
    Q_UNUSED(item)
    Q_ASSERT(item != m_item);

    const bool remove = (child == m_item) || isAncestor(child);

    // if the child isn't the wwindow item or its ancestor, then we don't care.
    if (!remove)
        return;

    // Remove any listener we attached to the child and its ancestors.
    removeAncestorListeners(item, changeMask);
}

void QQuickWindowControllerChangeListener::itemParentChanged(QQuickItem *item, QQuickItem *newParent)
{
    removeAncestorListeners(item->parentItem(), changeMask);
    // Adds this as a listener for newParent and its ancestors.
    addAncestorListeners(newParent, changeMask);
}

void QQuickWindowControllerChangeListener::addAncestorListeners(QQuickItem *item,
                                                    QQuickItemPrivate::ChangeTypes changeType)
{
    QQuickItem *p = item;
    while (p != 0) {
        QQuickItemPrivate::get(p)->addItemChangeListener(this, changeType);
        p = p->parentItem();
    }
}

void QQuickWindowControllerChangeListener::removeAncestorListeners(QQuickItem *item,
                                                       QQuickItemPrivate::ChangeTypes changeType)
{
    QQuickItem *p = item;
    while (p != 0) {
        QQuickItemPrivate::get(p)->removeItemChangeListener(this, changeType);
        p = p->parentItem();
    }
}

bool QQuickWindowControllerChangeListener::isAncestor(QQuickItem *item)
{
    Q_ASSERT(m_item != 0);

    if (item == 0)
        return false;

    QQuickItem *p = m_item->parentItem();
    while (p != 0) {
        if (p == item)
            return true;
        p = p->parentItem();
    }

    return false;
}

///
/// \brief QQuickWindowController::QQuickWindowController
/// \param parent
///

QQuickWindowController::QQuickWindowController(QQuickItem *parent)
    : QQuickItem(parent)
    , m_controlledWindow(nullptr)
    , m_changeListener(new QQuickWindowControllerChangeListener(this))
{
    connect(this, &QQuickWindowController::windowChanged, this, &QQuickWindowController::onWindowChanged);
    connect(this, &QQuickWindowController::visibleChanged, this, &QQuickWindowController::onVisibleChanged);
}

QQuickWindowController::~QQuickWindowController()
{
}

void QQuickWindowController::setControlledWindow(QWindow *window)
{
    if (m_controlledWindow == window)
        return;

    m_controlledWindow = window;
    emit controlledWindowChanged(m_controlledWindow);
    
    if (isComponentComplete())
        updatePolish();
}

QWindow *QQuickWindowController::controlledWindow() const
{
    return m_controlledWindow;
}

void QQuickWindowController::componentComplete()
{
   QQuickItem::componentComplete();
   if (m_controlledWindow == nullptr)
      return;
   
   m_controlledWindow->setVisibility(QWindow::Windowed);
}

void QQuickWindowController::updatePolish()
{
    if (m_controlledWindow == nullptr)
        return;

    QSize itemSize = QSize(width(), height());
    if (!itemSize.isValid())
        return;

    QQuickWindow *w = window();
    if (w == 0)
        return;

    // Find this item's geometry in the scene.
    QRect itemGeometry = mapRectToScene(QRect(QPoint(0, 0), itemSize)).toRect();
    // Check if we should be clipped to our parent's shape
    // Note: This is crude but it should give an acceptable result on all platforms.
    QQuickItem *p = parentItem();
    const bool clip = p != 0 ? p->clip() : false;
    if (clip) {
        const QSize &parentSize = QSize(p->width(), p->height());
        const QRect &parentGeometry = p->mapRectToScene(QRect(QPoint(0, 0), parentSize)).toRect();
        itemGeometry &= parentGeometry;
        itemSize = itemGeometry.size();
    }

    // Find the top left position of this item, in global coordinates.
    const QPoint &tl = w->mapToGlobal(itemGeometry.topLeft());
    // Get the actual render window, in case we're rendering into a off-screen window.
    QWindow *rw = QQuickRenderControl::renderWindowFor(w);

    m_controlledWindow->setGeometry(rw ? QRect(rw->mapFromGlobal(tl), itemSize) : itemGeometry);
    m_controlledWindow->setVisible(isVisible());
}

void QQuickWindowController::scheduleUpdatePolish()
{
    polish();
}

void QQuickWindowController::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
    if (newGeometry.isValid())
        polish();
}

void QQuickWindowController::onWindowChanged(QQuickWindow* window)
{
    QQuickWindow *oldParent = qobject_cast<QQuickWindow *>(m_controlledWindow->parent());
    if (oldParent != 0)
        oldParent->disconnect(this);

    if (window != 0) {
        connect(window, &QQuickWindow::widthChanged, this, &QQuickWindowController::scheduleUpdatePolish);
        connect(window, &QQuickWindow::heightChanged, this, &QQuickWindowController::scheduleUpdatePolish);
        connect(window, &QQuickWindow::xChanged, this, &QQuickWindowController::scheduleUpdatePolish);
        connect(window, &QQuickWindow::yChanged, this, &QQuickWindowController::scheduleUpdatePolish);
        connect(window, &QQuickWindow::sceneGraphInitialized, this, &QQuickWindowController::scheduleUpdatePolish);
        connect(window, &QQuickWindow::sceneGraphInvalidated, this, &QQuickWindowController::onSceneGraphInvalidated);
        connect(window, &QQuickWindow::visibleChanged, this, [this](bool visible) { m_controlledWindow->setVisible(visible); });
    }

    // Check if there's an actual window available.
    if (m_controlledWindow == nullptr)
       return;
    QWindow *rw = QQuickRenderControl::renderWindowFor(window);
    m_controlledWindow->setParent(rw ? rw : window);
}

void QQuickWindowController::onVisibleChanged()
{
    if (m_controlledWindow == nullptr)
       return;
    m_controlledWindow->setVisible(isVisible());
}

void QQuickWindowController::onSceneGraphInvalidated()
{
    if (m_controlledWindow == nullptr)
        return;

    m_controlledWindow->setVisible(false);
}

QT_END_NAMESPACE
