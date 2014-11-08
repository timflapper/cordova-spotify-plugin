//
//  AutomationCoreAudioController.m
//

#import "AutomationCoreAudioController.h"

@interface AutomationCoreAudioController ()

@property SPTCircularBuffer *circularBuffer;
@property BOOL buffering;

@property NSInteger framesSinceLastTimeUpdate;
@end

@implementation AutomationCoreAudioController

- (id)init {
    self = [super init];

    if (self) {
        _framesSinceLastTimeUpdate = 0;
        _buffering = false;
    }

    return self;
}

- (NSInteger)attemptToDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount streamDescription:(AudioStreamBasicDescription)audioDescription
{
    if (! self.circularBuffer) {
        self.circularBuffer = [[SPTCircularBuffer alloc] initWithMaximumLength:(audioDescription.mBytesPerFrame * audioDescription.mSampleRate) * 0.5];
        self.buffering = true;
    }

    NSUInteger bytesToAdd = audioDescription.mBytesPerPacket * frameCount;

    NSUInteger bytesAdded = [self.circularBuffer attemptAppendData:audioFrames ofLength:bytesToAdd chunkSize:audioDescription.mBytesPerPacket];

    NSUInteger framesAdded = bytesAdded / audioDescription.mBytesPerPacket;

    self.framesSinceLastTimeUpdate += framesAdded;

    if (self.framesSinceLastTimeUpdate >= 8820) {
        [[self delegate] coreAudioController:self didOutputAudioOfDuration:self.framesSinceLastTimeUpdate/audioDescription.mSampleRate];

        self.framesSinceLastTimeUpdate = 0;
    }

    if (self.buffering) {
        [self grabDataFromBufferOnInterval];
        self.buffering = false;
    }

    return framesAdded;
}

-(void)grabDataFromBufferOnInterval
{
    [NSTimer scheduledTimerWithTimeInterval:0.50f
                                     target:self selector:@selector(grabDataFromBuffer:) userInfo:nil repeats:YES];
}

-(void)grabDataFromBuffer:(NSTimer *)timer
{
    [self.circularBuffer clear];
}
@end
