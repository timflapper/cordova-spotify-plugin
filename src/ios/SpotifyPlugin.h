//
//  SpotifyPlugin.h
//

#import <Spotify/Spotify.h>
#import "Cordova/CDV.h"

@interface SpotifyPlugin : CDVPlugin {
    // Member variables go here.
}

- (void)authenticate:(CDVInvokedUrlCommand*)command;
- (void)search:(CDVInvokedUrlCommand*)command;
- (void)getPlaylistsForUser:(CDVInvokedUrlCommand*)command;
- (void)getObjectFromURI:(CDVInvokedUrlCommand*)command;
- (void)createPlaylist:(CDVInvokedUrlCommand*)command;

- (BOOL)authenticateCallback:(NSURL *)authURL;
@end