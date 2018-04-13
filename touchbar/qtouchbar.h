// QTouchBarDelegate supports using touch bars with Qt applications.
//
// Create a subclass of QTouchBarDelegate to define touch bar content.
// This is done by implementing two methods:
//   - NSTouchBar *)makeTouchBar
//   - (NSTouchBarItem *)touchBar:(NSTouchBar *) makeItemForIdentifier:(NSTouchBarItemIdentifier)
//
// Call attatchToApplication() to set a global touch bar for the application.
// Call attachToWindow() to set a touch bar for a QWindow.
//
#import <AppKit/AppKit.h>
#import <QtGui/QtGui>

@interface QTouchBarDelegate: NSResponder <NSTouchBarDelegate, NSTouchBarProvider, NSApplicationDelegate, NSWindowDelegate>

@property (strong) NSObject *qtDelegate;
@property (weak) NSObject *target;

- (void)attachToApplication;
- (void)attachToWindow:(QWindow *)window;

@end
