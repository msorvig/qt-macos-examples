/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which perfoms Metal setup and per frame rendering
*/
@import simd;
@import MetalKit;

#include <QtCore>

#import "AAPLRenderer.h"

// Header shared between C code here, which executes Metal API commands, and .metal files, which
//   uses these types as inpute to the shaders
#import "AAPLShaderTypes.h"

// Main class performing the rendering
@implementation AAPLRenderer
{
    // The device (aka GPU) we're using to render
    id <MTLDevice> _device;

    // Our render pipeline composed of our vertex and fragment shaders in the .metal shader file
    id<MTLRenderPipelineState> _pipelineState;

    // The command Queue from which we'll obtain command buffers
    id <MTLCommandQueue> _commandQueue;

    CAMetalLayer * _metalLayer;
}

- (nonnull instancetype)initWithMetalLayer:(nonnull CAMetalLayer *)metalLayer library:(nonnull id<MTLLibrary>)library
{
    self = [super init];
    if(self)
    {
        NSError *error = NULL;
        
        _metalLayer = metalLayer;
        
        _device = _metalLayer.device;

        // Indicate we would like to use the RGBAPisle format.
        _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;

        // Modification for Qt: use library loaded at runtime
        //id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLLibrary> defaultLibrary = library;

        // Load the vertex function from the library
        id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];

        // Load the fragment function from the library
        id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];

        // Set up a descriptor for creating a pipeline state object
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Simple Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = _metalLayer.pixelFormat;

        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                 error:&error];
        if (!_pipelineState)
        {
            // Pipeline State creation could fail if we haven't properly set up our pipeline descriptor.
            //  If the Metal API validation is enabled, we can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            NSLog(@"Failed to created pipeline state, error %@", error);
            return nil;
        }

        // Create the command queue
        _commandQueue = [_device newCommandQueue];
    }

    return self;
}
/// Called whenever the view needs to render a frame
- (void)drawFrame
{
    static const AAPLVertex triangleVertices[] =
    {
        // 2D Positions,    RGBA colors
        { {  250,  -250 }, { 1, 0, 0, 1 } },
        { { -250,  -250 }, { 0, 1, 0, 1 } },
        { {    0,   250 }, { 0, 0, 1, 1 } },
    };

    // Create a new command buffer for each renderpass to the current drawable
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    @autoreleasepool { // Make sure the CAMetalDrawable is released immediately, as per docs

    // Obtain a renderPassDescriptor generated from the view's drawable textures
    id<CAMetalDrawable> drawable = [_metalLayer nextDrawable];
    if (drawable == nil)
        return;
    
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    // Create a render command encoder so we can render into something
    id <MTLRenderCommandEncoder> renderEncoder =
    [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    renderEncoder.label = @"MyRenderEncoder";

    // Set the region of the drawable to which we'll draw.
    [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _metalLayer.drawableSize.width, _metalLayer.drawableSize.height, -1.0, 1.0 }];

    [renderEncoder setRenderPipelineState:_pipelineState];

    // We call -[MTLRenderCommandEncoder setVertexBytes:lenght:atIndex:] tp send data from our
    //   Application ObjC code here to our Metal 'vertexShader' function
    // This call has 3 arguments
    //   1) A pointer to the memory we want to pass to our shader
    //   2) The memory size of the data we want passed down
    //   3) An integer index which corresponds to the index of the buffer attribute qualifier
    //      of the argument in our 'vertexShader' function

    // Here we're sending a pointer to our 'triangleVertices' array (and indicating its size).
    //   The AAPLVertexInputIndexVertices enum value corresponds to the 'vertexArray' argument
    //   in our 'vertexShader' function because its buffer attribute qualifier also uses
    //   AAPLVertexInputIndexVertices for its index
    [renderEncoder setVertexBytes:triangleVertices
                           length:sizeof(triangleVertices)
                          atIndex:AAPLVertexInputIndexVertices];

    // Here we're sending a pointer to '_viewportSize' and also indicate its size so the whole
    //   think is passed into the shader.  The AAPLVertexInputIndexViewportSize enum value
    ///  corresponds to the 'viewportSizePointer' argument in our 'vertexShader' function
    //   because its buffer attribute qualifier also uses AAPLVertexInputIndexViewportSize
    //   for its index
    
    vector_uint2 viewportSize = { (unsigned int)(_metalLayer.bounds.size.width),
                                  (unsigned int)(_metalLayer.bounds.size.height) };
    [renderEncoder setVertexBytes:&viewportSize
                           length:sizeof(viewportSize)
                          atIndex:AAPLVertexInputIndexViewportSize];

    // Draw the 3 vertices of our triangle
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                      vertexStart:0
                      vertexCount:3];

    [renderEncoder endEncoding];

    // Schedule a present once the framebuffer is complete using the current drawable
    [commandBuffer presentDrawable:drawable];

    // Finalize rendering here & push the command buffer to the GPU
    [commandBuffer commit];
    
    } // autoreleasepool
}

@end
