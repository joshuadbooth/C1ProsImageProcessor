//
//  ActivationViewController.m
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/15/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "ActivationViewController.h"
#import "C1AppController.h"
#import "ActivationController.h"

@interface ActivationViewController ()

@end

@implementation ActivationViewController
@synthesize activationWindow = _activationWindow;


- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (instancetype) init {
    if (!self) {
        self = [super initWithNibName:@"ActivationWindow" bundle:[NSBundle mainBundle]];
    }
    return self;
}


+ (ActivationViewController *) sharedInstance {
    static ActivationViewController * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (IBAction)beginActivation:(id)sender {
    
}


- (void) loadView {
    [super loadView];
    NSLog(@"ActivationView loaded");
    
    [_activateButton setEnabled:NO];
    [_demoButton setEnabled:YES];
    [_demoButton setKeyEquivalent:@"\r"];
    
}


-(IBAction)runAsDemo:(id)sender {
    NSLog(@"ActivationWindow:\r%@\r%@", _activationWindow, self.view.window);
    [NSApp endSheet:_activationWindow];

}


@end
