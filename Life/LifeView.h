
#import <Cocoa/Cocoa.h>

@interface LifeView : NSView

@property (nonatomic) NSTimeInterval frameDelay;
@property (nonatomic) NSUInteger randomCeiling;

- (IBAction)frameDelaySlider:(id)sender;
- (IBAction)randomCeilingSlider:(id)sender;

@end
