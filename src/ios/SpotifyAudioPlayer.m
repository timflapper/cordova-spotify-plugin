//
//  SpotifyAudioPlayer.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 08/05/14.
//
//

#import "SpotifyAudioPlayer.h"


@interface SpotifyAudioPlayer()
@end

@implementation SpotifyAudioPlayer
static NSMutableDictionary *instances;

@synthesize delegate, playbackDelegate;

+ (void)initialize
{
    if (self == [SpotifyAudioPlayer class]) {
        instances = [NSMutableDictionary new];
    }
}

+ (instancetype)getInstanceByID:(NSString *)ID
{
    return [instances objectForKey: ID];
}

- (id)initWithCompanyName:(NSString *)companyName appName:(NSString *)appName
{
    self = [super initWithCompanyName:companyName appName:appName];

    if (self) {
        delegate = self;
        playbackDelegate = self;

        _instanceID = [NSString stringWithFormat:@"%lu", instances.count+1];
        [instances setObject:self
                      forKey: _instanceID];
    }

    return self;
}

- (void)dispatchEvent:(NSString *)type
{
    [self dispatchEvent:type withArguments:@[]];
}

- (void)dispatchEvent:(NSString *)type withArguments:(NSArray *)args
{

    NSDictionary *info = @{@"type": type,
                           @"args": args};

    NSNotification *note = [NSNotification notificationWithName:@"event" object:self userInfo:info];

    [[NSNotificationCenter defaultCenter] postNotification:note];
}

-(void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming
{
    [self dispatchEvent:@"login"];
}

-(void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming
{

}

-(void)audioStreamingDidLosePermissionForPlayback:(SPTAudioStreamingController *)audioStreaming
{
    [self dispatchEvent:@"permissionLost"];
}

-(void)audioStreamingDidBecomeActivePlaybackDevice:(SPTAudioStreamingController *)audioStreaming
{

}

-(void)audioStreamingDidBecomeInactivePlaybackDevice:(SPTAudioStreamingController *)audioStreaming
{

}

-(void)audioStreamingDidEncounterTemporaryConnectionError:(SPTAudioStreamingController *)audioStreaming
{

}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying
{

    [self dispatchEvent:@"playbackStatus" withArguments:@[[NSNumber numberWithBool:isPlaying]]];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeRepeatStatus:(BOOL)isRepeated
{

}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeShuffleStatus:(BOOL)isShuffled
{

}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata
{
 [self dispatchEvent:@"trackChanged" withArguments:@[trackMetadata]];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeVolume:(SPTVolume)volume
{

}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didEncounterError:(NSError *)error
{

    [self dispatchEvent:@"error" withArguments:@[error.localizedDescription]];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message
{

    [self dispatchEvent:@"message" withArguments:@[message]];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToOffset:(NSTimeInterval)offset
{
    [self dispatchEvent:@"seekToOffset" withArguments:@[[NSNumber numberWithDouble:offset]]];
}

-(void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming
{

}

-(void)audioStreamingDidSkipToPreviousTrack:(SPTAudioStreamingController *)audioStreaming
{

}

@end
