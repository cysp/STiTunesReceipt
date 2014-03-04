//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STCMS.h"
#import "STCMS+Internal.h"

#import <STASN1der/STASN1der.h>

// RFC 5652 - CMS http://www.rfc-editor.org/rfc/rfc5652.txt
// RFC 5280 - X.509 http://www.rfc-editor.org/rfc/rfc5280.txt
// A Layman's Guide to a Subset of ASN.1, BER, and DER ftp://ftp.rsa.com/pub/pkcs/ascii/layman.asc

// RFC 5652 4
static NSUInteger const STCMSDataContentTypeOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 1 };
NSIndexPath *STCMSDataContentTypeOID = nil;
// RFC 5652 5
static NSUInteger const STCMSSignedDataContentTypeOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 2 };
NSIndexPath *STCMSSignedDataContentTypeOID = nil;
// RFC 5652 6
static NSUInteger const STCMSEnvelopedDataContentTypeOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 3 };
NSIndexPath *STCMSEnvelopedDataContentTypeOID = nil;
// RFC 5652 7
static NSUInteger const STCMSDigestedDataContentTypeOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 5 };
NSIndexPath *STCMSDigestedDataContentTypeOID = nil;
// RFC 5652 8
static NSUInteger const STCMSEncryptedDataContentTypeOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 6 };
NSIndexPath *STCMSEncryptedDataContentTypeOID = nil;

__attribute__((constructor))
static void STCMSInitializeOIDs(void) {
    STCMSDataContentTypeOID = [[NSIndexPath alloc] initWithIndexes:STCMSDataContentTypeOIDIndexes length:sizeof(STCMSDataContentTypeOIDIndexes)/sizeof(STCMSDataContentTypeOIDIndexes[0])];
    STCMSSignedDataContentTypeOID = [[NSIndexPath alloc] initWithIndexes:STCMSSignedDataContentTypeOIDIndexes length:sizeof(STCMSSignedDataContentTypeOIDIndexes)/sizeof(STCMSSignedDataContentTypeOIDIndexes[0])];
    STCMSEnvelopedDataContentTypeOID = [[NSIndexPath alloc] initWithIndexes:STCMSEnvelopedDataContentTypeOIDIndexes length:sizeof(STCMSEnvelopedDataContentTypeOIDIndexes)/sizeof(STCMSEnvelopedDataContentTypeOIDIndexes[0])];
    STCMSDigestedDataContentTypeOID = [[NSIndexPath alloc] initWithIndexes:STCMSDigestedDataContentTypeOIDIndexes length:sizeof(STCMSDigestedDataContentTypeOIDIndexes)/sizeof(STCMSDigestedDataContentTypeOIDIndexes[0])];
    STCMSEncryptedDataContentTypeOID = [[NSIndexPath alloc] initWithIndexes:STCMSEncryptedDataContentTypeOIDIndexes length:sizeof(STCMSEncryptedDataContentTypeOIDIndexes)/sizeof(STCMSEncryptedDataContentTypeOIDIndexes[0])];
}


NSString *STCMSStringFromIndexPath(NSIndexPath *indexPath) {
    NSMutableString * const string = @"".mutableCopy;
    for (NSUInteger i = 0; i < indexPath.length; ++i) {
        if (i != 0) {
            [string appendString:@"."];
        }
        [string appendFormat:@"%lu", [indexPath indexAtPosition:i]];
    }
    return string;
}



@implementation STCMSParser

+ (STCMSContent *)contentWithData:(NSData *)data {
    NSError *error = nil;
    NSArray * const objects = [STASN1derParser objectsFromASN1Data:data error:&error];
    if (objects.count != 1) {
        return nil;
    }

    STASN1derSequenceObject * const sequence = STCMSEnsureClass(STASN1derSequenceObject, objects.firstObject);
    if (!sequence) {
        return nil;
    }

    return [[STCMSContent alloc] initWithASN1Sequence:sequence];
}

@end