//
//  CompletionViewController.h
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/21/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CompletionViewController;

@interface CompletionViewController : NSViewController
@property (strong) IBOutlet NSWindow *completeWindow;
@property (strong) IBOutlet NSWindow *cancelledWindow;

+ (CompletionViewController *) sharedInstance;

@end
