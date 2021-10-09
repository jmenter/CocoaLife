
#import "NSColor+Extras.h"
#import "NSImage+Extras.h"

@implementation NSColor (Extras)

+ (instancetype)transparencyPattern;
{
    return [self.class colorWithPatternImage:NSImage.checkerboard];
}

+ (instancetype)transparencyPatternWithGridSize:(CGSize)gridSize;
{
    return [self.class colorWithPatternImage:[NSImage checkerboardWithGridSize:gridSize]];
}

@end
