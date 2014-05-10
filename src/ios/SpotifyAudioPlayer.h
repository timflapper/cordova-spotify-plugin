//
//  SpotifyAudioPlayer.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 08/05/14.
//
//

#import <Spotify/Spotify.h>
#import "SpotifyShared.h"

@interface SpotifyAudioPlayer : SPTAudioStreamingController<SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>
@property NSString *callbackIdForEventListener;
@end
