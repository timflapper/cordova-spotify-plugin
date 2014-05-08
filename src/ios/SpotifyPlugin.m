//
//  SpotifyPlugin.m
//

#import "SpotifyPlugin.h"

@interface SpotifyPlugin()
@property (strong, nonatomic) NSMutableArray *audioPlayers;
@property NSURL *callbackUrl;
@end

@implementation SpotifyPlugin
@synthesize audioPlayers, callbackUrl;
- (void)pluginInitialize
{
    audioPlayers = [NSMutableArray arrayWithObject:[NSNull new]];
    
    callbackUrl = [NSURL URLWithString:@"spotify-ios-sdk-beta://callback"];
}

- (void)authenticate:(CDVInvokedUrlCommand*)command
{
//    NSLog(@"SpotifyPlugin authenticate");
    
    NSString *clientId = [command.arguments objectAtIndex:0];
    NSURL *tokenSwapUrl = [NSURL URLWithString: [command.arguments objectAtIndex:1]];
    NSArray *scopes = [command.arguments objectAtIndex:2];
    
    __weak SpotifyPlugin* weakSelf = self;
    
    __block id observer = nil;
    
    [self.commandDelegate runInBackground:^{
        
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:CDVPluginHandleOpenURLNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSURL *url = [note object];
            
            if([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL: callbackUrl]) {
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
                
                NSArray *queryArr = [[url query] componentsSeparatedByString:@"="];
                
                if (queryArr.count == 1 || [[queryArr objectAtIndex:0] isEqualToString:@"code"] == NO) {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"aborted"];
                    [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    return;
                }
                
                [[SPTAuth defaultInstance]
                 handleAuthCallbackWithTriggeredAuthURL:url
                 tokenSwapServiceEndpointAtURL:tokenSwapUrl
                 callback:^(NSError *error, id result) {
                     CDVPluginResult *pluginResult;
                     SPTSession *session;
                     
                     if (error != nil) {
//                         NSLog(@"Error on handleAuthCallback: %@", error);
                         
                         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                     } else {
                         session = result;
                         
                         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: @{@"username": session.canonicalUsername,
                                                                                                                     @"credential": session.credential}];
                     }
                     
                     [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                 }];
            }
        }];
        
        SPTAuth *auth = [SPTAuth defaultInstance];
        
        NSURL *loginURL = [auth loginURLForClientId:clientId
                                declaredRedirectURL:callbackUrl
                                             scopes:scopes];
        
        [[UIApplication sharedApplication] openURL:loginURL];
    }];
}

- (void)search:(CDVInvokedUrlCommand*)command
{
//    NSLog(@"SpotifyPlugin search");
    
    NSString *query = [command.arguments objectAtIndex:0];
    NSString *searchType = [command.arguments objectAtIndex:1];
    int offset = [((NSNumber *)[command.arguments objectAtIndex:2]) integerValue];
    
    [self.commandDelegate runInBackground:^{
        [SpotifyAPIRequest searchObjectsWithQuery:query type:searchType offset:offset limit:LIMIT_DEFAULT callback:^(NSError *error, NSData *data) {
            CDVPluginResult *pluginResult;
            
            NSDictionary *objects = [SpotifyJSON parseData:data error:&error];
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin search ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:objects];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
    
}

- (void)getPlaylistsForUser:(CDVInvokedUrlCommand*)command
{
//    NSLog(@"SpotifyPlugin getPlaylistsForUser");
    
    NSString *username = [command.arguments objectAtIndex:0];
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:1]];
    
    [self.commandDelegate runInBackground:^{
        [SPTRequest playlistsForUser:username withSession:session callback:^(NSError *error, SPTPlaylistList * list) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin getPlaylistsForUser ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:list.items];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)requestItemAtURI:(CDVInvokedUrlCommand*)command
{
//    NSLog(@"SpotifyPlugin getObjectFromURI");
    
    SPTSession *session = nil;
    NSString *uri = [command.arguments objectAtIndex:0];
    NSDictionary *sessionData = [command.arguments objectAtIndex:1];
    
    if (sessionData != nil) {
        session = [self convertSession: sessionData];
    }
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult;
        NSError *error = nil;
        NSString * objectType;
        NSString * objectID;
        
        NSString *pattern = @"^spotify:(?:(?:user:[^:]*:)(?=playlist:[a-zA-Z0-9]*$)|(?:(?=artist|album|track)))(playlist|artist|album|track):([a-zA-Z0-9]*)$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:&error];
        
        if (error) {
//            NSLog(@"REGEX ERROR %@", error);
        } else {
            NSTextCheckingResult *match = [regex firstMatchInString:uri options:0 range:NSMakeRange(0, uri.length)];
            
            if (match == nil) {
                error = [SpotifyPluginError errorWithCode:SpotifyPluginInvalidSpotifyURIError description:[NSString stringWithFormat:@"URI appears to be invalid %@", uri]];
            } else {
                
                objectType = [uri substringWithRange: [match rangeAtIndex:1]];
                
                objectID = [uri substringWithRange: [match rangeAtIndex:2]];
                
                if ([objectType isEqualToString:@"playlist"]) {
                    [SPTPlaylistSnapshot playlistWithURI:[NSURL URLWithString:uri] session:session callback:^(NSError *error, SPTPlaylistSnapshot* playlist) {
                        CDVPluginResult *pluginResult;
                        
                        if (error != nil) {
//                            NSLog(@"** SpotifyPlugin search ERROR: %@", error);
                            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                        } else {
                            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: [self convertPlaylist:playlist]];
                        }
                        
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                        
                    }];
                } else {
                    [SpotifyAPIRequest getObjectByID:objectID type:objectType callback:^(NSError *error, NSData *data) {
                        CDVPluginResult *pluginResult;
                        
                        NSDictionary *object = [SpotifyJSON parseData:data error:&error];
                        
                        if (error != nil) {
//                            NSLog(@"** SpotifyPlugin search ERROR: %@", error);
                            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
                        } else {
                            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:object];
                        }
                        
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }];
                }
                return;
            }
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)createAudioPlayerAndLogin:(CDVInvokedUrlCommand*)command
{
    NSString *companyName = [command.arguments objectAtIndex:0];
    NSString *appName = [command.arguments objectAtIndex:1];
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:2]];
    
    [self.commandDelegate runInBackground:^{
        SpotifyAudioPlayer *player = [[SpotifyAudioPlayer alloc] initWithCompanyName:companyName appName:appName];
        
        [player loginWithSession:session callback:^(NSError *error) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin CreateAudioPlayerAndLogin ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                [audioPlayers addObject:player];
                
                NSInteger playerID = [audioPlayers indexOfObject:player];
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:playerID];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)addAudioPlayerEventListener:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;
    
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    
    [self.commandDelegate runInBackground:^{
        [[self getAudioPlayerByID:playerID] registerEventCallback:^(NSArray *args) {
            
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:args];
            
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)playURI:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;
    
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    NSURL *uri = [NSURL URLWithString: [command.arguments objectAtIndex:1]];
    
    [self.commandDelegate runInBackground:^{
        [[self getAudioPlayerByID:playerID] playURI:uri callback:^(NSError *error) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin playURI ERROR: %@", error);
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
    
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    NSTimeInterval offset = ((NSNumber *)[command.arguments objectAtIndex:1]).doubleValue;
    
    [self.commandDelegate runInBackground:^{
        [[self getAudioPlayerByID:playerID] seekToOffset:offset callback:^(NSError *error) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin seekToOffset ERROR: %@", error);
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
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    
    BOOL isPlaying = [[self getAudioPlayerByID:playerID] isPlaying];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool: isPlaying];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setIsPlaying:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;
    
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    BOOL isPlaying = ((NSNumber *)[command.arguments objectAtIndex:1]).boolValue;
    
    [self.commandDelegate runInBackground:^{
        [[self getAudioPlayerByID:playerID] setIsPlaying:isPlaying callback:^(NSError *error) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin setIsPlaying ERROR: %@", error);
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
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    
    SPVolume volume = [[self getAudioPlayerByID:playerID] volume];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble: volume];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)setVolume:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;
    
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    SPVolume volume = ((NSNumber *)[command.arguments objectAtIndex:1]).doubleValue;
    
    [self.commandDelegate runInBackground:^{
        [[self getAudioPlayerByID:playerID] setVolume:volume callback:^(NSError *error) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin setVolume ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

-(void)getLoggedIn:(CDVInvokedUrlCommand*)command
{
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    
    BOOL loggedIn = [[self getAudioPlayerByID:playerID] loggedIn];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool: loggedIn];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)getCurrentTrack:(CDVInvokedUrlCommand*)command
{
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    
    NSDictionary *data = [[self getAudioPlayerByID:playerID] currentTrackMetadata];
    
    NSDictionary *track = @{@"name": [data valueForKey:@"SPAudioStreamingMetadataTrackName"],
                            @"uri": [data valueForKey:@"SPAudioStreamingMetadataTrackURI"],
                            @"artist": @{@"name": [data valueForKey:@"SPAudioStreamingMetadataArtistName"],
                                         @"uri": [data valueForKey:@"SPAudioStreamingMetadataArtistURI"]},
                            @"album": @{@"name": [data valueForKey:@"SPAudioStreamingMetadataAlbumName"],
                                        @"uri":[data valueForKey:@"SPAudioStreamingMetadataAlbumURI"]},
                            @"duration": [data valueForKey:@"SPAudioStreamingMetadataTrackDuration"]};
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: track];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)getCurrentPlaybackPosition:(CDVInvokedUrlCommand*)command
{
    NSInteger playerID = ((NSNumber *)[command.arguments objectAtIndex:0]).integerValue;
    
    NSTimeInterval position = [[self getAudioPlayerByID:playerID] currentPlaybackPosition];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble: position];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (SpotifyAudioPlayer*)getAudioPlayerByID:(NSInteger)playerID
{
    return [audioPlayers objectAtIndex:playerID];
}

- (void)createPlaylist:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin *weakSelf = self;
    
    NSString *name = [command.arguments objectAtIndex:0];
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:1]];
    
    
    [self.commandDelegate runInBackground:^{
        NSError *error;
        SPTPlaylistList *list = [[SPTPlaylistList alloc] initWithDecodedJSONObject:@{@"creator": session.canonicalUsername} error:&error];
        
        if (error != nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        [list createPlaylistWithName:name session:session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin createPlaylist ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: [self convertPlaylist:playlist]];
            }
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
    }];
}

- (void)setPlaylistName:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin *weakSelf = self;
    
    NSURL *uri = [NSURL URLWithString: [command.arguments objectAtIndex:0]];
    NSString *name = [command.arguments objectAtIndex:1];
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:2]];
    
    [self.commandDelegate runInBackground:^{
        NSError *error;
        SPTPlaylistSnapshot *playlist = [[SPTPlaylistSnapshot alloc] initWithDecodedJSONObject:@{@"uri": uri} error:&error];
        
        if (error != nil) {
//            NSLog(@"** SpotifyPlugin setPlaylistName ERROR: %@", error);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        [playlist setPlaylistName:name withSession:session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin setPlaylistName ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: [self convertPlaylist:playlist]];
            }
            
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)setPlaylistDescription:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin *weakSelf = self;
    
    NSURL *uri = [NSURL URLWithString: [command.arguments objectAtIndex:0]];
    NSString *description = [command.arguments objectAtIndex:1];
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:2]];
    
    [self.commandDelegate runInBackground:^{
        NSError *error;
        SPTPlaylistSnapshot *playlist = [[SPTPlaylistSnapshot alloc] initWithDecodedJSONObject:@{@"uri": uri} error:&error];
        
        if (error != nil) {
//            NSLog(@"** SpotifyPlugin setPlaylistName ERROR: %@", error);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        [playlist setPlaylistDescription:description withSession:session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin setPlaylistDescription ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: [self convertPlaylist:playlist]];
            }
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
    }];
}

- (void)setPlaylistCollaborative:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin *weakSelf = self;
    
    NSURL *uri = [NSURL URLWithString: [command.arguments objectAtIndex:0]];
    BOOL collaborative = ((NSNumber *)[command.arguments objectAtIndex:1]).boolValue;
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:2]];
    
    [self.commandDelegate runInBackground:^{
        NSError *error;
        SPTPlaylistSnapshot *playlist = [[SPTPlaylistSnapshot alloc] initWithDecodedJSONObject:@{@"uri": uri} error:&error];
        
        if (error != nil) {
//            NSLog(@"** SpotifyPlugin setPlaylistName ERROR: %@", error);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        [playlist setPlaylistIsCollaborative:collaborative withSession:session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin setPlaylistCollaborative ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: [self convertPlaylist:playlist]];
            }
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
    }];
    
}

- (void)addTracksToPlaylist:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin *weakSelf = self;
    
    NSURL *uri = [NSURL URLWithString: [command.arguments objectAtIndex:0]];
    NSArray *trackURIs = [command.arguments objectAtIndex:1];
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:2]];
    
    [self.commandDelegate runInBackground:^{
        
        NSMutableArray *tracks = [NSMutableArray new];
        
        [trackURIs enumerateObjectsUsingBlock:^(NSString *uri, NSUInteger idx, BOOL *stop) {
            [tracks addObject: [[SPTPartialTrack alloc] initWithDecodedJSONObject:@{@"uri": uri} error:nil]];
        }];
        
        NSError *error;
        SPTPlaylistSnapshot *playlist = [[SPTPlaylistSnapshot alloc] initWithDecodedJSONObject:@{@"uri": uri} error:&error];
        
        if (error != nil) {
//            NSLog(@"** SpotifyPlugin setPlaylistName ERROR: %@", error);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        [playlist addTracksToPlaylist:tracks withSession:session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin addTracksToPlaylist ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: [self convertPlaylist:playlist]];
            }
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
    }];
    
}

- (void)deletePlaylist:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin *weakSelf = self;
    
    NSURL *uri = [NSURL URLWithString: [command.arguments objectAtIndex:0]];
    SPTSession *session = [self convertSession: [command.arguments objectAtIndex:1]];
    
    [self.commandDelegate runInBackground:^{
        NSError *error;
        SPTPlaylistSnapshot *playlist = [[SPTPlaylistSnapshot alloc] initWithDecodedJSONObject:@{@"uri": uri} error:&error];
        
        if (error != nil) {
//            NSLog(@"** SpotifyPlugin setPlaylistName ERROR: %@", error);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        [playlist deletePlaylistWithSession: session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
            CDVPluginResult *pluginResult;
            
            if (error != nil) {
//                NSLog(@"** SpotifyPlugin deletePlaylist ERROR: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: [self convertPlaylist:playlist]];
            }
            
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
    
}

-(SPTSession *)convertSession:(NSDictionary *)data
{
    return [[SPTSession alloc] initWithUserName:[data valueForKey:@"username"] credential:[data valueForKey:@"credential"]];
}

-(NSDictionary *)convertPlaylist:(SPTPlaylistSnapshot*)playlist
{
    return @{@"type":@"playlist",
             @"name":playlist.name,
             @"version":[NSNumber numberWithInt:playlist.version],
             @"uri":playlist.uri,
             @"collaborative":[NSNumber numberWithBool:playlist.collaborative],
             @"creator":playlist.creator,
             @"tracks":playlist.tracks,
             @"dateModified":playlist.dateModified};
}

@end
