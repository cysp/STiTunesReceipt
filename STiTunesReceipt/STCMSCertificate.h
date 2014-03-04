//
//  STCMSCertificate.h
//  STiTunesReceipt
//
//  Created by Scott Talbot on 2/03/2014.
//  Copyright (c) 2014 Scott Talbot. All rights reserved.
//

#import "STCMS.h"

@class STTBSCertificate;
@class STCMSAlgorithmIdentifier;


@interface STCMSCertificate : NSObject
- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence;
@property (nonatomic,strong,readonly) STTBSCertificate *certificate;
@property (nonatomic,strong,readonly) STCMSAlgorithmIdentifier *signatureAlgorithm;
@property (nonatomic,copy,readonly) NSData *signatureValue;
@property (nonatomic,copy,readonly) NSData *data;
@end


@interface STTBSCertificate : NSObject
@property (nonatomic,assign,readonly) NSUInteger version;
@property (nonatomic,assign,readonly) NSUInteger serialNumber;
@property (nonatomic,strong,readonly) STCMSAlgorithmIdentifier *signatureAlgorithm;
//    signature            AlgorithmIdentifier,
//    issuer               Name,
//    validity             Validity,
//    subject              Name,
//    subjectPublicKeyInfo SubjectPublicKeyInfo,
//    issuerUniqueID  [1]  IMPLICIT UniqueIdentifier OPTIONAL,
//    -- If present, version MUST be v2 or v3
//    subjectUniqueID [2]  IMPLICIT UniqueIdentifier OPTIONAL,
//    -- If present, version MUST be v2 or v3
//    extensions      [3]  EXPLICIT Extensions OPTIONAL
//    -- If present, version MUST be v3

@end
