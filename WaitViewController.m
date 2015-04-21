//
//  WaitViewController.m
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/21/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "C1AppController.h"
#import "WaitViewController.h"

@interface WaitViewController ()

@end

@implementation WaitViewController

+ (WaitViewController *) sharedInstance {
    static WaitViewController * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)loadView {
    [super loadView];
    // Do view setup here.
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSLog(@"WaitingWindow initiated");
    }
    return self;
}


- (instancetype) init {
    if (!self) {
        self = [super initWithNibName:@"WaitWindow" bundle:[NSBundle mainBundle]];
    }
    else {
        
    }
    return self;
}

- (IBAction)okProceed:(id)sender {
    // close waitWindow & setupWindow
    dispatch_async(dispatch_get_main_queue(), ^ {
        [NSApp endSheet:self.view.window];
        [self.view.window orderOut:self];
        [[MainViewController sharedInstance].view.window orderOut:nil];
        [[ProgressViewController sharedInstance].view.window makeKeyAndOrderFront:nil];
    });
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // get currently stored ICCs
    NSMutableArray *currentICCs = [[prefs stringArrayForKey:@"AvailableICCs"] mutableCopy];
    NSLog(@"current ICCs: %@", currentICCs);
    
    // Get any newly selected ICCs
    NSString *jpegICC;
    NSString *tiffICC;
    
    if ([MainViewController sharedInstance].saveAsJPEG.state){
        jpegICC = [[C1AppController sharedInstance].JPEGrecipe selectRecipeByName:@"IP JPEG"].recipe.colorProfile;
    } else {
        jpegICC = @"IGNORE"; // if user didn't choose to save jpegs, it won't update the selected color profile
    }
    
    if ([MainViewController sharedInstance].saveAsTIFF.state) {
        tiffICC = [[C1AppController sharedInstance].TIFFrecipe selectRecipeByName:@"IP TIFF"].recipe.colorProfile;
    } else {
        tiffICC = @"IGNORE"; // if user didn't choose to save tiffs, it won't update the selected color profile
    }
    
    
    // if new icc profile isn't listed in available iccs, add it to the list for furture use
    if ((![currentICCs containsObject:jpegICC]) || (![currentICCs containsObject:tiffICC])) {
        
        NSLog(@"Adding new ICC to list");
        
        if (![currentICCs containsObject:jpegICC] && ![jpegICC isEqualToString:@"IGNORE"]) {
            [currentICCs addObject:jpegICC];
            NSLog(@"Adding %@", jpegICC);
            //NSLog(@"CurrentICCs: %@", currentICCs);
        }
        
        if (![currentICCs containsObject:tiffICC] && ![tiffICC isEqualToString:@"IGNORE"]) {
            [currentICCs addObject:tiffICC];
            NSLog(@"Adding %@", tiffICC);
            // NSLog(@"CurrentICCs: %@", currentICCs);
        }
        
        [prefs setObject:currentICCs forKey:@"AvailableICCs"];
        if ([MainViewController sharedInstance].saveAsDefaults.state) {
            if ([MainViewController sharedInstance].saveAsJPEG.state) [prefs setObject:jpegICC forKey:@"jpegICC"];
            if ([MainViewController sharedInstance].saveAsTIFF.state) [prefs setObject:tiffICC forKey:@"tiffICC"];
        }
        [prefs synchronize];
        
    }
    
    [[C1AppController sharedInstance] iterate];
}

- (IBAction)cancelAndReturnToSetup:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        
    [NSApp endSheet:self.view.window];
        [[ProgressViewController sharedInstance].view.window orderOut:nil];
        [self.view.window orderOut:nil];
    });
}
@end
