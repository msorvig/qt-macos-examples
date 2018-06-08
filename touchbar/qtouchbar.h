// QTouchBarDelegate supports using touch bars with Qt applications.
//
// Create a subclass of QTouchBarDelegate to define touch bar content.
// This is done by implementing two methods:
//   - NSTouchBar *)makeTouchBar
//   - (NSTouchBarItem *)touchBar:(NSTouchBar *) makeItemForIdentifier:(NSTouchBarItemIdentifier)
//
// The QTouchBarDelegate itself implements the NSApplicationDelegate and NSWindowDelegate
// protocols and  can be installed as a delegate on the application or on a top-level QWindow
// object. QTouchBarDelegate will retain a reference to any current delegate on installation and
// forward non touchbar invocations to this delegate.
//
// Call attatchToApplication() to set a global touch bar for the application.
// Call attachToWindow() to set a touch bar for a (top-level) QWindow.
//
#import <AppKit/AppKit.h>
#import <QtGui/QtGui>

@interface QTouchBarDelegate: NSResponder <NSApplicationDelegate, NSWindowDelegate>

@property (strong) NSObject *qtDelegate;
@property (weak) NSObject *target;

- (void)attachToApplication;
- (void)attachToWindow:(QWindow *)window;

@end
