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

typedef void (^SpotifyRequestBlock)(NSError *error, NSDictionary *object);

@interface SpotifyAPIRequest : NSObject
+(void)getObjectFromURI:(NSString *)uri callback:(SpotifyRequestBlock)callback;
@end
