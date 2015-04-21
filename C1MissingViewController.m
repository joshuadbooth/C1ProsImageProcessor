//
//  C1MissingViewController.m
//  Image Processor V2
//
//  Created by Josh Booth on 4/10/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "C1MissingViewController.h"

@interface C1MissingViewController ()

@end

@implementation C1MissingViewController

@synthesize defaultWindow;

+ (C1MissingViewController *) sharedInstance {
    static C1MissingViewController * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}


-(void) viewDidAppear {
    self.view.window.title = @"C1Pros Image Processor: Cannot locate Capture One Pro";
}

- (void) loadView {
    NSLog(@"C1 Missing view loaded");
    [super loadView];
        [self viewDidAppear];
    
}

- (instancetype) init {
    self = [super initWithNibName:@"C1MissingWindow" bundle:[NSBundle mainBundle]];
    NSLog(@"C1 Missing View init");
    return self;
}

- (IBAction)downloadC1Btn:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://captureintegration.com/download-archive/"]];
    [[NSApplication sharedApplication]terminate:self];
}

- (IBAction)emailBtn:(id)sender {
    //[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:tech@captureintegration.com"]];
    
    NSArray *email = @[@"Issue: could not detect Capture One Pro installation\r\r"];
    
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
    service.delegate = self;
    service.recipients = @[@"tech@captureintegration.com"];
    service.subject = @"C1Pros Image Processor - Tech Support";
    [service performWithItems:email];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSApplication sharedApplication] terminate:self];
    });
 
}

- (IBAction)quitBtn:(id)sender {
    [[NSApplication sharedApplication]terminate:self];
}
@end
