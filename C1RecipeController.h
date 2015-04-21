//
//  C1Recipe.h
//  Image Processor V2
//
//  Created by Josh Booth on 1/22/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "C1Pro.h"

@class C1RecipeController;

@interface C1RecipeController : NSObject

@property NSString *recipeName;

@property (nonatomic) NSMutableString *outputSubFolder;
@property (nonatomic) NSString *outputFormat;
@property (nonatomic) NSURL *baseOutputFolder;

@property BOOL waitBeforeProcessing;

@property BOOL shouldResize;
@property NSString *iccProfile;
@property NSInteger *dpi;
@property (nonatomic) C1ProScalingType scalingMethod;
@property (nonatomic) C1ProMeasurementUnit scalingUnit;

// jpegW/tiffW & jpegH/tiffH
@property (nonatomic) NSNumber *primaryScaleValue;
@property (nonatomic) NSNumber *secondaryScaleValue;

@property BOOL disableSharpening;
@property BOOL ignoreCrop;
@property BOOL includeRating;
@property BOOL includeCopyright;
@property BOOL includeGPS;
@property BOOL includeCamera;
@property BOOL includeOther;



// JPEG-specific options
@property NSInteger JPEGquality;


// TIFF-specific options
@property NSInteger bits;
@property NSString *compression;



// common functionality with Capture One Pro
@property C1ProApplication *C1Pro;
@property C1ProDocument *mainSession;
@property (nonatomic) C1ProRecipe *recipe;



-(instancetype)initWithFormat:(NSString *)imgFormat;

-(void)createRecipe;

-(void)updateLocation:(NSURL *)newLocation;

-(instancetype)selectRecipeByName:(NSString *)name;


@end
