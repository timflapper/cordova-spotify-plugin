//
//  MockCommandDelegate.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 08/05/14.
//
//

#import "MockCommandDelegate.h"

@interface MockCommandDelegate()
@property (copy, nonatomic) mockPluginResultCallback callback;
@end

@implementation MockCommandDelegate

- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)mockPluginResult:(mockPluginResultCallback)callback
{
    self.callback = callback;
}

- (void)sendPluginResult:(CDVPluginResult*)result callbackId:(NSString*)callbackId
{
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.callback)
            self.callback(result, callbackId);
    });
}

#pragma mark neccesary but unused protocol methods

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return @"";
}

- (id)getCommandInstance:(NSString*)pluginName
{
    return nil;
}

- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return YES;
}

- (void)evalJs:(NSString*)js
{
    
}

- (void)evalJs:(NSString*)js scheduledOnRunLoop:(BOOL)scheduledOnRunLoop
{
    
}

- (void)runInBackground:(void (^)())block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (NSString*)userAgent
{
    return @"";
}

- (BOOL)URLIsWhitelisted:(NSURL*)url
{
    return YES;
}

- (NSDictionary*)settings
{
    return @{};
}
@end
