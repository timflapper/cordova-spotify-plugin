//
//  SpotifyPluginError.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 07/05/14.
//
//

#import <Foundation/Foundation.h>

static NSString *const SpotifyPluginErrorDomain = @"com.timflapper.spotify.ErrorDomain";

typedef NS_ENUM(NSInteger, SpotifyPluginErrorCode) {
    SpotifyPluginEmptyQueryError = -1001,
    SpotifyPluginBadLimitError = -1002,
    SpotifyPluginBadOffsetError = -1003,
    SpotifyPluginBadSearchTypeError = -1004,
    SpotifyPluginInvalidJSONError = -1005
};

@interface SpotifyPluginError : NSError
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)desc;
@end
