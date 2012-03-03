//
//  Dropbox.m
//  Upupu
//
//  Created by T. Takeuchi on 1/24/12.
//  Copyright 2012 Xcoo, Inc. All rights reserved.
//

#import "DropboxUploader.h"

#import <DropboxSDK/DropboxSDK.h>
#import "Settings.h"


@interface DropboxUploader () <DBSessionDelegate, DBRestClientDelegate> {
    DBRestClient *_restClient;
}

- (void) startSession;
- (void) makeRestClient;
- (void) removeTmpImagefile;
- (void) loadAccount;

@end

@implementation DropboxUploader

@synthesize success = _success;

const static NSString *kDBTmpFilename = @"db_tmp.jpg";
static BOOL uploading = NO;

#pragma mark - Singleton -

static DropboxUploader *instance = nil;

+ (id)sharedInstance
{
    if (!instance) {
        instance = [[self alloc] init];   
    }
    return instance;   
}

#pragma mark - Lifecycle -

- (id)init
{
    self = [super init];
    if (self) {
        [self startSession];
    }
    return self;
}

- (void)dealloc
{
    SAFE_RELEASE(_restClient)
    
    [super dealloc];
}

#pragma mark - Actions -

- (BOOL) handleURL:(NSURL *)url
{
    if ([[DBSession sharedSession] handleOpenURL:url]) {
		if ([[DBSession sharedSession] isLinked]) {
            [self loadAccount];
			[Settings setDropboxEnabled:YES];
		}
		return YES;
	}
    
	return NO;
}

- (void)startSession
{
    DBSession *dbSession = [[DBSession alloc] initWithAppKey:kDBAppKey
                                                   appSecret:kDBAppSecret
                                                        root:kDBRootDropbox];
    dbSession.delegate = self;
    [DBSession setSharedSession:dbSession];
    [dbSession release];
}

- (BOOL)isLinked
{
    return [[DBSession sharedSession] isLinked];
}

- (void)link
{
    [[DBSession sharedSession] link];
}

- (void)makeRestClient
{
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
}

- (void)uploadWithName:(NSString *)filename imageData:(NSData *)imageData
{
    [self makeRestClient];
    
    _success = YES;
    
    NSString *dbSaveDirectory;
    NSString *dbFilename;
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    dbSaveDirectory = [NSString stringWithFormat:@"%@/%@", kDBSaveDirectory, [formatter stringFromDate:now]];

    if (!filename || [filename isEqualToString:@""]) {
        [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
        filename = [NSString stringWithFormat:@"%@", [formatter stringFromDate:now]];
    }
    dbFilename = [NSString stringWithFormat:@"%@.jpg", filename];
    
    [formatter release];
    
    // save image in temporary directory
    NSString *filePath = [NSString stringWithFormat:@"%@%@" , NSTemporaryDirectory(), kDBTmpFilename];  
    if ([imageData writeToFile:filePath atomically:YES]) {
        Logging(@"Suceed to write a temporary image file");
        Logging(@"Path: %@", filePath);
    } else {
        Logging(@"Failed to write a temporary image file");
        return;
    }

    // upload to Dropbox
    [_restClient uploadFile:dbFilename toPath:dbSaveDirectory withParentRev:nil fromPath:filePath];
    
    // wait for synchronous
    uploading = YES;
    while (uploading) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

// delete the temporary file
- (void)removeTmpImagefile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSString stringWithFormat:@"%@%@" , NSTemporaryDirectory(), kDBTmpFilename];
    [fileManager removeItemAtPath:filePath error:nil];
}

- (void)loadAccount
{
    [self makeRestClient];
    [_restClient loadAccountInfo];
}

#pragma mark - DBSessionDelegate -

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId
{
    Logging(@"sessionDidReceiveAuthorizationFailure")
}

#pragma mark - DBRestClientDelegate -

- (void)restClient:(DBRestClient *)client
      uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath
          metadata:(DBMetadata *)metadata 
{
    Logging(@"Succeeded to upload to Dropbox")
    Logging(@"Path: %@", metadata.path);
    [self removeTmpImagefile];
    uploading = NO;
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error 
{
    Logging(@"Fail to upload to Dropbox - %@", error)
    [self removeTmpImagefile];
    _success = NO;
    uploading = NO;
}

- (void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info {
    [Settings dropboxAccount:[info displayName]];
}

@end
