//
//  SpotifyPlugin.h
//

#import "Cordova/CDV.h"
#import <Spotify/Spotify.h>
#import "SpotifyAudioPlayer.h"

@interface SpotifyPlugin : CDVPlugin

@property NSURL *callbackUrl;

/* Linked to SPTAuth */
- (void)authenticate:(CDVInvokedUrlCommand*)command;
- (void)isSessionValid:(CDVInvokedUrlCommand*)command;
- (void)renewSession:(CDVInvokedUrlCommand*)command;

/* Linked to SpotifyAudioPlayer */
- (void)createAudioPlayerAndLogin:(CDVInvokedUrlCommand*)command;
- (void)audioPlayerLogout:(CDVInvokedUrlCommand*)command;
- (void)addAudioPlayerEventListener:(CDVInvokedUrlCommand*)command;
- (void)play:(CDVInvokedUrlCommand*)command;
- (void)queue:(CDVInvokedUrlCommand*)command;
- (void)seekToOffset:(CDVInvokedUrlCommand*)command;
- (void)skipNext:(CDVInvokedUrlCommand*)command;
- (void)skipPrevious:(CDVInvokedUrlCommand*)command;
- (void)getIsPlaying:(CDVInvokedUrlCommand*)command;
- (void)setIsPlaying:(CDVInvokedUrlCommand*)command;
- (void)getTargetBitrate:(CDVInvokedUrlCommand*)command;
- (void)setTargetBitrate:(CDVInvokedUrlCommand*)command;
- (void)getDiskCacheSizeLimit:(CDVInvokedUrlCommand*)command;
- (void)setDiskCacheSizeLimit:(CDVInvokedUrlCommand*)command;
- (void)getVolume:(CDVInvokedUrlCommand*)command;
- (void)setVolume:(CDVInvokedUrlCommand*)command;
- (void)getRepeat:(CDVInvokedUrlCommand*)command;
- (void)setRepeat:(CDVInvokedUrlCommand*)command;
- (void)getShuffle:(CDVInvokedUrlCommand*)command;
- (void)setShuffle:(CDVInvokedUrlCommand*)command;
- (void)getLoggedIn:(CDVInvokedUrlCommand*)command;
- (void)getTrackMetadata:(CDVInvokedUrlCommand*)command;
- (void)getCurrentPlaybackPosition:(CDVInvokedUrlCommand*)command;

@end

/**
 * TODO Specs:
 *  - isSessionValid
 *  - renewSession
 *
 *  - play for array of tracks
 *  - queue for single track and array of tracks
 *  - skipNext
 *  - skipPrevious
 *  - getTargetBitrate
 *  - setTargetBitrate
 *  - getdiskCacheSizeLimit
 *  - setdiskCacheSizeLimit
 *  - getTrackMetadata with trackID and relative
 *  - getRepeat
 *  - setRepeat
 *  - getShuffle
 *  - setShuffle
 *
 **/