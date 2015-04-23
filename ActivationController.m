//
//  ActivationController.m
//  Image Processor V2
//
//  Created by Josh Booth on 3/25/15.
//  Copyright (c) 2015 Capture Integration, Inc. All rights reserved.
//

#import "ActivationController.h"

#import <openssl/rsa.h>
#import <openssl/pem.h>
#import <openssl/err.h>
#import <openssl/ssl.h>
#import <openssl/bio.h>
#import <openssl/evp.h>


#import "JSRSA.h"
#import "ActivationViewController.h"
#import <IOKit/IOKitLib.h>


@implementation ActivationController

@synthesize keyName;
@synthesize keyContact;
@synthesize keyDiscussionPoints;
@synthesize appID;



+ (ActivationController *) sharedInstance {
    static ActivationController * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (BOOL) checkRegistration:(NSString *)userKey userName:(NSString *)name userEmail:(NSString *)contact {
    
    keyName = name;
    keyContact = contact;
    keyDiscussionPoints = userKey;
    
    
    BOOL results = [self decryptAndCompare];
    
    return results;
}


- (BOOL) decryptAndCompare {
    [JSRSA sharedInstance].publicKey = @"public_key.pem";
    
   // NSLog(@"\r\tkeyName = %@ \r\tkeyContact = %@", keyName, keyContact);
    
    NSString *results = [[JSRSA sharedInstance] publicDecrypt:keyDiscussionPoints];
    
   // NSLog (@"results: %@", results);
    
    NSString *compareString = [appID stringByAppendingFormat:@" - %@ - %@", keyName, keyContact];
    
    if ([results isEqualToString:compareString]){
        return YES;
    } else {
        return NO;
    }
}

- (NSDictionary *) getLicenseInfoFromFolder:(NSString *)appFolder forFile:(NSString *)filename isHidden:(BOOL)isHidden {

    NSLog(@"getting license info for window");
    
    self.appFolder = appFolder;
    
    if (isHidden) {
        self.licenseFileName = [NSString stringWithFormat:@".%@", filename];
    } else {
        self.licenseFileName = filename;
    }
    
    //NSLog(@"licenseFile = %@", [appFolder stringByAppendingFormat:@"/%@", self.licenseFileName]);
    
    NSString *hardwareID = [self getSystemUUID];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *newDir = [[fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:[appFolder stringByAppendingFormat:@"/%@", self.licenseFileName]];
    
    NSLog(@"Registration Exists? %i", [fileManager fileExistsAtPath:[newDir relativePath]]);
    
    if ([fileManager fileExistsAtPath:[newDir relativePath]]) {
        NSDictionary *discussionInfo = [NSDictionary dictionaryWithContentsOfFile:[newDir relativePath]];
        
        // Gets the encrypted key from the license file then decrypts it
        NSData *encryptedKey = [discussionInfo objectForKey:@"keyDiscussionPoints"];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver  alloc] initForReadingWithData:encryptedKey];
        [unarchiver setRequiresSecureCoding:YES];
        //NSString *results = [unarchiver decodeObjectForKey:@"mediumformat1"];
        //[unarchiver finishDecoding];
        
        NSString *results = [[NSString  alloc] init];
        @try {
            results = [unarchiver decodeObjectForKey:hardwareID];
            if (results == nil) {
                NSLog(@"Error reading key - hardware id may be different");
                return NO;
            }
            [unarchiver finishDecoding];
        }
        @catch (NSException *exception) {
            NSLog(@"Error: %@", [exception description]);
            [unarchiver finishDecoding];
            results = @"ERROR";
            return NO;
        }

        
        NSArray *theKeys = [NSArray arrayWithObjects:@"userName", @"userEmail", @"userLicense", nil];
        NSArray *theData = [NSArray arrayWithObjects:[discussionInfo objectForKey:@"keyName"], [discussionInfo objectForKey:@"keyContact"], results, nil];
        
        NSDictionary *returnInfo = [NSDictionary dictionaryWithObjects: theData
                                                                forKeys:theKeys];
        return returnInfo;
        
    } else {
        return nil;
    }
    
}

- (BOOL) checkRegistrationForAppID:(NSString*)theAppID
                          inFolder:(NSString *)appFolder
                           forFile:(NSString*)filename
                          isHidden:(BOOL)isHidden {
    
    NSLog(@"Checking Registration");
    
    appID = theAppID;
    
    BOOL isRegistered;
    
    self.appFolder = appFolder;
    
    if (isHidden) {
        self.licenseFileName = [NSString stringWithFormat:@".%@", filename];
    } else {
        self.licenseFileName = filename;
    }
    
    NSString *hardwareID = [self getSystemUUID];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *newDir = [[fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:[appFolder stringByAppendingFormat:@"/%@", self.licenseFileName]];
    
    NSLog(@"Registration Exists? %i", [fileManager fileExistsAtPath:[newDir relativePath]]);
    
    if ([fileManager fileExistsAtPath:[newDir relativePath]]) {
        NSDictionary *discussionInfo = [NSDictionary dictionaryWithContentsOfFile:[newDir relativePath]];
        
        // Gets the encrypted key from the license file then decrypts it
            NSData *encryptedKey = [discussionInfo objectForKey:@"keyDiscussionPoints"];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver  alloc] initForReadingWithData:encryptedKey];
            [unarchiver setRequiresSecureCoding:YES];
        
        NSString *results = [[NSString  alloc] init];
        @try {
            results = [unarchiver decodeObjectForKey:hardwareID];
            if (results == nil) {
                NSLog(@"Error reading key - hardware id may be different");
                return NO;
            }
            [unarchiver finishDecoding];
            //NSLog(@"results: %@", results);
        }
        @catch (NSException *exception) {
            NSLog(@"Error: %@", [exception description]);
            [unarchiver finishDecoding];
            results = @"ERROR";
            return NO;
        }
        
        isRegistered = [self checkRegistration:results userName:[discussionInfo objectForKey:@"keyName"] userEmail:[discussionInfo objectForKey:@"keyContact"]];
        
        if (isRegistered){
            [ActivationViewController sharedInstance].userName.stringValue = [discussionInfo objectForKey:@"keyName"];
            [ActivationViewController sharedInstance].userName.editable = NO;
            [ActivationViewController sharedInstance].userName.refusesFirstResponder = YES;
            
            [ActivationViewController sharedInstance].userEmail.stringValue = [discussionInfo objectForKey:@"keyContact"];
            [ActivationViewController sharedInstance].userEmail.editable = NO;
            [ActivationViewController sharedInstance].userEmail.refusesFirstResponder = YES;
            
            [ActivationViewController sharedInstance].userKey.stringValue = results;
            [ActivationViewController sharedInstance].userKey.editable = NO;
            [ActivationViewController sharedInstance].userKey.refusesFirstResponder = YES;
        
            [ActivationViewController sharedInstance].activationStatus.stringValue = @"Activated";
            [ActivationViewController sharedInstance].activationStatus.textColor = [ActivationViewController sharedInstance].activatedGreen;
            
            
            return YES;
        } else {
            return NO;
        }
        
    } else {
        return NO;
    }
    
}

- (BOOL) deactivateMeinFolder:(NSString *)appFolder
                           forFile:(NSString*)filename
                     isHidden:(BOOL)isHidden {
    BOOL deactivated;
    
    self.appFolder = appFolder;
    
    if (isHidden) {
        self.licenseFileName = [NSString stringWithFormat:@".%@", filename];
    } else {
        self.licenseFileName = filename;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *newDir = [[fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:[appFolder stringByAppendingFormat:@"/%@", self.licenseFileName]];
    
    NSLog(@"deactivating file: %@", newDir);
    
    if ([fileManager fileExistsAtPath:[newDir relativePath]]) {
        NSError *error;
        deactivated = [fileManager removeItemAtPath:[newDir relativePath] error:&error];
        if (deactivated) {
            NSLog(@"Sucessfully Deactivated");
        return YES;
        } else {
            NSLog(@"error deactivating: %@", [error description]);
            return NO;
        }
    } else {
        NSLog(@"Not Deactivated");
        return NO;
    }
    
    
}

- (NSString *)getSystemUUID {
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert)
        return nil;
    
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformUUIDKey),kCFAllocatorDefault, 0);
    IOObjectRelease(platformExpert);
    if (!serialNumberAsCFString)
        return nil;
    
    return (__bridge NSString *)(serialNumberAsCFString);;
}

- (BOOL) saveRegistrationInFolder:(NSString*)appFolder asFile:(NSString *)filename isHidden:(BOOL)isHidden {
    
    
    NSLog(@"Saving Registration Information");
    
    self.appFolder = appFolder;
    if (isHidden) {
        self.licenseFileName = [NSString stringWithFormat:@".%@", filename];
    } else {
        self.licenseFileName = filename;
    }
    
    
    NSString *hardwareID = [self getSystemUUID];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationSupportFolder = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    NSURL *newDir = [applicationSupportFolder URLByAppendingPathComponent:self.appFolder isDirectory:YES];

    // Check to see if application folder exists
    if (![fileManager fileExistsAtPath:[newDir relativePath]]){
        NSLog(@"creating registration directory");
        NSError *error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:newDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error != nil) {
            NSLog(@"Error: %@", error);
            return NO;
        } else {
            NSLog(@"success!");
        }
        
    }
    
    // Encrypts license key again when writing license file
    NSMutableData *archiveData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiveData];
    
    [archiver setRequiresSecureCoding:YES];
    // encrypts key again using hardwareID for cypher
    [archiver encodeObject:self.keyDiscussionPoints forKey:hardwareID];
    [archiver finishEncoding];
    
    
    NSDictionary *discussionInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.keyName, self.keyContact, archiveData, nil] forKeys: [NSArray arrayWithObjects:@"keyName", @"keyContact", @"keyDiscussionPoints", nil] ];
    
    // write license info to the file
    return ([discussionInfo writeToFile:[[newDir URLByAppendingPathComponent:self.licenseFileName] relativePath] atomically:YES]);
    
}

- (NSString*)rebuildLicense:(NSString *)license {
    /*
    NSLog(@"Key: %@", license);
    NSArray *keyParts;
    
        keyParts = [license componentsSeparatedByString:@"\n"];
    if ([keyParts count] < 4) {
         keyParts = [license componentsSeparatedByString:@"\r"];
             if ([keyParts count] < 4) {
                 keyParts = [license componentsSeparatedByString:@" "];
             } else {
                 NSLog(@"Error rebuilding license.");
                 return license;
             }
    }
    */
    NSArray *keyParts = [license componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"KeyParts: %@", keyParts);
    NSString *fullKey = [NSString stringWithFormat:@"%@%@%@%@", [keyParts objectAtIndex:0], [keyParts objectAtIndex:1], [keyParts objectAtIndex:2], [keyParts objectAtIndex:3]];
    NSLog(@"fullKey: %@", fullKey);
    
    //NSString *fullKey = [license componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSLog(@"fullKey = %@", fullKey);
    self.keyDiscussionPoints = fullKey;
    return fullKey;
    
}
- (NSString *) breakApartLicense:(NSString *)license {
    NSRange line1 = {0, 43};
    NSRange line2 = {43, 43};
    NSRange line3 = {86, 43};
    NSRange line4 = {129, 43};
    
    NSString *keyLine1 = [license substringWithRange:line1];
    NSLog(@"line1: %@", keyLine1);
    
    NSString *keyLine2 = [license substringWithRange:line2];
    NSLog(@"line2: %@", keyLine2);
    
    NSString *keyLine3 = [license substringWithRange:line3];
    NSLog(@"line3: %@", keyLine3);
    
    NSString *keyLine4 = [license substringWithRange:line4];
    NSLog(@"line4: %@", keyLine4);
    
    
    NSString *niceLicense = [NSString stringWithFormat:@"%@\r%@\r%@\r%@",keyLine1, keyLine2, keyLine3, keyLine4 ];
    
    return niceLicense;
}

@end
