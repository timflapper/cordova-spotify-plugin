//
//  SpotifyAdhocTrackProvider.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 19/10/14.
//
//

#import "SpotifyAdhocTrackProvider.h"

@interface SpotifyAdhocTrackProvider()
@property NSArray *tracks;
@end

@implementation SpotifyAdhocTrackProvider
- (id)initWithTracks:(NSArray *)tracks
{
    self = [super init];

    if (self) {
        _tracks = tracks;
    }

    return self;
}

- (NSURL *)playableUri
{
    return nil;
}

- (NSArray *)tracksForPlayback
{
    return _tracks;
}
@end