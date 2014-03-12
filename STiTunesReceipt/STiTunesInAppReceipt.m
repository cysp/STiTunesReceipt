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
    STiTunesInAppReceiptValueTypeWebOrderLineItemID = 1711,
    STiTunesInAppReceiptValueTypeCancellationDate = 1712,
};


@implementation STiTunesInAppReceipt

- (id)init {
    return [self initWithASN1Set:nil];
}

- (id)initWithASN1Set:(STASN1derSetObject *)set {
    NSUInteger quantity = 0;
    NSString *productId = nil;
    NSString *transactionId = nil;
    NSDate *purchaseDate = nil;
    NSString *originalTransactionId = nil;
    NSDate *originalPurchaseDate = nil;
    NSDate *expiresDate = nil;
    NSUInteger webOrderLineItemID = 0;
    NSDate *cancellationDate = nil;

    NSMutableIndexSet * const fieldTypesSeen = [[NSMutableIndexSet alloc] init];
    for (STASN1derSequenceObject *fieldSequence in set.value) {
        if (![fieldSequence isKindOfClass:[STASN1derSequenceObject class]]) {
            return nil;
        }
        if (fieldSequence.count != 3) {
            return nil;
        }
        STASN1derIntegerObject * const type = fieldSequence[0];
        if (![type isKindOfClass:[STASN1derIntegerObject class]]) {
            return nil;
        }
        STASN1derIntegerObject * const version = fieldSequence[1];
        if (![version isKindOfClass:[STASN1derIntegerObject class]]) {
            return nil;
        }
        if (version.value != 1) {
            return nil;
        }
        STASN1derOctetStringObject * const value = fieldSequence[2];
        if (![value isKindOfClass:[STASN1derOctetStringObject class]]) {
            return nil;
        }
        NSData * const fieldValueData = value.value;

        if ([fieldTypesSeen containsIndex:type.value]) {
            return nil;
        }
        [fieldTypesSeen addIndex:type.value];

        switch ((STiTunesInAppReceiptValueType)type.value) {
            case STiTunesInAppReceiptValueTypeQuantity: {
                STASN1derIntegerObject * const quantityIntegerObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                quantity = quantityIntegerObject.value;
            } break;
            case STiTunesInAppReceiptValueTypeProductIdentifier: {
                STASN1derUTF8StringObject * const productIdStringObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                productId = productIdStringObject.value;
            } break;
            case STiTunesInAppReceiptValueTypeTransactionIdentifier: {
                STASN1derUTF8StringObject * const transactionIdStringObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                transactionId = transactionIdStringObject.value;
            } break;
            case STiTunesInAppReceiptValueTypePurchaseDate: {
                STASN1derIA5StringObject * const purchaseDateStringObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                purchaseDate = [STiTunesReceiptParser st_dateForString:purchaseDateStringObject.value];
            } break;
            case STiTunesInAppReceiptValueTypeOriginalTransactionIdentifier: {
                STASN1derUTF8StringObject * const originalTransactionIdStringObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                originalTransactionId = originalTransactionIdStringObject.value;
            } break;
            case STiTunesInAppReceiptValueTypeOriginalPurchaseDate: {
                STASN1derIA5StringObject * const originalPurchaseDateStringObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                originalPurchaseDate = [STiTunesReceiptParser st_dateForString:originalPurchaseDateStringObject.value];
            } break;
            case STiTunesInAppReceiptValueTypeExpiresDate: {
                STASN1derIA5StringObject * const expiresDateStringObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                expiresDate = [STiTunesReceiptParser st_dateForString:expiresDateStringObject.value];
            } break;
            case STiTunesInAppReceiptValueTypeWebOrderLineItemID: {
                STASN1derIntegerObject * const webOrderLineItemIdIntegerObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                webOrderLineItemID = webOrderLineItemIdIntegerObject.value;
            } break;
            case STiTunesInAppReceiptValueTypeCancellationDate: {
                STASN1derIA5StringObject * const cancellationDateStringObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
                cancellationDate = [STiTunesReceiptParser st_dateForString:cancellationDateStringObject.value];
            } break;
//            default: {
//                STASN1derUTF8StringObject * const valueObject = [STASN1derParser objectFromASN1Data:fieldValueData error:NULL];
//                NSLog(@"unknown iareceipt field: %lld %@", type.value, fieldValueData);
//                NSLog(@"    %@", [valueObject debugDescription]);
//            } break;
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
