//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>

#import "STiTunesAppReceipt.h"
#import "STiTunesInAppReceipt.h"


@interface STiTunesReceiptParser : NSObject
+ (STiTunesAppReceipt *)receiptWithData:(NSData *)data error:(NSError * __autoreleasing *)error;
@end
