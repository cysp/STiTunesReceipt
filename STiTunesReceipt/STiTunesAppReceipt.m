//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STiTunesAppReceipt.h"
#import "STiTunesInAppReceipt+Internal.h"
#import "STiTunesReceiptParser+Internal.h"

#import <STASN1der/STASN1der.h>


typedef NS_ENUM(NSUInteger, STiTunesReceiptValueType) {
    STiTunesReceiptValueTypeBundleId = 2,
    STiTunesReceiptValueTypeApplicationVersion = 3,
    STiTunesReceiptValueTypeOpaqueValue = 4,
    STiTunesReceiptValueTypeSHA1Hash = 5,
    STiTunesReceiptValueTypeInAppPurchaseReceipt = 17,
    STiTunesReceiptValueTypeOriginalApplicationVersion = 19,
    STiTunesReceiptValueTypeExpirationDate = 21,
};


@implementation STiTunesAppReceipt

- (id)init {
    return [self initWithAppReceiptFields:nil];
}

- (id)initWithAppReceiptFields:(NSSet *)fields {
    NSString *bundleId = nil;
    NSString *applicationVersion = nil;
    NSString *originalApplicationVersion = nil;
    NSDate *expirationDate = nil;
    NSMutableArray * const inApp = [[NSMutableArray alloc] init];
    for (NSArray *receiptAttribute in fields) {
        NSNumber * const type = [receiptAttribute objectAtIndex:0];
//        NSNumber * const version = [inAppAttribute objectAtIndex:1];
//        if (version.unsignedIntegerValue != 1) {
//            return nil;
//        }
        NSData * const value = [receiptAttribute objectAtIndex:2];
        switch ((STiTunesReceiptValueType)type.unsignedIntegerValue) {
            case STiTunesReceiptValueTypeOpaqueValue:
                NSLog(@"opaqueValue: %@", value);
                break;
            case STiTunesReceiptValueTypeSHA1Hash:
                NSLog(@"sha1Hash: %@", value);
                break;
            case STiTunesReceiptValueTypeBundleId: {
                id const valueObject = [STASN1derParser objectFromASN1Data:value error:NULL];
                bundleId = valueObject;
            } break;
            case STiTunesReceiptValueTypeApplicationVersion: {
                id const valueObject = [STASN1derParser objectFromASN1Data:value error:NULL];
                applicationVersion = valueObject;
            } break;
            case STiTunesReceiptValueTypeOriginalApplicationVersion: {
                id const valueObject = [STASN1derParser objectFromASN1Data:value error:NULL];
                originalApplicationVersion = valueObject;
            } break;
            case STiTunesReceiptValueTypeExpirationDate: {
                NSString * const dateString = [STASN1derParser objectFromASN1Data:value error:NULL];
                expirationDate = [STiTunesReceiptParser st_dateForString:dateString];
            } break;
            case STiTunesReceiptValueTypeInAppPurchaseReceipt: {
                NSArray * const valueObjects = [STASN1derParser objectsFromASN1Data:value error:NULL];
                if (valueObjects.count != 1) {
                    return nil;
                }

                NSSet * const inAppReceiptFields = valueObjects.firstObject;
                STiTunesInAppReceipt * const inAppReceipt = [[STiTunesInAppReceipt alloc] initWithInAppPurchaseReceiptFields:inAppReceiptFields];
                if (inAppReceipt) {
                    [inApp addObject:inAppReceipt];
                }
            } break;
        }
    }

    if (!bundleId || !applicationVersion || !originalApplicationVersion) {
        return nil;
    }
    if ((self = [super init])) {
        _bundleId = bundleId.copy;
        _applicationVersion = applicationVersion.copy;
        _originalApplicationVersion = originalApplicationVersion.copy;
        _expirationDate = expirationDate.copy;
        _inApp = inApp.copy;
    }
    return self;
}

@end
