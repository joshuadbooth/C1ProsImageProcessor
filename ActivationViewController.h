//
//  ActivationViewController.h
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/15/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ActivationViewController;

@interface ActivationViewController : NSViewController <NSWindowDelegate, NSTextViewDelegate>
@property (weak) IBOutlet NSWindow *activationWindow;

@property (weak) IBOutlet NSTextField *RegistrationDescription;
@property (weak) IBOutlet NSTextField *userName;
@property (weak) IBOutlet NSTextField *userEmail;
@property (weak) IBOutlet NSTextField *userKey;
@property (weak) IBOutlet NSTextField *activationStatus;
@property (weak) IBOutlet NSButton *activateButton;
@property (weak) IBOutlet NSButton *demoButton;

@property NSColor *C1ProsOrange;
@property NSColor *activatedGreen;

+ (ActivationViewController *) sharedInstance;
- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (instancetype) init;

- (IBAction)beginActivation:(id)sender;
- (IBAction)runAsDemo:(id)sender;

@end
