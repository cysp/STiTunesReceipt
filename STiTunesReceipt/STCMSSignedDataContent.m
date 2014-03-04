//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STCMS.h"
#import "STCMS+Internal.h"

#import <STASN1der/STASN1der.h>


// RFC 5652 5
//
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
//CertificateSet ::= SET OF CertificateChoices
//
//CertificateChoices ::= CHOICE {
//    certificate Certificate,
//    extendedCertificate [0] IMPLICIT ExtendedCertificate, -- Obsolete
//    v1AttrCert [1] IMPLICIT AttributeCertificateV1,       -- Obsolete
//    v2AttrCert [2] IMPLICIT AttributeCertificateV2,
//    other [3] IMPLICIT OtherCertificateFormat }
//
//OtherCertificateFormat ::= SEQUENCE {
//    otherCertFormat OBJECT IDENTIFIER,
//    otherCert ANY DEFINED BY otherCertFormat }
//
//SignerInfos ::= SET OF SignerInfo

static struct STASN1derIdentifier const STCMSSignedDataCertificatesIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = YES,
    .tag = 0,
};

static struct STASN1derIdentifier const STCMSSignedDataCRLsIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = YES,
    .tag = 1,
};


@implementation STCMSSignedDataContent

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    if (![sequence isKindOfClass:[STASN1derSequenceObject class]]) {
        return nil;
    }
    if (sequence.count != 2) {
        return nil;
    }

    STASN1derObject * const contentContainer = [sequence.value objectAtIndex:1];
    if (!STASN1derIdentifierEqual(STCMSContentIdentifier, contentContainer.identifier)) {
        return nil;
    }

    NSArray * const contentObjects = [STASN1derParser objectsFromASN1Data:contentContainer.content error:NULL];
    if (contentObjects.count != 1) {
        return nil;
    }

    STASN1derSequenceObject * const contentSequence = STCMSEnsureClass(STASN1derSequenceObject, contentObjects.firstObject);
    if (contentSequence.count < 3 || contentSequence.count > 5) {
        return nil;
    }
    STASN1derIntegerObject * const version = contentSequence[0];
//    if (version.value != 1) {
//        return nil;
//    }

    STASN1derSetObject * const digestAlgorithmsASN1Set = contentSequence[1];
    NSMutableSet * const digestAlgorithms = [[NSMutableSet alloc] initWithCapacity:digestAlgorithmsASN1Set.count];
    for (id digestAlgorithmsASN1Object in digestAlgorithmsASN1Set.value) {
        STASN1derSequenceObject * const digestAlgorithmIdentifierASN1Sequence = STCMSEnsureClass(STASN1derSequenceObject, digestAlgorithmsASN1Object);
        STCMSAlgorithmIdentifier * const digestAlgorithmIdentifier = [[STCMSAlgorithmIdentifier alloc] initWithASN1Sequence:digestAlgorithmIdentifierASN1Sequence];
        if (!digestAlgorithmIdentifier) {
            return nil;
        }
        [digestAlgorithms addObject:digestAlgorithmIdentifier];
    }
    STASN1derSequenceObject * const encapsulatedContentInfoASN1Sequence = STCMSEnsureClass(STASN1derSequenceObject, contentSequence[2]);
    STCMSContent * const encapsulatedContent = [[STCMSContent alloc] initWithASN1Sequence:encapsulatedContentInfoASN1Sequence];

    NSUInteger i = 3;

    NSMutableArray *certificates = [[NSMutableArray alloc] init];
    {
        STASN1derObject *object = contentSequence[i];
        if (STASN1derIdentifierEqual(STCMSSignedDataCertificatesIdentifier, object.identifier)) {
            STASN1derSetObject * const certificateSet = [[STASN1derSetObject alloc] initWithIdentifier:STCMSSignedDataCertificatesIdentifier content:object.content];
            if (!certificateSet) {
                return nil;
            }
            for (STASN1derObject *certificateObject in certificateSet.value) {
                STASN1derSequenceObject * const certificateSequence = STCMSEnsureClass(STASN1derSequenceObject, certificateObject);
                if (!certificateSequence) {
                    return nil;
                }
                STCMSCertificate * const certificate = [[STCMSCertificate alloc] initWithASN1Sequence:certificateSequence];
                if (!certificate) {
                    return nil;
                }
                [certificates addObject:certificate];
            }
            ++i;
        }
    }

    NSSet *crls = nil;
    {
        STASN1derObject *object = contentSequence[i];
        if (STASN1derIdentifierEqual(STCMSSignedDataCRLsIdentifier, object.identifier)) {
            ++i;
        }
    }

    STASN1derSetObject * const signerInfosASN1Set = contentSequence[i];
    NSMutableSet * const signerInfos = [[NSMutableSet alloc] initWithCapacity:signerInfosASN1Set.count];
    for (STASN1derSequenceObject *signerInfoASN1Sequence in signerInfosASN1Set.value) {
        STCMSSignerInfo * const signerInfo = [[STCMSSignerInfo alloc] initWithASN1Sequence:signerInfoASN1Sequence];
        if (!signerInfo) {
            return nil;
        }
        [signerInfos addObject:signerInfo];
    }

    if ((self = [super initWithASN1Sequence:sequence])) {
        _version = version.value;
        _digestAlgorithms = digestAlgorithms.copy;
        _encapsulatedContent = encapsulatedContent;
        _certificates = certificates.copy;
        _signerInfos = signerInfos.copy;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p v%lu>", NSStringFromClass(self.class), self, (unsigned long)_version];
}


- (BOOL)verifySignature {
    NSArray * const certificates = self.certificates;
    NSArray * const signerInfos = self.signerInfos;

    NSMutableArray * const certificateRefs = [[NSMutableArray alloc] initWithCapacity:certificates.count];
    for (STCMSCertificate *certificate in certificates) {
        SecCertificateRef const certRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(certificate.data));
        CFStringRef cname = nil;
        OSStatus err = SecCertificateCopyCommonName(certRef, &cname);
        if (cname) {
            NSLog(@"%@", cname);
            CFRelease(cname);
        }
        if (certRef) {
            [certificateRefs addObject:(__bridge id)(certRef)];
            CFRelease(certRef);
        }
    }


    SecTrustRef trust = NULL;
    SecPolicyRef policy = SecPolicyCreateSSL(NO, NULL);
    OSStatus rv = SecTrustCreateWithCertificates((__bridge CFTypeRef)(certificateRefs), policy, &trust);
    if (rv != errSecSuccess) {
        return NO;
    }

    SecTrustResultType trustResult = kSecTrustResultInvalid;
    rv = SecTrustEvaluate(trust, &trustResult);
    if (rv != errSecSuccess) {
        return NO;
    }

    switch (trustResult) {
        case kSecTrustResultInvalid:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case kSecTrustResultConfirm:
#pragma clang diagnostic pop
        case kSecTrustResultDeny:
        case kSecTrustResultFatalTrustFailure:
        case kSecTrustResultOtherError:
            return NO;
        case kSecTrustResultProceed:
        case kSecTrustResultRecoverableTrustFailure:
            break;
    }

    CFRelease(trust), trust = NULL;
    CFRelease(policy), policy = NULL;

    return YES;
}

@end