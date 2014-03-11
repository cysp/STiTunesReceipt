//
//  STCMSAlgorithmIdentifier.m
//  STiTunesReceipt
//
//  Created by Scott Talbot on 2/03/2014.
//  Copyright (c) 2014 Scott Talbot. All rights reserved.
//

#import "STCMSAlgorithmIdentifier.h"
#import "STCMS+Internal.h"


// RFC 3370 - Cryptographic Message Syntax (CMS) Algorithms
// http://www.rfc-editor.org/rfc/rfc3370.txt

// RFC 5754 - Using SHA2 Algorithms with Cryptographic Message Syntax
// http://www.rfc-editor.org/rfc/rfc5754.txt


static NSUInteger const STCMSSHA1AlgorithmIdentifierOIDIndexes[] = { 1, 3, 14, 3, 2, 26 };
NSIndexPath *STCMSSHA1AlgorithmIdentifierOID = nil;
static NSUInteger const STCMSMD5AlgorithmIdentifierOIDIndexes[] = { 1, 2, 840, 113549, 2, 5 };
NSIndexPath *STCMSMD5AlgorithmIdentifierOID = nil;
static NSUInteger const STCMSDSAAlgorithmIdentifierOIDIndexes[] = { 1, 2, 840, 10040, 4, 1 };
NSIndexPath *STCMSDSAAlgorithmIdentifierOID = nil;
static NSUInteger const STCMSRSAAlgorithmIdentifierOIDIndexes[] = { 1, 2, 840, 113549, 1, 1, 1 };
NSIndexPath *STCMSRSAAlgorithmIdentifierOID = nil;


__attribute__((constructor))
static void STCMSAlgorithmIdentifierInitializeOIDs(void) {
    STCMSSHA1AlgorithmIdentifierOID = [[NSIndexPath alloc] initWithIndexes:STCMSSHA1AlgorithmIdentifierOIDIndexes length:sizeof(STCMSSHA1AlgorithmIdentifierOIDIndexes)/sizeof(STCMSSHA1AlgorithmIdentifierOIDIndexes[0])];
    STCMSMD5AlgorithmIdentifierOID = [[NSIndexPath alloc] initWithIndexes:STCMSMD5AlgorithmIdentifierOIDIndexes length:sizeof(STCMSMD5AlgorithmIdentifierOIDIndexes)/sizeof(STCMSMD5AlgorithmIdentifierOIDIndexes[0])];
    STCMSDSAAlgorithmIdentifierOID = [[NSIndexPath alloc] initWithIndexes:STCMSDSAAlgorithmIdentifierOIDIndexes length:sizeof(STCMSDSAAlgorithmIdentifierOIDIndexes)/sizeof(STCMSDSAAlgorithmIdentifierOIDIndexes[0])];
    STCMSRSAAlgorithmIdentifierOID = [[NSIndexPath alloc] initWithIndexes:STCMSRSAAlgorithmIdentifierOIDIndexes length:sizeof(STCMSRSAAlgorithmIdentifierOIDIndexes)/sizeof(STCMSRSAAlgorithmIdentifierOIDIndexes[0])];
}


// RFC 5280 4.1.1.2
//
//AlgorithmIdentifier  ::=  SEQUENCE  {
//    algorithm               OBJECT IDENTIFIER,
//    parameters              ANY DEFINED BY algorithm OPTIONAL  }

@interface STCMSAlgorithmIdentifierPlaceholder : NSObject
- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence;
@end


static STCMSAlgorithmIdentifierPlaceholder *gSTCMSAlgorithmIdentifierPlaceholder = nil;


@implementation STCMSAlgorithmIdentifier

+ (void)initialize {
    if (self == [STCMSAlgorithmIdentifier class]) {
        gSTCMSAlgorithmIdentifierPlaceholder = [[STCMSAlgorithmIdentifierPlaceholder alloc] init];
    }
}
+ (id)alloc {
    if (self == [STCMSAlgorithmIdentifier class]) {
        return (id)gSTCMSAlgorithmIdentifierPlaceholder;
    }
    return [super alloc];
}
+ (id)st_alloc {
    return [super alloc];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)init { [self doesNotRecognizeSelector:_cmd]; return nil; }
#pragma clang diagnostic pop

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    if (sequence.count < 1) {
        return nil;
    }
    STASN1derObjectIdentifierObject * const algorithm = STCMSEnsureClass(STASN1derObjectIdentifierObject, sequence.value.firstObject);
    if (!algorithm) {
        return nil;
    }
    if ((self = [super init])) {
        _algorithm = algorithm.value;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p %@>", NSStringFromClass(self.class), self, STCMSStringFromIndexPath(_algorithm)];
}

@end


@implementation STCMSAlgorithmIdentifierPlaceholder

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    if (![sequence isKindOfClass:[STASN1derSequenceObject class]]) {
        return nil;
    }

    STASN1derObjectIdentifierObject * const algorithmIdentifierOIDObject = STCMSEnsureClass(STASN1derObjectIdentifierObject, sequence.value.firstObject);
    if (!algorithmIdentifierOIDObject) {
        return nil;
    }

    Class klass = nil;
    NSIndexPath * const algorithmIdentifierOID = algorithmIdentifierOIDObject.value;

    if ([STCMSSHA1AlgorithmIdentifierOID isEqual:algorithmIdentifierOID]) {
        klass = [STCMSSHA1AlgorithmIdentifier class];
    } else if ([STCMSMD5AlgorithmIdentifierOID isEqualTo:algorithmIdentifierOID]) {
        klass = [STCMSMD5AlgorithmIdentifier class];
    } else if ([STCMSDSAAlgorithmIdentifierOID isEqualTo:algorithmIdentifierOID]) {
        klass = [STCMSDSAAlgorithmIdentifier class];
    } else if ([STCMSRSAAlgorithmIdentifierOID isEqualTo:algorithmIdentifierOID]) {
        klass = [STCMSRSAAlgorithmIdentifier class];
    }

    id algorithmIdentifier = [[klass st_alloc] initWithASN1Sequence:sequence];
    if (!algorithmIdentifier) {
        algorithmIdentifier = [[STCMSAlgorithmIdentifier st_alloc] initWithASN1Sequence:sequence];
    }
    return algorithmIdentifier;
}
@end


@implementation STCMSSHA1AlgorithmIdentifier

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    do {
        if (sequence.count == 1) {
            break;
        }
        if (sequence.count == 2) {
            STASN1derObject * const parameter = sequence[1];
            if ([parameter isKindOfClass:[STASN1derNullObject class]]) {
                break;
            }
        }
        return nil;
    } while (0);

    if ((self = [super initWithASN1Sequence:sequence])) {
    }
    return self;
}

@end


@implementation STCMSMD5AlgorithmIdentifier

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    do {
        if (sequence.count == 1) {
            break;
        }
        if (sequence.count == 2) {
            STASN1derObject * const parameter = sequence[1];
            if ([parameter isKindOfClass:[STASN1derNullObject class]]) {
                break;
            }
        }
        return nil;
    } while (0);

    if ((self = [super initWithASN1Sequence:sequence])) {
    }
    return self;
}

@end


@implementation STCMSDSAAlgorithmIdentifier

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    STASN1derIntegerObject *p = nil, *q = nil, *g = nil;
    do {
        if (sequence.count == 1) {
            break;
        }
        if (sequence.count == 2) {
            STASN1derSequenceObject * const parameter = sequence[1];
            if (![parameter isKindOfClass:[STASN1derSequenceObject class]]) {
                break;
            }
            if (parameter.count != 3) {
                return nil;
            }
            p = STCMSEnsureClass(STASN1derIntegerObject, parameter[0]);
            q = STCMSEnsureClass(STASN1derIntegerObject, parameter[1]);
            g = STCMSEnsureClass(STASN1derIntegerObject, parameter[2]);
        }
        return nil;
    } while (0);

    if ((self = [super initWithASN1Sequence:sequence])) {
        _p = p.value;
        _q = q.value;
        _g = g.value;
    }
    return self;
}

@end


@implementation STCMSRSAAlgorithmIdentifier

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    do {
        if (sequence.count == 2) {
            STASN1derObject * const parameter = sequence[1];
            if ([parameter isKindOfClass:[STASN1derNullObject class]]) {
                break;
            }
        }
        return nil;
    } while (0);

    if ((self = [super initWithASN1Sequence:sequence])) {
    }
    return self;
}

@end
