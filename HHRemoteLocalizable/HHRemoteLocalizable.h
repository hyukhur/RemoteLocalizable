//
//  HHRemoteLocalizable.h
//  HHRemoteLocalizable
//
//  Created by hyukhur on 2013. 12. 31..
//  Copyright (c) 2013년 hyukhur. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HHLocalizedString(key, comment) \
        HHLocalizedStringFromTable(key, nil, comment)
#define HHLocalizedStringFromTable(key, tbl, comment) \
        HHLocalizedStringFromTableInBundle(key, tbl, [HHRemoteLocalizable defautlLocalizable].remoteBundle, comment) ? HHLocalizedStringFromTableInBundle(key, tbl, [HHRemoteLocalizable defautlLocalizable].remoteBundle, comment) :HHLocalizedStringFromTableInBundle(key, tbl, [NSBundle mainBundle], comment)
#define HHLocalizedStringFromTableInBundle(key, tbl, bundle, comment) \
        HHLocalizedStringWithDefaultValue(key, tbl, bundle, @"", tbl)
#define HHLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) \
        [bundle localizedStringForKey:(key) value:(val) table:(tbl)]

@class HHRemoteLocalizableSettings;

@interface HHRemoteLocalizable : NSObject
@property HHRemoteLocalizableSettings *setting;
@property (readonly) NSBundle *remoteBundle;
- (BOOL)setBundleWithURL:(NSURL *)URL;

+ (HHRemoteLocalizable *)defautlLocalizable;
@end
