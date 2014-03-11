//  Copyright (c) 2014 Scott Talbot. All rights reserved.

@import Foundation;
#import "STiTunesReceiptParser.h"

#import <STASN1der/STASN1der.h>
#import "STCMS.h"

#import "STAppleRootCertificate.h"


__attribute__((noreturn)) static void usage(char const * const progname) {
    fprintf(stderr, "usage: %s <receipt>", progname);
    exit(1);
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            usage(argv[0]);
        }
        NSString * const path = [[NSString alloc] initWithUTF8String:argv[1]];
        NSData * const data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:NULL];
        if (!data) {
            return 1;
        }

        NSData * const appleRootCAData = STAppleIncRootCertificateData();

        STCMSSignedDataContent * const signedContent = (STCMSSignedDataContent *)[STCMSParser contentWithData:data];
        if ([signedContent verifySignatureWithAnchorCertificateDatas:@[ appleRootCAData ]]) {
            STCMSDataContent * const encapsulatedContent = (STCMSDataContent *)((STCMSSignedDataContent *)signedContent).encapsulatedContent;
            STASN1derSetObject * const receiptObjectsSet = [STASN1derParser objectFromASN1Data:encapsulatedContent.content error:NULL];
            STiTunesAppReceipt * const receipt = [[STiTunesAppReceipt alloc] initWithASN1Set:receiptObjectsSet];

            unsigned char guidBytes[16] = { 0xED, 0xD3, 0x4B, 0xD4, 0x25, 0x3A, 0x46, 0x8E, 0xB8, 0xF7, 0x91, 0x9B, 0x22, 0x29, 0x34, 0xC8 };
            NSData * const guidData = [[NSData alloc] initWithBytes:guidBytes length:16];
            if (![receipt validateWithBundleIdentifier:@"au.com.fairfaxdigital.SMH-iPad" version:@"2.4.1" guidData:guidData]) {
                NSLog(@"failed validation");
            }
            NSLog(@"%@", receipt);
        }
    }
    return 0;
}

