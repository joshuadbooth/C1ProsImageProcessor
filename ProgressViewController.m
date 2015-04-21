//
//  ProgressViewController.m
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/15/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "ProgressViewController.h"
#import "C1AppController.h"

@interface ProgressViewController ()

@end

@implementation ProgressViewController

@synthesize progressBar;
@synthesize progressLabel;
@synthesize incrementValue;


- (void)loadView {
    [super loadView];
}

- (instancetype) init {
    self = [super initWithNibName:@"ProgressWindow" bundle:[NSBundle mainBundle]];
    NSLog(@"Progress View init");
    return self;
}

+ (ProgressViewController *) sharedInstance {
    static ProgressViewController * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void) resetProgressBar {
    [progressBar setDoubleValue:0.0];
}

- (void) updateProgressBar: (double) totalImages {
    
    incrementValue = 1.0 / totalImages * 100.00;
    
    [progressBar incrementBy:incrementValue];
    [progressBar setNeedsDisplay:YES];
}
-(void) updateStatus:(NSString*) msg{
    [progressLabel setStringValue:msg];
}

- (IBAction)stopIteration:(id)sender {
    NSLog(@"\t***************************");
    NSLog(@"\t\t\tStop it!");
    NSLog(@"\t***************************");
    
    [[C1AppController sharedInstance] cancelProcessingAndClearBatchQueue];
    
}

@end
