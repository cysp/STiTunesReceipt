//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STiTunesReceiptParser.h"

#import <STASN1der/STASN1der.h>
#import "STCMS.h"

// https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/ValidateAppStoreReceipt.pdf


static NSString * const STiTunesReceiptParserDateRegExpPattern = @""
"^"
"(\\d{4})(?:-(\\d{2})(?:-(\\d{2})(?:T(\\d{2})(?::(\\d{2})(?:(?::(\\d{2})(?:.(\\d+))?)?(?:(Z|([+-])(\\d\\d):(\\d\\d)))?)?)?)?)?)?"
"$";
static NSRegularExpression *STiTunesReceiptParserDateRegExp = nil;


@implementation STiTunesReceiptParser

+ (void)initialize {
    if (self == [STiTunesReceiptParser class]) {
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
    STCMSContent * const document = [STCMSParser contentWithData:data];
    if (![document isKindOfClass:[STCMSSignedDataContent class]]) {
        return nil;
    }

    STCMSSignedDataContent * const signedDataContent = (STCMSSignedDataContent *)document;
    if (![signedDataContent verifySignature]) {
        return nil;
    }
    // verify signature

    STCMSContent * const encapsulatedContent = signedDataContent.encapsulatedContent;
    if (![encapsulatedContent isKindOfClass:[STCMSDataContent class]]) {
        return nil;
    }
    STCMSDataContent * const encapsulatedDataContent = (STCMSDataContent *)encapsulatedContent;
    return [self receiptWithUnsignedData:encapsulatedDataContent.content error:error];
}
+ (STiTunesAppReceipt *)receiptWithUnsignedData:(NSData *)data error:(NSError *__autoreleasing *)error {
    NSArray * const objects = [STASN1derParser objectsFromASN1Data:data error:error];
    if (objects.count != 1) {
        return nil;
    }

    STASN1derSetObject * const receiptFields = objects.firstObject;
    if (![receiptFields isKindOfClass:[STASN1derSetObject class]]) {
        return nil;
    }

    return [[STiTunesAppReceipt alloc] initWithASN1Set:receiptFields];
}

@end
