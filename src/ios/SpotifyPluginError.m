//
//  SpotifyPluginError.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 07/05/14.
//
//

#import "SpotifyPluginError.h"

@implementation SpotifyPluginError
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)desc
{
    return [self errorWithDomain:SpotifyPluginErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: desc}];
}
@end
