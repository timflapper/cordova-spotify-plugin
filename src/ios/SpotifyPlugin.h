//
//  SpotifyPlugin.h
//

#import <Spotify/Spotify.h>
#import "Cordova/CDV.h"
#import "SpotifyShared.h"
#import "SpotifyAPIRequest.h"
#import "SpotifyAudioPlayer.h"

@interface SpotifyPlugin : CDVPlugin

/* Linked to SPTAuth */
- (void)authenticate:(CDVInvokedUrlCommand*)command;

/* Linked to Web API methods */
- (void)search:(CDVInvokedUrlCommand*)command;
- (void)requestItemAtURI:(CDVInvokedUrlCommand*)command;

/* Linked to SPTRequest */
- (void)getPlaylistsForUser:(CDVInvokedUrlCommand*)command;

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

/* Linked to SPTPlaylistSnapshot */
- (void)createPlaylist:(CDVInvokedUrlCommand*)command;
- (void)setPlaylistName:(CDVInvokedUrlCommand*)command;
- (void)setPlaylistDescription:(CDVInvokedUrlCommand*)command;
- (void)setPlaylistCollaborative:(CDVInvokedUrlCommand*)command;
- (void)addTracksToPlaylist:(CDVInvokedUrlCommand*)command;
- (void)deletePlaylist:(CDVInvokedUrlCommand*)command;

@end