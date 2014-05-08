//
//  SpotifyAudioPlayer.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 08/05/14.
//
//

#import "SpotifyAudioPlayer.h"


@interface SpotifyAudioPlayer()
@property (strong) SpotifyEventCallback eventCallback;
@end

@implementation SpotifyAudioPlayer
@synthesize delegate, playbackDelegate;

-(id)initWithCompanyName:(NSString *)companyName appName:(NSString *)appName
{
    self = [super initWithCompanyName:companyName appName:appName];
    
    if (self) {
        delegate = self;
        playbackDelegate = self;
    }
    
    return self;
}

- (void)dispatch:(NSArray *)args
{
    if (self.eventCallback)
        self.eventCallback(args);
}

-(void)registerEventCallback:(SpotifyEventCallback)callback
{
    self.eventCallback = callback;
}

-(void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming
{
    [self dispatch:@[@"login"]];
}

-(void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming
{
    [self dispatch:@[@"logout"]];
}

-(void)audioStreamingDidLosePermissionForPlayback:(SPTAudioStreamingController *)audioStreaming
{
    [self dispatch:@[@"permissionLost"]];
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
    [self dispatch:@[@"playbackStatus", [NSNumber numberWithBool:isPlaying]]];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeRepeatStatus:(BOOL)isRepeated
{
    
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeShuffleStatus:(BOOL)isShuffled
{
    
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata
{
    
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeVolume:(SPVolume)volume
{

}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didEncounterError:(NSError *)error
{
     [self dispatch:@[@"error", error.localizedDescription]];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message
{
    
    [self dispatch:@[@"message", message]];
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToOffset:(NSTimeInterval)offset
{
    [self dispatch:@[@"seekToOffset", [NSNumber numberWithInt:offset]]];
}

-(void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming
{
    
}

-(void)audioStreamingDidSkipToPreviousTrack:(SPTAudioStreamingController *)audioStreaming
{
    
}

@end
