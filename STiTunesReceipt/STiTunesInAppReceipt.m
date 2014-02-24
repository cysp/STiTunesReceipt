//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STiTunesInAppReceipt.h"
#import "STiTunesReceiptParser+Internal.h"

#import <STASN1der/STASN1der.h>


typedef NS_ENUM(NSUInteger, STiTunesInAppReceiptValueType) {
    STiTunesInAppReceiptValueTypeQuantity = 1701,
    STiTunesInAppReceiptValueTypeProductIdentifier = 1702,
    STiTunesInAppReceiptValueTypeTransactionIdentifier = 1703,
    STiTunesInAppReceiptValueTypePurchaseDate = 1704,
    STiTunesInAppReceiptValueTypeOriginalTransactionIdentifier = 1705,
    STiTunesInAppReceiptValueTypeOriginalPurchaseDate = 1706,
    STiTunesInAppReceiptValueTypeExpiresDate = 1708,
    STiTunesInAppReceiptValueTypeWebOrderItemID = 1711,
    STiTunesInAppReceiptValueTypeCancellationDate = 1712,
};


@implementation STiTunesInAppReceipt

- (id)init {
    return [self initWithInAppPurchaseReceiptFields:nil];
}

- (id)initWithInAppPurchaseReceiptFields:(NSSet *)fields {
    NSUInteger quantity = 0;
    NSString *productId = nil;
    NSString *transactionId = nil;
    NSDate *purchaseDate = nil;
    NSString *originalTransactionId = nil;
    NSDate *originalPurchaseDate = nil;
    NSDate *expiresDate = nil;
    NSUInteger webOrderLineItemID = 0;
    NSDate *cancellationDate = nil;

    for (NSArray *field in fields) {
        NSNumber * const type = [field objectAtIndex:0];
        NSNumber * const version = [field objectAtIndex:1];
        if (version.unsignedIntegerValue != 1) {
            return nil;
        }
        NSData * const value = [field objectAtIndex:2];
        switch ((STiTunesInAppReceiptValueType)type.unsignedIntegerValue) {
            case STiTunesInAppReceiptValueTypeQuantity: {
                NSNumber * const quantityNumber = [STASN1derParser objectFromASN1Data:value error:NULL];
                quantity = quantityNumber.unsignedIntegerValue;
            } break;
            case STiTunesInAppReceiptValueTypeProductIdentifier: {
                productId = [STASN1derParser objectFromASN1Data:value error:NULL];
            } break;
            case STiTunesInAppReceiptValueTypeTransactionIdentifier: {
                transactionId = [STASN1derParser objectFromASN1Data:value error:NULL];
            } break;
            case STiTunesInAppReceiptValueTypePurchaseDate: {
                NSString * const dateString = [STASN1derParser objectFromASN1Data:value error:NULL];
                purchaseDate = [STiTunesReceiptParser st_dateForString:dateString];
            } break;
            case STiTunesInAppReceiptValueTypeOriginalTransactionIdentifier: {
                originalTransactionId = [STASN1derParser objectFromASN1Data:value error:NULL];
            } break;
            case STiTunesInAppReceiptValueTypeOriginalPurchaseDate: {
                NSString * const dateString = [STASN1derParser objectFromASN1Data:value error:NULL];
                originalPurchaseDate = [STiTunesReceiptParser st_dateForString:dateString];
            } break;
            case STiTunesInAppReceiptValueTypeExpiresDate: {
                NSString * const dateString = [STASN1derParser objectFromASN1Data:value error:NULL];
                expiresDate = [STiTunesReceiptParser st_dateForString:dateString];
            } break;
            case STiTunesInAppReceiptValueTypeWebOrderItemID: {
                NSNumber * const webOrderItemIDNumber = [STASN1derParser objectFromASN1Data:value error:NULL];
                webOrderLineItemID = webOrderItemIDNumber.unsignedIntegerValue;
            } break;
            case STiTunesInAppReceiptValueTypeCancellationDate: {
                NSString * const dateString = [STASN1derParser objectFromASN1Data:value error:NULL];
                cancellationDate = [STiTunesReceiptParser st_dateForString:dateString];
            } break;
        }
    }

    if ((self = [super init])) {
        _quantity = quantity;
        _productId = productId.copy;
        _transactionId = transactionId.copy;
        _purchaseDate = purchaseDate.copy;
        _originalTransactionId = originalTransactionId.copy;
        _originalPurchaseDate = originalPurchaseDate.copy;
        _expiresDate = expiresDate.copy;
        _webOrderLineItemId = webOrderLineItemID;
        _cancellationDate = cancellationDate.copy;
    }
    return self;
}

@end
