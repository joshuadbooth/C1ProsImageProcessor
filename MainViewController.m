//
//  MainViewController.m
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/15/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "MainViewController.h"
#import "C1AppController.h"

#import "ActivationViewController.h"
#import "C1MissingViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize mainWindow = _mainWindow;

+ (MainViewController *) sharedInstance {
    static MainViewController * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}


-(instancetype) init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void) loadView {
    [super loadView];
    [self.view.window setTitle:@"C1Pros Image Processor *DEMO MODE*"];
    
    [[C1AppController sharedInstance] loadMainVC:self];
    [[C1AppController sharedInstance] loadDefaults];
    
    [self toggleJPEGs:self];
    [self toggleTIFFs:self];
    
    if ([C1AppController sharedInstance].discussionOver) {
        self.registerBtn.hidden = YES;
        
    }
    
    
    [_startBtn setEnabled:NO];
    
    [_qualityJPEG setDelegate:self];
    [_resolutionJPEG setDelegate:self];
    [_jpegW  setDelegate:self];
    [_jpegH  setDelegate:self];
    
    [_resolutionTIFF setDelegate:self];
    [_tiffW  setDelegate:self];
    [_tiffH  setDelegate:self];
    
    [self checkForC1Pro];
    
    
    if (![C1AppController sharedInstance].discussionOver) {
        _mainWindow.title = @"C1Pros Image Processor *DEMO MODE*";
        
        // waits 1 seconds before launching activation
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            [self startRegistration:self];
        });
    } else {
        _mainWindow.title = @"C1Pros Image Processor";
    }
    
}

- (void) controlTextDidEndEditing:(NSNotification *)obj {
    [self checkRequirements];
    NSLog(@"Ended Editing");
}

- (IBAction)startProcessing:(id)sender {
    NSLog(@"Start Processing");
    [[C1AppController sharedInstance] startProcessing];
    
}

- (IBAction)loadDefaultValues:(id)sender {
    [self.view.window setTitle:@"Blah"];
}

- (IBAction)startRegistration:(id)sender {
    NSLog(@"Starting Registration");
    
    ActivationViewController *activationVC = [ActivationViewController sharedInstance];
    NSLog(@"Activation View: %@", activationVC.view.identifier);
    
   [NSApp beginSheet:activationVC.view.window
      modalForWindow:self.view.window
       modalDelegate:self
      didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
         contextInfo:nil];
    
    [activationVC.activationWindow makeKeyAndOrderFront:nil];
    
}

-(void) didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    NSLog(@"Now that THAT's over with");
    [sheet orderOut:nil];
    
}


- (IBAction)chooseCaptureFolder:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    [panel setCanChooseFiles:NO];
    
    NSInteger result = [panel runModal];
    if (result == NSOKButton) {
        NSArray *folderList = [panel URLs];
        
        _captureFolder = [folderList objectAtIndex:0];
        NSLog(@"captureFolder: %@", _captureFolder);
        
        
        [_captureLabel setStringValue:[[_captureFolder relativePath] stringByAppendingString:@"/"]];
        
    }
    [self checkRequirements];
}

- (IBAction)chooseOutputFolder:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    [panel setCanChooseFiles:NO];
    
    NSInteger result = [panel runModal];
    if (result == NSOKButton) {
        NSArray *folderList = [panel URLs];
        
        _outputFolder = [folderList objectAtIndex:0];
        NSLog(@"outputFolder: %@", _outputFolder);
        
        [_outputLabel setStringValue:[[_outputFolder relativePath] stringByAppendingString:@"/"]];
    }
    [self checkRequirements];
}

- (IBAction)loadCaptureFolder:(id)sender {
    _captureFolder = [[C1AppController sharedInstance] loadCaptureFolder];
    [_captureLabel setStringValue:[[_captureFolder relativePath] stringByAppendingString:@"/"]];
    [self checkRequirements];
}

- (IBAction)loadOutputFolder:(id)sender {
    _outputFolder = [[C1AppController sharedInstance] loadOutputFolder];
    [_outputLabel setStringValue:[[_outputFolder relativePath] stringByAppendingString:@"/"]];
    [self checkRequirements];
}

- (IBAction)resetDefaults:(id)sender {
    [[C1AppController sharedInstance] initiateDefaults];
}

- (IBAction)forceCheckRequirements:(id)sender {
    [self checkRequirements];
}

// Extra Functions
- (void) toggleJPEGs:(id)sender {
    NSArray *array = [NSArray arrayWithObjects:_qualityJPEG, _resolutionJPEG, _jpegICC, _jpegDisableSharpening, _jpegIgnoreCrop, _jpegIncludeRating, _jpegIncludeCopyright, _jpegIncludeGPS, _jpegIncludeCamera, _jpegIncludeOther, _resizeJPEG, nil];
    
    if ([_saveAsJPEG state]) {
        
        if([_saveAsTIFF state]){
            [_groupingMenu setEnabled:YES];
        }
        
        
        NSEnumerator *enumerator = [array objectEnumerator];
        id anObject;
        
        while (anObject = [enumerator nextObject]){
            [anObject setEnabled:1];
        }
        
        [_jpegResolutionLabel setTextColor:[NSColor textColor]];
        [_jpegQualityLabel setTextColor:[NSColor textColor]];
        [_jpegICClabel setTextColor:[NSColor textColor]];
        
        [self toggleJPEGresize:self];
    } else {
        
        // Disable and reset Grouping Menu
        [_groupingMenu selectItemWithTitle:@"File Type"];
        [self changeGrouping:self];
        [_groupingMenu setEnabled:NO];
        
        NSEnumerator *enumerator = [array objectEnumerator];
        id anObject;
        
        while (anObject = [enumerator nextObject]){
            [anObject setEnabled:0];
        }
        
        [_jpegResolutionLabel setTextColor:[NSColor disabledControlTextColor]];
        [_jpegQualityLabel setTextColor:[NSColor disabledControlTextColor]];
        [_jpegICClabel setTextColor:[NSColor disabledControlTextColor]];
        
        [self toggleJPEGresize:self];
    }
    [self checkRequirements];

}

- (void) toggleJPEGresize:(id)sender {
    if ((_resizeJPEG.state) && (_resizeJPEG.isEnabled)) {
        
        [_jpegW setEnabled:1];
        [_jpegH setEnabled:1];
        
        [_jpegWlabel setTextColor:[NSColor textColor]];
        [_jpegHlabel setTextColor:[NSColor textColor]];
        [_jpegPXw setTextColor:[NSColor textColor]];
        [_jpegPXh setTextColor:[NSColor textColor]];
    }
    else {
        [_jpegW setEnabled:0];
        [_jpegH setEnabled:0];
        
        [_jpegWlabel setTextColor:[NSColor disabledControlTextColor]];
        [_jpegHlabel setTextColor:[NSColor disabledControlTextColor]];
        [_jpegPXw setTextColor:[NSColor disabledControlTextColor]];
        [_jpegPXh setTextColor:[NSColor disabledControlTextColor]];
        
        
    }
    [self checkRequirements];
}

- (void) toggleTIFFs:(id)sender {
    NSArray *array = [NSArray arrayWithObjects:_bitDepthTIFF, _resolutionTIFF, _tiffICC, _tiffCompression, _tiffDisableSharpening, _tiffIgnoreCrop, _tiffIncludeRating, _tiffIncludeCopyright, _tiffIncludeGPS, _tiffIncludeCamera, _tiffIncludeOther, _resizeTIFF, nil];
    
    if ([_saveAsTIFF state]) {
        
        if([_saveAsJPEG state]){
            [_groupingMenu setEnabled:YES];
        }
        
        NSEnumerator *enumerator = [array objectEnumerator];
        id anObject;
        
        while (anObject = [enumerator nextObject]){
            [anObject setEnabled:1];
        }
        
        [_tiffBitLabel setTextColor:[NSColor textColor]];
        [_tiffResolutionLabel setTextColor:[NSColor textColor]];
        [_tiffICClabel setTextColor:[NSColor textColor]];
        [_tiffCompressionLabel setTextColor:[NSColor textColor]];
        
        [self toggleTIFFresize:self];
    } else {
        
        [_groupingMenu selectItemWithTitle:@"File Type"];
        [self changeGrouping:self];
        [_groupingMenu setEnabled:NO];
        
        NSEnumerator *enumerator = [array objectEnumerator];
        id anObject;
        
        while (anObject = [enumerator nextObject]){
            [anObject setEnabled:0];
        }
        [self toggleTIFFresize:self];
    }
    
    [_tiffBitLabel setTextColor:[NSColor disabledControlTextColor]];
    [_tiffResolutionLabel setTextColor:[NSColor disabledControlTextColor]];
    [_tiffICClabel setTextColor:[NSColor disabledControlTextColor]];
    [_tiffCompressionLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self checkRequirements];
}

- (void) toggleTIFFresize:(id)sender {
    if ((_resizeTIFF.isEnabled) && ([_resizeTIFF state])) {
        [_tiffW setEnabled:1];
        [_tiffH setEnabled:1];
        
        [_tiffWlabel setTextColor:[NSColor textColor]];
        [_tiffHlabel setTextColor:[NSColor textColor]];
        [_tiffPXw setTextColor:[NSColor textColor]];
        [_tiffPXh setTextColor:[NSColor textColor]];
        
    }
    else {
        [_tiffW setEnabled:0];
        [_tiffH setEnabled:0];
        
        [_tiffWlabel setTextColor:[NSColor disabledControlTextColor]];
        [_tiffHlabel setTextColor:[NSColor disabledControlTextColor]];
        [_tiffPXw setTextColor:[NSColor disabledControlTextColor]];
        [_tiffPXh setTextColor:[NSColor disabledControlTextColor]];
    }
    [self checkRequirements];
}

- (void) checkRequirements {
    NSLog(@"Checking Requirements");
    // check to make sure all important elements are entered.
    
    BOOL go = NO;
    
    NSMutableArray *missingElements = [[NSMutableArray alloc] init];
    
    if (
        (_captureFolder != nil) &&
        (_outputFolder != nil) &&
        ([_saveAsJPEG state] || [_saveAsTIFF state])
        ) {
        
        go = YES;
        
        if ([_resizeJPEG state] && ([_jpegW.stringValue isEqualTo:@""] || [_jpegH.stringValue isEqualTo:@""])) {
            [missingElements addObject:@"Resizing JPEGs but missing JPEG W or H"];
            go = NO;
        }
        
        if ([_resizeTIFF state] && ([_tiffW.stringValue isEqualTo:@""] || [_tiffH.stringValue isEqualTo:@""])) {
            //NSLog(@"TIFF no");
            [missingElements addObject:@"Resizing TIFFs but missing Tiff W or H"];
            go = NO;
        }
        
    } else {
        
        if (_captureFolder == nil) [missingElements addObject:@"No Capture folder"];
        if (_outputFolder == nil) [missingElements addObject:@"No Output folder"];
        if (!([_saveAsJPEG state] || [_saveAsTIFF state])) [missingElements addObject:@"Neither JPEGs or TIFFs selected to save"];
    }
    
    if (go) {
        [_startBtn setEnabled:YES];
    } else {
        NSLog(@"Not all requirements are met. Missing Elements= %@", missingElements);
        [_startBtn setEnabled:NO];
    }
}

- (void) changeGrouping:(id)sender {
    
}

-(void) checkForC1Pro {
    NSLog(@"Checking for C1");
    
    BOOL installed = [[C1AppController sharedInstance] checkForC1];
    
    if (!installed) {
        NSLog(@"!installed");
        @try {
            C1MissingViewController *missing = [[C1MissingViewController sharedInstance]init];
            [missing loadView];
            [missing.view.window makeKeyAndOrderFront:nil];
            
            [self.view.window orderOut:nil];
        }
        @catch (NSException *exception) {
            NSLog(@"Uh oh! %@", [exception description]);
        }
        
    } else {
        [C1AppController sharedInstance].C1Pro = nil;
        [C1AppController sharedInstance].C1Pro = [SBApplication applicationWithBundleIdentifier:@"com.phaseone.captureone8"];
        
        if ([C1AppController sharedInstance].C1Pro.isRunning == NO){
            
            NSUserNotification * launchNote  = [[NSUserNotification alloc]init];
            launchNote.title = @"Launching Capture One";
            launchNote.informativeText = @"Capture One wasn't running. Opening Capture One Pro.";
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:launchNote];
            
            NSLog(@"C1 Pro isn't running. activating.");
            [[C1AppController sharedInstance].C1Pro activate];
        }
        else {
            NSLog(@"C1 Pro is running");
        }
    }
}

@end
