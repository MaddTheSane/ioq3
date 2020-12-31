//
//  Controller.m
//  ioquake3fe
//
//  Created by Ben Wilber on 3/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "ErrorWindow.h"

#define IOQ3_BUNDLE @"/Applications/ioquake3/ioquake3.app"
#define IOQ3_UB_BIN @"ioquake3.ub"
#define IOQ3_BIN @"ioquake3"

@implementation Controller
@synthesize argsTextField;

- (id)init {
	if (self = [super init]) {
	quakeData = [[NSMutableData alloc] initWithCapacity:1.0];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readPipe:) name:NSFileHandleReadCompletionNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskNote:) name:NSTaskDidTerminateNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)launch:(id)sender {
	NSString *ioQuake3Path = [[NSBundle mainBundle] pathForAuxiliaryExecutable:IOQ3_UB_BIN];
	if (!ioQuake3Path)
		ioQuake3Path = [[NSBundle mainBundle] pathForAuxiliaryExecutable:IOQ3_BIN];
	if (!ioQuake3Path)
		ioQuake3Path = [[NSBundle bundleWithPath:IOQ3_BUNDLE] pathForAuxiliaryExecutable:IOQ3_UB_BIN];
	if (!ioQuake3Path)
		ioQuake3Path = [[NSBundle bundleWithPath:IOQ3_BUNDLE] pathForAuxiliaryExecutable:IOQ3_BIN];

	if (!ioQuake3Path) {
		NSArray *copyURLArray = CFBridgingRelease(LSCopyApplicationURLsForBundleIdentifier(CFSTR("org.ioquake3.ioquake3"), NULL));
		for (NSURL *aPath in copyURLArray) {
			ioQuake3Path = [[NSBundle bundleWithURL:aPath] pathForAuxiliaryExecutable:IOQ3_UB_BIN];
			if (!ioQuake3Path) {
				ioQuake3Path = [[NSBundle bundleWithURL:aPath] pathForAuxiliaryExecutable:IOQ3_BIN];
			}
			if (ioQuake3Path) {
				break;
			}
		}
	}
	if (!ioQuake3Path) {
		NSBundle *theBundle = [NSBundle bundleWithURL:[NSURL fileURLWithPath:@"ioquake3.app"]];
		if (theBundle) {
			ioQuake3Path = [[NSBundle bundleWithPath:@"ioquake3.app"] pathForAuxiliaryExecutable:IOQ3_UB_BIN];
			if (!ioQuake3Path) {
				ioQuake3Path = [[NSBundle bundleWithPath:@"ioquake3.app"] pathForAuxiliaryExecutable:IOQ3_BIN];
			}
		}
	}
	NSPipe *pipe = [NSPipe pipe];
	quakeOut = [pipe fileHandleForReading];
	[quakeOut readInBackgroundAndNotify];
	
	quakeTask = [NSTask new];
	[quakeTask setStandardOutput:pipe];
	[quakeTask setStandardError:pipe];

	NSString *args = [argsTextField stringValue];
	if ([args length])
		[quakeTask setArguments:[args componentsSeparatedByString:@" "]];
//		[quakeTask setArguments:[args componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]; // tiger
			
	BOOL die = NO;
	
	@try {
		[quakeTask setLaunchPath:ioQuake3Path];
		[quakeTask launch];
	}
	@catch (NSException *e) {
		[[NSAlert
		  alertWithMessageText:NSLocalizedString(@"Launch Failed", @"launch failed")
		  defaultButton:NSLocalizedString(@"OK", @"OK")
		  alternateButton:nil
		  otherButton:nil
//		  informativeTextWithFormat:NSLocalizedString(@"Something is probably wrong with the actual ioquake3 binary.", @"launch failed text")]
//		  informativeTextWithFormat:NSLocalizedString([@"Unable to find the Quake binary at:\n" stringByAppendingString:ioQuake3Path], @"launch failed text")]
		  informativeTextWithFormat:NSLocalizedString([[[e reason] stringByAppendingString:@"\n\nExecutable path was:\n"] stringByAppendingString:ioQuake3Path], @"launch failed text")]
		  runModal];
		die = YES;
	}
	@finally {
		if (die)
			[NSApp terminate:self];
	}

	[[sender window] close];
	return;
}

- (void)readPipe:(NSNotification *)note {
	if ([note object] == quakeOut) {
		NSData *outputData = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
		if ([outputData length])
			[quakeData appendData:outputData];
		if (quakeTask)
			[quakeOut readInBackgroundAndNotify];
	}
}

- (void)taskNote:(NSNotification *)note {
	if ([note object] == quakeTask) {
		if ([quakeTask isRunning] == NO) {
			if ([quakeTask terminationStatus] != 0) {
				ErrorWindow *ew = [[ErrorWindow alloc] init];
				[ew bitch:[[NSString alloc] initWithData:quakeData encoding:NSUTF8StringEncoding]];
			} 
			else
				[NSApp terminate:self];
		}
	}
}
@end
