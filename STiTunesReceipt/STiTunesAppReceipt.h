//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>

@class STASN1derSetObject;


@interface STiTunesAppReceipt : NSObject
- (id)initWithASN1Set:(STASN1derSetObject *)set;
@property (nonatomic,copy,readonly) NSString *bundleId;
@property (nonatomic,copy,readonly) NSString *applicationVersion;
@property (nonatomic,copy,readonly) NSString *originalApplicationVersion;
@property (nonatomic,copy,readonly) NSDate *expirationDate;
@property (nonatomic,copy,readonly) NSArray *inApp;
- (BOOL)validateWithBundleIdentifier:(NSString *)bundleIdentifier version:(NSString *)version guidData:(NSData *)guidData;
@end
