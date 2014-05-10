//
//  SpotifyAudioPlayer+Testing.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 09/05/14.
//
//

#import "SpotifyAudioPlayer.h"

typedef void (^mockResultCallback)(id callback);

@interface SpotifyAudioPlayer (Testing)
+ (void)clearTestValues;

+ (void)setNextCallback:(mockResultCallback)block;

+ (void)setNextCallback:(mockResultCallback)block afterDelayInSeconds:(NSTimeInterval)delayInSeconds;

+ (void)setNextMethodReturn:(id)returnValue;

+ (void)setNextEvent:(NSDictionary *)event;
@end
