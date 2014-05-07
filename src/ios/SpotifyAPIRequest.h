//
//  SpotifyAPIRequest.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//
//

#import <Foundation/Foundation.h>
#import "SpotifyJSON.h"
#import "SpotifyShared.h"

typedef void (^SpotifyRequestBlock)(NSError *err, NSData* data);

@interface SpotifyAPIRequest : NSObject

+(void)setup;
+(void)searchObjectsWithQuery:(NSString *)query type:(NSString *)searchType offset:(int)offset limit:(int)limit callback:(SpotifyRequestBlock)callback;
+(void)getObjectFromURI:(NSString *)uri callback:(SpotifyRequestBlock)callback;
@end
