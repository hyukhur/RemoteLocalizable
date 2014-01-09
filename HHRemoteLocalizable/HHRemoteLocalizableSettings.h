//
//  HHRemoteLocalizableSettings.h
//  RemoteLocalizable
//
//  Created by hyukhur on 2013. 12. 31..
//  Copyright (c) 2013년 hyukhur. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString *HHRemoteLocalizableErrorDomain;

typedef NS_ENUM(NSInteger, HHRemoteLocalizableErrorCode)
{
    HHRemoteLocalizableErrorCodeUnknown = 0,
};

@interface HHRemoteLocalizableSettings : NSObject
@property (getter = isOverwrite) BOOL overwrite;
@property NSString *pathToUnzip;
@end
