//
//  SpotifyPlugin+AudioPlayer.h
//

#import "SpotifyPlugin.h"

@interface SpotifyPlugin (AudioPlayer)
- (void)addAudioPlayerEventListener:(CDVInvokedUrlCommand*)command;
@end
