//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import "STCMS.h"
#import "STCMS+Internal.h"

#import <STASN1der/STASN1der.h>


@implementation STCMSDataContent

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

    STASN1derOctetStringObject * const octetStringObject = STCMSEnsureClass(STASN1derOctetStringObject, contentObjects.firstObject);
    if (!octetStringObject) {
        return nil;
    }
    if ((self = [super initWithASN1Sequence:sequence])) {
        _content = octetStringObject.content;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p %lu bytes>", NSStringFromClass(self.class), self, _content.length];
}

@end
