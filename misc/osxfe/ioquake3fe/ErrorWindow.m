#import "ErrorWindow.h"

@implementation ErrorWindow
@synthesize errorWindow;
@synthesize errorTextField;

- (void)bitch:(NSString *)errorlog {
	NSLog(@"%@", errorlog);

	NSNib *nib = [[NSNib alloc] initWithNibNamed:@"ErrorWindow" bundle:[NSBundle mainBundle]];
	[nib instantiateWithOwner:self topLevelObjects:nil];
	
	[errorWindow makeKeyWindow];
	[errorTextField setFont:[NSFont userFixedPitchFontOfSize:12.0]];
	[errorTextField setString:@""];
	[[errorTextField textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:errorlog]];
    [errorTextField scrollRangeToVisible:NSMakeRange([[errorTextField string] length], 0)];
}

@end
