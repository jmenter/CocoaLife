
#import "LifeViewController.h"
#import "LifeView.h"

@interface LifeViewController ()
@property (weak) IBOutlet LifeView *lifeView;
@end

@implementation LifeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(windowDidEndLiveResize) name:NSWindowDidEndLiveResizeNotification object:nil];
}

- (IBAction)checkWasClicked:(NSButton *)sender;
{
    if (sender.tag > 5) {
        [self.lifeView configureIsOn:sender.state forDeadRuleAtIndex:sender.tag - 6];
    } else {
        [self.lifeView configureIsOn:sender.state forLiveRuleAtIndex:sender.tag - 1];
    }
}

- (void)windowDidEndLiveResize;
{
    [self.lifeView reconfigureCellArray];
}

- (IBAction)randomOffsetChanged:(id)sender;
{
    self.lifeView.randomCeiling = [sender maxValue] - [sender integerValue] + 2;
    [self.lifeView reconfigureCellArray];
}

- (IBAction)frameDelaySliderChanged:(id)sender;
{
    self.lifeView.frameDelay = 1.f / [sender doubleValue];
}

- (IBAction)scalingMultiplierChanged:(id)sender;
{
    NSUInteger senderValue = [sender integerValue];
    self.lifeView.scaleMultiplier = senderValue == 1 ? 1 : senderValue == 2 ? 2 : senderValue == 3 ? 4 : senderValue == 4 ? 8 : 16;
    NSUInteger titleBarHeight = 22;
    NSUInteger multiplier = self.lifeView.scaleMultiplier;
    NSUInteger quantizedWidth = (int)(self.lifeView.bounds.size.width / multiplier) * multiplier;
    NSUInteger quantizedHeight = (int)(self.lifeView.bounds.size.height / multiplier) * multiplier;
    NSRect windowRect = NSApplication.sharedApplication.mainWindow.frame;
    windowRect.size = NSMakeSize(quantizedWidth, quantizedHeight + titleBarHeight);
    [NSApplication.sharedApplication.mainWindow setFrame:windowRect display:YES];
    NSApplication.sharedApplication.mainWindow.resizeIncrements = NSMakeSize(multiplier, multiplier);
    [self windowDidEndLiveResize];

    [self configureWindowTitle];
}

- (void)configureWindowTitle;
{
    NSApplication.sharedApplication.mainWindow.title = [NSString stringWithFormat:@"Life @ %i× (%i × %i)", (int)self.lifeView.scaleMultiplier, (int)self.lifeView.frame.size.width, (int)self.lifeView.frame.size.height];
}
- (void)viewDidLayout;
{
    [self configureWindowTitle];
}

@end
