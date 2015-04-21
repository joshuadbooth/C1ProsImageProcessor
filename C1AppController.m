//
//  C1AppController.m
//  Image Processor V2
//
//  Created by Josh Booth on 2/13/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "C1Pro.h"
#import "ActivationController.h"
#import "C1AppController.h"

#import "ActivationViewController.h"
#import "ProgressViewController.h"
#import "WaitViewController.h"
#import "CompletionViewController.h"


static C1AppController* Object;

@implementation C1AppController

@synthesize JPEGrecipe;
@synthesize TIFFrecipe;
@synthesize mainWindow;
//@synthesize progressVC;
@synthesize waitBeforeProcessing;
@synthesize shouldRenameVariants;
@synthesize outputGrouping;
@synthesize prefs;
@synthesize discussionOver;

@synthesize C1Pro;
@synthesize captureFolder;
@synthesize outputFolder;


BOOL stopIteration = NO;



+ (C1AppController *) sharedInstance {
    if (Object == nil) {
        Object = [[C1AppController alloc] init];
        Object.discussionOver = NO;
    }
    return Object;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.C1Pro = [SBApplication applicationWithBundleIdentifier:@"com.phaseone.captureone8"];
    }
    return self;
}

- (BOOL) checkForC1 {
    C1ProApplication *C1ProCheck = [SBApplication applicationWithBundleIdentifier:@"com.phaseone.captureone8"];
    NSLog(@"C1ProCheck: %@", C1ProCheck);
    
    if (C1ProCheck != nil) {
        self.C1Pro = [SBApplication applicationWithBundleIdentifier:@"com.phaseone.captureone8"];
        return YES;
    } else {
        return NO;
    }
    
}

-(void) loadMainVC:(MainViewController *) mainVC {
    self.mainWindow = mainVC;
    shouldRenameVariants = mainWindow.renameVariants.state;
}




// main functions

- (NSURL*) loadCaptureFolder {
    
    @try {
        C1ProDocument *mainSession = [[C1Pro documents]firstObject];
        captureFolder = [[mainSession captures] get];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
        captureFolder = nil;
    }
    @finally {
        return captureFolder;
    }
}
- (NSURL*) loadOutputFolder {
    
    @try {
        C1ProDocument *mainSession = [[C1Pro documents]firstObject];
        outputFolder = [[mainSession output] get];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
        outputFolder = nil;
    }
    @finally {
        return outputFolder;
    }
}

- (void)startProcessing {
    if (!mainWindow) {
        mainWindow = [MainViewController sharedInstance];
    }
    
    if (mainWindow.saveAsDefaults.state){
        NSLog(@"User chose to save defaults");
        [self saveDefaults];
    } else {
        NSLog(@"User chose not to save defaults");
    }
    
    
    // first create recipes and see if need to adjust before iteration
    //[mainWindow performSegueWithIdentifier:@"segueToProgress" sender:nil];
    
    
    [[ProgressViewController sharedInstance] init];
    [[ProgressViewController sharedInstance].view.window  makeKeyAndOrderFront:nil];
    [[ProgressViewController sharedInstance] updateStatus:@"Creating Recipes"];
    
    /*
    // waits 1 seconds before launching activation
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self createRecipes];
    });
*/
    
    void (^processingBlock) (void);
    processingBlock = ^ {
        
        [self createRecipes];
        
        if (self.waitBeforeProcessing) {
            // [mainWindow performSegueWithIdentifier:@"segueToWait" sender:mainWindow];
            WaitViewController *waitWindow = [[WaitViewController alloc] initWithNibName:@"WaitWindow" bundle:[NSBundle mainBundle]];
            [waitWindow.waitWindow makeKeyAndOrderFront:nil];
            [[mainWindow mainWindow] orderOut:nil];
            
        } else {
            //[[ProgressViewController sharedInstance] init];
            //[[ProgressViewController sharedInstance].view.window  makeKeyAndOrderFront:nil];
            
            [[mainWindow mainWindow] orderOut:nil];
            
            [self iterate];
        }
    };
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, processingBlock);
    
}

- (void) createRecipes {
    NSLog(@"\r\t************\r\tCreate Recipes\r\t************\r");
    
    dispatch_async(dispatch_get_main_queue(), ^{
            [[ProgressViewController sharedInstance] updateStatus:@"Creating Recipes"];
        });
        
    BOOL processJPEG = mainWindow.saveAsJPEG.state;
    BOOL shouldResizeJPEG = mainWindow.resizeJPEG.state;
    
    BOOL processTIFF = mainWindow.saveAsTIFF.state;
    BOOL shouldResizeTIFF = mainWindow.resizeTIFF.state;
    

    
    shouldRenameVariants = mainWindow.renameVariants.state;
    outputGrouping = [[mainWindow groupingMenu] titleOfSelectedItem];
    NSLog(@"output grouping: %@", outputGrouping);
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ProgressViewController sharedInstance] updateProgressBar:4];
    });

    
    if (processJPEG) {
        
        NSLog(@"JPEG Processing: TRUE");
        JPEGrecipe = [[C1RecipeController alloc] initWithFormat:@"JPEG"];
        
        // check resizing
        if (shouldResizeJPEG) {
            JPEGrecipe.recipe.scalingMethod = C1ProScalingTypeWidth_by_Height;
            JPEGrecipe.recipe.scalingUnit = C1ProMeasurementUnitPixels;
            JPEGrecipe.recipe.primaryScalingValue = [f numberFromString:mainWindow.jpegW.stringValue];
            JPEGrecipe.recipe.secondaryScalingValue = [f numberFromString:mainWindow.jpegH.stringValue];
        } else {
            JPEGrecipe.recipe.scalingMethod = C1ProScalingTypeFixed;
            JPEGrecipe.recipe.scalingUnit = C1ProMeasurementUnitPercent;
            JPEGrecipe.recipe.primaryScalingValue = [NSNumber numberWithInteger:100];
        }
        
        // other parameters
        
        JPEGrecipe.recipe.rootFolderLocation = mainWindow.outputFolder;
        JPEGrecipe.recipe.pixelsPerInch = [f numberFromString:mainWindow.resolutionJPEG.stringValue];
        JPEGrecipe.recipe.sharpened = !mainWindow.jpegDisableSharpening.state;
        JPEGrecipe.recipe.ignoreCrop = mainWindow.jpegIgnoreCrop.state;
        JPEGrecipe.recipe.includeRatings = mainWindow.jpegIncludeRating.state;
        JPEGrecipe.recipe.includeCopyright = mainWindow.jpegIncludeCopyright.state;
        JPEGrecipe.recipe.includeGPS = mainWindow.jpegIncludeGPS.state;
        JPEGrecipe.recipe.includeCameraMetadata = mainWindow.jpegIncludeCamera.state;
        JPEGrecipe.recipe.includeOtherMetadata = mainWindow.jpegIncludeOther.state;
        
        // Grouping Option
        if ([[mainWindow.groupingMenu titleOfSelectedItem] isEqualToString:@"File Type"] || !processTIFF){
            if (!processTIFF){
                JPEGrecipe.baseOutputFolder = mainWindow.outputFolder;
            } else {
                JPEGrecipe.baseOutputFolder = [NSURL URLWithString:[[mainWindow.outputFolder relativeString] stringByAppendingString:@"JPEG/"]];
            }
            
            JPEGrecipe.recipe.rootFolderLocation = JPEGrecipe.baseOutputFolder;
            JPEGrecipe.recipe.outputSubFolder = @"";
            
            
        } else {
            JPEGrecipe.baseOutputFolder = mainWindow.outputFolder;
            JPEGrecipe.recipe.rootFolderLocation = JPEGrecipe.baseOutputFolder;
            
            JPEGrecipe.recipe.outputSubFolder = @"JPEG";
            
        }
        
        //ICC Profile Assignment
        if (![[mainWindow.jpegICC titleOfSelectedItem] isEqualToString:@"Choose Before Processing"]) {
            if ([[mainWindow.jpegICC titleOfSelectedItem] isEqualToString:@"Embed camera profile"]){
                JPEGrecipe.recipe.colorProfile = @"";
            } else {
                JPEGrecipe.recipe.colorProfile = [mainWindow.jpegICC titleOfSelectedItem];
            }
        } else {
            NSLog(@"JPEG: I'm supposed to wait before processing.");
            JPEGrecipe.waitBeforeProcessing = YES;
            self.waitBeforeProcessing = YES;
            
        }
    } else {
        JPEGrecipe = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ProgressViewController sharedInstance] updateProgressBar:4];
    });
    
    
    // TIFF Recipe Creation
    if (processTIFF) {
        NSLog(@"TIFF Processing: TRUE");
        TIFFrecipe = [[C1RecipeController alloc] initWithFormat:@"TIFF"];
        
        // check resizing
        if (shouldResizeTIFF) {
            TIFFrecipe.recipe.scalingMethod = C1ProScalingTypeWidth_by_Height;
            TIFFrecipe.recipe.scalingUnit = C1ProMeasurementUnitPixels;
            TIFFrecipe.recipe.primaryScalingValue = [f numberFromString:mainWindow.tiffW.stringValue];
            TIFFrecipe.recipe.secondaryScalingValue = [f numberFromString:mainWindow.tiffH.stringValue];
        } else {
            TIFFrecipe.recipe.scalingMethod = C1ProScalingTypeFixed;
            TIFFrecipe.recipe.scalingUnit = C1ProMeasurementUnitPercent;
            TIFFrecipe.recipe.primaryScalingValue = [NSNumber numberWithInteger:100];
        }
        
        // other parameters
        
        TIFFrecipe.recipe.rootFolderLocation = mainWindow.outputFolder;
        TIFFrecipe.recipe.pixelsPerInch = [f numberFromString:mainWindow.resolutionTIFF.stringValue];
        TIFFrecipe.recipe.sharpened = !mainWindow.tiffDisableSharpening.state;
        TIFFrecipe.recipe.ignoreCrop = mainWindow.tiffIgnoreCrop.state;
        TIFFrecipe.recipe.includeRatings = mainWindow.tiffIncludeRating.state;
        TIFFrecipe.recipe.includeCopyright = mainWindow.tiffIncludeCopyright.state;
        TIFFrecipe.recipe.includeGPS = mainWindow.tiffIncludeGPS.state;
        TIFFrecipe.recipe.includeCameraMetadata = mainWindow.tiffIncludeCamera.state;
        TIFFrecipe.recipe.includeOtherMetadata = mainWindow.tiffIncludeOther.state;
        
        // Grouping Option
        if ([[mainWindow.groupingMenu titleOfSelectedItem] isEqualToString:@"File Type"] || !processJPEG){
            if (!processJPEG){
                TIFFrecipe.baseOutputFolder = mainWindow.outputFolder;
            } else {
                TIFFrecipe.baseOutputFolder = [NSURL URLWithString:[[mainWindow.outputFolder relativeString] stringByAppendingString:@"TIFF/"]];
            }
            
            TIFFrecipe.recipe.rootFolderLocation = TIFFrecipe.baseOutputFolder;
            TIFFrecipe.recipe.outputSubFolder = @"";
            
            
        } else {
            TIFFrecipe.baseOutputFolder = mainWindow.outputFolder;
            TIFFrecipe.recipe.rootFolderLocation = TIFFrecipe.baseOutputFolder;
            
            TIFFrecipe.recipe.outputSubFolder = @"TIFF";
            
        }
        
        //ICC Profile Assignment
        if (![[mainWindow.tiffICC titleOfSelectedItem] isEqualToString:@"Choose Before Processing"]) {
            if ([[mainWindow.tiffICC titleOfSelectedItem] isEqualToString:@"Embed camera profile"]){
                TIFFrecipe.recipe.colorProfile = @"";
            } else {
                TIFFrecipe.recipe.colorProfile = [mainWindow.tiffICC titleOfSelectedItem];
            }
        } else {
            NSLog(@"JPEG: I'm supposed to wait before processing.");
            TIFFrecipe.waitBeforeProcessing = YES;
            self.waitBeforeProcessing = YES;
            
        }
        
        // Tiff Compression
        
        if ([[mainWindow.tiffCompression titleOfSelectedItem] isEqualToString:@"ZIP"]){
            TIFFrecipe.recipe.TIFFCompression = C1ProTiffCompressZIP;
        } else if ([[mainWindow.tiffCompression titleOfSelectedItem] isEqualToString:@"LZW"]){
            TIFFrecipe.recipe.TIFFCompression = C1ProTiffCompressLZW;
        } else {
            TIFFrecipe.recipe.TIFFCompression = C1ProTiffCompressNone;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ProgressViewController sharedInstance] updateProgressBar:4];
    });
    
    JPEGrecipe = [JPEGrecipe selectRecipeByName:@"IP JPEG"];
    TIFFrecipe = [TIFFrecipe selectRecipeByName:@"IP TIFF"];
    
    if (TIFFrecipe != nil) NSLog(@"TIFF: %@", self.TIFFrecipe.recipe.rootFolderLocation);
    if (JPEGrecipe != nil) NSLog(@"JPEG: %@", self.JPEGrecipe.recipe.rootFolderLocation);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ProgressViewController sharedInstance] updateProgressBar:4];
    });

    NSLog(@"Finished creating recipes via C1AppController");
    
        return;
}

- (void) browse:(NSURL *)theFolder {
   
    C1ProDocument *main = [[C1Pro documents] objectAtIndex:0];
    [main browseToPath:[theFolder relativePath]];
    
}

- (void) processCurrentFolderWithRecipe:(NSString*) recipeName {
    
    //NSLog(@"Processing with recipe: %@", recipeName);
    
    if (stopIteration) {
        return;
    }

    C1ProDocument *main = [[C1Pro documents] objectAtIndex:0];

    
    SBElementArray *images = [main images];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ProgressViewController sharedInstance] resetProgressBar];
        });
    
    // NSLog(@"Count of Images: %lu", (unsigned long)[images count]);
    
    for (C1ProImage *image in images) {
        
        if (stopIteration) {
            break;
        }
        
     //   NSLog(@"\r***********************\rImage: %@\r***********************\r", image.name);
        
        SBElementArray *variants = [image variants];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ProgressViewController sharedInstance] updateProgressBar:[images count]];
        });
        
        if ((variants.count > 1) && (mainWindow.renameVariants.state)){
            main.outputNameFormat = @"Image Name/ - Variant /Variant Position";
            for (C1ProVariant *variant in variants) {
                NSString *processResult = [variant processRecipe:recipeName];
                
                if ([processResult hasPrefix:@"ERROR"]) {
                    NSLog(@"process error: %@", processResult);
                } else {
                   // NSLog(@"Successfully processed: %@", image.name);
                }
                
                if (!self.discussionOver) break;
                
            }
        } else {
            main.outputNameFormat = @"Image Name/Sub Name";
            NSString *processResult = [[variants objectAtIndex:0] processRecipe:recipeName];
            
            if ([processResult hasPrefix:@"ERROR"]) {
                NSLog(@"process error: %@", processResult);
            } else {
                //NSLog(@"Successfully processed: %@", image.name);
            }
        }
        if (!self.discussionOver) {
            break;
        }
    }
    
}
- (void) iterate {
    
    // Iteration commands
    
    BOOL JPEG = [mainWindow.saveAsJPEG state];
    BOOL TIFF = [mainWindow.saveAsTIFF state];
    
    JPEGrecipe = [JPEGrecipe selectRecipeByName:@"IP JPEG"];
    TIFFrecipe = [TIFFrecipe selectRecipeByName:@"IP TIFF"];
    
    C1Pro.processingDoneScript = @"";
    C1Pro.batchDoneScript = @"display notification \"C1 Image Processor Complete\" \rtell application \"Capture One\" to set batch done script to \"\"";
    
    NSLog(@"\r\t\t***********************\r\t\tBeginning Iteration\r\t\t***********************");
    
    if (mainWindow.captureFolder == nil) {
        NSLog(@"ERROR: Capture folder not set");
        return;
    }
    
    void (^iterateBlock)(void);
    
    iterateBlock = ^ {
        
        NSFileManager *filemanager = [NSFileManager defaultManager];
        
        NSDirectoryEnumerator *dirEnumerator = [filemanager enumeratorAtURL:mainWindow.captureFolder
                                                 includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, nil]
                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                               errorHandler:nil];
        
        NSString *statusPath =[[mainWindow.captureFolder relativePath] lastPathComponent];
        NSString *updateStatusString = [NSString stringWithFormat:@"Processing folder:  ../%@", statusPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"updateStatusString: %@", updateStatusString);
            [[ProgressViewController sharedInstance] updateStatus:updateStatusString];
        });
        
        [self browse:mainWindow.captureFolder];
        
        
        
        if (JPEG) [self processCurrentFolderWithRecipe:@"IP JPEG"];
        if (TIFF) [self processCurrentFolderWithRecipe:@"IP TIFF"];
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
        [[ProgressViewController sharedInstance] updateStatus:updateStatusString];
        });
        
        
        for (NSURL *theURL in dirEnumerator){
            // Exit loop if told to stop / cancel
            if (stopIteration){
                break;
            }
            
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            
            
            if ([isDirectory boolValue] == NO) continue;
            
            
            NSString *fileName;
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            
            // Skip over CaptureOne folder
            if ([fileName isEqualToString:@"CaptureOne"]) {
                [dirEnumerator skipDescendants];
                continue;
            }
            
            NSString *addendum = [[theURL relativePath] substringFromIndex:[[mainWindow.captureFolder relativePath] length]+1];
            //NSLog(@"Addendum: %@", addendum);
            
            
            if (JPEG){
                
                NSURL *jpegURL = [JPEGrecipe.baseOutputFolder URLByAppendingPathComponent:addendum];
                NSLog(@"jpegURL: %@", jpegURL);
                [JPEGrecipe updateLocation:jpegURL];
            }
            
            if (TIFF) {
                
                NSURL *tiffURL = [TIFFrecipe.baseOutputFolder URLByAppendingPathComponent:addendum];
                NSLog(@"tiffURL: %@", tiffURL);
                [TIFFrecipe updateLocation:tiffURL];
            }
            
            [self browse:theURL];
            
            statusPath = [[mainWindow.captureFolder lastPathComponent] stringByAppendingFormat:@"/%@", addendum];
            updateStatusString = [NSString stringWithFormat:@"../%@", statusPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ProgressViewController sharedInstance] updateStatus:updateStatusString];
            });
            
            
            if (JPEG) [self processCurrentFolderWithRecipe:@"IP JPEG"];
            if (TIFF) [self processCurrentFolderWithRecipe:@"IP TIFF"];
            
        }
        NSLog(@"\r***********************\rIteration Complete\r***********************\r");
        
        
        // Finished so move to complete window
        if (!stopIteration) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSUserNotification *notification  = [[NSUserNotification alloc]init];
                notification.title = @"C1Pros Image Processor Complete";
                //notification.informativeText = @"";
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                
                CompletionViewController *completeWindow = [[CompletionViewController sharedInstance] initWithNibName:@"CompleteWindow" bundle:[NSBundle mainBundle]];
                
                [completeWindow.view.window makeKeyAndOrderFront:nil];
                [[ProgressViewController sharedInstance].view.window orderOut:nil];
            });
        }
        
    };  // End of Block
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, iterateBlock);
    
    
}

- (BOOL) checkRegistration {
    
    self.discussionOver = [[ActivationController sharedInstance] checkRegistrationForAppID:@"C1PIP" inFolder:@"C1Pros Image Processor" forFile:@"C1PIPlicense" isHidden:NO];
    
    if (self.discussionOver) {
        //[self.mainWindow.view.window setTitle:@"C1Pros Image Processor"];
        return YES;
        
    } else {
        //[self.mainWindow.view.window setTitle:@"C1Pros Image Processor *DEMO MODE*"];
        return NO;
    }
}

-(void) saveRegistration {
    /*
    NSLog(@"Saving Registration Information");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationSupportFolder = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    NSURL *newDir = [applicationSupportFolder URLByAppendingPathComponent:@"C1Pros Image Processor" isDirectory:YES];
    NSLog(@"newDir: %@", newDir);
    
    if (![fileManager fileExistsAtPath:[newDir relativePath]]){
        NSLog(@"creating registration directory");
        NSError *error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:newDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error != nil) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"success!");
        }
        
    }

    // Encrypts license key again when writing license file
    NSMutableData *archiveData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiveData];
    
    [archiver setRequiresSecureCoding:YES];
    [archiver encodeObject:[ActivationController sharedInstance].keyDiscussionPoints forKey:@"mediumformat1"];
    [archiver finishEncoding];
    
  
    NSDictionary *discussionInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[ActivationController sharedInstance].keyName, [ActivationController sharedInstance].keyContact, archiveData, nil] forKeys: [NSArray arrayWithObjects:@"keyName", @"keyContact", @"keyDiscussionPoints", nil] ];
    [discussionInfo writeToFile:[[newDir URLByAppendingPathComponent:@".C1PIPlicense"] relativePath] atomically:YES];
 */
    BOOL saved = [[ActivationController sharedInstance] saveRegistrationInFolder:@"C1Pros Image Processor" asFile:@"C1PIPlicense" isHidden:NO];
    
    if (!saved) {
        NSLog(@"Error saving Registration");
    }
}
- (void) saveDefaults {
    NSLog(@"Saving Defaults");
    
    prefs = [NSUserDefaults standardUserDefaults];
    
    // General Preferences
    [prefs setObject:mainWindow.groupingMenu.titleOfSelectedItem forKey:@"Grouping"];
    [prefs setBool:mainWindow.renameVariants.state forKey:@"renameVariants"];
    
    NSLog(@"General defaults set.");
    
    // JPEG prefs
    [prefs setBool:mainWindow.saveAsJPEG.state forKey:@"SaveAsJPEG"];
    [prefs setBool:mainWindow.resizeJPEG.state forKey:@"ResizeJPEG"];
    [prefs setObject:mainWindow.qualityJPEG.stringValue forKey:@"qualityJPEG"];
    [prefs setObject:mainWindow.jpegICC.titleOfSelectedItem forKey:@"jpegICC"];
    [prefs setObject:mainWindow.resolutionJPEG.stringValue forKey:@"resolutionJPEG"];
    
    if (mainWindow.resizeJPEG.state) {
        [prefs setObject:mainWindow.jpegW.stringValue forKey:@"jpegW"];
        [prefs setObject:mainWindow.jpegH.stringValue forKey:@"jpegH"];
    } else {
        [prefs setObject:@"" forKey:@"jpegW"];
        [prefs setObject:@"" forKey:@"jpegH"];
    }
    
    [prefs setBool:mainWindow.jpegDisableSharpening.state forKey:@"jpegDisableSharpening"];
    [prefs setBool:mainWindow.jpegIgnoreCrop.state forKey:@"jpegIgnoreCrop"];
    [prefs setBool:mainWindow.jpegIncludeRating.state forKey:@"jpegIncludeRating"];
    [prefs setBool:mainWindow.jpegIncludeCopyright.state forKey:@"jpegIncludeCopyright"];
    [prefs setBool:mainWindow.jpegIncludeGPS.state forKey:@"jpegIncludeGPS"];
    [prefs setBool:mainWindow.jpegIncludeCamera.state forKey:@"jpegIncludeCamera"];
    [prefs setBool:mainWindow.jpegIncludeOther.state forKey:@"jpegIncludeOther"];
    
    NSLog(@"JPEG defaults set.");
    
    
    // TIFF prefs
    [prefs setBool:mainWindow.saveAsTIFF.state forKey:@"SaveAsTIFF"];
    [prefs setBool:mainWindow.resizeTIFF.state forKey:@"ResizeTIFF"];
    [prefs setObject:mainWindow.tiffICC.titleOfSelectedItem forKey:@"tiffICC"];
    [prefs setObject:mainWindow.resolutionTIFF.stringValue forKey:@"resolutionTIFF"];
    [prefs setObject:mainWindow.tiffCompression.titleOfSelectedItem forKey:@"tiffCompression"];
    [prefs setObject:mainWindow.bitDepthTIFF.titleOfSelectedItem forKey:@"bitDepthTIFF"];
    
    if (mainWindow.resizeTIFF.state) {
        [prefs setObject:mainWindow.tiffW.stringValue forKey:@"tiffW"];
        [prefs setObject:mainWindow.tiffH.stringValue forKey:@"tiffH"];
    } else {
        [prefs setObject:@"" forKey:@"tiffW"];
        [prefs setObject:@"" forKey:@"tiffH"];
    }
    
    [prefs setBool:mainWindow.tiffDisableSharpening.state forKey:@"tiffDisableSharpening"];
    [prefs setBool:mainWindow.tiffIgnoreCrop.state forKey:@"tiffIgnoreCrop"];
    [prefs setBool:mainWindow.tiffIncludeRating.state forKey:@"tiffIncludeRating"];
    [prefs setBool:mainWindow.tiffIncludeCopyright.state forKey:@"tiffIncludeCopyright"];
    [prefs setBool:mainWindow.tiffIncludeGPS.state forKey:@"tiffIncludeGPS"];
    [prefs setBool:mainWindow.tiffIncludeCamera.state forKey:@"tiffIncludeCamera"];
    [prefs setBool:mainWindow.tiffIncludeOther.state forKey:@"tiffIncludeOther"];
    
    NSLog(@"TIFF defaults set.");
    
    // Save the defaults
    [prefs synchronize];
    
    NSLog(@"Defaults successfully saved.");

}

- (void) loadDefaults {
    NSLog(@"Loading Defaults");
    
    prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs stringForKey:@"Grouping"]) {
        NSLog(@"Prefs found");

        // General Preferences
        [MainViewController sharedInstance].ignoreEventsWarning = [prefs boolForKey:@"ignoreEventsWarning"];
        
        [[[MainViewController sharedInstance] groupingMenu] selectItemWithTitle:[prefs stringForKey:@"Grouping"]];
        [[MainViewController sharedInstance] changeGrouping:self];
        
        [[[MainViewController sharedInstance] renameVariants] setState:[prefs boolForKey:@"renameVariants"]];
        
        // Load Available ICCs
        [[MainViewController sharedInstance].jpegICC removeAllItems];
        [[[MainViewController sharedInstance] jpegICC] addItemsWithTitles:[prefs stringArrayForKey:@"AvailableICCs"]];
        
        [[[MainViewController sharedInstance] tiffICC] removeAllItems];
        [[[MainViewController sharedInstance] tiffICC] addItemsWithTitles:[prefs stringArrayForKey:@"AvailableICCs"]];
        
        // JPEG prefs
        [[mainWindow saveAsJPEG] setState:[prefs boolForKey:@"SaveAsJPEG"]];
        [[mainWindow resizeJPEG] setState:[prefs boolForKey:@"ResizeJPEG"]];
        
        if (!mainWindow.resizeJPEG.state) {
            [[mainWindow jpegW] setEnabled:NO];
            [[mainWindow jpegH] setEnabled: NO];
            
        }
        
        [[mainWindow qualityJPEG] setStringValue:[prefs stringForKey:@"qualityJPEG"]];
        
        [[mainWindow jpegICC]selectItemWithTitle:[prefs stringForKey:@"jpegICC"]];
        [[mainWindow resolutionJPEG] setStringValue:[prefs stringForKey:@"resolutionJPEG"]];
        
        [[mainWindow jpegW] setStringValue:[prefs stringForKey:@"jpegW"]];
        [[mainWindow jpegH] setStringValue:[prefs stringForKey:@"jpegH"]];
        
        [[mainWindow jpegDisableSharpening] setState:[prefs boolForKey:@"jpegDisableSharpening"]];
        [[mainWindow jpegIgnoreCrop] setState:[prefs boolForKey:@"jpegIgnoreCrop"]];
        [[mainWindow jpegIncludeRating] setState:[prefs boolForKey:@"jpegIncludeRating"]];
        [[mainWindow jpegIncludeCopyright] setState:[prefs boolForKey:@"jpegIncludeCopyright"]];
        [[mainWindow jpegIncludeGPS] setState:[prefs boolForKey:@"jpegIncludeGPS"]];
        [[mainWindow jpegIncludeCamera] setState:[prefs boolForKey:@"jpegIncludeCamera"]];
        [[mainWindow jpegIncludeOther] setState:[prefs boolForKey:@"jpegIncludeOther"]];
        
        
        // TIFF prefs
        
        [[mainWindow saveAsTIFF] setState:[prefs boolForKey:@"SaveAsTIFF"]];
        [[mainWindow resizeTIFF] setState:[prefs boolForKey:@"ResizeTIFF"]];
        [[mainWindow tiffICC] selectItemWithTitle:[prefs stringForKey:@"tiffICC"]];
        [[mainWindow resolutionTIFF] setStringValue:[prefs stringForKey:@"resolutionTIFF"]];
        [[mainWindow tiffCompression] selectItemWithTitle:[prefs stringForKey:@"tiffCompression"]];
        [[mainWindow bitDepthTIFF] selectItemWithTitle:[prefs stringForKey:@"bitDepthTIFF"]];
        
        [[mainWindow tiffW] setStringValue:[prefs stringForKey:@"tiffW"]];
        [[mainWindow tiffH] setStringValue:[prefs stringForKey:@"tiffH"]];
        
        [[mainWindow tiffDisableSharpening] setState:[prefs boolForKey:@"tiffDisableSharpening"]];
        [[mainWindow tiffIgnoreCrop] setState:[prefs boolForKey:@"tiffIgnoreCrop"]];
        [[mainWindow tiffIncludeRating] setState:[prefs boolForKey:@"tiffIncludeRating"]];
        [[mainWindow tiffIncludeCopyright] setState:[prefs boolForKey:@"tiffIncludeCopyright"]];
        [[mainWindow tiffIncludeGPS] setState:[prefs boolForKey:@"tiffIncludeGPS"]];
        [[mainWindow tiffIncludeCamera] setState:[prefs boolForKey:@"tiffIncludeCamera"]];
        [[mainWindow tiffIncludeOther] setState:[prefs boolForKey:@"tiffIncludeOther"]];
    
    } else {
        NSLog(@"Prefs missing");
        [self initiateDefaults];
        [self loadDefaults];
    }
    
    [self checkRegistration];
}

- (void) initiateDefaults {
    NSLog(@"Initiating Defaults");
    
    prefs = [NSUserDefaults standardUserDefaults];
    
    // General Preferences
    [prefs setObject:@"Sub Folder" forKey:@"Grouping"];
    [prefs setBool:YES forKey:@"renameVariants"];
    [prefs setBool:NO forKey:@"ignoreEventsWarning"];
    
    // Available ICCs
    NSArray *ICCs = [NSArray arrayWithObjects: @"Choose Before Processing", @"Embed camera profile", @"Adobe RGB (1998)", @"sRGB Color Space Profile", @"ProPhoto", @"Generic CMYK Profile", nil];
    
    [prefs setObject:ICCs forKey:@"AvailableICCs"];
    
    
    // JPEG prefs
    [prefs setBool:YES forKey:@"SaveAsJPEG"];
    [prefs setBool:NO forKey:@"ResizeJPEG"];
    [prefs setObject:@"100" forKey:@"qualityJPEG"];
    [prefs setObject:@"sRGB Color Space Profile" forKey:@"jpegICC"];
    [prefs setObject:@"72" forKey:@"resolutionJPEG"];
    
    [prefs setObject:@"" forKey:@"jpegW"];
    [prefs setObject:@"" forKey:@"jpegH"];
    
    [prefs setBool:NO forKey:@"jpegDisableSharpening"];
    [prefs setBool:NO forKey:@"jpegIgnoreCrop"];
    [prefs setBool:NO forKey:@"jpegIncludeRating"];
    [prefs setBool:YES forKey:@"jpegIncludeCopyright"];
    [prefs setBool:YES forKey:@"jpegIncludeGPS"];
    [prefs setBool:YES forKey:@"jpegIncludeCamera"];
    [prefs setBool:YES forKey:@"jpegIncludeOther"];
    
    
    // TIFF prefs
    [prefs setBool:YES forKey:@"SaveAsTIFF"];
    [prefs setBool:NO forKey:@"ResizeTIFF"];
    [prefs setObject:@"Adobe RGB (1998)" forKey:@"tiffICC"];
    [prefs setObject:@"300" forKey:@"resolutionTIFF"];
    [prefs setObject:@"Uncompressed" forKey:@"tiffCompression"];
    [prefs setObject:@"16 bit" forKey:@"bitDepthTIFF"];
    
    [prefs setObject:@"" forKey:@"tiffW"];
    [prefs setObject:@"" forKey:@"tiffH"];
    
    [prefs setBool:NO forKey:@"tiffDisableSharpening"];
    [prefs setBool:NO forKey:@"tiffIgnoreCrop"];
    [prefs setBool:NO forKey:@"tiffIncludeRating"];
    [prefs setBool:YES forKey:@"tiffIncludeCopyright"];
    [prefs setBool:YES forKey:@"tiffIncludeGPS"];
    [prefs setBool:YES forKey:@"tiffIncludeCamera"];
    [prefs setBool:YES forKey:@"tiffIncludeOther"];
    
    // Save the defaults
    [prefs synchronize];
    
}

- (void) cancelProcessingAndClearBatchQueue {
    stopIteration = YES;
    
    C1ProDocument *main = [[C1Pro documents] objectAtIndex:0];
    main.processingQueueEnabled = NO;
    
    [[main jobs] removeAllObjects];
    
    main.processingQueueEnabled = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSUserNotification *notification  = [[NSUserNotification alloc]init];
        notification.title = @"C1Pros Image Processor Cancelled";
        //notification.informativeText = @"Capture One wasn't running. Opening Capture One Pro.";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
    
        CompletionViewController *cancelledWindow = [[CompletionViewController sharedInstance] initWithNibName:@"CancelledWindow" bundle:[NSBundle mainBundle]];
        
        [cancelledWindow.view.window makeKeyAndOrderFront:nil];
        [[ProgressViewController sharedInstance].view.window orderOut:nil];
    });
}

@end
