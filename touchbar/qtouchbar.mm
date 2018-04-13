#include "qtouchbar.h"

#include <QtGui/QtGui>

@implementation QTouchBarDelegate {
//    DeleteComplainer complainer;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    // We want to forward all non touch bar calls to the Qt delegate. Respond to
    // selectors it responds to in addition to selectors this instance resonds to.
    return [_qtDelegate respondsToSelector:aSelector] || [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // Forward to the Qt delegate. This function is only called for selectors
    // this instance does not respond to, which means that the qt delegate
    // must respond to it (due to the respondsToSelector implementation above).
    [anInvocation invokeWithTarget:_qtDelegate];
}

- (void)installAsDelegateForWindow:(NSWindow *)window
{
    _qtDelegate = window.delegate;
    window.delegate = self;
}

- (void)installAsDelegateForView:(NSView *)view
{
    Q_UNUSED(view)
    // ### ??? !!!

//    _qtDelegate = view.delegate;
//    view.delegate = self;
}

- (void)uninstallDelegate
{
    if (!self.target)
        return;

    id delegate = [self.target valueForKey:@"delegate"];

    // Check that the target delegagte is still this delegate
    if (delegate != self) {
        qWarning("Target delegate is not self; cannot uninstall.");
        return;
    }

    // Restore the Qt delegate
    [self.target setValue:self.qtDelegate forKey:@"delegate"];
}

- (void)invalidateTouchBar
{
    if (!self.target)
        return;

    [self.target setValue:nil forKey:@"touchBar"]; // ### check property name
}

- (void)installAsDelegateForApplication:(NSApplication *)application
{
    _qtDelegate = application.delegate;
    application.delegate = self;
}

- (void)attachToApplication
{
    [self installAsDelegateForApplication:[NSApplication sharedApplication]];
}

- (void)attachToWindow:(QWindow *)window
{
    NSView *view = (__bridge NSView *)reinterpret_cast<void *>(window->winId()); // ARC-allowed cast
    [self installAsDelegateForWindow:view.window]; // ### attach to view
}

- (void)clearAttachment
{
    [self uninstallDelegate];
}

@end
