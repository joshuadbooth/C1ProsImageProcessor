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
@synthesize activationStatus;
@synthesize activatedGreen;
@synthesize C1ProsOrange;


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
    NSButton *control = sender;
    // Dual - purpose button...
    
    if ([control.title isEqualToString:@"Activate"]) {
        [ActivationController sharedInstance].appID = @"C1PIP";
        
        [_activateButton setEnabled:NO];
        [_demoButton setEnabled:NO];
        
        NSString *fullKey = [[ActivationController sharedInstance] rebuildLicense:self.userKey.stringValue];
        
        BOOL pointMade = [[ActivationController sharedInstance] checkRegistration:fullKey userName:self.userName.stringValue userEmail:self.userEmail.stringValue];
        
        NSLog(@"Point Made? %i", pointMade);
        
        if (pointMade) {
            [C1AppController sharedInstance].discussionOver = YES;
            [[MainViewController sharedInstance].view.window setTitle:@"C1Pros Image Processor"];
            [[C1AppController sharedInstance] saveRegistration];
            
            [MainViewController sharedInstance].registerBtn.hidden = YES;
            
            activationStatus.stringValue = @"Activated.";
            activationStatus.textColor = activatedGreen;
            [self.userKey resignFirstResponder];
            self.userKey.editable = NO;
            self.userName.editable = NO;
            self.userEmail.editable = NO;
            
            // waits 1 second before launching activation
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                [NSApp endSheet:_activationWindow];
            });
            
        } else {
            activationStatus.stringValue = @"Invalid License Code - Please verify all information.";
            [_activateButton setEnabled:YES];
            [_demoButton setEnabled:YES];
            activationStatus.textColor = [NSColor redColor];
            
            [C1AppController sharedInstance].discussionOver = NO;
            [[C1AppController sharedInstance].mainWindow.view.window setTitle:@"C1Pros Image Processor *DEMO MODE*"];
        }
    } else { // IF button is set to Deactivate
        
        [_activateButton setEnabled:NO];
        [_demoButton setEnabled:NO];
        
        BOOL deactivated = [[ActivationController sharedInstance] deactivateMeinFolder:@"C1Pros Image Processor" forFile:@"C1PIPlicense" isHidden:NO];
        
        if (deactivated) {
            
            [C1AppController sharedInstance].discussionOver = NO;
            activationStatus.stringValue = @"Deactivated";
            activationStatus.textColor = [NSColor redColor];
            
            self.userKey.editable = YES;
            self.userName.editable = YES;
            self.userEmail.editable = YES;
            
            self.userKey.stringValue = @"";
            self.userName.stringValue = @"";
            self.userEmail.stringValue = @"";
            
            [[C1AppController sharedInstance].mainWindow.view.window setTitle:@"C1Pros Image Processor *DEMO MODE*"];
            [[C1AppController sharedInstance].mainWindow.registerBtn setHidden:NO];
            
            // waits 1 second before launching activation
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //[self.view.window orderOut:nil];
                [NSApp endSheet:_activationWindow];
            });
            
            
        } else {
            [_activateButton setEnabled:YES];
            [_demoButton setEnabled:YES];
            
        }
    }
    
}


- (void) loadView {
    [super loadView];
    NSLog(@"ActivationView loaded");
    
    [_activateButton setEnabled:NO];
    [_demoButton setEnabled:YES];
    [_demoButton setKeyEquivalent:@"\r"];
    
    BOOL activated = [[ActivationController sharedInstance] checkRegistrationForAppID:@"C1PIP" inFolder:@"C1Pros Image Processor" forFile:@"C1PIPlicense" isHidden:NO];
    
    
    
    C1ProsOrange = [NSColor colorWithRed:(232.0/255.0) green:(158.0/255.0) blue:0.0 alpha:1];
    activatedGreen = [NSColor colorWithCalibratedRed:(97.0/255.0) green:(192.0/255.0) blue:(59.0/255.0) alpha:1];
    
    [_userName setDelegate:self];
    [_userEmail setDelegate:self];
    [_userKey setDelegate:self];
    
    
    if (activated) {
        [_activateButton setTitle:@"Deactivate"];
        [_demoButton setTitle:@"Close"];
        
        [_demoButton setKeyEquivalent:@""];
        [_activateButton setKeyEquivalent:@"\r"];
        [_activateButton setEnabled:YES];
        
        activationStatus.stringValue = @"Activated";
        activationStatus.textColor = activatedGreen;
        
        NSDictionary *regInfo = [[ActivationController sharedInstance] getLicenseInfoFromFolder:@"C1Pros Image Processor" forFile:@"C1PIPlicense" isHidden:NO];
        
        @try {
            
            _userName.stringValue = [regInfo objectForKey:@"userName"];
            _userName.editable = NO;
            _userName.refusesFirstResponder = YES;
            [_userName setDrawsBackground:NO];
            [_userName setBordered:NO];
            
            _userEmail.stringValue = [regInfo objectForKey:@"userEmail"];
            _userEmail.editable = NO;
            _userEmail.refusesFirstResponder = YES;
            [_userEmail setDrawsBackground:NO];
            [_userEmail setBordered:NO];
            
            _userKey.stringValue = [regInfo objectForKey:@"userLicense"];
            _userKey.editable = NO;
            _userKey.refusesFirstResponder = YES;
            [_userKey setDrawsBackground:NO];
            //[_userKey setBordered:NO];
        }
        @catch (NSException *exception) {
            _userName.stringValue = @"";
            _userEmail.stringValue = @"";
            _userKey.stringValue = @"";
        }
        
    }

    
}

- (void) checkAllFields {
    if ((![[_userName stringValue] isEqualToString:@""]) &&
        (![[_userEmail stringValue] isEqualToString:@""]) &&
        (![[_userKey stringValue]isEqualToString:@""])) {
        [_activateButton setKeyEquivalent:@"\r"];
        [_demoButton setKeyEquivalent:@"\e"];
        [_activateButton setEnabled:YES];
        
    } else {
        [_activateButton setKeyEquivalent:@""];
        [_demoButton setKeyEquivalent:@"\r"];
        [_activateButton setEnabled:NO];
    }
}

-(void) controlTextDidEndEditing:(NSNotification *)obj {
    [self checkAllFields];
}

-(void) controlTextDidChange:(NSNotification *)obj {
    if ([[obj object] isEqualTo:_userKey]){
        [self checkAllFields];
    }
}

-(IBAction)runAsDemo:(id)sender {
    NSLog(@"ActivationWindow:\r%@\r%@", _activationWindow, self.view.window);
    [NSApp endSheet:_activationWindow];

}


@end
