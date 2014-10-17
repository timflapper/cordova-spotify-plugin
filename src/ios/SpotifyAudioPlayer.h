//
//  SpotifyAudioPlayer.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 08/05/14.
//
//

#import <Spotify/Spotify.h>

@interface SpotifyAudioPlayer : SPTAudioStreamingController<SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>
+ (instancetype)getInstanceByID:(NSString *)ID;
@property NSString *instanceID;
@end
