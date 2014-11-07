//
//  HHRemoteLocalizable.m
//  HHRemoteLocalizable
//
//  Created by hyukhur on 2013. 12. 31..
//  Copyright (c) 2013년 hyukhur. All rights reserved.
//

#import "HHRemoteLocalizable.h"
#import <SSZipArchive/SSZipArchive.h>
#import <TCBlobDownload/TCBlobDownloadManager.h>

#import "HHRemoteLocalizableSettings.h"

static HHRemoteLocalizable *gDefaultLocalizable;

@interface HHRemoteLocalizable () <SSZipArchiveDelegate>
@property NSBundle *remoteBundle;
- (BOOL)bundleForURL:(NSURL *)URL completion:(void(^)(NSBundle *, NSError *))aCompletionBlock;
@end


@implementation HHRemoteLocalizable (HHPrivate)

- (NSBundle *)bundleWithUnzipFile:(NSString *)pathToFile error:(NSError **)errorReference;
{
    if (![SSZipArchive unzipFileAtPath:pathToFile toDestination:self.setting.pathToUnzip overwrite:self.setting.isOverwrite password:@"" error:errorReference]) {
        if (!*errorReference) {
            NSError *error = [NSError errorWithDomain:HHRemoteLocalizableErrorDomain code:HHRemoteLocalizableErrorCodeUnknown userInfo:nil];
            *errorReference = error;
        }
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
            //TODO
        }
        if (!pathToFile.length)
        {
            //TODO
        }
        if (aCompletionBlock)
        {
            NSError *error = nil;
            NSBundle *bundle = [sSelf bundleWithUnzipFile:pathToFile error:&error];
            aCompletionBlock(bundle, error);
        }
        sSelf = nil;
    }];
    return download.isReady;
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
