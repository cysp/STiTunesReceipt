//  Copyright (c) 2014 Scott Talbot. All rights reserved.

@import Foundation;
#import "STiTunesReceiptParser.h"


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

        NSError *error = nil;
        STiTunesAppReceipt * const receipt = [STiTunesReceiptParser receiptWithData:data error:&error];
        NSLog(@"%@", receipt);
    }
    return 0;
}

