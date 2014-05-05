//
//  SpotifyPlugin+Playlist.h
//

#import "SpotifyPlugin.h"

@interface SpotifyPlugin (Playlist)
- (void)setPlaylistName:(CDVInvokedUrlCommand*)command;
- (void)setPlaylistDescription:(CDVInvokedUrlCommand*)command;
- (void)setPlaylistCollaborative:(CDVInvokedUrlCommand*)command;
- (void)addTracksToPlaylist:(CDVInvokedUrlCommand*)command;
- (void)deletePlaylist:(CDVInvokedUrlCommand*)command;
@end
