//
//  C1AppController.h
//  Image Processor V2
//
//  Created by Josh Booth on 2/13/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "ProgressViewController.h"
#import "C1RecipeController.h"
#import "C1Pro.h"
#import "ActivationViewController.h"


@class C1AppController;

@interface C1AppController : NSObject

@property NSURL *captureFolder;
@property NSURL *outputFolder;

@property (strong) C1RecipeController *TIFFrecipe;
@property (strong) C1RecipeController *JPEGrecipe;
@property BOOL discussionOver;
@property NSString *appID;

@property BOOL waitBeforeProcessing;
@property BOOL shouldRenameVariants;
@property NSString *outputGrouping;

@property MainViewController *mainWindow;
@property NSUserDefaults *prefs;
@property ProgressViewController *progressVC;



@property (strong) NSString *testShared;
@property C1ProApplication *C1Pro;


+ (C1AppController *) sharedInstance;
- (instancetype) init;

- (BOOL) checkForC1;

- (void) loadMainVC:(MainViewController *)mainVC;

- (void) startProcessing;
- (void) createRecipes;

- (void) browse:(NSURL *)theFolder;
- (void) processCurrentFolderWithRecipe:(NSString*) recipeName;
- (void) iterate;

- (void) saveDefaults;
- (void) loadDefaults;
- (void) initiateDefaults;
- (void) cancelProcessingAndClearBatchQueue;
- (void) saveRegistration;

- (NSURL*) loadCaptureFolder;
- (NSURL*) loadOutputFolder;

@end
