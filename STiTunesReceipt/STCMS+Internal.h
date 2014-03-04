//  Copyright (c) 2014 Scott Talbot. All rights reserved.


#import <STASN1der/STASN1der.h>


#define STCMSEnsureClass(className, object) (className *)_STCMSEnsureClass([className class], (object))
static inline id _STCMSEnsureClass(Class klass, id object) {
    if (![object isKindOfClass:klass]) {
        return nil;
    }
    return object;
}

extern NSString *STCMSStringFromIndexPath(NSIndexPath *indexPath);

extern struct STASN1derIdentifier const STCMSContentIdentifier;
extern NSIndexPath *STCMSDataContentTypeOID;
extern NSIndexPath *STCMSSignedDataContentTypeOID;
extern NSIndexPath *STCMSEnvelopedDataContentTypeOID;
extern NSIndexPath *STCMSDigestedDataContentTypeOID;
extern NSIndexPath *STCMSEncryptedDataContentTypeOID;
