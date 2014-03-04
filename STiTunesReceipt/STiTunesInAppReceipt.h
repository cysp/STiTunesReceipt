//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>

@class STASN1derSetObject;


@interface STiTunesInAppReceipt : NSObject
- (id)initWithASN1Set:(STASN1derSetObject *)set;
@property (nonatomic,assign,readonly) NSUInteger quantity;
@property (nonatomic,copy,readonly) NSString *productId;
@property (nonatomic,copy,readonly) NSString *transactionId;
@property (nonatomic,copy,readonly) NSString *originalTransactionId;
@property (nonatomic,copy,readonly) NSDate *purchaseDate;
@property (nonatomic,copy,readonly) NSDate *originalPurchaseDate;
@property (nonatomic,copy,readonly) NSDate *expiresDate;
@property (nonatomic,copy,readonly) NSDate *cancellationDate;
@property (nonatomic,copy,readonly) NSString *versionExternalIdentifier;
@property (nonatomic,assign,readonly) NSUInteger webOrderLineItemId;
@end
