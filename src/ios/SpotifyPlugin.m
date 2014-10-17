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

        observer = [[NSNotificationCenter defaultCenter] addObserverForName:CDVPluginHandleOpenURLNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSURL *url = [note object];

            if([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL: callbackUrl]) {
                [[NSNotificationCenter defaultCenter] removeObserver:observer];

                [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
                 tokenSwapServiceEndpointAtURL:tokenSwapUrl
                 callback:^(NSError *error, id result) {
                     CDVPluginResult *pluginResult;
                     SPTSession *session;

                     if (error != nil) {
                         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                     } else {
                         session = result;

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

        SPTAuth *auth = [SPTAuth defaultInstance];

        NSURL *loginURL = [auth loginURLForClientId:clientId
                                declaredRedirectURL:callbackUrl
                                             scopes:scopes];

        [[UIApplication sharedApplication] openURL:loginURL];
    }];
}

#pragma mark AudioPlayer methods

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
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: player.instanceID];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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

- (void)playURI:(CDVInvokedUrlCommand*)command
{
    __weak SpotifyPlugin * weakSelf = self;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];
    NSURL *uri = [NSURL URLWithString: [command.arguments objectAtIndex:1]];

    [self.commandDelegate runInBackground:^{
        if (player == nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

            return;
        }

        [player playURI:uri callback:^(NSError *error) {
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

    [self.commandDelegate runInBackground:^{
        if (player == nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

            return;
        }

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

    [self.commandDelegate runInBackground:^{
        if (player == nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

            return;
        }

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

- (void)getCurrentTrack:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult;

    SpotifyAudioPlayer *player = [self getAudioPlayerByID: [command.arguments objectAtIndex:0]];

    if (player == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"AudioPlayer does not exist"];
    } else {
        NSDictionary *data = [player currentTrackMetadata];
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
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

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
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:(NSInteger)[data valueForKey:@"expirationDate"]];

    return [[SPTSession alloc] initWithUserName:[data valueForKey:@"username"] accessToken:[data valueForKey:@"credential"] expirationDate: expirationDate];
}

@end
