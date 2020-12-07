//
//  Controller.h
//  ioquake3fe
//
//  Created by Ben Wilber on 3/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Controller : NSObject <NSApplicationDelegate> {
	NSTask			*quakeTask;
	NSFileHandle	*quakeOut;
	NSMutableData	*quakeData;
}
@property (assign) IBOutlet NSTextField *argsTextField;

- (IBAction)launch:(id)sender;
- (void)readPipe:(NSNotification *)note;
- (void)taskNote:(NSNotification *)note;

@end
