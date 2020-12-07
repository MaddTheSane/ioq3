#import <Cocoa/Cocoa.h>

@interface ErrorWindow : NSObject
@property (assign) IBOutlet NSWindow	*errorWindow;
@property (assign) IBOutlet NSTextView	*errorTextField;

- (void)bitch:(NSString *)errorlog;

@end
