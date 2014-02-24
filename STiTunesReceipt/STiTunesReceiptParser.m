//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STiTunesReceiptParser.h"
#import "STiTunesAppReceipt+Internal.h"

#import <STASN1der/STASN1der.h>


static struct STASN1derIdentifier const STPKCS7ContentType = {
    .class = STASN1derIdentifierClassUniversal,
    .constructed = NO,
    .tag = STASN1derIdentifierTagOBJECTIDENTIFIER,
};

NSUInteger const STPKCS7DataOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 1 };
static NSIndexPath *STPKCS7DataOID = nil;
NSUInteger const STPKCS7SignedDataOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 2 };
static NSIndexPath *STPKCS7SignedDataOID = nil;
NSUInteger const STPKCS7EnvelopedDataOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 3 };
static NSIndexPath *STPKCS7EnvelopedDataOID = nil;
NSUInteger const STPKCS7SignedAndEnvelopedDataOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 4 };
static NSIndexPath *STPKCS7SignedAndEnvelopedDataOID = nil;
NSUInteger const STPKCS7DigestedDataOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 5 };
static NSIndexPath *STPKCS7DigestedDataOID = nil;
NSUInteger const STPKCS7EncryptedDataOIDIndexes[] = { 1, 2, 840, 113549, 1, 7, 6 };
static NSIndexPath *STPKCS7EncryptedDataOID = nil;

static struct STASN1derIdentifier const STPKCS7SignedDataData = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = YES,
    .tag = STASN1derIdentifierTagEOC,
};

static NSString * const STiTunesReceiptParserDateRegExpPattern = @""
"^"
"(\\d{4})(?:-(\\d{2})(?:-(\\d{2})(?:T(\\d{2})(?::(\\d{2})(?:(?::(\\d{2})(?:.(\\d+))?)?(?:(Z|([+-])(\\d\\d):(\\d\\d)))?)?)?)?)?)?"
"$";
static NSRegularExpression *STiTunesReceiptParserDateRegExp = nil;


@implementation STiTunesReceiptParser

+ (void)initialize {
    if (self == [STiTunesReceiptParser class]) {
        STPKCS7DataOID = [[NSIndexPath alloc] initWithIndexes:STPKCS7DataOIDIndexes length:sizeof(STPKCS7DataOIDIndexes)/sizeof(STPKCS7DataOIDIndexes[0])];
        STPKCS7SignedDataOID = [[NSIndexPath alloc] initWithIndexes:STPKCS7SignedDataOIDIndexes length:sizeof(STPKCS7SignedDataOIDIndexes)/sizeof(STPKCS7SignedDataOIDIndexes[0])];
        STPKCS7EnvelopedDataOID = [[NSIndexPath alloc] initWithIndexes:STPKCS7EnvelopedDataOIDIndexes length:sizeof(STPKCS7EnvelopedDataOIDIndexes)/sizeof(STPKCS7EnvelopedDataOIDIndexes[0])];
        STPKCS7SignedAndEnvelopedDataOID = [[NSIndexPath alloc] initWithIndexes:STPKCS7SignedAndEnvelopedDataOIDIndexes length:sizeof(STPKCS7SignedAndEnvelopedDataOIDIndexes)/sizeof(STPKCS7SignedAndEnvelopedDataOIDIndexes[0])];
        STPKCS7DigestedDataOID = [[NSIndexPath alloc] initWithIndexes:STPKCS7DigestedDataOIDIndexes length:sizeof(STPKCS7DigestedDataOIDIndexes)/sizeof(STPKCS7DigestedDataOIDIndexes[0])];
        STPKCS7EncryptedDataOID = [[NSIndexPath alloc] initWithIndexes:STPKCS7EncryptedDataOIDIndexes length:sizeof(STPKCS7EncryptedDataOIDIndexes)/sizeof(STPKCS7EncryptedDataOIDIndexes[0])];
        STiTunesReceiptParserDateRegExp = [[NSRegularExpression alloc] initWithPattern:STiTunesReceiptParserDateRegExpPattern options:0 error:NULL];
    }
}

+ (NSDate *)st_dateForString:(NSString *)string {
    if (string.length == 0) {
        return nil;
    }
    NSArray * const matches = [STiTunesReceiptParserDateRegExp matchesInString:string options:0 range:(NSRange){ .length = [string length] }];

	NSTextCheckingResult * const match = [matches lastObject];
	NSRange const yearRange = [match rangeAtIndex:1];
	NSRange const monthRange = [match rangeAtIndex:2];
	NSRange const dayRange = [match rangeAtIndex:3];
	NSRange const hourRange = [match rangeAtIndex:4];
	NSRange const minuteRange = [match rangeAtIndex:5];
	NSRange const secondRange = [match rangeAtIndex:6];
	NSRange const timezoneRange = [match rangeAtIndex:8];
	NSRange const timezonesignRange = [match rangeAtIndex:9];
	NSRange const timezonehourRange = [match rangeAtIndex:10];
	NSRange const timezoneminuteRange = [match rangeAtIndex:11];

	NSDateComponents * const components = [[NSDateComponents alloc] init];
	components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

	if (yearRange.location != NSNotFound) {
		components.year = [[string substringWithRange:yearRange] integerValue];
	}
	if (monthRange.location != NSNotFound) {
		components.month = [[string substringWithRange:monthRange] integerValue];
	}
	if (dayRange.location != NSNotFound) {
		components.day = [[string substringWithRange:dayRange] integerValue];
	}
	if (hourRange.location != NSNotFound) {
		components.hour = [[string substringWithRange:hourRange] integerValue];
	}
	if (minuteRange.location != NSNotFound) {
		components.minute = [[string substringWithRange:minuteRange] integerValue];
	}
	if (secondRange.location != NSNotFound) {
		components.second = [[string substringWithRange:secondRange] integerValue];
	}
	if (timezoneRange.location != NSNotFound) {
		NSString * const timezonestring = [string substringWithRange:timezoneRange];
		if (![@"Z" isEqualToString:timezonestring]) {
			NSInteger const timezonesign = [@"-" isEqualToString:[string substringWithRange:timezonesignRange]] ? -1 : 1;
			NSInteger const timezonehour = [[string substringWithRange:timezonehourRange] integerValue];
			NSInteger const timezoneminute = [[string substringWithRange:timezoneminuteRange] integerValue];
			components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:timezonesign * ((timezonehour * 60 + timezoneminute) * 60)];
		}
	}

	NSCalendar * const gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	gregorian.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

	NSDate * const date = [gregorian dateFromComponents:components];
    return date;
}

+ (STiTunesAppReceipt *)receiptWithData:(NSData *)data error:(NSError * __autoreleasing *)error {
    NSArray * const objects = [STASN1derParser objectsFromASN1Data:data error:error];
    if (!objects) {
        return nil;
    }

    if (objects.count != 1) {
        return nil;
    }

    id const documentFirstObject = objects.firstObject;
    if (![documentFirstObject isKindOfClass:[NSArray class]]) {
        return nil;
    }

    NSArray * const sequence = documentFirstObject;

    STASN1derObject * const contentTypeOIDObject = [sequence objectAtIndex:0];
    if (!STASN1derIdentifierEqual(contentTypeOIDObject.identifier, STPKCS7ContentType)) {
        return nil;
    }
    NSIndexPath * const contentTypeOID = STASN1derObjectIdentifierIndexPathFromData(contentTypeOIDObject.content);
    if ([STPKCS7SignedDataOID isEqual:contentTypeOID]) {
        if (sequence.count < 2) {
            return nil;
        }
        STASN1derObject * const contentObject = [sequence objectAtIndex:1];
        return [self st_receiptWithPKCS7SignedData:contentObject.content error:error];
    } else {
        return nil;
    }

    return nil;
}

+ (STiTunesAppReceipt *)st_receiptWithPKCS7SignedData:(NSData *)data error:(NSError * __autoreleasing *)error {
    NSArray * const objects = [STASN1derParser objectsFromASN1Data:data error:error];
    if (objects.count != 1) {
        return nil;
    }
    NSArray * const sequence = objects.firstObject;
    if (sequence.count < 3) {
        return nil;
    }
    NSNumber * const version = [sequence objectAtIndex:0];
    if (version.unsignedIntegerValue != 1) {
        return nil;
    }
    //XXX maybe verify the signed data?
//    NSArray * const digestAlgorithms = [sequence objectAtIndex:1];
    id const contentInfo = [sequence objectAtIndex:2];

    /*
     version Version,
     digestAlgorithms DigestAlgorithmIdentifiers,
     contentInfo ContentInfo,
     certificates
     [0] IMPLICIT ExtendedCertificatesAndCertificates
     OPTIONAL,
     crls
     [1] IMPLICIT CertificateRevocationLists OPTIONAL,
     signerInfos SignerInfos }
     */
    return [self st_receiptWithPKCS7SignedDataObjects:contentInfo error:error];
}

+ (STiTunesAppReceipt *)st_receiptWithPKCS7SignedDataObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error {
    if (objects.count < 2) {
        return nil;
    }
    STASN1derObject * const contentTypeOIDObject = objects.firstObject;
    NSIndexPath * const contentTypeOID = STASN1derObjectIdentifierIndexPathFromData(contentTypeOIDObject.content);
    if ([STPKCS7DataOID isEqual:contentTypeOID]) {
        return [self st_receiptWithPKCS7DataObject:[objects objectAtIndex:1] error:error];
    }
    return nil;
}

+ (STiTunesAppReceipt *)st_receiptWithPKCS7DataObject:(STASN1derObject *)object error:(NSError * __autoreleasing *)error {
    if (!STASN1derIdentifierEqual(object.identifier, STPKCS7SignedDataData)) {
        return nil;
    }
    NSArray * const objects = [STASN1derParser objectsFromASN1Data:object.content error:error];
    if (objects.count != 1) {
        return nil;
    }
    id const dataObject = objects.firstObject;
    if (![dataObject isKindOfClass:[NSData class]]) {
        return nil;
    }
    return [self st_receiptWithPKCS7DataObjectData:dataObject error:error];
}

+ (STiTunesAppReceipt *)st_receiptWithPKCS7DataObjectData:(NSData *)data error:(NSError * __autoreleasing *)error {
    NSArray * const objects = [STASN1derParser objectsFromASN1Data:data error:error];
    if (objects.count != 1) {
        return nil;
    }
    NSSet * const receiptFields = objects.firstObject;
    return [[STiTunesAppReceipt alloc] initWithAppReceiptFields:receiptFields];
}

@end
