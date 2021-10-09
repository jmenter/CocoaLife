
#import "NSImage+Extras.h"

@implementation NSImage (Extras)

static const CGFloat kGridSize = 4.f;
static const CGFloat kGridWhite = 0.75;

+ (NSImage *)checkerboard;
{
    return [self checkerboardWithGridSize:CGSizeMake(kGridSize, kGridSize)];
}

+ (NSImage *)checkerboardWithGridSize:(CGSize)gridSize;
{
    CGSize actualSize = CGSizeMake(gridSize.width * 2, gridSize.height * 2);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(NULL, actualSize.width, actualSize.height, 8, actualSize.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    CGContextSetFillColorWithColor(imageContext, NSColor.whiteColor.CGColor);
    CGContextFillRect(imageContext, CGRectMake(0, 0, actualSize.width, actualSize.height));

    CGContextSetFillColorWithColor(imageContext, [NSColor colorWithWhite:kGridWhite alpha:1].CGColor);
    CGContextFillRect(imageContext, CGRectMake(0, 0, gridSize.width, gridSize.height));
    CGContextFillRect(imageContext, CGRectMake(gridSize.width, gridSize.height, gridSize.width, gridSize.height));

    CGImageRef cgImage = CGBitmapContextCreateImage(imageContext);
    CGContextRelease(imageContext);
    
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:actualSize];
    CGImageRelease(cgImage);
    return image;
}

@end
