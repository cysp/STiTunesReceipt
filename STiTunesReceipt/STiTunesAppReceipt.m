//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STiTunesAppReceipt.h"
#import "STiTunesReceiptParser+Internal.h"

#import <STASN1der/STASN1der.h>

#import <CommonCrypto/CommonCrypto.h>


typedef NS_ENUM(NSUInteger, STiTunesReceiptValueType) {
    STiTunesReceiptValueTypeEnvironment = 0,
    STiTunesReceiptValueTypeAppleId = 1,
    STiTunesReceiptValueTypeBundleId = 2,
    STiTunesReceiptValueTypeApplicationVersion = 3,
    STiTunesReceiptValueTypeOpaqueValue = 4,
    STiTunesReceiptValueTypeSHA1Hash = 5,
    STiTunesReceiptValueTypeContentAdvisoryRating = 10,
    STiTunesReceiptValueTypeDownloadId = 15,
    STiTunesReceiptValueTypeInAppPurchaseReceipt = 17,
    STiTunesReceiptValueTypeOriginalPurchaseDate = 18,
    STiTunesReceiptValueTypeOriginalApplicationVersion = 19,
    STiTunesReceiptValueTypeExpirationDate = 21,
};


static enum STiTunesAppReceiptEnvironment STiTunesAppReceiptEnvironmentFromString(NSString *string) {
    if ([@"Production" isEqualToString:string]) {
        return STiTunesAppReceiptEnvironmentProduction;
    }
    if ([@"Sandbox" isEqualToString:string]) {
        return STiTunesAppReceiptEnvironmentSandbox;
    }
    return 0;
}


@implementation STiTunesAppReceipt {
@private
    NSData *_opaqueValue;
    NSData *_sha1Hash;
}

- (id)init {
    return [self initWithASN1Set:nil];
}

- (id)initWithASN1Set:(STASN1derSetObject *)set {
    NSString *environment = nil;
    NSUInteger appleId = 0;
    NSString *bundleId = nil;
    NSData *bundleIdData = nil;
    NSString *applicationVersion = nil;
    NSString *originalApplicationVersion = nil;
    NSDate *expirationDate = nil;
    NSData *opaqueValue = nil;
    NSData *sha1Hash = nil;

    NSMutableArray * const inApp = [[NSMutableArray alloc] init];

    for (STASN1derSequenceObject *receiptAttribute in set.value) {
        if (receiptAttribute.count != 3) {
            return nil;
        }
        STASN1derIntegerObject * const type = receiptAttribute[0];
        if (![type isKindOfClass:[STASN1derIntegerObject class]]) {
            return nil;
        }
        STASN1derIntegerObject * const version = receiptAttribute[1];
        if (![version isKindOfClass:[STASN1derIntegerObject class]]) {
            return nil;
        }
//        if (version.value != 1) {
//            return nil;
//        }
        STASN1derOctetStringObject * const value = receiptAttribute[2];
        if (![value isKindOfClass:[STASN1derOctetStringObject class]]) {
            return nil;
        }
        NSData * const valueData = value.content;
        switch ((STiTunesReceiptValueType)type.value) {
            case STiTunesReceiptValueTypeEnvironment: {
                STASN1derUTF8StringObject * const valueObject = [STASN1derParser objectFromASN1Data:valueData error:NULL];
                environment = valueObject.value;
            } break;
            case STiTunesReceiptValueTypeAppleId: {
                STASN1derIntegerObject * const valueObject = [STASN1derParser objectFromASN1Data:valueData error:NULL];
                appleId = valueObject.value;
            } break;
            case STiTunesReceiptValueTypeBundleId: {
                bundleIdData = valueData;
                STASN1derUTF8StringObject * const valueObject = [STASN1derParser objectFromASN1Data:valueData error:NULL];
                bundleId = valueObject.value;
            } break;
            case STiTunesReceiptValueTypeApplicationVersion: {
                STASN1derUTF8StringObject * const valueObject = [STASN1derParser objectFromASN1Data:valueData error:NULL];
                applicationVersion = valueObject.value;
            } break;
            case STiTunesReceiptValueTypeOpaqueValue:
                opaqueValue = valueData;
                break;
            case STiTunesReceiptValueTypeSHA1Hash:
                sha1Hash = valueData;
                break;
            case STiTunesReceiptValueTypeContentAdvisoryRating:
                break;
            case STiTunesReceiptValueTypeDownloadId:
                break;
            case STiTunesReceiptValueTypeInAppPurchaseReceipt: {
                NSArray * const valueObjects = [STASN1derParser objectsFromASN1Data:valueData error:NULL];
                if (valueObjects.count != 1) {
                    return nil;
                }

                STASN1derSetObject * const inAppReceiptSet = valueObjects.firstObject;
                if (![inAppReceiptSet isKindOfClass:[STASN1derSetObject class]]) {
                    return nil;
                }
                STiTunesInAppReceipt * const inAppReceipt = [[STiTunesInAppReceipt alloc] initWithASN1Set:inAppReceiptSet];
                if (inAppReceipt) {
                    [inApp addObject:inAppReceipt];
                }
            } break;
            case STiTunesReceiptValueTypeOriginalPurchaseDate:
                break;
            case STiTunesReceiptValueTypeOriginalApplicationVersion: {
                STASN1derUTF8StringObject * const valueObject = [STASN1derParser objectFromASN1Data:valueData error:NULL];
                originalApplicationVersion = valueObject.value;
            } break;
            case STiTunesReceiptValueTypeExpirationDate: {
                STASN1derUTF8StringObject * const dateString = [STASN1derParser objectFromASN1Data:valueData error:NULL];
                expirationDate = [STiTunesReceiptParser st_dateForString:dateString.value];
            } break;
//            default: {
//                STASN1derUTF8StringObject * const valueObject = [STASN1derParser objectFromASN1Data:valueData error:NULL];
//                NSLog(@"unknown receipt field: %lld %@", type.value, valueData);
//                NSLog(@"    %@", [valueObject debugDescription]);
//            } break;
        }
    }

    if (!bundleId || !applicationVersion || !originalApplicationVersion) {
        return nil;
    }
    if ((self = [super init])) {
        _environment = STiTunesAppReceiptEnvironmentFromString(environment);
        _appleId = appleId;
        _bundleId = bundleId.copy;
        _bundleIdData = bundleIdData.copy;
        _applicationVersion = applicationVersion.copy;
        _originalApplicationVersion = originalApplicationVersion.copy;
        _expirationDate = expirationDate.copy;
        _inApp = inApp.copy;
        _opaqueValue = opaqueValue;
        _sha1Hash = sha1Hash;
    }
    return self;
}

- (BOOL)validateWithBundleIdentifier:(NSString *)bundleIdentifier version:(NSString *)version guidData:(NSData *)guidData {
    if (![_bundleId isEqualToString:bundleIdentifier]) {
        return NO;
    }
    if (![_applicationVersion isEqualToString:version]) {
        return NO;
    }

    NSData * const bundleIdData = _bundleIdData;
    NSData * const opaqueValue = _opaqueValue;
    NSData * const sha1Hash = _sha1Hash;

    CC_SHA1_CTX ctx = { 0 };
    CC_SHA1_Init(&ctx);

    void const * guidBytes = guidData.bytes;
    CC_LONG guidLength = (CC_LONG)guidData.length;
    CC_SHA1_Update(&ctx, guidBytes, guidLength);

    void const * opaqueBytes = opaqueValue.bytes;
    CC_LONG opaqueLength = (CC_LONG)opaqueValue.length;
    CC_SHA1_Update(&ctx, opaqueBytes, opaqueLength);

    void const * bundleIdBytes = bundleIdData.bytes;
    CC_LONG bundleIdLength = (CC_LONG)bundleIdData.length;
    CC_SHA1_Update(&ctx, bundleIdBytes, bundleIdLength);

    unsigned char digestBytes[CC_SHA1_DIGEST_LENGTH] = { 0 };
    CC_SHA1_Final((unsigned char *)&digestBytes, &ctx);

    NSData * const digestData = [[NSData alloc] initWithBytes:digestBytes length:CC_SHA1_DIGEST_LENGTH];
    BOOL const digestMatches = [digestData isEqualToData:sha1Hash];

    return digestMatches;
}

@end
