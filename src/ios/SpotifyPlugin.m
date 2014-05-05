//
//  SpotifyPlugin.m
//

#import "SpotifyPlugin.h"

@interface SpotifyPlugin() {
    NSURL *callbackUrl;
    SpotifyAuthentication *authentication;
}

@end

@implementation SpotifyPlugin

- (void)pluginInitialize
{
    callbackUrl = [NSURL URLWithString: @"spotify-ios-sdk-beta://callback"];
}

- (void)authenticate:(CDVInvokedUrlCommand*)command
{
    NSLog(@"SpotifyPlugin authenticate");
    
    NSString *clientId = [command.arguments objectAtIndex:0];
    NSString *tokenSwapUrl = [command.arguments objectAtIndex:1];
    NSArray *scopes = [command.arguments objectAtIndex:2];
        
    [self.commandDelegate runInBackground:^{
        
        authentication = [[SpotifyAuthentication alloc] initWithCallbackId:command.callbackId tokenSwapUrl:tokenSwapUrl];
        
        SPTAuth *auth = [SPTAuth defaultInstance];
        
        NSURL *loginURL = [auth loginURLForClientId:clientId
                                declaredRedirectURL:callbackUrl
                                             scopes:scopes];
        
        [[UIApplication sharedApplication] performSelector:@selector(openURL:)
                                                withObject:loginURL];
    }];
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
    
    if([[SPTAuth defaultInstance] canHandleURL:authURL withDeclaredRedirectURL: callbackUrl] && authentication != nil) {
        
        [[SPTAuth defaultInstance]
         handleAuthCallbackWithTriggeredAuthURL:authURL
         tokenSwapServiceEndpointAtURL:[NSURL URLWithString:authentication.tokenSwapUrl]
         callback:^(NSError *error, SPTSession *session) {
             
             if (error != nil) {
                 NSLog(@"*** Auth error: %@", error);
                 return;
             }
             
             NSLog(@"Authentication successful for username: %@", session.canonicalUsername);
             
             NSDictionary *message = @{@"username": session.canonicalUsername, @"credential": session.credential};
             
             CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: message];
             
             [self.commandDelegate sendPluginResult:result callbackId:authentication.callbackId];
             
             authentication = nil;
         }];
        
        return YES;
    }
    
    return NO;
}

@end
