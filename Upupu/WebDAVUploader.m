//
//  Uploader.m
//  Upupu
//
//  Created by David Ott on 11/18/11.
//  Copyright 2011 Xcoo, Inc. All rights reserved.
//

#import "FMWebDAVRequest.h"
#import "WebDAVUploader.h"
#import "Settings.h"

@implementation WebDAVUploader {
    NSString *_fileName;
    NSData *_imageData;
    
    BOOL _waitingOnAuthentication;
}

@synthesize success = _success;

#pragma mark - Class Method -

+ (NSString *) directoryName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *result = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    return result;
}

#pragma mark - Life cycle -

- (id) initWithName:(NSString *)fileName imageData:(NSData *)imageData
{
    self = [super init];
    
    if (!self) {
        return nil;
    }

    _imageData = [imageData retain];
    _fileName = [fileName retain];
    
    return self;
}

- (void)upload
{
    _success = YES;
    
    _waitingOnAuthentication = YES;
    
    NSMutableString *baseURL = nil;
    
    // validate server path
    NSString *settingURL = [Settings webDAVURL];
    
    if( [settingURL characterAtIndex:([settingURL length] -1)] != '/' ) {
        baseURL = [NSMutableString stringWithFormat:@"%@/", settingURL];
    } else {
        baseURL = [NSMutableString stringWithString:settingURL];
    }
    
    // validate http scheme
    NSRange httpRange = [baseURL rangeOfString:@"http://"];
    NSRange httpsRange = [baseURL rangeOfString:@"https://"];
    
    if( httpRange.location == NSNotFound && 
        httpsRange.location == NSNotFound ) {
        _success = NO;
        return; // TODO error message
    }
    
    // fetch directory
    [[FMWebDAVRequest requestToURL:NSStringToURL(baseURL)
                          delegate:self
                       endSelector:@selector(requestDidFetchDirectoryListingAndTestAuthenticationDidFinish:)
                       contextInfo:nil] fetchDirectoryListing];
    
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    while (_waitingOnAuthentication && [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        usleep(100000);
    }
    
    if ( !_success ) {
        return;
    }
    
    NSString *directoryName = [WebDAVUploader directoryName];
    
    // set URL and directory folder
    NSString *dirURL = [baseURL stringByAppendingFormat:@"%@/", directoryName];
    
    // creat a new folder, if it doesnt exist
    [[[FMWebDAVRequest requestToURL:NSStringToURL(dirURL) delegate:self endSelector:nil contextInfo:nil] synchronous] createDirectory];
    
    // put
    NSString *putURL = [baseURL stringByAppendingFormat:@"%@/%@.jpg", directoryName, _fileName];
    
    NSData *data = [NSData dataWithData:_imageData];
    
    [[[FMWebDAVRequest requestToURL:NSStringToURL(putURL) delegate:self endSelector:nil contextInfo:nil] synchronous] putData:data];
}

- (void)dealloc
{
    SAFE_RELEASE(_imageData)
    SAFE_RELEASE(_fileName)
    
    [super dealloc];
}

#pragma mark - FMWebDAVRequestDelegate -

- (void)request:(FMWebDAVRequest *)request didFailWithError:(NSError *)error
{
    _success = NO;
}

- (void)request:(FMWebDAVRequest *)request hadStatusCodeErrorWithResponse:(NSHTTPURLResponse *)httpResponse
{
    _success = NO;
}

- (void)request:(FMWebDAVRequest *)request didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{
    NSString *username = [Settings webDAVUser];
    NSString *password = [Settings webDAVPassword];
    
    NSInteger prvFailCnt = [challenge previousFailureCount];
    if (prvFailCnt == 0) {
        NSURLCredential *cred = [NSURLCredential credentialWithUser:username
                                                           password:password
                                                        persistence:NSURLCredentialPersistenceForSession];
        
        [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
    } else {
        _success = NO;
        _waitingOnAuthentication = NO;
    }
}

- (void)requestDidFetchDirectoryListingAndTestAuthenticationDidFinish:(FMWebDAVRequest *)req 
{
    if( req.error != nil ) {
        _success = NO;
    }
    
    _waitingOnAuthentication = NO;
}

@end
