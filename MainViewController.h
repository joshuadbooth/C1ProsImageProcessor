//
//  MainViewController.h
//  C1Pros Image Processor
//
//  Created by Josh Booth on 4/15/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "C1RecipeController.h"

@class MainViewController;

@interface MainViewController : NSViewController <NSTextViewDelegate>

+ (MainViewController *) sharedInstance;
- (instancetype) init;
//- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@property NSString* testLoad;
@property (weak) IBOutlet NSWindow *mainWindow;

// Start screen
@property (weak) IBOutlet NSTextField *captureLabel;
@property (weak) IBOutlet NSTextField *outputLabel;
@property (weak) IBOutlet NSButton *startBtn;
@property (weak) IBOutlet NSButton *registerBtn;

@property NSURL *captureFolder;
@property NSURL *outputFolder;

- (IBAction)startProcessing:(id)sender;
- (IBAction)loadDefaultValues:(id)sender;
- (IBAction)startRegistration:(id)sender;
- (IBAction)chooseCaptureFolder:(id)sender;
- (IBAction)chooseOutputFolder:(id)sender;
- (IBAction)loadCaptureFolder:(id)sender;
- (IBAction)loadOutputFolder:(id)sender;


// JPEG tab
@property (weak) IBOutlet NSButton *saveAsJPEG;
@property (weak) IBOutlet NSButton *resizeJPEG;
@property (weak) IBOutlet NSTextField *qualityJPEG;
@property (weak) IBOutlet NSTextField *resolutionJPEG;
@property (weak) IBOutlet NSTextField *jpegW;
@property (weak) IBOutlet NSTextField *jpegH;
@property (weak) IBOutlet NSPopUpButton *jpegICC;
@property (weak) IBOutlet NSButton *jpegDisableSharpening;
@property (weak) IBOutlet NSButton *jpegIgnoreCrop;
@property (weak) IBOutlet NSButton *jpegIncludeRating;
@property (weak) IBOutlet NSButton *jpegIncludeCopyright;
@property (weak) IBOutlet NSButton *jpegIncludeGPS;
@property (weak) IBOutlet NSButton *jpegIncludeCamera;
@property (weak) IBOutlet NSButton *jpegIncludeOther;

@property (weak) IBOutlet NSTextField *jpegQualityLabel;
@property (weak) IBOutlet NSTextField *jpegResolutionLabel;
@property (weak) IBOutlet NSTextField *jpegICClabel;
@property (weak) IBOutlet NSTextField *jpegWlabel;
@property (weak) IBOutlet NSTextField *jpegHlabel;
@property (weak) IBOutlet NSTextField *jpegPXw;
@property (weak) IBOutlet NSTextField *jpegPXh;


- (IBAction)toggleJPEGs:(id)sender;
- (IBAction)toggleJPEGresize:(id)sender;


// TIFF tab
@property (weak) IBOutlet NSButton *saveAsTIFF;
@property (weak) IBOutlet NSButton *resizeTIFF;
@property (weak) IBOutlet NSPopUpButton *bitDepthTIFF;
@property (weak) IBOutlet NSTextField *resolutionTIFF;
@property (weak) IBOutlet NSTextField *tiffW;
@property (weak) IBOutlet NSTextField *tiffH;
@property (weak) IBOutlet NSPopUpButton *tiffICC;
@property (weak) IBOutlet NSPopUpButton *tiffCompression;

@property (weak) IBOutlet NSButton *tiffDisableSharpening;
@property (weak) IBOutlet NSButton *tiffIgnoreCrop;
@property (weak) IBOutlet NSButton *tiffIncludeRating;
@property (weak) IBOutlet NSButton *tiffIncludeCopyright;
@property (weak) IBOutlet NSButton *tiffIncludeGPS;
@property (weak) IBOutlet NSButton *tiffIncludeCamera;
@property (weak) IBOutlet NSButton *tiffIncludeOther;

@property (weak) IBOutlet NSTextField *tiffBitLabel;
@property (weak) IBOutlet NSTextField *tiffResolutionLabel;
@property (weak) IBOutlet NSTextField *tiffICClabel;
@property (weak) IBOutlet NSTextField *tiffCompressionLabel;
@property (weak) IBOutlet NSTextField *tiffWlabel;
@property (weak) IBOutlet NSTextField *tiffHlabel;
@property (weak) IBOutlet NSTextField *tiffPXw;
@property (weak) IBOutlet NSTextField *tiffPXh;

- (IBAction)toggleTIFFs:(id)sender;
- (IBAction)toggleTIFFresize:(id)sender;

// Extras Tab
@property (weak) IBOutlet NSButton *renameVariants;
@property (weak) IBOutlet NSPopUpButton *groupingMenu;
@property (weak) IBOutlet NSTextField *groupingDescription;
@property (weak) IBOutlet NSButton *saveAsDefaults;
- (IBAction)changeGrouping:(id)sender;
- (IBAction)resetDefaults:(id)sender;

- (IBAction)forceCheckRequirements: (id)sender;
- (void) checkRequirements;
@end
