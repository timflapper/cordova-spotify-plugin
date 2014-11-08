//
//  SpotifyPlugin+Testing.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 25/10/14.
//
//

#import "SpotifyPlugin+Testing.h"
#import <objc/runtime.h>

static char const * const authWebViewKey = "__authWebView";

void createAuthWebView(SpotifyPlugin *self)
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

    UIWebView *authWebView = [[UIWebView alloc] initWithFrame:frame];

    [authWebView setHidden:YES];

    [self.webView.superview addSubview:authWebView];
    [self.webView.superview bringSubviewToFront:authWebView];

    objc_setAssociatedObject([self class], authWebViewKey, authWebView, OBJC_ASSOCIATION_RETAIN);
}

UIWebView * getAuthWebView(SpotifyPlugin *self)
{
    return (UIWebView *)objc_getAssociatedObject([self class], authWebViewKey);
}

static IMP __original_pluginInitialize_Imp;
void _replacement_pluginInitialize(SpotifyPlugin *self, SEL _cmd)
{
    ((void(*)(id,SEL))__original_pluginInitialize_Imp)(self, _cmd);

    createAuthWebView(self);
}

static IMP __original_authenticate_Imp;
void _replacement_authenticate(SpotifyPlugin *self, SEL _cmd, CDVInvokedUrlCommand *command)
{
    NSString *clientId = [command.arguments objectAtIndex:0];
    NSArray *scopes = [command.arguments objectAtIndex:2];

    __weak SpotifyPlugin* weakSelf = self;

    __block id observer = nil;

    __weak UIWebView *authWebView = getAuthWebView(self);

    [self.commandDelegate runInBackground:^{

        observer = [[NSNotificationCenter defaultCenter]
                    addObserverForName:CDVPluginHandleOpenURLNotification
                    object:nil queue:nil usingBlock:^(NSNotification *note) {
                        NSURL *url = [note object];

                        [authWebView removeFromSuperview];

                        if([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL: self.callbackUrl]) {
                            [[NSNotificationCenter defaultCenter] removeObserver:observer];

                            [[SPTAuth defaultInstance]
                             handleAuthCallbackWithTriggeredAuthURL:url
                             callback:^(NSError *error, SPTSession *session) {
                                 CDVPluginResult *pluginResult;

                                 if (error != nil) {
                                     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                                 } else {
                                     NSNumber *expirationDate = [NSNumber numberWithInteger:session.expirationDate.timeIntervalSince1970];

                                     pluginResult = [CDVPluginResult
                                                     resultWithStatus:CDVCommandStatus_OK
                                                     messageAsDictionary: @{@"username": session.canonicalUsername,
                                                                            @"credential": session.accessToken,
                                                                            @"expirationDate": expirationDate}];
                                 }

                                 [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                             }];
                        }
                    }];

        NSURL *loginURL = [[SPTAuth defaultInstance]
                           loginURLForClientId:clientId
                           declaredRedirectURL:self.callbackUrl
                           scopes:scopes
                           withResponseType:@"token"];

        [authWebView setHidden:NO];
        [authWebView loadRequest:[NSURLRequest requestWithURL:loginURL]];
    }];
}

@implementation SpotifyPlugin (Testing)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        [class swizzlePluginInitialize];
        [class swizzleAuthenticate];
    });
}

+ (void)swizzlePluginInitialize
{
    Class class = [self class];

    Method m = class_getInstanceMethod(class, @selector(pluginInitialize));

    __original_pluginInitialize_Imp = method_setImplementation(m, (IMP)_replacement_pluginInitialize);
}

+ (void)swizzleAuthenticate
{
    Class class = [self class];

    Method m = class_getInstanceMethod(class, @selector(authenticate:));

    __original_authenticate_Imp = method_setImplementation(m, (IMP)_replacement_authenticate);
}
@end
