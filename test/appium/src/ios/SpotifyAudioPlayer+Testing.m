//
//  SpotifyAudioPlayer+Testing.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 08/11/14.
//
//

#import "SpotifyAudioPlayer+Testing.h"
#import "AutomationCoreAudioController.h"
#import <objc/runtime.h>

static IMP __initWithClientId_Imp;
id __Swizzle_initWithClientId(SpotifyAudioPlayer *self, SEL _cmd, NSString *clientId, SPTCoreAudioController *audioController)
{
    AutomationCoreAudioController *controller = [AutomationCoreAudioController new];

    return __initWithClientId_Imp(self, _cmd, clientId, controller);
}

@implementation SpotifyAudioPlayer (Testing)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(initWithClientId:audioController:));
        __initWithClientId_Imp = method_setImplementation(originalMethod, (IMP)__Swizzle_initWithClientId);
    });
}
@end
