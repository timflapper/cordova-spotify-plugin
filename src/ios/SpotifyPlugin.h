//
//  SpotifyPlugin.h
//

#import <Spotify/Spotify.h>
#import "Cordova/CDV.h"

#import "SpotifyAuthentication.h"
#import "SpotifyAPIRequest.h"

@interface SpotifyPlugin : CDVPlugin {
    // Member variables go here.
}

- (void)authenticate:(CDVInvokedUrlCommand*)command;
- (void)search:(CDVInvokedUrlCommand*)command;
//- (void)getPlaylistsForUser:(CDVInvokedUrlCommand*)command;
//- (void)getObjectFromURI:(CDVInvokedUrlCommand*)command;
//- (void)createPlaylist:(CDVInvokedUrlCommand*)command;

@end