//
//  SpotifyPlugin+Playlist.m
//

#import "SpotifyPlugin+Playlist.h"

@implementation SpotifyPlugin (Playlist)
- (void)setPlaylistName:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin+Playlist setPlaylistName");
    
    NSDictionary *playlist = @{@"name": @"Blablabla"};
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playlist] callbackId:command.callbackId];
}

- (void)setPlaylistDescription:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin+Playlist setPlaylistDescription");
    
    NSDictionary *playlist = @{@"name": @"Blablabla"};
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playlist] callbackId:command.callbackId];
}

- (void)setPlaylistCollaborative:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin+Playlist setPlaylistCollaborative");
    
    NSDictionary *playlist = @{@"name": @"Blablabla"};
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playlist] callbackId:command.callbackId];
}

- (void)addTracksToPlaylist:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin+Playlist addTracksToPlaylist");
    
    NSDictionary *playlist = @{@"name": @"Blablabla"};
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playlist] callbackId:command.callbackId];
}

- (void)deletePlaylist:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin+Playlist deletePlaylist");
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}
@end
