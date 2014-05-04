/********* CDVSpotify Cordova Plugin.m Cordova Plugin Implementation *******/

#import "SpotifyPlugin.h"

@interface SpotifyPlugin() {
    NSString *callbackId;
}

@end

@implementation SpotifyPlugin

- (void)trackFromURI:(CDVInvokedUrlCommand*)command
{
    callbackId = command.callbackId;
    
    NSDictionary *track = @{
        @"name": @"Boobo blabla",
        @"album": @{@"name": @"Albumpie", @"uri": @"Wheee"},
        @"uri": [command.arguments objectAtIndex:0]
    };

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:track];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//- (void)sendTrackObject:(SPTTrack *)object
//{
//    
//    NSDictionary *track = [self SPTTrackToDictionary:object];
//    
//    CDVPluginResult* pluginResult = nil;
//    
//    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:track];
//    
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
//}
//
//-(NSDictionary *)SPTTrackToDictionary:(SPTTrack *)object
//{
//    return @{@"name": object.name,
//            @"uri": object.uri,
//            @"sharingURL": object.sharingURL,
//            @"previewURL": object.previewURL,
//            @"duration": [NSNumber numberWithDouble: object.duration],
//            @"artists": object.artists,
//            @"album": object.album,
//            @"trackNumber": [NSNumber numberWithDouble: object.trackNumber],
//            @"discNumber": [NSNumber numberWithDouble: object.discNumber],
//            @"popularity": [NSNumber numberWithDouble: object.popularity],
//            @"flaggedExplicit": object.flaggedExplicit ? @YES : @NO,
//            @"externalIds": object.externalIds,
//            @"availableTerritories": object.availableTerritories};
//}

@end
