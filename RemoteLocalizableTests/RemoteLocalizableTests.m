//
//  RemoteLocalizableTests.m
//  RemoteLocalizableTests
//
//  Created by hyukhur on 2013. 12. 31..
//  Copyright (c) 2013년 hyukhur. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <AGAsyncTestHelper/AGWaitForAsyncTestHelper.h>
#import <TCBlobDownload/TCBlobDownloadManager.h>

#import "HHRemoteLocalizable.h"

@interface HHRemoteLocalizable ()
@property NSBundle *remoteBundle;
- (NSBundle *)bundleWithUnzipFile:(NSString *)pathToFile error:(NSError **)error;
- (BOOL)bundleForURL:(NSURL *)URL completion:(void(^)(NSBundle *, NSError *))aCompletionBlock;
@end

@interface RemoteLocalizableTests : XCTestCase
@property HHRemoteLocalizable *localizable;
@end

@implementation RemoteLocalizableTests

- (void)setUp
{
    self.localizable = [HHRemoteLocalizable defautlLocalizable];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.localizable.remoteBundle = nil;
}

- (void)testDownloadFromLocal {
    NSURL *bundleURL = [[NSBundle bundleForClass:[self class]] resourceURL];
    NSURL *remotedBundleURL = [bundleURL URLByAppendingPathComponent:@"LocalizedBundle.bundle.zip"];
    XCTAssertNotNil(self.localizable);
    __block BOOL downloaded = NO;
    [self.localizable bundleForURL:remotedBundleURL completion:^(NSBundle *bundle, NSError *error) {
        XCTAssertNotNil(bundle);
        XCTAssertNil(error);
        downloaded = YES;
    }];
    AG_STALL_RUNLOPP_WHILE(downloaded, 60);
}



- (void) testSettupRemoteBundle {
    NSURL *bundleURL = [[[NSBundle bundleForClass:[self class]] resourceURL] URLByAppendingPathComponent:@"LocalizedBundle.bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    XCTAssertNotNil(bundle, @"Bundle Set up Fail.");
    XCTAssertNil(self.localizable.remoteBundle, @"Test Clean up");
    self.localizable.remoteBundle = bundle;
    XCTAssertNotNil(self.localizable.remoteBundle, @"Remote Bundle setting up Fail");
    NSString *localizedString = HHLocalizedString(@"String Number 1", @"Comment");
    XCTAssert([localizedString isEqualToString:@"Localized String Number 1 in Bundle"], @"Localized Value loading Fail in HHLocalizedString");
}


- (void) testUnzipBundleFile {
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString *remotedBundlePath = [bundlePath stringByAppendingPathComponent:@"LocalizedBundle.bundle.zip"];
    NSError *error = nil;
    NSBundle *bundle = [self.localizable bundleWithUnzipFile:remotedBundlePath error:&error];
    XCTAssertNotNil(bundle);
    XCTAssertNil(error);
}


- (void) testLoadHHLocalizedStringFromZippedBundle {
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString *remotedBundlePath = [bundlePath stringByAppendingPathComponent:@"LocalizedBundle.bundle.zip"];
    NSError *error = nil;
    NSBundle *bundle = [self.localizable bundleWithUnzipFile:remotedBundlePath error:&error];
    XCTAssertNotNil(bundle);
    XCTAssertNil(error);
    NSString *localizedString = [bundle localizedStringForKey:@"String Number 1" value:nil table:nil];
    XCTAssertNotNil(localizedString);
    XCTAssert([localizedString isEqualToString:@"Localized String Number 1 in Bundle"], @"Localized Value loading Fail in HHLocalizedString");
}


- (void) testLoadHHLocalizedStringWithBundleSetting {
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString *remotedBundlePath = [bundlePath stringByAppendingPathComponent:@"LocalizedBundle.bundle.zip"];
    NSError *error = nil;
    NSBundle *bundle = [self.localizable bundleWithUnzipFile:remotedBundlePath error:&error];
    self.localizable.remoteBundle = bundle;
    XCTAssertNotNil(self.localizable.remoteBundle);
    NSString *localizedString = HHLocalizedString(@"String Number 1", @"Comment");
    XCTAssertNotNil(localizedString);
    XCTAssert([localizedString isEqualToString:@"Localized String Number 1 in Bundle"], @"Localized Value loading Fail in HHLocalizedString");
}


- (void) testLoadHHLocalizedString {
    NSURL *bundleURL = [[NSBundle bundleForClass:[self class]] resourceURL];
    NSURL *remotedBundleURL = [bundleURL URLByAppendingPathComponent:@"LocalizedBundle.bundle.zip"];
    [self.localizable setBundleWithURL:remotedBundleURL];
    __block BOOL downloaded = NO;
    [self.localizable bundleForURL:remotedBundleURL completion:^(NSBundle *bundle, NSError *error) {
        self.localizable.remoteBundle = bundle;
        XCTAssertNil(error);
        downloaded = YES;
    }];
    AG_STALL_RUNLOPP_WHILE(downloaded, 60);
    
    XCTAssertNotNil(self.localizable.remoteBundle);
    NSString *localizedString = HHLocalizedString(@"String Number 1", @"Comment");
    XCTAssert([localizedString isEqualToString:@"Localized String Number 1 in Bundle"], @"Localized Value loading Fail in HHLocalizedString");
}


/**
 when there are remote bundles, then search the localized string in older remote bundles
 */
- (void) _testLoadOldHHLocalizedString {
    NSURL *bundleURL = [[NSBundle bundleForClass:[self class]] resourceURL];
    NSURL *remotedBundleURL = [bundleURL URLByAppendingPathComponent:@"LocalizedBundle.bundle.zip"];
    [self.localizable setBundleWithURL:remotedBundleURL];
    __block BOOL downloaded = NO;
    [self.localizable bundleForURL:remotedBundleURL completion:^(NSBundle *bundle, NSError *error) {
        self.localizable.remoteBundle = bundle;
        XCTAssertNil(error);
        downloaded = YES;
    }];
    AG_STALL_RUNLOPP_WHILE(downloaded, 60);

    remotedBundleURL = [bundleURL URLByAppendingPathComponent:@"LocalizedBundle.20140101.bundle.zip"];
    [self.localizable setBundleWithURL:remotedBundleURL];
    downloaded = NO;
    [self.localizable bundleForURL:remotedBundleURL completion:^(NSBundle *bundle, NSError *error) {
        self.localizable.remoteBundle = bundle;
        XCTAssertNil(error);
        downloaded = YES;
    }];
    AG_STALL_RUNLOPP_WHILE(downloaded, 60);
    
    NSString *localizedString = HHLocalizedString(@"Localized Key", @"Comment");
    XCTAssert([localizedString isEqualToString:@"Localized Value in HHLocalizedString"], @"Localized Value loading Fail in HHLocalizedString");
}


- (void) testLoadNSLocalizedString {
    NSString *localizedString = NSLocalizedString(@"Localized Key", @"Comment");
    XCTAssert([localizedString isEqualToString:@"Localized Value in NSLocalizedString"], @"Localized Value loading Fail in NSLocalizedString");
}


- (void) testLoadFailInNSLocalizedString {
    [[NSBundle mainBundle] unload];
    NSString *localizedString = HHLocalizedString(@"UNLocalized Key", @"Comment");
    XCTAssert([localizedString isEqualToString:@"UNLocalized Key"], @"Localized Value loading Fail in HHLocalizedString and Load Key");

}

@end
