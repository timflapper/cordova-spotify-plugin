//
//  shared.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 07/05/14.
//
//

#import "SpotifyPlugin.h"
#import <XCTest/XCTest.h>

NSData *getDataFromTestDataFile(NSString *filename) {
    NSString *path = [[NSBundle bundleForClass: [SpotifyPlugin class]] pathForResource:filename ofType:@"" inDirectory:@"TestData"];
        
    return [NSData dataWithContentsOfFile:path];
}

void waitForSecondsOrDone(NSTimeInterval noOfSeconds, BOOL *done) {
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:noOfSeconds];
    while (!*done && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.005, YES);
}


NSError *errorForTesting() {
    return [NSError errorWithDomain:@"for.testing.ErrorDomain" code:42 userInfo:@{NSLocalizedDescriptionKey: @"Nope"}];
}