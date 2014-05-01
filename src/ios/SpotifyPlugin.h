//
//  SpotifyPlugin.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 30/04/14.
//
//

#import <Spotify/Spotify.h>
#import "Cordova/CDV.h"

@interface SpotifyPlugin : CDVPlugin {
    // Member variables go here.
}

- (void)trackFromURI:(CDVInvokedUrlCommand*)command;
@end