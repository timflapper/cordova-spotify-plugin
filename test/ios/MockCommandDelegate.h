//
//  MockCommandDelegate.h
//  SpotifyPlugin
//
//  Created by Tim Flapper on 08/05/14.
//
//

#import "Cordova/CDV.h"

typedef void (^mockPluginResultCallback)(CDVPluginResult *result, NSString *callbackId);

@interface MockCommandDelegate : NSObject <CDVCommandDelegate>

- (void)mockPluginResult:(mockPluginResultCallback)callback;

@end
