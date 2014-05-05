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
            }
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:session];
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)search:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin search");

    [self.commandDelegate runInBackground:^{
        [[SpotifyAPIRequest new] test];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[]] callbackId:command.callbackId];
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
//- (void)getObjectFromURI:(CDVInvokedUrlCommand*)command
//{
//    NSLog(@"SpotifyPlugin getObjectFromURI");
//    
//    NSDictionary *obj = @{@"name": @"fake", @"uri": @"Faker"};
//    
//    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:obj] callbackId:command.callbackId];
//    
//}
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
