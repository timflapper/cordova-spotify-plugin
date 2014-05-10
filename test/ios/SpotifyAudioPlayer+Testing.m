//
//  SpotifyAudioPlayer+Testing.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 09/05/14.
//
//

#import "SpotifyAudioPlayer+Testing.h"
#import <objc/runtime.h>

static char const * const nextCallbackKey = "__nextCallbackForTesting";
static char const * const nextReturnKey = "__nextReturnForTesting";
static char const * const delayInSecondsKey = "__delayInSecondsTesting";

void runBlockAfterDelayInSeconds(NSTimeInterval delayInSeconds, dispatch_block_t block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@implementation SpotifyAudioPlayer (Testing)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(registerEventCallback:);
        SEL swizzledSelector = @selector(swizzled_registerEventCallback:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        [self clearTestValues];
    });
}

+ (void)clearTestValues
{
    objc_setAssociatedObject([self class], nextCallbackKey, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject([self class], delayInSecondsKey, @0, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject([self class], nextReturnKey, nil, OBJC_ASSOCIATION_RETAIN);
}

+ (void)setNextCallback:(mockResultCallback)block
{
    objc_setAssociatedObject([self class], nextCallbackKey, block, OBJC_ASSOCIATION_COPY);
}

+ (void)setNextCallback:(mockResultCallback)block afterDelayInSeconds:(NSTimeInterval)delayInSeconds
{
    objc_setAssociatedObject([self class], delayInSecondsKey, [NSNumber numberWithDouble:delayInSeconds], OBJC_ASSOCIATION_RETAIN);
    [self setNextCallback:block];
}

+ (void)setNextMethodReturn:(id)returnValue
{
    objc_setAssociatedObject([self class], nextReturnKey, returnValue, OBJC_ASSOCIATION_RETAIN);
}

+ (id)getNextMethodReturn
{
    return objc_getAssociatedObject([self class], nextReturnKey);
}

+ (void)invokeNextCallback:(id)block
{
    mockResultCallback callback = objc_getAssociatedObject([self class], nextCallbackKey);
    NSTimeInterval delayInSeconds = ((NSNumber *)objc_getAssociatedObject([self class], delayInSecondsKey)).doubleValue;
    
    if (delayInSeconds > 0 && callback) {
        runBlockAfterDelayInSeconds(delayInSeconds, ^{
            callback(block);
        });
    } else {
        callback(block);
    }
}

- (id)initWithCompanyName:(NSString *)companyName appName:(NSString *)appName
{
    self = [super init];
    
    return self;
}

- (void)swizzled_registerEventCallback:(SpotifyEventCallback)callback
{
    [[self class] invokeNextCallback:callback];
}

- (void)loginWithSession:(SPTSession *)session callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
}

- (void)playURI:(NSURL *)uri callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
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
    [[self class] invokeNextCallback:block];
}

- (SPVolume)volume
{
    NSNumber *methodReturn = [[self class] getNextMethodReturn];
    
    return methodReturn.doubleValue;
}

- (void)setVolume:(SPVolume)volume callback:(SPTErrorableOperationCallback)block
{
    [[self class] invokeNextCallback:block];
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
