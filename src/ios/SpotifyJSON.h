//
//  SpotifyJSON.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//
//

#import <Foundation/Foundation.h>

@interface SpotifyJSON : NSObject
+(NSDictionary *)parseData:(NSData *)data;
@end
