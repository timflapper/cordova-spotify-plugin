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
//    [self audio]
}

- (void)playURI:(NSURL *)uri callback:(SPTErrorableOperationCallback)block
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

- (NSDictionary *)currentTrackMetadata
{
    return [[self class] getNextMethodReturn];
}

- (NSTimeInterval)currentPlaybackPosition
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];
        
    return methodReturn.doubleValue;
}

@end
