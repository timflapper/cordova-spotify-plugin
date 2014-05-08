//
//  SpotifyPluginTests.m
//  SpotifyPluginTests
//
//  Created by Tim Flapper on 05/05/14.
//
//

#import <XCTest/XCTest.h>
#import "testShared.h"
#import "SpotifyPlugin.h"
#import "MockCommandDelegate.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <Spotify/Spotify.h>

@interface SpotifyPluginTests : XCTestCase
@end

@implementation SpotifyPluginTests
- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAuthenticateSuccess
{
    
    MockCommandDelegate *commandDelegate = [[MockCommandDelegate alloc] init];
    SpotifyPlugin *plugin = [[SpotifyPlugin alloc] init];
    NSArray *args = @[@"spotify-ios-sdk-beta", @"http://foo.bar:1234/swap", @[@"login"]];
    NSURL *callbackURL = [NSURL URLWithString:@"spotify-ios-sdk-beta://callback?code=NQpvC5h6MnausBFRG2hJjXifw2CZrXzQIh4S_SgBfpcVi6svpZKXpwYyoLRYhWN8g4L-zoZqYK0hfFNFgMqTpESGvodAuXGngZFiKc16y7oeMRJTZaY3-_1BgnSO9cLwzgMOztqUCRJV23LjtmEurM9_BEhSm-smLgqQHUrLtXldCz-JpDOkckA"];

    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"foo.bar"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"session.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    plugin.commandDelegate = commandDelegate;
    
    [plugin pluginInitialize];
    
    [plugin authenticate:[[CDVInvokedUrlCommand alloc]initWithArguments:args callbackId:@"test" className:nil methodName:nil]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:callbackURL]];
    });
                   
    NSTimeInterval timeout = 1;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
}

- (void)testAuthenticateAborted
{
    MockCommandDelegate *commandDelegate = [[MockCommandDelegate alloc] init];
    SpotifyPlugin *plugin = [[SpotifyPlugin alloc] init];
    NSArray *args = @[@"spotify-ios-sdk-beta", @"http://foo.bar:1234/swap", @[@"login"]];
    NSURL *callbackURL = [NSURL URLWithString:@"spotify-ios-sdk-beta://callback?error=access_denied"];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"foo.bar"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssert(NO, "Swap server should never be called");
        
        return [OHHTTPStubsResponse responseWithError: [[NSError alloc] init]];
    }];
    
    plugin.commandDelegate = commandDelegate;
    
    [plugin pluginInitialize];
    
    [plugin authenticate:[[CDVInvokedUrlCommand alloc]initWithArguments:args callbackId:@"test" className:nil methodName:nil]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:callbackURL]];
    });
    
    NSTimeInterval timeout = 1;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearch
{
    MockCommandDelegate *commandDelegate = [[MockCommandDelegate alloc] init];
    SpotifyPlugin *plugin = [[SpotifyPlugin alloc] init];
    NSArray *args = @[@"Some artist", @"artist", @0, @{@"username": @"justsomefakeuser", @"credential": @"a3mFAyzr0JlUCtipI39eDoq41xHY54WOUMoY3KmIJIrzyaywru94mEr8A7Tb8W_Yb75DZmpUKZF0plTxFN96UNZHowOVl98YQWyzqShOrQoKXzOcAgA6XQoLLX0HLAFjhGvDgIHRojSLhsL"}];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-tracks.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    plugin.commandDelegate = commandDelegate;
    
    [plugin pluginInitialize];
    
    [plugin search:[[CDVInvokedUrlCommand alloc]initWithArguments:args callbackId:@"test" className:nil methodName:nil]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    NSTimeInterval timeout = 1;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testGetPlaylistsForUser
{
  
    MockCommandDelegate *commandDelegate = [[MockCommandDelegate alloc] init];
    SpotifyPlugin *plugin = [[SpotifyPlugin alloc] init];
    NSArray *args = @[@"justafakeuser", @{@"username": @"justafakeuser", @"credential": @"a3mFAyzr0JlUCtipI39eDoq41xHY54WOUMoY3KmIJIrzyaywru94mEr8A7Tb8W_Yb75DZmpUKZF0plTxFN96UNZHowOVl98YQWyzqShOrQoKXzOcAgA6XQoLLX0HLAFjhGvDgIHRojSLhsL"}];

    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"ws.spotify.com"] || [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSDictionary *headers = @{@"Content-Type": @"application/json; charset=\"utf-8\""};

        OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"playlists.json")
                                                                    statusCode:200 headers:headers];
        return response;
    }];
    
    plugin.commandDelegate = commandDelegate;
    
    [plugin pluginInitialize];
    
    [plugin getPlaylistsForUser:[[CDVInvokedUrlCommand alloc]initWithArguments:args callbackId:@"test" className:nil methodName:nil]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    NSTimeInterval timeout = 4;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}


@end
