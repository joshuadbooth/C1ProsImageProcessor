//
//  C1Recipe.m
//  Image Processor V2
//
//  Created by Josh Booth on 1/22/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//


#import "C1RecipeController.h"


@implementation C1RecipeController

@synthesize recipe;


-(instancetype) initWithFormat:(NSString *)imgFormat {
    self = [super init];
    if (self) {
        self.outputFormat = imgFormat;
        if ([imgFormat isEqualToString:@"JPEG"]) {
            self.recipeName = @"IP JPEG";
            
        } else {
            self.recipeName = @"IP TIFF";
        }
        
        self.C1Pro = [SBApplication applicationWithBundleIdentifier:@"com.phaseone.captureone8"];
        self.mainSession = [[self.C1Pro documents]objectAtIndex:0];
        [self createRecipe];
    }
    return self;
    
}


-(void) createRecipe {
    NSLog(@" ");
    NSLog(@"Creating Recipe for %@", self.outputFormat);
    
    // check to see if Capture One Pro is running
    if ([_C1Pro isRunning]){
        _mainSession = [[_C1Pro documents] objectAtIndex:0];
    }
    else {
        [_C1Pro activate];
        _mainSession = [[_C1Pro documents] objectAtIndex:0];
       
    }
    
    // now that Capture One Pro is running, get a list of existing recipes
    NSLog(@"Getting Recipes...");
    SBElementArray *ExistingRecipes = [_mainSession recipes];

    
    if ([[ExistingRecipes valueForKey:@"name"] containsObject:self.recipeName]){
        NSLog(@"Recipe Exists");
        self.recipe = [ExistingRecipes objectAtIndex:[ExistingRecipes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            BOOL found = ([[obj name] isEqualToString:self.recipeName]);
            return found;
        }]];
        NSLog(@"Recipe Name: %@", recipe.name);
        
        
        // deletes existing recipe and creates a new one.
        [[_mainSession recipes] removeObject:recipe];
        
        self.recipe = nil;
          
        self.recipe = [[[_C1Pro classForScriptingClass:@"recipe"] alloc] initWithProperties: @{@"name":self.recipeName}];
        [[_mainSession recipes] addObject:self.recipe];
         
        
    } else {
        NSLog(@"Recipe Does not Exist... Creating");
        
        self.recipe = [[[_C1Pro classForScriptingClass:@"recipe"] alloc] initWithProperties: @{@"name":self.recipeName}];
        
        [[_mainSession recipes] addObject:self.recipe];
    }
    
    recipe.rootFolderType = C1ProRecipeRootTypeOutput;
    
    
    // Output format assignment
    if ([self.outputFormat isEqualToString:@"JPEG"]) {
    recipe.outputFormat = C1ProRecipeFileFormatJPEG;
        recipe.bits = 8;
    } else {
        recipe.outputFormat = C1ProRecipeFileFormatTIFF;
    }
}

-(void)updateLocation:(NSURL *)newLocation{
    NSLog(@" ");
    NSLog(@"********\tUpdate Location\t********");
    NSLog(@"Recipe: %@", recipe.name);
    NSLog(@"Recipe rootFolderLocation: %@", recipe.rootFolderLocation);
    NSLog(@"Updating output folder to %@",[newLocation relativePath]);
    
    recipe.rootFolderLocation = newLocation;
    
    NSLog(@"New Location: %@", recipe.rootFolderLocation);
    NSLog(@"********\tLocation Update Complete.\t********\r\r");
}



-(instancetype)selectRecipeByName:(NSString *)theName {
    NSLog(@"SelectRecipeByName: %@", theName);
    
    C1ProRecipe *foundRecipe;
    
    SBElementArray *ExistingRecipes = [_mainSession recipes];
    
    if ([[ExistingRecipes valueForKey:@"name"] containsObject:theName]){
        NSLog(@"Recipe Exists");
        foundRecipe = [ExistingRecipes objectAtIndex:[ExistingRecipes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            BOOL found = ([[obj name] isEqualToString:theName]);
            return found;
        }]];
   
        self.recipe = foundRecipe;
        NSLog(@"recipe name: %@", self.recipe.name);
        return self;
        
    } else {
        NSLog(@"Cannot locate recipe");
        return NULL;
    }
}

@end
