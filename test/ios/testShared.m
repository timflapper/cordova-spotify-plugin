//
//  shared.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 07/05/14.
//
//

#import "SpotifyJSON.h"

NSData *getDataFromTestDataFile(NSString *filename) {    
    NSString *path = [[NSBundle bundleForClass: [SpotifyJSON class]] pathForResource:filename ofType:@"" inDirectory:@"TestData"];
    return [NSData dataWithContentsOfFile:path];
}