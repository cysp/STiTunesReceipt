//
//  STCMSCertificate.m
//  STiTunesReceipt
//
//  Created by Scott Talbot on 2/03/2014.
//  Copyright (c) 2014 Scott Talbot. All rights reserved.
//

#import "STCMSCertificate.h"
#import "STCMS+Internal.h"

#import "STCMSAlgorithmIdentifier.h"


// RFC 5280 4.1.2
//Certificate  ::=  SEQUENCE  {
//    tbsCertificate       TBSCertificate,
//    signatureAlgorithm   AlgorithmIdentifier,
//    signatureValue       BIT STRING  }
//
//TBSCertificate  ::=  SEQUENCE  {
//    version         [0]  EXPLICIT Version DEFAULT v1,
//    serialNumber         CertificateSerialNumber,
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
//}
//
//Version  ::=  INTEGER  {  v1(0), v2(1), v3(2)  }
//
//CertificateSerialNumber  ::=  INTEGER
//
//Validity ::= SEQUENCE {
//    notBefore      Time,
//    notAfter       Time }
//
//Time ::= CHOICE {
//    utcTime        UTCTime,
//    generalTime    GeneralizedTime }
//
//UniqueIdentifier  ::=  BIT STRING
//
//SubjectPublicKeyInfo  ::=  SEQUENCE  {
//    algorithm            AlgorithmIdentifier,
//    subjectPublicKey     BIT STRING  }
//
//Extensions  ::=  SEQUENCE SIZE (1..MAX) OF Extension
//
//Extension  ::=  SEQUENCE  {
//    extnID      OBJECT IDENTIFIER,
//    critical    BOOLEAN DEFAULT FALSE,
//    extnValue   OCTET STRING
//    -- contains the DER encoding of an ASN.1 value
//    -- corresponding to the extension type identified
//    -- by extnID
//}

static struct STASN1derIdentifier const STTBSCertificateVersionIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = NO,
    .tag = 0,
};
static struct STASN1derIdentifier const STTBSCertificateIssuerIdIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = NO,
    .tag = 1,
};
static struct STASN1derIdentifier const STTBSCertificateSubjectIdIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = NO,
    .tag = 2,
};
static struct STASN1derIdentifier const STTBSCertificateExtensionsIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = YES,
    .tag = 3,
};


@implementation STTBSCertificate

- (id)init { [self doesNotRecognizeSelector:_cmd]; return nil; }

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    if (![sequence isKindOfClass:[STASN1derSequenceObject class]]) {
        return nil;
    }
    if (sequence.count < 6 || sequence.count > 10) {
        return nil;
    }

    NSUInteger i = 0;

    NSUInteger version = 0;
    {
        STASN1derObject *object = sequence[i];
        if (STASN1derIdentifierEqual(STTBSCertificateVersionIdentifier, object.identifier)) {
            STASN1derIntegerObject * const versionObject = STCMSEnsureClass(STASN1derIntegerObject, object);
            if (!versionObject) {
                return nil;
            }
            version = versionObject.value;
            ++i;
        }
    }
    long long serialNumber;
    {
        STASN1derObject *object = sequence[i];
    }
    if ((self = [super init])) {
    }
    return self;
}

@end


@implementation STCMSCertificate

- (id)init { [self doesNotRecognizeSelector:_cmd]; return nil; }

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    if (![sequence isKindOfClass:[STASN1derSequenceObject class]]) {
        return nil;
    }
    if (sequence.count != 3) {
        return nil;
    }


    STASN1derSequenceObject * const certificateSequence = STCMSEnsureClass(STASN1derSequenceObject, sequence[0]);
    if (!certificateSequence) {
        return nil;
    }

    STASN1derSequenceObject * const algorithmSequence = STCMSEnsureClass(STASN1derSequenceObject, sequence[1]);
    if (!algorithmSequence) {
        return nil;
    }

    STASN1derBitStringObject * const signatureBitString = STCMSEnsureClass(STASN1derBitStringObject, sequence[2]);
    if (!signatureBitString) {
        return nil;
    }

    STTBSCertificate * const certificate = [[STTBSCertificate alloc] initWithASN1Sequence:certificateSequence];
    STCMSAlgorithmIdentifier * const algorithm = [[STCMSAlgorithmIdentifier alloc] initWithASN1Sequence:algorithmSequence];

    if ((self = [super init])) {
        _certificate = certificate;
        _signatureAlgorithm = algorithm;
        _signatureValue = signatureBitString.value;
        _data = sequence.data.copy;
    }
    return self;
}

@end
