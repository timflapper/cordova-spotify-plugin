//
//  SpotifyAudioPlayer.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 08/05/14.
//
//

#import "SpotifyAudioPlayer.h"


@interface SpotifyAudioPlayer()
@property (copy) SpotifyEventCallback eventCallback;
@end

@implementation SpotifyAudioPlayer
@synthesize eventCallback, delegate, playbackDelegate;

-(id)initWithCompanyName:(NSString *)companyName appName:(NSString *)appName
{
    self = [super init];
    
    if (self) {
        delegate = self;
        playbackDelegate = self;
    }
    
    return self;
}

-(void)registerEventCallback:(SpotifyEventCallback)callback
{
    eventCallback = callback;
}

-(void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming
{
    eventCallback(@[@"login"]);
}

-(void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming
{
    eventCallback(@[@"logout"]);
}

-(void)audioStreamingDidLosePermissionForPlayback:(SPTAudioStreamingController *)audioStreaming
{
    eventCallback(@[@"permissionLost"]);
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
    
    eventCallback(@[@"playbackStatus", [NSNumber numberWithBool:isPlaying]]);
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
//     eventCallback(@[@"volume", [NSNumber numberWithDouble:volume]]);
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didEncounterError:(NSError *)error
{
     eventCallback(@[@"error", error.localizedDescription]);
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message
{
     eventCallback(@[@"message", message]);
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToOffset:(NSTimeInterval)offset
{
     eventCallback(@[@"seekToOffset", [NSNumber numberWithInt:offset]]);
}

-(void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming
{
    
}

-(void)audioStreamingDidSkipToPreviousTrack:(SPTAudioStreamingController *)audioStreaming
{
    
}

@end
