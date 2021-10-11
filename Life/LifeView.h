
@import Cocoa;

@interface LifeView : NSView

@property (nonatomic) NSTimeInterval frameDelay;
@property (nonatomic) NSUInteger randomCeiling;
@property (nonatomic) NSUInteger scaleMultiplier;

- (void)reconfigureCellArray;

- (void)configureIsOn:(BOOL)isOn forLiveRuleAtIndex:(NSUInteger)index;
- (void)configureIsOn:(BOOL)isOn forDeadRuleAtIndex:(NSUInteger)index;

@end
