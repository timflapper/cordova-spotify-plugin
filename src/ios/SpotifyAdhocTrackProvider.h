//
//  SpotifyAdhocTrackProvider.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 19/10/14.
//
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>

@interface SpotifyAdhocTrackProvider : NSObject<SPTTrackProvider>
- (id)initWithTracks:(NSArray *)tracks;
@end
