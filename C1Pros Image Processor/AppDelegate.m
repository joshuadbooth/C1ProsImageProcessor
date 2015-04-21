//
//  AppDelegate.m
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/15/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "ActivationViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    MainViewController *mainVC = [[MainViewController sharedInstance] initWithNibName:@"SetupWindow" bundle:[NSBundle mainBundle]];
    [mainVC loadView];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (IBAction)deactivateLicense:(id)sender {
    NSLog(@"Deactivating");
    
    [[MainViewController sharedInstance] startRegistration:nil];
    
    /*
     ActivationController *deactivator = [ActivationController sharedInstance];
     
     BOOL deactivated = [deactivator deactivateMeinFolder:@"C1Pros Image Processor" forFile:@"C1PIPlicense" isHidden:NO];
     if (deactivated) {
     [_deactivateButton setEnabled:NO];
     [C1AppController sharedInstance].discussionOver = NO;
     [[NSApplication sharedApplication] terminate:self];
     } else {
     [_deactivateButton setEnabled:YES];
     
     }
     */
}
@end
