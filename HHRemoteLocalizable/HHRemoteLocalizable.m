//
//  HHRemoteLocalizable.m
//  HHRemoteLocalizable
//
//  Created by hyukhur on 2013. 12. 31..
//  Copyright (c) 2013년 hyukhur. All rights reserved.
//

#import "HHRemoteLocalizable.h"
#import <ZipArchive/ZipArchive.h>
#import <TCBlobDownload/TCBlobDownloadManager.h>

#import "HHRemoteLocalizableSettings.h"

static HHRemoteLocalizable *gDefaultLocalizable;

@interface HHRemoteLocalizable () <ZipArchiveDelegate>
@property NSBundle *remoteBundle;
- (BOOL)bundleForURL:(NSURL *)URL completion:(void(^)(NSBundle *, NSError *))aCompletionBlock;
@end


@implementation HHRemoteLocalizable (HHPrivate)

- (NSBundle *)bundleWithUnzipFile:(NSString *)pathToFile error:(NSError **)errorReference;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    ZipArchive *zipArchive = [[ZipArchive alloc] initWithFileManager:fileManager];
    [zipArchive setDelegate:self];
    if (![zipArchive UnzipOpenFile:pathToFile])
    {
        [zipArchive setDelegate:nil];
        NSError *error = [NSError errorWithDomain:HHRemoteLocalizableErrorDomain code:HHRemoteLocalizableErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey:@""}];
        *errorReference = error;
        return nil;
    }
    [fileManager createDirectoryAtPath:self.setting.pathToUnzip withIntermediateDirectories:YES attributes:nil error:nil];
    if (![zipArchive UnzipFileTo:self.setting.pathToUnzip overWrite:self.setting.isOverwrite])
    {
        [zipArchive setDelegate:nil];
        NSError *error = [NSError errorWithDomain:HHRemoteLocalizableErrorDomain code:HHRemoteLocalizableErrorCodeUnknown userInfo:nil];
        *errorReference = error;
        return nil;
    }
    NSString *bundleName = [[pathToFile lastPathComponent] stringByDeletingPathExtension];
    NSString *pathToUnzip = [self.setting.pathToUnzip stringByAppendingPathComponent:bundleName];
    NSBundle *bundle = [NSBundle bundleWithPath:pathToUnzip];
    return bundle;
}

@end


@implementation HHRemoteLocalizable

- (id)init
{
    self = [super init];
    if (self) {
        self.setting = [[HHRemoteLocalizableSettings alloc] init];
        self.setting.pathToUnzip = [NSTemporaryDirectory() stringByAppendingPathComponent:NSStringFromClass([self class])];
//        self.setting.pathToUnzip = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:NSStringFromClass([self class])];
    }
    return self;
}


- (BOOL)bundleForURL:(NSURL *)URL completion:(void(^)(NSBundle *, NSError *))aCompletionBlock
{
    __block HHRemoteLocalizable *sSelf = self;
    TCBlobDownloadManager *downloader = [TCBlobDownloadManager sharedDownloadManager];
    TCBlobDownload *download = [downloader startDownloadWithURL:URL customPath:nil firstResponse:nil progress:nil error:^(NSError *error) {
        if (aCompletionBlock)
        {
            aCompletionBlock(nil, error);
        }
        sSelf = nil;
    } complete:^(BOOL downloadFinished, NSString *pathToFile) {
        if (!downloadFinished)
        {
            
        }
        if (!pathToFile.length)
        {
            
        }
        if (aCompletionBlock)
        {
            NSError *error = nil;
            NSBundle *bundle = [sSelf bundleWithUnzipFile:pathToFile error:&error];
            aCompletionBlock(bundle, error);
        }
        sSelf = nil;
    }];
    return download.isExecuting;
}


- (BOOL)setBundleWithURL:(NSURL *)URL
{
    return [self bundleForURL:URL completion:^(NSBundle *bundle, NSError *error) {
        if (bundle)
        {
            self.remoteBundle = bundle;
        }
    }];
}


+ (HHRemoteLocalizable *)defautlLocalizable
{
    if (!gDefaultLocalizable)
    {
        gDefaultLocalizable = [[self alloc] init];
    };
    return gDefaultLocalizable;
}

@end
