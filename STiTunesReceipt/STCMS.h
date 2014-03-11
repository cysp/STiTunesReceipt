//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


@class STASN1derObject;
@class STASN1derSequenceObject;
@class STASN1derSetObject;

#import "STCMSAlgorithmIdentifier.h"
#import "STCMSCertificate.h"


@interface STCMSContent : NSObject
- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence __attribute__((objc_designated_initializer));
@property (nonatomic,copy,readonly) NSIndexPath *contentType;
@end
@interface STCMSDataContent : STCMSContent
@property (nonatomic,copy,readonly) NSData *content;
@end


@interface STCMSSignerIdentifier : NSObject
- (id)initWithASN1Object:(STASN1derObject *)object __attribute__((objc_designated_initializer));
@end
@interface STCMSIssuerAndSerialNumberSignerIdentifier : STCMSSignerIdentifier
@property (nonatomic,copy,readonly) NSString *issuer;
@property (nonatomic,assign,readonly) NSUInteger serialNumber;
@end
@interface STCMSSubjectKeyIdentifierSignerIdentifier :  STCMSSignerIdentifier
@property (nonatomic,copy,readonly) NSString *subjectKeyIdentifier;
@end

@protocol STCMSRevocationInfo <NSObject> @end
@interface STCMSOtherRevocationInfo : NSObject<STCMSRevocationInfo>
@property (nonatomic,copy,readonly) NSIndexPath *otherRevInfoFormat;
@property (nonatomic,strong,readonly) id otherRevInfo;
@end


@interface STCMSTBSCertExtension : NSObject
@property (nonatomic,copy,readonly) NSIndexPath *extensionIdentifier;
@property (nonatomic,assign,readonly) BOOL critical;
@property (nonatomic,copy,readonly) NSData *extensionValue;
@end
@interface STCMSTBSCertList : NSObject
@property (nonatomic,assign,readonly) NSUInteger version;
@property (nonatomic,copy,readonly) NSIndexPath *signatureAlgorithm;
@property (nonatomic,copy,readonly) NSString *issuer;
@property (nonatomic,copy,readonly) NSDate *thisUpdate;
@property (nonatomic,copy,readonly) NSDate *nextUpdate;
@property (nonatomic,copy,readonly) NSArray *revokedCertificates; // STCMSTBSCert
@property (nonatomic,copy,readonly) NSArray *crlExtensions;
@end
@interface STCMSTBSRevokedCert : NSObject
@property (nonatomic,assign,readonly) NSUInteger userCertificate;
@property (nonatomic,copy,readonly) NSDate *revocationDate;
@property (nonatomic,copy,readonly) NSArray *crlEntryExtensions;
@end
@interface STCMSCRLRevocationInfo : NSObject<STCMSRevocationInfo>
@property (nonatomic,strong,readonly) STCMSTBSCertList *tbsCertList;
@property (nonatomic,copy,readonly) NSIndexPath *signatureAlgorithm;
@property (nonatomic,copy,readonly) NSData *signatureValue;
@end

@interface STCMSAttribute : NSObject
@property (nonatomic,copy,readonly) NSIndexPath *attrType;
@property (nonatomic,copy,readonly) NSArray *attrValues;
@end


@interface STCMSSignerInfo : NSObject
- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence __attribute__((objc_designated_initializer));
@property (nonatomic,assign,readonly) NSUInteger version;
@property (nonatomic,strong,readonly) STCMSSignerIdentifier *signerIdentifier;
@property (nonatomic,copy,readonly) STCMSAlgorithmIdentifier *digestAlgorithm;
@property (nonatomic,strong,readonly) NSArray *signedAttrs; // STCMSAttribute
@property (nonatomic,copy,readonly) STCMSAlgorithmIdentifier *signatureAlgorithm;
@property (nonatomic,copy,readonly) NSData *signature;
@property (nonatomic,strong,readonly) NSArray *unsignedAttrs; // STCMSAttribute
@end

//SignedData ::= SEQUENCE {
//    version CMSVersion,
//    digestAlgorithms DigestAlgorithmIdentifiers,
//    encapContentInfo EncapsulatedContentInfo,
//    certificates [0] IMPLICIT CertificateSet OPTIONAL,
//    crls [1] IMPLICIT RevocationInfoChoices OPTIONAL,
//    signerInfos SignerInfos }
//
//DigestAlgorithmIdentifiers ::= SET OF DigestAlgorithmIdentifier
//
//SignerInfos ::= SET OF SignerInfo


@interface STCMSSignedDataContent : STCMSContent
- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence __attribute__((objc_designated_initializer));
@property (nonatomic,assign,readonly) NSUInteger version;
@property (nonatomic,copy,readonly) NSArray *digestAlgorithms;
@property (nonatomic,strong,readonly) STCMSContent *encapsulatedContent;
@property (nonatomic,copy,readonly) NSArray *certificates; // STCMSCertificate
@property (nonatomic,copy,readonly) NSArray *crls; // STCMSRevocationInfo
@property (nonatomic,copy,readonly) NSArray *signerInfos; // STCMSSignerInfo
- (BOOL)verifySignature;
- (BOOL)verifySignatureWithAnchorCertificateDatas:(NSArray *)anchorCertificateDatas;
@end



@interface STCMSParser : NSObject
+ (STCMSContent *)contentWithData:(NSData *)data;
@end
