//
//  SpotifyPlugin.m
//

#import "SpotifyPlugin.h"
#import "SpotifyAdhocTrackProvider.h"

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

    NSString *clientId = [command.arguments objectAtIndex:0];
    NSURL *tokenSwapUrl = [NSURL URLWithString: [command.arguments objectAtIndex:1]];
    NSArray *scopes = [command.arguments objectAtIndex:2];

    __weak SpotifyPlugin* weakSelf = self;

    __block id observer = nil;

    [self.commandDelegate runInBackground:^{

        observer = [[NSNotificationCenter defaultCenter]
                    addObserverForName:CDVPluginHandleOpenURLNotification
                    object:nil queue:nil usingBlock:^(NSNotification *note) {
                        NSURL *url = [note object];

                        if([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL: callbackUrl]) {
                            [[NSNotificationCenter defaultCenter] removeObserver:observer];

                            [[SPTAuth defaultInstance]
                             handleAuthCallbackWithTriggeredAuthURL:url
                             tokenSwapServiceEndpointAtURL:tokenSwapUrl
                             callback:^(NSError *error, SPTSession *session) {
                                 CDVPluginResult *pluginResult;

                                 if (error != nil) {
                                     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                                 } else {
                                     NSNumber *expirationDate = [NSNumber numberWithInteger:session.expirationDate.timeIntervalSince1970];

                                     pluginResult = [CDVPluginResult
                                                     resultWithStatus:CDVCommandStatus_OK
                                                     messageAsDictionary: @{@"username": session.canonicalUsername,
                                                                            @"credential": session.accessToken,
                                                                            @"expirationDate": expirationDate}];
                                 }

                                 [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                             }];
                        }
                    }];

        NSURL *loginURL = [[SPTAuth defaultInstance]
                           loginURLForClientId:clientId
                           declaredRedirectURL:callbackUrl
                           scopes:scopes];

        [[UIApplication sharedApplication] openURL:loginURL];
    }];
}

- (void)renewSession:(CDVInvokedUrlCommand *)command
{
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:0]];
    NSURL *tokenRefreshUrl = [NSURL URLWithString: [command.arguments objectAtIndex:1]];

    __weak SpotifyPlugin* weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [[SPTAuth defaultInstance]
         renewSession:session
         withServiceEndpointAtURL:tokenRefreshUrl callback:^(NSError *error, SPTSession *session) {
             CDVPluginResult *pluginResult;

             if (error != nil) {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
             } else {
                 NSNumber *expirationDate = [NSNumber numberWithInteger:session.expirationDate.timeIntervalSince1970];

                 pluginResult = [CDVPluginResult
                                 resultWithStatus:CDVCommandStatus_OK
                                 messageAsDictionary: @{@"username": session.canonicalUsername,
                                                        @"credential": session.accessToken,
                                                        @"expirationDate": expirationDate}];
             }

             [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }];
    }];
}

- (void)isSessionValid:(CDVInvokedUrlCommand *)command
{
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:0]];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool: session.isValid];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark AudioPlayer methods

- (void)createAudioPlayerAndLogin:(CDVInvokedUrlCommand*)command
{
    NSString *clientId = [command.arguments objectAtIndex:0];
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:1]];

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
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    if (player == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    __weak SpotifyPlugin* weakSelf = self;

    [self.commandDelegate runInBackground:^{
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
}

- (void)addAudioPlayerEventListener:(CDVInvokedUrlCommand*)command
{

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    [self.commandDelegate runInBackground:^{
        if (player == nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

            return;
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventNotificationFromAudioPlayer:) name:@"event" object:player];
    }];
}

- (void)play:(CDVInvokedUrlCommand*)command
{
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    id data = [command.arguments objectAtIndex:1];

    if (player == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    if ([data isKindOfClass:[NSString class]]) {
        [self playURI:[NSURL URLWithString: data] player:player callbackId:command.callbackId];
    } else if ([data isKindOfClass:[NSArray class]]) {
        int index = ((NSNumber *)[command.arguments objectAtIndex:2]).intValue;
        [self playArray:data fromIndex:index player:player callbackId:command.callbackId];
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown data"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }
}

- (void)playURI:(NSURL *)uri player:(SpotifyAudioPlayer *)player callbackId:(NSString *)callbackId
{
    __weak SpotifyPlugin * weakSelf = self;

    [self.commandDelegate runInBackground:^{
        [player playURI:uri callback:^(NSError *error) {
            CDVPluginResult *pluginResult;

            if (error != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }

            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }];
    }];
}

- (void)playArray:(NSArray *)tracks fromIndex:(int)index player:(SpotifyAudioPlayer *)player callbackId:(NSString *)callbackId
{
    __weak SpotifyPlugin * weakSelf = self;

    NSMutableArray *trackURIs = [NSMutableArray new];

    [tracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [trackURIs addObject:[NSURL URLWithString:obj]];
    }];

    [SPTTrack tracksWithURIs:trackURIs session:nil callback:^(NSError *error, id object) {
        SpotifyAdhocTrackProvider *provider = [[SpotifyAdhocTrackProvider alloc] initWithTracks:object];

        [self.commandDelegate runInBackground:^{
            [player playTrackProvider:provider callback:^(NSError *error) {
                CDVPluginResult *pluginResult;

                if (error != nil) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }

                [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            }];
        }];
    }];
}

- (void)queue:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    NSURL *uri = [NSURL URLWithString: [command.arguments objectAtIndex:1]];

    if (player == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    [self.commandDelegate runInBackground:^{
        [player queueURI:uri callback:^(NSError *error) {
            CDVPluginResult *pluginResult;

            if (error != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }

            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)skipNext:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin *weakSelf = self;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    if (player == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    [self.commandDelegate runInBackground:^{
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
}

- (void)skipPrevious:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin *weakSelf = self;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    if (player == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    [self.commandDelegate runInBackground:^{
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
}

- (void)seekToOffset:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    NSTimeInterval offset = ((NSNumber *)[command.arguments objectAtIndex:1]).doubleValue;

    if (player == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    [self.commandDelegate runInBackground:^{
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

}

- (void)getIsPlaying:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        BOOL isPlaying = [player isPlaying];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool: isPlaying];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setIsPlaying:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    BOOL isPlaying = ((NSNumber *)[command.arguments objectAtIndex:1]).boolValue;

    [self.commandDelegate runInBackground:^{
        if (player == nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

            return;
        }

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
}

- (void)getVolume:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        SPTVolume volume = [player volume];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble: volume];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setVolume:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    SPTVolume volume = ((NSNumber *)[command.arguments objectAtIndex:1]).doubleValue;

    if (player == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    [self.commandDelegate runInBackground:^{

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
}

- (void)getRepeat:(CDVInvokedUrlCommand *)command
{
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    CDVPluginResult *pluginResult;

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:player.repeat];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setRepeat:(CDVInvokedUrlCommand *)command
{
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    BOOL repeat = ((NSNumber *)[command.arguments objectAtIndex:1]).boolValue;
    CDVPluginResult *pluginResult;

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        player.repeat = repeat;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:player.repeat];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getShuffle:(CDVInvokedUrlCommand *)command
{
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    CDVPluginResult *pluginResult;

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:player.shuffle];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setShuffle:(CDVInvokedUrlCommand *)command
{
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    BOOL shuffle = ((NSNumber *)[command.arguments objectAtIndex:1]).boolValue;
    CDVPluginResult *pluginResult;

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        player.shuffle = shuffle;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:player.shuffle];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getTargetBitrate:(CDVInvokedUrlCommand *)command
{
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    CDVPluginResult *pluginResult;

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)player.targetBitrate];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setTargetBitrate:(CDVInvokedUrlCommand *)command
{
    __weak SpotifyPlugin * weakSelf = self;
    __weak SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    SPTBitrate bitrate = ((NSNumber *)[command.arguments objectAtIndex:1]).unsignedIntegerValue;

    if (player == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return;
    }

    [self.commandDelegate runInBackground:^{
        [player setTargetBitrate:bitrate callback:^(NSError *error) {
            CDVPluginResult *pluginResult;

            if (error != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)player.targetBitrate];
            }

            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)getDiskCacheSizeLimit:(CDVInvokedUrlCommand *)command
{
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    CDVPluginResult *pluginResult;

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)player.diskCacheSizeLimit];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)setDiskCacheSizeLimit:(CDVInvokedUrlCommand *)command
{
    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    NSUInteger diskCacheSizeLimit = ((NSNumber *)[command.arguments objectAtIndex:1]).unsignedIntegerValue;
    CDVPluginResult *pluginResult;

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        player.diskCacheSizeLimit = diskCacheSizeLimit;

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)player.diskCacheSizeLimit];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)getLoggedIn:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        BOOL loggedIn = [player loggedIn];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool: loggedIn];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getTrackMetadata:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult *pluginResult;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    int trackID = -1;
    BOOL relative = false;

    if ([command.arguments count] >= 2) {
        trackID = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;

        if ([command.arguments count] == 3) {
            relative = ((NSNumber *)[command.arguments objectAtIndex:2]).boolValue;
        }
    }

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
        return [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

    [self.commandDelegate runInBackground:^{
        void (^dataCallback)(NSDictionary*) = ^void(NSDictionary *data) {
            NSDictionary *track = nil;

            if (data != nil) {
                track = @{@"name": [data valueForKey:@"SPAudioStreamingMetadataTrackName"],
                          @"uri": [data valueForKey:@"SPAudioStreamingMetadataTrackURI"],
                          @"artist": @{@"name": [data valueForKey:@"SPAudioStreamingMetadataArtistName"],
                                       @"uri": [data valueForKey:@"SPAudioStreamingMetadataArtistURI"]},
                          @"album": @{@"name": [data valueForKey:@"SPAudioStreamingMetadataAlbumName"],
                                      @"uri":[data valueForKey:@"SPAudioStreamingMetadataAlbumURI"]},
                          @"duration": [data valueForKey:@"SPAudioStreamingMetadataTrackDuration"]};
            }

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: track];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
}

- (void)getCurrentPlaybackPosition:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        NSTimeInterval position = [player currentPlaybackPosition];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble: position];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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

- (SpotifyAudioPlayer*)getAudioPlayerByID:(NSString *)playerID
{
    return [SpotifyAudioPlayer getInstanceByID:playerID];
}


-(SPTSession *)convertSession:(NSDictionary *)data
{
    return [[SPTSession alloc]
            initWithUserName:[data valueForKey:@"username"]
            accessToken:[data valueForKey:@"credential"]
            expirationDate: [NSDate dateWithTimeIntervalSince1970: [[data valueForKey:@"expirationDate"] doubleValue]]];
}

@end
