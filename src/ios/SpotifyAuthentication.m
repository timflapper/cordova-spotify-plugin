//
//  SpotifyAuthentication.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//  Copyright (c) 2014 Tim Flapper. All rights reserved.
//

#import "SpotifyAuthentication.h"

static NSString *const CALLBACK_URL = @"spotify-ios-sdk-beta://callback";

@interface SpotifyAuthentication()
@property NSURL *callbackUrl;

@property (copy) NSURL *tokenSwapUrl;
@property (copy) SpotifyLoginBlock loginCallback;
@end

@implementation SpotifyAuthentication
+(SpotifyAuthentication *)defaultInstance
{
    static dispatch_once_t once;
    static SpotifyAuthentication *instance;
    
    dispatch_once(&once, ^{
        instance = [SpotifyAuthentication new];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if (self) {
        self.callbackUrl = [NSURL URLWithString:CALLBACK_URL];
    }
    
    return self;
}

-(void)loginWithClientId:(NSString *)clientId tokenSwapUrl:(NSURL *)tokenSwapUrl scopes:(NSArray *)scopes callback:(SpotifyLoginBlock)callback
{
    
    self.tokenSwapUrl = tokenSwapUrl;
    self.loginCallback = callback;
    
    SPTAuth *auth = [SPTAuth defaultInstance];

    NSURL *loginURL = [auth loginURLForClientId:clientId
                            declaredRedirectURL:self.callbackUrl
                                         scopes:scopes];

    [[UIApplication sharedApplication] openURL:loginURL];
}

-(BOOL)openURL:(NSURL *)url
{
    if([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL: self.callbackUrl]) {
        if (self.tokenSwapUrl == nil || self.loginCallback == nil)
            return NO;

        [[SPTAuth defaultInstance]
             handleAuthCallbackWithTriggeredAuthURL:url
             tokenSwapServiceEndpointAtURL:self.tokenSwapUrl
             callback:^(NSError *error, SPTSession *session) {
                 self.tokenSwapUrl = nil;
                 
                 if (error != nil) {
                     NSLog(@"Error on handleAuthCallback: %@", error);
                     
                     self.loginCallback(error, nil);

                     self.loginCallback = nil;

                     return;
                 }
                 
                 NSDictionary *result = @{@"username": session.canonicalUsername, @"credential": session.credential};
                 
                 self.loginCallback(nil, result);
                 
                 self.loginCallback = nil;
             }];
    }
    
    return NO;
}

@end
