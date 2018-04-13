/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for renderer class which perfoms Metal setup and per frame rendering
*/

@import MetalKit;

// Our platform independent render class
@interface AAPLRenderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView library:(nonnull id<MTLLibrary>)library;

@end
