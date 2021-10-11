
#import "LifeView.h"
#import "NSColor+Extras.h"

@interface LifeView() {
    @private
    int *_cells;
    int _width;
    int _height;
    BOOL _isRunning;
    BOOL _isDirty;
    BOOL _liveLiveRules[5];
    BOOL _liveDeadRules[5];

}
@end

@implementation LifeView

- (instancetype)init; { return (self = [super init]) ? [self commonInit] : nil; }
- (instancetype)initWithCoder:(NSCoder *)coder; { return (self = [super initWithCoder:coder]) ? [self commonInit] : nil; }
- (instancetype)initWithFrame:(NSRect)frameRect; { return (self = [super initWithFrame:frameRect]) ? [self commonInit] : nil; }


- (instancetype)commonInit;
{
    _width = self.bounds.size.width;
    _height = self.bounds.size.height;
    _cells = (int *)calloc(_width * _height, sizeof(int));
    _isRunning = YES;

    _liveLiveRules[0] = NO;
    _liveLiveRules[1] = YES;
    _liveLiveRules[2] = YES;
    _liveLiveRules[3] = NO;
    _liveLiveRules[4] = NO;

    _liveDeadRules[0] = NO;
    _liveDeadRules[1] = NO;
    _liveDeadRules[2] = YES;
    _liveDeadRules[3] = NO;
    _liveDeadRules[4] = NO;

    self.scaleMultiplier = 1;
    self.frameDelay = 1.f / 60.f;
    self.randomCeiling = 3;
    [self randomizeCells];
    [self performSelector:@selector(incrementGeneration) withObject:nil afterDelay:0.1];
    return self;
}

- (void)configureIsOn:(BOOL)isOn forLiveRuleAtIndex:(NSUInteger)index;
{
    _liveLiveRules[index] = isOn;
}

- (void)configureIsOn:(BOOL)isOn forDeadRuleAtIndex:(NSUInteger)index;
{
    _liveDeadRules[index] = isOn;
}

- (void)reconfigureCellArray;
{
    _isDirty = YES;
    _width = self.bounds.size.width / self.scaleMultiplier;
    _height = self.bounds.size.height / self.scaleMultiplier;
    free(_cells);
    _cells = (int *)calloc(_width * _height, sizeof(int));
    [self randomizeCells];
}

- (void)randomizeCells;
{
    int ceiling = (int)self.randomCeiling;
    for (int i = 0; i < (_width * _height); i++) {
        _cells[i] = (arc4random_uniform((uint32_t)(ceiling)) == 0) ? 1 : 0;
    }
}

- (void)rightMouseDown:(NSEvent *)event;
{
    _isRunning = !_isRunning;
    [self incrementGeneration];
}

- (void)mouseDown:(NSEvent *)event;
{
    [self randomizeCells];
    [self incrementGeneration];
}

- (void)incrementGeneration;
{
    if (_isDirty) {
        _isDirty = NO;
        if (_isRunning) {
            [self performSelector:@selector(incrementGeneration) withObject:nil afterDelay:self.frameDelay];
        }
        return;
    }

    int *nextGen = (int *)calloc(_width * _height, sizeof(int));

    // create new generation based on the rules
    int lastX = _width - 1, lastY = _height - 1;
    for (int y = 0; y < _height; y++) {
        int prevY = ((y == 0)     ?  lastY : -1) * _width;
        int nextY = ((y == lastY) ? -lastY :  1) * _width;
        int yOffset = y * _width;

        for (int x = 0; x < _width; x++) {
            int index = x + yOffset;
            int prevX = (x == 0)     ?  lastX : -1;
            int nextX = (x == lastX) ? -lastX :  1;

            NSUInteger neighborCount =
            (_cells[index + prevX + prevY]) + (_cells[index + prevY]) + (_cells[index + nextX + prevY]) +
            (_cells[index + prevX        ]) +                           (_cells[index + nextX        ]) +
            (_cells[index + prevX + nextY]) + (_cells[index + nextY]) + (_cells[index + nextX + nextY]);
            
            int cellIsAlive = _cells[index];
            int cellShouldLive = 0;

            if (cellIsAlive && (
                (_liveLiveRules[0] && neighborCount == 1) ||
                (_liveLiveRules[1] && neighborCount == 2) ||
                (_liveLiveRules[2] && neighborCount == 3) ||
                (_liveLiveRules[3] && neighborCount == 4) ||
                (_liveLiveRules[4] && neighborCount == 5))) {
                cellShouldLive = 1;
            } else if (
                (_liveDeadRules[0] && neighborCount == 1) ||
                (_liveDeadRules[1] && neighborCount == 2) ||
                (_liveDeadRules[2] && neighborCount == 3) ||
                (_liveDeadRules[3] && neighborCount == 4) ||
                (_liveDeadRules[4] && neighborCount == 5)) {
                cellShouldLive = 1;
            }

            nextGen[index] = cellShouldLive;
        }
    }

    memcpy(_cells, nextGen, sizeof(int) * _width * _height);
    free(nextGen);
    [self assignCellsToLayer];
    if (_isRunning) {
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
