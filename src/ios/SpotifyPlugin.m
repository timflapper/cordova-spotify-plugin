//
//  SpotifyPlugin.m
//

#import "SpotifyPlugin.h"

@interface SpotifyPlugin()

@end

@implementation SpotifyPlugin

- (void)pluginInitialize
{

}

- (void)authenticate:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin authenticate");
    
    NSString *clientId = [command.arguments objectAtIndex:0];
    NSURL *tokenSwapUrl = [NSURL URLWithString: [command.arguments objectAtIndex:1]];
    NSArray *scopes = [command.arguments objectAtIndex:2];

    [self.commandDelegate runInBackground:^{
        [[SpotifyAuthentication defaultInstance] loginWithClientId:clientId tokenSwapUrl:tokenSwapUrl scopes:scopes callback:^(NSError *error, NSDictionary *session) {
            CDVPluginResult *pluginResult;
                        
            if (error != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:session];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)search:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin search");
    
    NSString *query = [command.arguments objectAtIndex:0];
    NSString *searchType = [command.arguments objectAtIndex:1];
    int offset = [((NSNumber *)[command.arguments objectAtIndex:2]) integerValue];
    
    [self.commandDelegate runInBackground:^{
        [SpotifyAPIRequest searchObjectsWithQuery:query type:searchType offset:offset limit:LIMIT_DEFAULT callback:^(NSError *error, NSData *data) {
            CDVPluginResult *pluginResult;
            
            NSDictionary *objects = [SpotifyJSON parseData:data error:&error];
            
            if (error != nil) {
                NSLog(@"** SpotifyPlugin search ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:objects];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];

}
//
//- (void)getPlaylistsForUser:(CDVInvokedUrlCommand*)command
//{
//    NSLog(@"SpotifyPlugin getPlaylistsForUser");
//    
//    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[]] callbackId:command.callbackId];
//}
//
- (void)requestItemAtURI:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin getObjectFromURI");
    
    NSString *uri = [command.arguments objectAtIndex:0];
    
    [self.commandDelegate runInBackground:^{
        [SpotifyAPIRequest getObjectFromURI:uri callback:^(NSError *error, NSData *data) {
            CDVPluginResult *pluginResult;
            
            NSDictionary *objects = [SpotifyJSON parseData:data error:&error];
            
            if (error != nil) {
                NSLog(@"** SpotifyPlugin search ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:objects];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}
//
//- (void)createPlaylist:(CDVInvokedUrlCommand*)command
//{
//    NSLog(@"SpotifyPlugin createPlaylist");
//    
//    NSDictionary *playlist = @{@"name": @"Blablabla"};
//    
//    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playlist] callbackId:command.callbackId];
//}

@end
