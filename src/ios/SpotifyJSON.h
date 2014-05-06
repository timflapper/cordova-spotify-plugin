//
//  SpotifyJSON.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//
//

#import <Foundation/Foundation.h>

@class SpotifyJSON;

@interface SpotifyJSON : NSObject
+(NSDictionary *)parseData:(NSData *)data;
+(NSString *)objectTypeFromSearchType:(NSString *)type;
+(NSString *)searchTypeForObjectType:(NSString *)type;
@end
