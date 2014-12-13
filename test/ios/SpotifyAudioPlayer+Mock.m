//
//  SpotifyAudioPlayer+Mock.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 09/05/14.
//
//

#import "SpotifyAudioPlayer+Mock.h"
#import <objc/runtime.h>

static char const * const nextCallbackKey = "__nextCallbackForTesting";
static char const * const delayInSecondsKey = "__delayInSecondsTesting";
static char const * const nextReturnKey = "__nextReturnForTesting";
static char const * const nextEventKey = "__nextEventForTesting";


void runBlockAfterDelayInSeconds(NSTimeInterval delayInSeconds, dispatch_block_t block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@implementation SpotifyAudioPlayer (Mock)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self clearTestValues];
    });

    [super load];
}

+ (void)clearTestValues
{
    objc_setAssociatedObject([self class], nextCallbackKey, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject([self class], delayInSecondsKey, @0, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject([self class], nextReturnKey, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject([self class], nextEventKey, nil, OBJC_ASSOCIATION_RETAIN);
}

+ (void)setNextCallback:(mockResultCallback)block
{
    objc_setAssociatedObject([self class], nextCallbackKey, block, OBJC_ASSOCIATION_COPY);
}

+ (void)setNextCallback:(mockResultCallback)block afterDelayInSeconds:(NSTimeInterval)delayInSeconds
{
    objc_setAssociatedObject([self class], delayInSecondsKey, [NSNumber numberWithDouble:delayInSeconds], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject([self class], nextCallbackKey, block, OBJC_ASSOCIATION_COPY);
}

+ (void)setNextMethodReturn:(id)returnValue
{
    objc_setAssociatedObject([self class], nextReturnKey, returnValue, OBJC_ASSOCIATION_RETAIN);
}

+ (void)setNextEvent:(NSDictionary *)event
{
    objc_setAssociatedObject([self class], nextEventKey, event, OBJC_ASSOCIATION_RETAIN);
}

+ (void)invokeNextCallback:(id)block
{
    mockResultCallback callback = objc_getAssociatedObject([self class], nextCallbackKey);
    NSTimeInterval delayInSeconds = ((NSNumber *)objc_getAssociatedObject([self class], delayInSecondsKey)).doubleValue;
    
    if (! callback)
        return;
    
    if (delayInSeconds > 0) {
        runBlockAfterDelayInSeconds(delayInSeconds, ^{
            callback(block);
        });
    } else {
        callback(block);
    }
}

+ (id)getNextMethodReturn
{
    return objc_getAssociatedObject([self class], nextReturnKey);
}

+ (NSDictionary *)getNextEvent
{
    return objc_getAssociatedObject([self class], nextEventKey);
}

- (void)loginWithSession:(SPTSession *)session callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
    
    [self audioStreamingDidLogin:self];
}

- (void)playURI:(NSURL *)uri callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
    
    if ([[self class] getNextMethodReturn] != nil)
        [self audioStreaming:self didChangeToTrack:[[self class] getNextMethodReturn]];
    
    [self audioStreaming:self didChangePlaybackStatus:YES];
}

- (void)playURI:(NSURL *)uri fromIndex:(int)index callback:(SPTErrorableOperationCallback)block
{
    [self playURI:uri callback:block];
}

- (void)playURIs:(NSArray *)uris fromIndex:(int)index callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];

    if ([[self class] getNextMethodReturn] != nil)
        [self audioStreaming:self didChangeToTrack:[[self class] getNextMethodReturn]];

    [self audioStreaming:self didChangePlaybackStatus:YES];
}

- (void)setURIs:(NSArray *)uris callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
}

- (void)playURIsFromIndex:(int)index callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];

    if ([[self class] getNextMethodReturn] != nil)
        [self audioStreaming:self didChangeToTrack:[[self class] getNextMethodReturn]];

    [self audioStreaming:self didChangePlaybackStatus:YES];
}

- (void)queueURI:(NSURL *)uri callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
}

- (void)queueURI:(NSURL *)uri clearQueue:(BOOL)clear callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
}

- (void)queueURIs:(NSArray *)uris clearQueue:(BOOL)clear callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
}

- (void)queuePlay:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];

    if ([[self class] getNextMethodReturn] != nil)
        [self audioStreaming:self didChangeToTrack:[[self class] getNextMethodReturn]];

    [self audioStreaming:self didChangePlaybackStatus:YES];
}

- (void)queueClear:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
}

- (void)stop:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];

    if ([[self class] getNextMethodReturn] != nil)
        [self audioStreaming:self didChangeToTrack:[[self class] getNextMethodReturn]];

    [self audioStreaming:self didChangePlaybackStatus:YES];
}

- (void)skipNext:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];

    if ([[self class] getNextMethodReturn] != nil)
        [self audioStreaming:self didChangeToTrack:[[self class] getNextMethodReturn]];

    [self audioStreaming:self didChangePlaybackStatus:YES];

}

- (void)skipPrevious:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];

    if ([[self class] getNextMethodReturn] != nil)
        [self audioStreaming:self didChangeToTrack:[[self class] getNextMethodReturn]];

    [self audioStreaming:self didChangePlaybackStatus:YES];

}

- (void)seekToOffset:(NSTimeInterval)offset callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
}

- (BOOL)isPlaying
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];
    
    return methodReturn.boolValue;
}

- (void)setIsPlaying:(BOOL)playing callback:(SPTErrorableOperationCallback)block
{
    [self audioStreaming:self didChangePlaybackStatus:playing];
    
    [[self class] invokeNextCallback:block];
}

- (SPTBitrate)targetBitrate
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];

    return methodReturn.intValue;
}

- (void)setTargetBitrate:(SPTBitrate)bitrate callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
}

- (NSUInteger)diskCacheSizeLimit
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];

    return methodReturn.intValue;
}

- (void)setDiskCacheSizeLimit:(NSUInteger)diskCacheSizeLimit
{
    return;
}

- (SPTVolume)volume
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];

    return methodReturn.doubleValue;
}

- (void)setVolume:(SPTVolume)volume callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
    [self audioStreaming:self didChangeVolume:volume];
}

- (BOOL)repeat
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];

    return methodReturn.boolValue;
}

- (void)setRepeat:(BOOL)repeat
{
    [self audioStreaming:self didChangeRepeatStatus:repeat];
}

- (BOOL)shuffle
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];

    return methodReturn.boolValue;
}

- (void)setShuffle:(BOOL)shuffle
{
    [self audioStreaming:self didChangeShuffleStatus:shuffle];
}

- (int)queueSize
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];

    return methodReturn.intValue;
}

- (int)trackListSize
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];

    return methodReturn.intValue;
}

- (NSDictionary *)currentTrackMetadata
{
    return [[self class] getNextMethodReturn];
}

- (void)getRelativeTrackMetadata:(int)index callback:(void (^)(NSDictionary *))block
{
   [[self class] invokeNextCallback:block];
}

- (void)getAbsoluteTrackMetadata:(int)index callback:(void (^)(NSDictionary *))block
{
   [[self class] invokeNextCallback:block];
}

- (NSTimeInterval)currentPlaybackPosition
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];
        
    return methodReturn.doubleValue;
}

@end
