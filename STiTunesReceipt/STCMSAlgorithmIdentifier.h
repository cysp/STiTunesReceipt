//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>

#import "STCMS.h"


extern NSIndexPath *STCMSSHA1AlgorithmIdentifierOID;
extern NSIndexPath *STCMSMD5AlgorithmIdentifierOID;
extern NSIndexPath *STCMSDSAAlgorithmIdentifierOID;
extern NSIndexPath *STCMSRSAAlgorithmIdentifierOID;


@interface STCMSAlgorithmIdentifier : NSObject
- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence __attribute__((objc_designated_initializer));
@property (nonatomic,copy,readonly) NSIndexPath *algorithm;
@end

@interface STCMSSHA1AlgorithmIdentifier : STCMSAlgorithmIdentifier
@end

@interface STCMSMD5AlgorithmIdentifier : STCMSAlgorithmIdentifier
@end

@interface STCMSDSAAlgorithmIdentifier : STCMSAlgorithmIdentifier
@property (nonatomic,assign,readonly) NSUInteger p;
@property (nonatomic,assign,readonly) NSUInteger q;
@property (nonatomic,assign,readonly) NSUInteger g;
@end

@interface STCMSRSAAlgorithmIdentifier : STCMSAlgorithmIdentifier
@end
