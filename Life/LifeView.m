
#import "LifeView.h"

static const NSUInteger kWidth  = 400;
static const NSUInteger kHeight = 400;

@interface LifeView() {
    BOOL _cells[kWidth][kHeight];
}

@property (nonatomic) BOOL isRunning;
@end

@implementation LifeView

- (instancetype)init; { return (self = [super init]) ? [self commonInit] : nil; }
- (instancetype)initWithCoder:(NSCoder *)coder; { return (self = [super initWithCoder:coder]) ? [self commonInit] : nil; }
- (instancetype)initWithFrame:(NSRect)frameRect; { return (self = [super initWithFrame:frameRect]) ? [self commonInit] : nil; }

- (instancetype)commonInit;
{
    self.wantsLayer = YES;
    self.layer.backgroundColor = NSColor.blackColor.CGColor;
    self.isRunning = YES;
    self.frameDelay = 1.f / 60.f;
    self.randomCeiling = 3;
    [self randomizeCells];
    [self performSelector:@selector(incrementGeneration) withObject:nil afterDelay:0.1];
    return self;
}

- (void)randomizeCells;
{
    for (int y = 0; y < kHeight; y++) {
        for (int x = 0; x < kWidth; x++) {
            if (arc4random_uniform( (uint32_t)(self.randomCeiling)) == 0) {
                _cells[x][y] = YES;
            } else {
                _cells[x][y] = NO;
            }
        }
    }
}
- (void)rightMouseDown:(NSEvent *)event;
{
    self.isRunning = !self.isRunning;
    [self incrementGeneration];
}
- (void)mouseDown:(NSEvent *)event;
{
    [self randomizeCells];
    [self incrementGeneration];
}

- (void)incrementGeneration;
{
    BOOL nextGen[kWidth][kHeight];

    // create new generation based on the rules
    int lastX = kWidth - 1, lastY = kHeight - 1;
    for (int y = 0; y < kHeight; y++) {
        int prevY = (y == 0)     ?  lastY : -1;
        int nextY = (y == lastY) ? -lastY :  1;
        
        for (int x = 0; x < kWidth; x++) {
            
            int prevX = (x == 0)     ?  lastX : -1;
            int nextX = (x == lastX) ? -lastX :  1;
            
            NSUInteger neighborCount =
            (int)(_cells[x + prevX][y + prevY]) + (int)(_cells[x][y + prevY]) + (int)(_cells[x + nextX][y + prevY]) +
            (int)(_cells[x + prevX][y        ]) +                               (int)(_cells[x + nextX][y        ]) +
            (int)(_cells[x + prevX][y + nextY]) + (int)(_cells[x][y + nextY]) + (int)(_cells[x + nextX][y + nextY]);
            
            BOOL cellIsAlive = _cells[x][y];
            BOOL shouldLiveForLive = (neighborCount == 2 || neighborCount == 3);
            BOOL shouleLiveForDead = (neighborCount == 3);
            
            nextGen[x][y] = cellIsAlive ? shouldLiveForLive : shouleLiveForDead;
        }
    }
    memcpy(_cells, nextGen, sizeof(nextGen));
    [self assignCellsToLayer];
    if (self.isRunning) {
        [self performSelector:@selector(incrementGeneration) withObject:nil afterDelay:self.frameDelay];
    }
}

- (void)assignCellsToLayer;
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipFirst;
    CGContextRef imageContext = CGBitmapContextCreate(nil, kWidth, kHeight, 8, kWidth * 4, colorSpace, bitmapInfo);
    CFRelease(colorSpace);
    //            A         R             G               B
    UInt32 on  = 0xFF | (0xFF << 8) | (0xFF << 16) | (0xFF << 24);
    UInt32 off = 0xFF | (0x00 << 8) | (0x00 << 16) | (0x00 << 24);
    UInt32 *imagePixelData = CGBitmapContextGetData(imageContext);
    for (int y = 0; y < kHeight; y++) {
        int yOffset = y * kHeight;
        for (int x = 0; x < kWidth; x++) {
            imagePixelData[x + yOffset] = _cells[x][y] ? on : off;
        }
    }
    CGImageRef imageRef = CGBitmapContextCreateImage(imageContext);
    CGContextRelease(imageContext);
    self.layer.minificationFilter = kCAFilterNearest;
    self.layer.magnificationFilter = kCAFilterNearest;
    self.layer.contents = (__bridge id)imageRef;
    CGImageRelease(imageRef);
}

@end
