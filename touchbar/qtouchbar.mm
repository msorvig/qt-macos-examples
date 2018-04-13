#include "qtouchbar.h"

#include <QtGui/QtGui>

@implementation QTouchBarDelegate {

}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    // We want to handle touch bar related calls in this delegate, and forward 
    // all non touch bar calls to the Qt delegate. Claim that we respond to the
    // Qt delegate's selectors as well.
    return [super respondsToSelector:aSelector] || [_qtDelegate respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // Forward to the Qt delegate. This function is only called for selectors
    // this instance does actually not respond to (despite what we claimed above).
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
