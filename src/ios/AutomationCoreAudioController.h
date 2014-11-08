//
//  AutomationCoreAudioController.h
//

#import <Spotify/Spotify.h>

@interface AutomationCoreAudioController : SPTCoreAudioController<SPTCoreAudioControllerDelegate>
//- (BOOL)connectOutputBus:(UInt32)sourceOutputBusNumber ofNode:(AUNode)sourceNode toInputBus:(UInt32)destinationInputBusNumber ofNode:(AUNode)destinationNode inGraph:(AUGraph)graph error:(NSError *__autoreleasing *)error;

- (NSInteger)attemptToDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount streamDescription:(AudioStreamBasicDescription)audioDescription;
@end
