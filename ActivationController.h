//
//  ActivationController.h
//  Image Processor V2
//
//  Created by Josh Booth on 3/25/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ActivationController;

@interface ActivationController : NSObject

@property (strong) NSString *keyName;
@property (strong) NSString *keyContact;
@property (strong) NSString *keyDiscussionPoints;
@property (strong) NSString *appID;

@property NSString *appFolder;
@property NSString *licenseFileName;

+ (ActivationController *) sharedInstance;

- (BOOL) deactivateMeinFolder:(NSString *)appFolder
                      forFile:(NSString*)filename
                     isHidden:(BOOL)isHidden;

- (BOOL) checkRegistration:(NSString *)key userName:(NSString *)name userEmail:(NSString *)contact;

- (BOOL) saveRegistrationInFolder:(NSString*)appFolder asFile:(NSString *)filename isHidden:(BOOL)isHidden;

- (BOOL) checkRegistrationForAppID:(NSString*)theAppID
                          inFolder:(NSString *)appFolder
                           forFile:(NSString*)filename
                          isHidden:(BOOL)isHidden;

- (NSDictionary *) getLicenseInfoFromFolder:(NSString *)appFolder
                                    forFile:(NSString *)filename
                                   isHidden:(BOOL)isHidden;
@end
