//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STCMS.h"
#import "STCMS+Internal.h"


// RFC 5652 3
//
//ContentInfo ::= SEQUENCE {
//    contentType ContentType,
//    content [0] EXPLICIT ANY DEFINED BY contentType }
//
//ContentType ::= OBJECT IDENTIFIER

struct STASN1derIdentifier const STCMSContentIdentifier = {
    .class = STASN1derIdentifierClassContextSpecific,
    .constructed = 1,
    .tag = 0,
};


@interface STCMSContentPlaceholder : NSObject
- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence;
@end


static STCMSContentPlaceholder *gSTCMSContentPlaceholder = nil;

@implementation STCMSContent

+ (void)initialize {
    if (self == [STCMSContent class]) {
        gSTCMSContentPlaceholder = [[STCMSContentPlaceholder alloc] init];
    }
}
+ (id)alloc {
    if (self == [STCMSContent class]) {
        return (id)gSTCMSContentPlaceholder;
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
    if (![sequence isKindOfClass:[STASN1derSequenceObject class]]) {
        return nil;
    }
    if (sequence.count != 2) {
        return nil;
    }

    STASN1derObjectIdentifierObject * const contentTypeOIDObject = STCMSEnsureClass(STASN1derObjectIdentifierObject, sequence.value.firstObject);
    if (!contentTypeOIDObject) {
        return nil;
    }
    STASN1derObject * const contentObject = [sequence.value objectAtIndex:1];
    if (!STASN1derIdentifierEqual(STCMSContentIdentifier, contentObject.identifier)) {
        return nil;
    }

    NSIndexPath * const contentTypeOID = contentTypeOIDObject.value;
    if ((self = [super init])) {
        _contentType = contentTypeOID;
    }
    return self;
}

@end

@implementation STCMSContentPlaceholder

- (id)initWithASN1Sequence:(STASN1derSequenceObject *)sequence {
    if (![sequence isKindOfClass:[STASN1derSequenceObject class]]) {
        return nil;
    }

    STASN1derObjectIdentifierObject * const contentTypeOIDObject = STCMSEnsureClass(STASN1derObjectIdentifierObject, sequence.value.firstObject);
    if (!contentTypeOIDObject) {
        return nil;
    }

    Class klass = nil;
    NSIndexPath * const contentTypeOID = contentTypeOIDObject.value;

    if ([STCMSDataContentTypeOID isEqual:contentTypeOID]) {
        klass = [STCMSDataContent class];
    } else if ([STCMSSignedDataContentTypeOID isEqual:contentTypeOID]) {
        klass = [STCMSSignedDataContent class];
    }

    id content = [[klass st_alloc] initWithASN1Sequence:sequence];
    if (!content) {
        content = [[STCMSContent st_alloc] initWithASN1Sequence:sequence];
    }
    return content;
}
@end
