//
//  AppDelegate+SpotifyPlugin.m
//

#import "AppDelegate+SpotifyPlugin.h"
#import "SpotifyPlugin.h"
#import "SpotifyAuthentication.h"
#import <objc/runtime.h>

@implementation AppDelegate (SpotifyPlugin)
+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleApplicationOpenURL];
    });
}

+(void)swizzleApplicationOpenURL
{
    Class class = [self class];
    
    SEL originalSelector = @selector(application:openURL:sourceApplication:annotation:);
    SEL customSelector = @selector(customApplication:openURL:sourceApplication:annotation:);
    SEL backupSelector = @selector(backupApplication:openURL:sourceApplication:annotation:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method customMethod = class_getInstanceMethod(class, customSelector);
    Method backupMethod = class_getInstanceMethod(class, backupSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(customMethod),
                                        method_getTypeEncoding(customMethod));
    
    if (didAddMethod) {
        if (originalMethod) {
            class_replaceMethod(class,
                                customSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            class_replaceMethod(class,
                                customSelector,
                                method_getImplementation(backupMethod),
                                method_getTypeEncoding(backupMethod));
        }
    } else {
        method_exchangeImplementations(originalMethod, customMethod);
    }
    
}

- (id) getCommandInstance:(NSString*)className
{
	return [self.viewController getCommandInstance:className];
}

-(BOOL)customApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"OpenURL Result in AppDelegate+SpotifyPlugin");
 
    if ([[SpotifyAuthentication defaultInstance] openURL:url])
        return YES;
    
    return [self customApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

-(BOOL)backupApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return NO;
}

@end
