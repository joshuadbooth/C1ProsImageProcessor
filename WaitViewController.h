//
//  WaitViewController.h
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/21/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WaitViewController;

@interface WaitViewController : NSViewController
@property (strong) IBOutlet NSWindow *waitWindow;
- (IBAction)okProceed:(id)sender;
- (IBAction)cancelAndReturnToSetup:(id)sender;

+ (WaitViewController*) sharedInstance;
- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end
