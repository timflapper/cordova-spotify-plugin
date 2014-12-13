//
//  SpotifyPlugin.h
//

#import "Cordova/CDV.h"
#import <Spotify/Spotify.h>
#import "SpotifyAudioPlayer.h"

NSString *dateToString(NSDate *date);
NSDate *stringToDate(NSString *dateString);

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
- (void)setURIs:(CDVInvokedUrlCommand*)command;
- (void)playURIsFromIndex:(CDVInvokedUrlCommand*)command;
- (void)queue:(CDVInvokedUrlCommand*)command;
- (void)queuePlay:(CDVInvokedUrlCommand*)command;
- (void)queueClear:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
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
- (void)getQueueSize:(CDVInvokedUrlCommand*)command;
- (void)getTrackListSize:(CDVInvokedUrlCommand*)command;
- (void)getTrackMetadata:(CDVInvokedUrlCommand*)command;
- (void)getCurrentPlaybackPosition:(CDVInvokedUrlCommand*)command;
@end
