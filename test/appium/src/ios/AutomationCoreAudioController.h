//
//  AutomationCoreAudioController.h
//

#import <Spotify/Spotify.h>

@interface AutomationCoreAudioController : SPTCoreAudioController<SPTCoreAudioControllerDelegate>
- (NSInteger)attemptToDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount streamDescription:(AudioStreamBasicDescription)audioDescription;
@end
