
#import "LifeView.h"
#import "NSColor+Extras.h"

@interface LifeView() {
    int *_cells;
    int _width;
    int _height;
}

@property (nonatomic) BOOL isRunning;
@property (nonatomic) BOOL isDirty;

@end

@implementation LifeView

- (instancetype)init; { return (self = [super init]) ? [self commonInit] : nil; }
- (instancetype)initWithCoder:(NSCoder *)coder; { return (self = [super initWithCoder:coder]) ? [self commonInit] : nil; }
- (instancetype)initWithFrame:(NSRect)frameRect; { return (self = [super initWithFrame:frameRect]) ? [self commonInit] : nil; }

- (instancetype)commonInit;
{
    _width = 500;
    _height = 400;

    _cells = (int *)calloc(_width * _height, sizeof(int));

    self.wantsLayer = YES;
//    self.layer.backgroundColor = NSColor.transparencyPattern.CGColor;
    self.scaleMultiplier = 1;
    self.isRunning = YES;
    self.frameDelay = 1.f / 60.f;
    self.randomCeiling = 3;
    [self randomizeCells];
    [self performSelector:@selector(incrementGeneration) withObject:nil afterDelay:0.1];
    return self;
}

- (void)reconfigureCellArray;
{
    NSLog(@"reconfiguring cell array");
    self.isDirty = YES;
    _width = self.bounds.size.width / self.scaleMultiplier;
    _height = self.bounds.size.height / self.scaleMultiplier;
    free(_cells);
    _cells = (int *)calloc(_width * _height, sizeof(int));
    [self randomizeCells];
}

- (void)randomizeCells;
{
    for (int y = 0; y < _height; y++) {
        int yOffset = y * _width;
        for (int x = 0; x < _width; x++) {
            _cells[x + yOffset] = (arc4random_uniform((uint32_t)(self.randomCeiling)) == 0) ? 1 : 0;
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
    if (self.isDirty) {
        NSLog(@"is dirty, skipping");
        self.isDirty = NO;
        if (self.isRunning) {
            [self performSelector:@selector(incrementGeneration) withObject:nil afterDelay:self.frameDelay];
        }
        return;
    }

    int *nextGen = (int *)calloc(_width * _height, sizeof(int));

    // create new generation based on the rules
    int lastX = _width - 1, lastY = _height - 1;
    for (int y = 0; y < _height; y++) {
        int prevY = (y == 0)     ?  lastY : -1;
        int nextY = (y == lastY) ? -lastY :  1;

        int yOffset = y * _width;
        for (int x = 0; x < _width; x++) {
            
            int prevX = (x == 0)     ?  lastX : -1;
            int nextX = (x == lastX) ? -lastX :  1;

            NSUInteger neighborCount =
            (_cells[x + prevX + yOffset + prevY * _width ]) + (_cells[x + yOffset + prevY * _width]) + (_cells[x + nextX + yOffset + prevY * _width]) +
            (_cells[x + prevX + yOffset        ]) +                              (_cells[x + nextX + yOffset        ]) +
            (_cells[x + prevX + yOffset + nextY * _width]) + (_cells[x + yOffset + nextY * _width]) + (_cells[x + nextX + yOffset + nextY * _width]);
            
            int cellIsAlive = _cells[x + yOffset];
            BOOL shouldLiveForLive = (neighborCount == 2 || neighborCount == 3);
            BOOL shouleLiveForDead = (neighborCount == 3);
            
            nextGen[x + yOffset] = cellIsAlive ? (int)shouldLiveForLive : (int)shouleLiveForDead;
        }
    }

    memcpy(_cells, nextGen, sizeof(int) * _width * _height);
    free(nextGen);
    [self assignCellsToLayer];
    if (self.isRunning) {
        [self performSelector:@selector(incrementGeneration) withObject:nil afterDelay:self.frameDelay];
    }
}

- (void)assignCellsToLayer;
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipFirst;
    CGContextRef imageContext = CGBitmapContextCreate(nil, _width, _height, 8, _width * 4, colorSpace, bitmapInfo);
    CFRelease(colorSpace);
    //            A         R             G               B
    UInt32 on  = 0xFF | (0xFF << 8) | (0xFF << 16) | (0xFF << 24);
    UInt32 off = 0xFF | (0x00 << 8) | (0x00 << 16) | (0x00 << 24);
    UInt32 *imagePixelData = CGBitmapContextGetData(imageContext);
    for (int y = 0; y < _height; y++) {
        int yOffset = y * _width;
        for (int x = 0; x < _width; x++) {
            imagePixelData[x + yOffset] = (_cells[x + yOffset] == 1) ? on : off;
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
