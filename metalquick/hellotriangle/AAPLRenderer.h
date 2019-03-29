/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for renderer class which perfoms Metal setup and per frame rendering
*/

@import MetalKit;

// Our platform independent render class
@interface AAPLRenderer : NSObject

- (nonnull instancetype)initWithMetalLayer:(nonnull CAMetalLayer *)mtkLayer library:(nonnull id<MTLLibrary>)library;
- (void)drawFrame;

@end
