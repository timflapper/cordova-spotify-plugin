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
+(NSArray *)searchTypes;
+(NSArray *)objectTypes;

+(NSString *)objectTypeFromSearchType:(NSString *)type;
+(NSString *)searchTypeForObjectType:(NSString *)type;

+(NSDictionary *)parseData:(NSData *)data error:(NSError **)error;
@end
