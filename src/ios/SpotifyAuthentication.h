//
//  SpotifyAuthentication.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//  Copyright (c) 2014 Tim Flapper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifyAuthentication : NSObject
@property (readonly) NSString *callbackId;
@property (readonly) NSString *tokenSwapUrl;

-(id)initWithCallbackId:(NSString *)callbackId tokenSwapUrl:(NSString *)tokenSwapUrl;
@end
