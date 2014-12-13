//
//  SpotifyPlugin.m
//

#import "SpotifyPlugin.h"
#import <objc/runtime.h>

static NSString *SpotifyPluginErrorDomain = @"com.timflapper.spotify.errors";

typedef void (^PlayerResultCallback)(NSError *error, SpotifyAudioPlayer *player);

typedef void (^TrackMetadataCallback)(NSDictionary *metadata);

NSDateFormatter *getDateFormatter()
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterLongStyle];

    return formatter;
}

NSString *dateToString(NSDate *date)
{
    return [getDateFormatter() stringFromDate:date];
}

NSDate *stringToDate(NSString *dateString)
{
    return [getDateFormatter() dateFromString:dateString];
}

@interface SpotifyPlugin()
@end

@implementation SpotifyPlugin
@synthesize callbackUrl;
- (void)pluginInitialize
{
    callbackUrl = [NSURL URLWithString:@"spotify-ios-sdk-beta://callback"];
}

- (void)authenticate:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin* weakSelf = self;

    NSArray *validResponseTypes = @[@"code", @"token"];

    NSString *clientId = [command.arguments objectAtIndex:0];
    NSString *responseType = [command.arguments objectAtIndex:1];
    NSURL *tokenSwapUrl;
    NSArray *scopes;

    int argumentIndex = 2;

    if ([validResponseTypes indexOfObject:responseType] == NSNotFound) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid responseType"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    if ([responseType isEqualToString:@"code"])
        tokenSwapUrl = [NSURL URLWithString:[command.arguments objectAtIndex:argumentIndex++]];

    scopes = [command.arguments objectAtIndex:argumentIndex];

    __block id observer;

    [self.commandDelegate runInBackground:^{

        SPTAuthCallback callback = ^(NSError *error, SPTSession *session) {
            CDVPluginResult *pluginResult;

            if (error != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult
                                resultWithStatus:CDVCommandStatus_OK
                                messageAsDictionary: [self ConvertSessionToDictionary:session]];
            }

            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        };

        observer = [[NSNotificationCenter defaultCenter]
                    addObserverForName:CDVPluginHandleOpenURLNotification
                    object:nil queue:nil usingBlock:^(NSNotification *note) {
                        NSURL *url = [note object];
                        if([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL: callbackUrl]) {
                            [[NSNotificationCenter defaultCenter] removeObserver:observer];

                            if ([responseType isEqualToString:@"code"])
                                return [[SPTAuth defaultInstance]
                                 handleAuthCallbackWithTriggeredAuthURL:url
                                 tokenSwapServiceEndpointAtURL:tokenSwapUrl
                                 callback:callback];

                            if ([responseType isEqualToString:@"token"])
                                return [[SPTAuth defaultInstance]
                                 handleAuthCallbackWithTriggeredAuthURL:url
                                 callback:callback];
                        }
                    }];

        NSURL *loginURL = [[SPTAuth defaultInstance]
                           loginURLForClientId:clientId
                           declaredRedirectURL:callbackUrl
                           scopes:scopes
                           withResponseType:responseType];

        [[UIApplication sharedApplication] openURL:loginURL];
    }];
}

- (void)renewSession:(CDVInvokedUrlCommand *)command
{
    __block SPTSession *session = [self ConvertDictionaryToSession:[command.arguments objectAtIndex:0]];
    NSURL *tokenRefreshUrl = [NSURL URLWithString: [command.arguments objectAtIndex:1]];

    __weak SpotifyPlugin* weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [[SPTAuth defaultInstance]
         renewSession:session
         withServiceEndpointAtURL:tokenRefreshUrl callback:^(NSError *error, SPTSession *newSession) {
             CDVPluginResult *pluginResult;

             if (error != nil) {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
             } else {
                 pluginResult = [CDVPluginResult
                                 resultWithStatus:CDVCommandStatus_OK
                                 messageAsDictionary: [self ConvertSessionToDictionary:newSession withOriginalSession:session]];
             }

             [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }];
    }];
}

- (void)isSessionValid:(CDVInvokedUrlCommand *)command
{
    SPTSession *session = [self ConvertDictionaryToSession:[command.arguments objectAtIndex:0]];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool: session.isValid];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark AudioPlayer methods

- (void)createAudioPlayerAndLogin:(CDVInvokedUrlCommand*)command
{
    NSString *clientId = [command.arguments objectAtIndex:0];
    SPTSession *session = [self ConvertDictionaryToSession: [command.arguments objectAtIndex:1]];

    __weak SpotifyPlugin* weakSelf = self;

    [self.commandDelegate runInBackground:^{
        SpotifyAudioPlayer *player = [[SpotifyAudioPlayer alloc] initWithClientId:clientId];

        [player loginWithSession:session callback:^(NSError *error) {
            CDVPluginResult *pluginResult;

            if (error != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: player.instanceID];
            }

            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)audioPlayerLogout:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin* weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            [player logout:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"event" object:player];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)addAudioPlayerEventListener:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventNotificationFromAudioPlayer:) name:@"event" object:player];
        }];
    }];
}

- (void)play:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            id data = [command.arguments objectAtIndex:1];
            NSNumber *index = [command.arguments count] > 2 ? [command.arguments objectAtIndex:2] : nil;

            if ([data isKindOfClass:[NSString class]])
                return [self playURI:[NSURL URLWithString: data] fromIndex:index player:player callbackId:command.callbackId];

            if ([data isKindOfClass:[NSArray class]])
                return [self playURIs:data fromIndex:index player:player callbackId:command.callbackId];

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown data"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];

}

- (void)playURI:(NSURL *)uri fromIndex:(NSNumber *)index player:(SpotifyAudioPlayer *)player callbackId:(NSString *)callbackId
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        SPTErrorableOperationCallback callback = ^(NSError *error) {
            CDVPluginResult *pluginResult;

            if (error != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }

            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        };

        if (index)
            return [player playURI:uri fromIndex:index.intValue callback:callback];

        [player playURI:uri callback:callback];
    }];
}

- (void)playURIs:(NSArray *)uris fromIndex:(NSNumber *)index player:(SpotifyAudioPlayer *)player callbackId:(NSString *)callbackId
{
    __weak SpotifyPlugin * weakSelf = self;

    uris = [self convertStringsToURIs:uris];

    [self.commandDelegate runInBackground:^{
        SPTErrorableOperationCallback callback = ^(NSError *error) {
            CDVPluginResult *pluginResult;

            if (error != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }

            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        };

        [player playURIs:uris fromIndex:index.intValue callback:callback];
    }];
}

- (void)setURIs:(CDVInvokedUrlCommand*)command;
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            NSArray *uris = [self convertStringsToURIs:[command.arguments objectAtIndex:1]];

            [self.commandDelegate runInBackground:^{
                SPTErrorableOperationCallback callback = ^(NSError *error) {
                    CDVPluginResult *pluginResult;

                    if (error != nil) {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                    } else {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                    }

                    [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                };

                [player setURIs:uris callback:callback];
            }];
        }];
    }];
}

- (void)playURIsFromIndex:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            SPTErrorableOperationCallback callback = ^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            };

            [player playURIsFromIndex:[[command.arguments objectAtIndex:0] intValue] callback:callback];
        }];
    }];
}

- (void)queue:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            id data = [command.arguments objectAtIndex:1];
            BOOL clearQueue = [[command.arguments objectAtIndex:2] boolValue];

            SPTErrorableOperationCallback callback = ^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            };

            if ([data isKindOfClass:[NSString class]]) {
                [player queueURI:[NSURL URLWithString:data] clearQueue:clearQueue callback:callback];
            } else if ([data isKindOfClass:[NSArray class]]) {
                [player queueURIs:[self convertStringsToURIs:data] clearQueue:clearQueue callback:callback];
            } else {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown data"];
                
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
                return;
            }
        }];
    }];
}

- (void)queuePlay:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            [player queuePlay:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)queueClear:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            [player queueClear:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)stop:(CDVInvokedUrlCommand*)command
{

    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            [player stop:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)skipNext:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            [player skipNext:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)skipPrevious:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            [player skipPrevious:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)seekToOffset:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            NSTimeInterval offset = ((NSNumber *)[command.arguments objectAtIndex:1]).doubleValue;

            [player seekToOffset:offset callback:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)getIsPlaying:(CDVInvokedUrlCommand*)command
{
    [self sendAudioPlayerAttribute:@"isPlaying" toCommand:command];
}

- (void)setIsPlaying:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            BOOL isPlaying = ((NSNumber *)[command.arguments objectAtIndex:1]).boolValue;

            [player setIsPlaying:isPlaying callback:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)getVolume:(CDVInvokedUrlCommand*)command
{
    [self sendAudioPlayerAttribute:@"volume" toCommand:command];
}

- (void)setVolume:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            SPTVolume volume = [[command.arguments objectAtIndex:1] doubleValue];

            [player setVolume:volume callback:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)getRepeat:(CDVInvokedUrlCommand *)command
{
    [self sendAudioPlayerAttribute:@"repeat" toCommand:command];
}

- (void)setRepeat:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            player.repeat = ((NSNumber *)[command.arguments objectAtIndex:1]).boolValue;

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:player.repeat];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)getShuffle:(CDVInvokedUrlCommand *)command
{
    [self sendAudioPlayerAttribute:@"shuffle" toCommand:command];
}

- (void)setShuffle:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            player.shuffle = ((NSNumber *)[command.arguments objectAtIndex:1]).boolValue;

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:player.shuffle];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)getTargetBitrate:(CDVInvokedUrlCommand *)command
{
    [self sendAudioPlayerAttribute:@"targetBitrate" toCommand:command];
}

- (void)setTargetBitrate:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            __weak SpotifyAudioPlayer *weakPlayer = player;

            SPTBitrate bitrate = ((NSNumber *)[command.arguments objectAtIndex:1]).unsignedIntegerValue;
            [player setTargetBitrate:bitrate callback:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)weakPlayer.targetBitrate];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }];
    }];
}

- (void)getDiskCacheSizeLimit:(CDVInvokedUrlCommand *)command
{
    [self sendAudioPlayerAttribute:@"diskCacheSizeLimit" toCommand:command];
}

- (void)setDiskCacheSizeLimit:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            __weak SpotifyAudioPlayer *weakPlayer = player;

            NSUInteger diskCacheSizeLimit = ((NSNumber *)[command.arguments objectAtIndex:1]).unsignedIntegerValue;

            player.diskCacheSizeLimit = diskCacheSizeLimit;

            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)weakPlayer.diskCacheSizeLimit];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

-(void)getLoggedIn:(CDVInvokedUrlCommand*)command
{
    [self sendAudioPlayerAttribute:@"loggedIn" toCommand:command];
}

- (void)getQueueSize:(CDVInvokedUrlCommand*)command
{
    [self sendAudioPlayerAttribute:@"queueSize" toCommand:command];
}

- (void)getTrackListSize:(CDVInvokedUrlCommand*)command
{

    [self sendAudioPlayerAttribute:@"trackListSize" toCommand:command];
}

- (void)getTrackMetadata:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [self getAudioPlayerByID: [command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
            if (error) return;

            int trackID = -1;
            BOOL relative = false;

            if ([command.arguments count] >= 2) {
                trackID = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;

                if ([command.arguments count] == 3) {
                    relative = ((NSNumber *)[command.arguments objectAtIndex:2]).boolValue;
                }
            }

            TrackMetadataCallback dataCallback = ^(NSDictionary *metadata) {
                NSDictionary *track = nil;

                if (metadata != nil) {
                    track = @{@"name": [metadata valueForKey:@"SPAudioStreamingMetadataTrackName"],
                              @"uri": [metadata valueForKey:@"SPAudioStreamingMetadataTrackURI"],
                              @"artist": @{@"name": [metadata valueForKey:@"SPAudioStreamingMetadataArtistName"],
                                           @"uri": [metadata valueForKey:@"SPAudioStreamingMetadataArtistURI"]},
                              @"album": @{@"name": [metadata valueForKey:@"SPAudioStreamingMetadataAlbumName"],
                                          @"uri":[metadata valueForKey:@"SPAudioStreamingMetadataAlbumURI"]},
                              @"duration": [metadata valueForKey:@"SPAudioStreamingMetadataTrackDuration"]};
                }

                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: track];

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            };

            if (trackID > -1) {
                if (relative) {
                    [player getRelativeTrackMetadata:trackID callback:dataCallback];
                } else {
                    [player getAbsoluteTrackMetadata:trackID callback:dataCallback];
                }
            } else {
                dataCallback(player.currentTrackMetadata);
            }
        }];
    }];
}

- (void)getCurrentPlaybackPosition:(CDVInvokedUrlCommand*)command
{
    [self sendAudioPlayerAttribute:@"currentPlaybackPosition" toCommand:command];
}

#pragma mark Notification handlers

- (void) eventNotificationFromAudioPlayer:(NSNotification *)note
{
    SpotifyAudioPlayer *player = note.object;

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:note.userInfo];

    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:player.instanceID];
}

#pragma mark Convenience methods

- (void)getAudioPlayerByID:(NSString *)playerID callbackId:(NSString *)callbackId callback:(PlayerResultCallback)block
{
    SpotifyAudioPlayer *player;

    if ((player = [SpotifyAudioPlayer getInstanceByID:playerID]) == nil) {
        NSDictionary *errorInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Player does not exist", nil) };

        NSError *error = [NSError errorWithDomain:SpotifyPluginErrorDomain
                                             code:-1000
                                         userInfo:errorInfo];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];

        return block(error, nil);
    }

    block(nil, player);
}

- (void)sendAudioPlayerAttribute:(NSString *)attribute toCommand:(CDVInvokedUrlCommand*)command
{
    [self getAudioPlayerByID:[command.arguments objectAtIndex:0] callbackId:command.callbackId callback:^(NSError *error, SpotifyAudioPlayer *player) {
        if (error) return;

        CDVPluginResult *pluginResult;
        id message = [player valueForKey:attribute];

        objc_property_t property = class_getProperty([SPTAudioStreamingController class], [attribute UTF8String]);
        char *type = strtok(strdup(property_getAttributes(property)), ",");

        if (strcmp(type, "Td") == 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:[message doubleValue]];
        } else if (strcmp(type, "Ti") == 0 || strcmp(type, "TQ") == 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[message intValue]];
        } else if (strcmp(type, "TB") == 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[message boolValue]];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        free(type);
    }];
}

-(SPTSession *)ConvertDictionaryToSession:(NSDictionary *)data
{
    if (![data valueForKey:@"encryptedRefreshToken"])
        return [[SPTSession alloc]
                initWithUserName:[data valueForKey:@"canonicalUsername"]
                accessToken:[data valueForKey:@"accessToken"]
                expirationDate:stringToDate([data valueForKey:@"expirationDate"])];

    return [[SPTSession alloc]
            initWithUserName:[data valueForKey:@"canonicalUsername"]
            accessToken:[data valueForKey:@"accessToken"]
            encryptedRefreshToken:[data valueForKey:@"encryptedRefreshToken"]
            expirationDate:stringToDate([data valueForKey:@"expirationDate"])];

}

-(NSDictionary *)ConvertSessionToDictionary:(SPTSession *)session
{
    return [self ConvertSessionToDictionary:session withOriginalSession:session];
}

-(NSDictionary *)ConvertSessionToDictionary:(SPTSession *)session withOriginalSession:(SPTSession *)originalSession
{
    id canonicalUsername = [originalSession canonicalUsername];
    id encryptedRefreshToken = [originalSession encryptedRefreshToken];

    return @{@"canonicalUsername": canonicalUsername,
             @"accessToken": [session accessToken],
             @"encryptedRefreshToken": encryptedRefreshToken ? encryptedRefreshToken : [NSNull null],
             @"expirationDate": dateToString([session expirationDate]),
             @"tokenType": [session tokenType]};

}

-(NSArray *)convertStringsToURIs:(NSArray *)strings
{
    NSMutableArray *uris = [NSMutableArray new];

    [strings enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [uris addObject:[NSURL URLWithString:obj]];
    }];

    return uris;
}

@end
