//
//  SpotifyPlugin.h
//

#import "Cordova/CDV.h"
#import <Spotify/Spotify.h>
#import "SpotifyAudioPlayer.h"

@interface SpotifyPlugin : CDVPlugin

/* Linked to SPTAuth */
- (void)authenticate:(CDVInvokedUrlCommand*)command;

/* Linked to SpotifyAudioPlayer */
- (void)createAudioPlayerAndLogin:(CDVInvokedUrlCommand*)command;
- (void)addAudioPlayerEventListener:(CDVInvokedUrlCommand*)command;
- (void)playURI:(CDVInvokedUrlCommand*)command;
- (void)seekToOffset:(CDVInvokedUrlCommand*)command;
- (void)getIsPlaying:(CDVInvokedUrlCommand*)command;
- (void)setIsPlaying:(CDVInvokedUrlCommand*)command;
- (void)getVolume:(CDVInvokedUrlCommand*)command;
- (void)setVolume:(CDVInvokedUrlCommand*)command;
- (void)getLoggedIn:(CDVInvokedUrlCommand*)command;
- (void)getCurrentTrack:(CDVInvokedUrlCommand*)command;
- (void)getCurrentPlaybackPosition:(CDVInvokedUrlCommand*)command;

@end