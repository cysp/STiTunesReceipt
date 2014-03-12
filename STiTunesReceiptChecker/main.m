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

//            uuid_t const guid = { 0xED, 0xD3, 0x4B, 0xD4, 0x25, 0x3A, 0x46, 0x8E, 0xB8, 0xF7, 0x91, 0x9B, 0x22, 0x29, 0x34, 0xC8 };
//            NSData * const guidData = [[NSData alloc] initWithBytes:guid length:sizeof(guid)];
//            NSData * const guidData = [@"EDD34BD4-253A-468E-B8F7-919B222934C8" dataUsingEncoding:NSASCIIStringEncoding];
//            NSUUID * const guid = [[NSUUID alloc] initWithUUIDString:@"EDD34BD4-253A-468E-B8F7-919B222934C8"];
//            uuid_t const uuid = guid.
//            NSData * const guidData = guid.UUIDString;

//            if (![receipt validateWithBundleIdentifier:@"au.com.fairfaxdigital.SMH-iPad" version:@"2.4.1" guidData:guidData]) {

            uuid_t const guid = { 0x51, 0xB9, 0x1F, 0xB9, 0x70, 0xA2, 0x4B, 0x64, 0x84, 0xF8, 0xA1, 0x0D, 0x87, 0x3F, 0x94, 0x3F };
            NSData * const guidData = [[NSData alloc] initWithBytes:guid length:sizeof(guid)];
            if (![receipt validateWithBundleIdentifier:@"au.com.fairfaxdigital.Domain" version:@"4.0.4" guidData:guidData]) {
                NSLog(@"failed validation");
            }
            NSLog(@"%@", receipt);
        }
    }
    return 0;
}

