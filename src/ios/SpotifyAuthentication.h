//
//  SpotifyAuthentication.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//  Copyright (c) 2014 Tim Flapper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>

typedef void (^SpotifyLoginBlock)(NSError *error, NSDictionary *session);

@interface SpotifyAuthentication : NSObject

+(SpotifyAuthentication *)defaultInstance;

-(void)loginWithClientId:(NSString *)clientId tokenSwapUrl:(NSURL *)tokenSwapUrl scopes:(NSArray *)scopes callback:(SpotifyLoginBlock)callback;

-(BOOL)openURL:(NSURL *)url;

@end
