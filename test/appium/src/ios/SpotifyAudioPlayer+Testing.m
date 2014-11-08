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

static IMP __initWithCompanyName_Imp;
id __Swizzle_initWithCompanyName(SpotifyAudioPlayer *self, SEL _cmd, NSString *companyName, NSString *appName, SPTCoreAudioController *audioController)
{
    AutomationCoreAudioController *controller = [AutomationCoreAudioController new];

    return __initWithCompanyName_Imp(self, _cmd, companyName, appName, controller);
}

@implementation SpotifyAudioPlayer (Testing)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(initWithCompanyName:appName:audioController:));
        __initWithCompanyName_Imp = method_setImplementation(originalMethod, (IMP)__Swizzle_initWithCompanyName);
    });
}
@end
