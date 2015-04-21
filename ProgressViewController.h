//
//  ProgressViewController.h
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/15/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ProgressViewController;

@interface ProgressViewController : NSViewController
@property (strong) IBOutlet NSWindow *progressWindow;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *progressLabel;
@property double incrementValue;

- (IBAction)stopIteration:(id)sender;

+ (ProgressViewController*) sharedInstance;
- (void) resetProgressBar;
- (void) updateStatus:(NSString*) msg;
- (void) updateProgressBar: (double) totalImages;

@end

