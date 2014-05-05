//
//  SpotifyPlugin.m
//

#import "SpotifyPlugin.h"

@interface SpotifyPlugin() {
    NSString *callbackId;
    NSString *callbackUrl;
    NSString *tokenSwapUrl;
}

@end

@implementation SpotifyPlugin

- (void)authenticate:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin authenticate");
    
    callbackUrl = @"spotify-ios-sdk-beta://callback";
    callbackId = command.callbackId;
    tokenSwapUrl = [command.arguments objectAtIndex:1];
    
    NSString *clientId = [command.arguments objectAtIndex:0];
    NSArray *scopes = [command.arguments objectAtIndex:2];
    
    [self.commandDelegate runInBackground:^{
        SPTAuth *auth = [SPTAuth defaultInstance];
        
        NSURL *loginURL = [auth loginURLForClientId:clientId
                                declaredRedirectURL:[NSURL URLWithString:callbackUrl]
                                             scopes:scopes];
        
        [[UIApplication sharedApplication] performSelector:@selector(openURL:)
                                                withObject:loginURL];
    }];
//    NSDictionary *session = @{@"username": @"fake", @"credential": @"faker"};
//    
//    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:session] callbackId:command.callbackId];
}

- (void)search:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin search");
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[]] callbackId:command.callbackId];
}

- (void)getPlaylistsForUser:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin getPlaylistsForUser");
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[]] callbackId:command.callbackId];
}

- (void)getObjectFromURI:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin getObjectFromURI");
    
    NSDictionary *obj = @{@"name": @"fake", @"uri": @"Faker"};
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:obj] callbackId:command.callbackId];
    
}

- (void)createPlaylist:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin createPlaylist");
    
    NSDictionary *playlist = @{@"name": @"Blablabla"};
 
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playlist] callbackId:command.callbackId];
}


- (BOOL)authenticateCallback:(NSURL *)authURL
{
    if([[SPTAuth defaultInstance] canHandleURL:authURL withDeclaredRedirectURL:[NSURL URLWithString:callbackUrl]]) {
        
        [[SPTAuth defaultInstance]
         handleAuthCallbackWithTriggeredAuthURL:authURL
         tokenSwapServiceEndpointAtURL:[NSURL URLWithString:tokenSwapUrl]
         callback:^(NSError *error, SPTSession *session) {
             if (error != nil) {
                 //                 NSLog(@"Auth Error");
                 NSLog(@"*** Auth error: %@", error);
                 return;
             }
             
             NSLog(@"Session result: %@", session);
         }];
        
        return YES;
    }
    
    return NO;
}

@end
