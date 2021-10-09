
@import Cocoa;

@interface LifeView : NSView

@property (nonatomic) NSTimeInterval frameDelay;
@property (nonatomic) NSUInteger randomCeiling;
@property (nonatomic) NSUInteger scaleMultiplier;

- (void)reconfigureCellArray;

- (void)configureon:(BOOL)on forRuleAtIndex:(NSUInteger)index;

@end
