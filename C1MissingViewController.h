//
//  C1MissingViewController.h
//  Image Processor V2
//
//  Created by Josh Booth on 4/10/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class C1MissingViewController;

@interface C1MissingViewController : NSViewController <NSSharingServiceDelegate>

@property (strong) IBOutlet NSWindow *defaultWindow;

- (instancetype) init;

+ (C1MissingViewController*) sharedInstance;

- (IBAction)downloadC1Btn:(id)sender;
- (IBAction)emailBtn:(id)sender;
- (IBAction)quitBtn:(id)sender;

@end
