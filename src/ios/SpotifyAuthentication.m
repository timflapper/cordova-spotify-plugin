//
//  SpotifyAuthentication.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//  Copyright (c) 2014 Tim Flapper. All rights reserved.
//

#import "SpotifyAuthentication.h"

@interface SpotifyAuthentication()
@property (readwrite) NSString *callbackId;
@property (readwrite) NSString *tokenSwapUrl;
@end

@implementation SpotifyAuthentication
-(id)initWithCallbackId:(NSString *)callbackId tokenSwapUrl:(NSString *)tokenSwapUrl
{
    self = [super init];
    
    if (self) {
        self.callbackId = callbackId;
        self.tokenSwapUrl = tokenSwapUrl;
    }
    
    return self;
}
@end
