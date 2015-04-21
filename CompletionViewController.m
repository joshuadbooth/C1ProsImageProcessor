//
//  CompletionViewController.m
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/21/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "CompletionViewController.h"

@interface CompletionViewController ()

@end

@implementation CompletionViewController

- (void)loadView {
    [super loadView];
    // Do view setup here.
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSLog(@"CompletionWindow initiated");
    }
    return self;
}

+ (CompletionViewController *) sharedInstance {
    static CompletionViewController * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

@end
