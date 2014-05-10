//
//  shared.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 07/05/14.
//
//

#import <Foundation/Foundation.h>

NSData *getDataFromTestDataFile(NSString *filename);

void waitForSecondsOrDone(NSTimeInterval noOfSeconds, BOOL *done);

NSError *errorForTesting();