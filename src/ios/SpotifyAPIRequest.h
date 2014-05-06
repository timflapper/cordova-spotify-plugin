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

typedef void (^SpotifyRequestBlock)(NSError *err, id obj);

@interface SpotifyAPIRequest : NSObject
+(void)searchObjectsWithQuery:(NSString *)query type:(NSString *)searchType offset:(NSInteger)offset callback:(SpotifyRequestBlock)callback;
+(void)getObjectFromURI:(NSString *)uri callback:(SpotifyRequestBlock)callback;
@end
