//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STCMS.h"
#import "STCMS+Internal.h"


// RFC5652 5.3
//
//SignerInfo ::= SEQUENCE {
//    version CMSVersion,
//    sid SignerIdentifier,
//    digestAlgorithm DigestAlgorithmIdentifier,
//    signedAttrs [0] IMPLICIT SignedAttributes OPTIONAL,
//    signatureAlgorithm SignatureAlgorithmIdentifier,
//    signature SignatureValue,
//    unsignedAttrs [1] IMPLICIT UnsignedAttributes OPTIONAL }
//
//SignerIdentifier ::= CHOICE {
//    issuerAndSerialNumber IssuerAndSerialNumber,
//    subjectKeyIdentifier [0] SubjectKeyIdentifier }
//
//SignedAttributes ::= SET SIZE (1..MAX) OF Attribute
//
//UnsignedAttributes ::= SET SIZE (1..MAX) OF Attribute
//
//Attribute ::= SEQUENCE {
//    attrType OBJECT IDENTIFIER,
//    attrValues SET OF AttributeValue }
//
//AttributeValue ::= ANY
//
//SignatureValue ::= OCTET STRING


static struct STASN1derIdentifier const STCMSSignerInfoSignedAttributesIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = YES,
    .tag = 0,
};

static struct STASN1derIdentifier const STCMSSignerInfoUnsignedAttributesIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = YES,
    .tag = 1,
};


@implementation STCMSSignerInfo

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)init { [self doesNotRecognizeSelector:_cmd]; return nil; }
#pragma clang diagnostic pop

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    if (sequence.count < 5 || sequence.count > 7) {
        return nil;
    }

    NSUInteger i = 0;

    STASN1derIntegerObject * const versionObject = STCMSEnsureClass(STASN1derIntegerObject, sequence[i]);
    if (!versionObject) {
        return nil;
    }
    ++i;

//    STASN1derObject * const sidObject = sequence[i];
    STCMSSignerIdentifier * const signerIdentifier = nil;// [[STCMSSignerIdentifier alloc] initWithASN1Object:sidObject];
//    if (!signerIdentifier) {
//        return nil;
//    }
    ++i;

    STASN1derSequenceObject * const digestAlgorithmSequence = STCMSEnsureClass(STASN1derSequenceObject, sequence[i]);
    STCMSAlgorithmIdentifier * const digestAlgorithm = [[STCMSAlgorithmIdentifier alloc] initWithASN1Sequence:digestAlgorithmSequence];
    ++i;

    {
        STASN1derObject * const object = sequence[i];
        if (STASN1derIdentifierEqual(STCMSSignerInfoSignedAttributesIdentifier, object.identifier)) {
            ++i;
        }
    }

    STASN1derSequenceObject * const signatureAlgorithmSequence = STCMSEnsureClass(STASN1derSequenceObject, sequence[i]);
    STCMSAlgorithmIdentifier * const signatureAlgorithm = [[STCMSAlgorithmIdentifier alloc] initWithASN1Sequence:signatureAlgorithmSequence];
    if (!signatureAlgorithm) {
        return nil;
    }
    ++i;

    {
        STASN1derObject * const object = sequence[i];
        if (STASN1derIdentifierEqual(STCMSSignerInfoUnsignedAttributesIdentifier, object.identifier)) {
            ++i;
        }
    }

    STASN1derOctetStringObject * const signatureObject = STCMSEnsureClass(STASN1derOctetStringObject, sequence[i]);
    if (!signatureObject) {
        return nil;
    }

    if ((self = [super init])) {
        _version = versionObject.value;
        _signerIdentifier = signerIdentifier;
        _digestAlgorithm = digestAlgorithm;
        _signatureAlgorithm = signatureAlgorithm;
        _signature = signatureObject.content;
    }
    return self;
}

@end
