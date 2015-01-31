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
#import "SpotifyAudioPlayer+Mock.h"

@interface SpotifyPluginTests : XCTestCase
@property SpotifyPlugin *plugin;
@property MockCommandDelegate *commandDelegate;
@property NSDictionary *codeSession;
@property NSDictionary *tokenSession;
@property NSDictionary *expiredSession;
@end

@implementation SpotifyPluginTests
@synthesize plugin, commandDelegate, codeSession, tokenSession, expiredSession;

+ (void)setUp
{
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:2];
    while ([timeoutDate timeIntervalSinceNow]>0)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.005, YES);
}

- (void)setUp
{
    [super setUp];

    plugin = [SpotifyPlugin new];
    [plugin pluginInitialize];

    commandDelegate = [MockCommandDelegate new];

    plugin.commandDelegate = commandDelegate;

    codeSession = @{@"canonicalUsername": @"awesomeuser",
                    @"accessToken": @"Ab4wVEt-33dSMLfD_Nd_GLjBGX5TQc0VrQRIXW2WVP69Z5I_bIw4YIumYsOPXNA-1-6HLdS_XdfX9FXrtezc-ltUAT6cj69scFrqxJPWV12mK-224W0ekpsi-WQe_T1OYSZbyv00abgBopOzx9AOH5sd",
                    @"encryptedRefreshToken": @"XXXX_qPeacCRHWujLagqGV0khtZ_jaF_Ek8VI80g7HpAzjmbQZHz1j5_0YbcpSvi31mE7AMipJcYGQ9_p_65elCf_OS6vIhhNJRCmlOPc3RJVjuNdadQTR9sucB413X4Xx",
                    @"expirationDate": dateToString([NSDate dateWithTimeIntervalSinceNow:3600]),
                    @"tokenType": @"Bearer"};

    tokenSession = @{@"canonicalUsername": @"awesomeuser",
                     @"accessToken": @"NQpvC5h6MnausBFRG2hJjXifw2CZrXzQIh4S_SgBfpcVi6svpZKXpwYyoLRYhWN8g4L-zoZqYK0hfFNFgMqTpESGvodAuXGngZFiKc16y7oeMRJTZaY3",
                     @"encryptedRefreshToken": [NSNull null],
                     @"expirationDate": dateToString([NSDate dateWithTimeIntervalSinceNow:3600]),
                     @"tokenType": @"Bearer"};

    expiredSession = @{@"canonicalUsername": @"awesomeuser",
                       @"accessToken": @"Ab4wVEt-33dSMLfD_Nd_GLjBGX5TQc0VrQRIXW2WVP69Z5I_bIw4YIumYsOPXNA-1-6HLdS_XdfX9FXrtezc-ltUAT6cj69scFrqxJPWV12mK-224W0ekpsi-WQe_T1OYSZbyv00abgBopOzx9AOH5sd",
                       @"encryptedRefreshToken": @"XXXX_qPeacCRHWujLagqGV0khtZ_jaF_Ek8VI80g7HpAzjmbQZHz1j5_0YbcpSvi31mE7AMipJcYGQ9_p_65elCf_OS6vIhhNJRCmlOPc3RJVjuNdadQTR9sucB413X4Xx",
                       @"expirationDate": dateToString([NSDate dateWithTimeIntervalSinceNow:-1800]),
                       @"tokenType": @"Bearer"};
}

- (void)tearDown
{
    [super tearDown];

    [OHHTTPStubs removeAllStubs];

    [SpotifyAudioPlayer clearTestValues];
}

#pragma mark authenticate

- (void)testAuthenticateSuccessWithCode
{
    NSArray *args = @[@"test-url-scheme", @"someRandomClientId", @"code", @"http://foo.bar:1234/swap", @[@"streaming"]];

    __block BOOL responseArrived = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"foo.bar"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"session.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];


    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"profile.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        XCTAssertEqualObjects(result.message, codeSession);
        responseArrived = YES;
    }];

    [plugin authenticate:[self createTestURLCommand:args]];

    double delayInSeconds = 0.005;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURL *callbackURL = [NSURL URLWithString:@"test-url-scheme://callback?code=NQpvC5h6MnausBFRG2hJjXifw2CZrXzQIh4S_SgBfpcVi6svpZKXpwYyoLRYhWN8g4L-zoZqYK0hfFNFgMqTpESGvodAuXGngZFiKc16y7oeMRJTZaY3-_1BgnSO9cLwzgMOztqUCRJV23LjtmEurM9_BEhSm-smLgqQHUrLtXldCz-JpDOkckA"];

        [[NSNotificationCenter defaultCenter]
         postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification
                                                        object:callbackURL]];
    });

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testAuthenticateSuccessWithToken
{
    NSArray *args = @[@"test-url-scheme", @"someRandomClientId", @"token", @[@"streaming"]];

    __block BOOL responseArrived = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"profile.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        XCTAssertEqualObjects(result.message, tokenSession);
        responseArrived = YES;
    }];

    [plugin authenticate:[self createTestURLCommand:args]];

    double delayInSeconds = 0.005;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURL *callbackURL = [NSURL URLWithString:@"test-url-scheme://callback?access_token=NQpvC5h6MnausBFRG2hJjXifw2CZrXzQIh4S_SgBfpcVi6svpZKXpwYyoLRYhWN8g4L-zoZqYK0hfFNFgMqTpESGvodAuXGngZFiKc16y7oeMRJTZaY3&token_type=Bearer&expires_in=3600"];

        [[NSNotificationCenter defaultCenter]
         postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification
                                                        object:callbackURL]];
    });

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testAuthenticateInvalidResponseType
{
    __block BOOL responseArrived = NO;

    [plugin authenticate:[self createTestURLCommand:@[@"test-url-scheme", @"aClientId", @"bla", @[@"streaming"]]]];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}


- (void)testAuthenticateFailed
{
    __block BOOL responseArrived = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"foo.bar"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssert(NO, "Swap server should never be called");

        return [OHHTTPStubsResponse responseWithError: errorForTesting()];
    }];

    [plugin authenticate:[self createTestURLCommand:@[@"test-url-scheme", @"clientId", @"code", @"http://foo.bar:1234/swap", @[@"streaming"]]]];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    double delayInSeconds = 0.005;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURL *callbackURL = [NSURL URLWithString:@"test-url-scheme://callback?error=access_denied"];

        [[NSNotificationCenter defaultCenter]
         postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification
                                                        object:callbackURL]];
    });

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark renewSession

- (void)testRenewSessionSuccess
{
    NSArray *args = @[codeSession, @"http://foo.bar:1234/refresh"];

    __block BOOL responseArrived = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        if (![request.URL.host isEqualToString:@"foo.bar"]) {
            XCTFail(@"It should not call any other URL");
            return NO;
        }

        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"refresh.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        XCTAssertEqualObjects(result.message, codeSession);

        responseArrived = YES;
    }];

    [plugin renewSession:[self createTestURLCommand:args]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testRenewSessionFailed
{
    NSArray *args = @[codeSession, @"http://foo.bar:1234/refresh"];

    __block BOOL responseArrived = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        if (![request.URL.host isEqualToString:@"foo.bar"]) {
            XCTFail(@"It should not call any other URL");
            return NO;
        }

        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"refresh_failed.json")
                                          statusCode:400 headers:@{@"Content-Type":@"application/json"}];
    }];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");

        responseArrived = YES;
    }];

    [plugin renewSession:[self createTestURLCommand:args]];

    waitForSecondsOrDone(8, &responseArrived);
}

#pragma mark isSessionValid

- (void)testIsSessionValidYES
{
    NSArray *args = @[codeSession];

    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");

        XCTAssertEqualObjects(result.message, [NSNumber numberWithBool:YES]);

        responseArrived = YES;
    }];

    [plugin isSessionValid:[self createTestURLCommand:args]];

    waitForSecondsOrDone(8, &responseArrived);
}

- (void)testIsSessionValidNO
{
    NSArray *args = @[expiredSession];

    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");

        XCTAssertEqualObjects(result.message, [NSNumber numberWithBool:NO]);

        responseArrived = YES;
    }];

    [plugin isSessionValid:[self createTestURLCommand:args]];

    waitForSecondsOrDone(8, &responseArrived);
}

#pragma mark createAudioPlayerAndLogin

- (void)testCreateAudioPlayerAndLoginCorrect
{
    __block BOOL responseArrived = NO;

    [self setPlayerActionCallback:nil];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];

    [plugin createAudioPlayerAndLogin:[self createTestURLCommand:@[@"RandomClientId", codeSession]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testCreateAudioPlayerAndLoginFailure
{
    NSArray *args = @[@"RandomClientId", codeSession];

    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [self setPlayerActionCallback:errorForTesting()];

    [plugin createAudioPlayerAndLogin:[self createTestURLCommand:args]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark addAudioPlayerEventListener

- (void)testAddAudioPlayerEventListenerAndEvent
{
    __block int responses = 0;
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");

            if (++responses == 2)
                responseArrived = YES;
        }];

        [SpotifyAudioPlayer setNextMethodReturn:@{@"SPAudioStreamingMetadataTrackName": @"Emerge",
                                                  @"SPAudioStreamingMetadataTrackURI": @"spotify:track:3vyKSb9sAdXl0kQ1KnS9fY",
                                                  @"SPAudioStreamingMetadataArtistName": @"Fischerspooner",
                                                  @"SPAudioStreamingMetadataArtistURI": @"spotify:artist:5R7K1GezC0jy24v1R2n4x3",
                                                  @"SPAudioStreamingMetadataAlbumName": @"#1",
                                                  @"SPAudioStreamingMetadataAlbumURI": @"spotify:album:3OCiJ6mbOzJdzTrk8R9hy2",
                                                  @"SPAudioStreamingMetadataTrackDuration": @"288.306"}];

        [plugin addAudioPlayerEventListener:[self createTestURLCommand:@[playerID]]];

        [plugin play:[self createTestURLCommand: @[playerID, @"spotify:track:0F0MA0ns8oXwGw66B2BSXm"]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testAddAudioPlayerEventListenerUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(mockResultCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.005];

    [plugin addAudioPlayerEventListener:[self createTestURLCommand:@[@"12423424234dfadsf"]]];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark play

- (void)testPlaySingleUriSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(nil);
        } afterDelayInSeconds:0.005];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin play:[self createTestURLCommand: @[playerID, @"spotify:track:0F0MA0ns8oXwGw66B2BSXm"]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURISuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin play:[self createTestURLCommand: @[playerID, @"spotify:bla:bla"]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(mockResultCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.005];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin play:[self createTestURLCommand: @[@"afsdfsdasdf324242", @"spotify:bla:bla"]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURIWithIndexSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin play:[self createTestURLCommand: @[playerID, @"spotify:album:0F0MA0ns8oXwGw66B2BSXm", @3]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURIsSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        NSArray *tracks = @[@"spotify:track:0F0MA0ns8oXwGw66B2BSXm", @"spotify:track:0F0MA0ns8oXwGw66d26SXv"];
        NSArray *args = @[playerID, tracks];

        [plugin play:[self createTestURLCommand: args]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURIsFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        NSArray *tracks = @[@"spotify:track:0F0MA0ns8oXwGw66B2BSXm", @"spotify:track:0F0MA0ns8oXwGw66d26SXv"];
        NSArray *args = @[playerID, tracks];

        [plugin play:[self createTestURLCommand: args]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark setURIs

- (void)testSetURIsSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        NSArray *tracks = @[@"spotify:track:0F0MA0ns8oXwGw66B2BSXm", @"spotify:track:0F0MA0ns8oXwGw66d26SXv"];
        NSArray *args = @[playerID, tracks];

        [plugin setURIs:[self createTestURLCommand: args]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetURIsFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        NSArray *tracks = @[@"spotify:track:0F0MA0ns8oXwGw66B2BSXm", @"spotify:track:0F0MA0ns8oXwGw66d26SXv"];
        NSArray *args = @[playerID, tracks];

        [plugin setURIs:[self createTestURLCommand: args]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark playURIsFromIndex

- (void)testPlayURIsFromIndexSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin playURIsFromIndex:[self createTestURLCommand: @[playerID, @2]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURIsFromIndexFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin playURIsFromIndex:[self createTestURLCommand: @[playerID, @2]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark queue

- (void)testQueueURISuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        NSArray *args = @[playerID, @"spotify:track:0F0MA0ns8oXwGw66B2BSXm", [NSNumber numberWithBool:YES]];

        [plugin queue:[self createTestURLCommand: args]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testQueueURIsSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        NSArray *tracks = @[@"spotify:track:0F0MA0ns8oXwGw66B2BSXm", @"spotify:track:0F0MA0ns8oXwGw66d26SXv"];
        NSArray *args = @[playerID, tracks, [NSNumber numberWithBool:YES]];

        [plugin queue:[self createTestURLCommand: args]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testQueueInvalidData
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            XCTAssertEqualObjects(result.message, @"Unknown data");
            responseArrived = YES;
        }];

        NSArray *args = @[playerID, @3, [NSNumber numberWithBool:YES]];

        [plugin queue:[self createTestURLCommand: args]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testQueueFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        NSArray *args = @[playerID, @"spotify:track:0F0MA0ns8oXwGw66d26SXv", [NSNumber numberWithBool:NO]];

        [plugin queue:[self createTestURLCommand: args]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark queuePlay

- (void)testQueuePlaySuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin queuePlay:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testQueuePlayFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be FAILED");
            responseArrived = YES;
        }];

        [plugin queuePlay:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark queueClear

- (void)testQueueClearSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin queueClear:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testQueueClearFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be FAILED");
            responseArrived = YES;
        }];

        [plugin queueClear:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

#pragma mark stop


- (void)testStoppedSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin stop:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testStopFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be FAILED");
            responseArrived = YES;
        }];

        [plugin stop:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark skipNext

- (void)testSkipNextSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin skipNext:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testSkipNextFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be FAILED");
            responseArrived = YES;
        }];

        [plugin skipNext:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark skipPrevious

- (void)testSkipPreviousSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin skipNext:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testSkipPreviousFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be FAILED");
            responseArrived = YES;
        }];

        [plugin skipNext:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark seekToOffset

- (void)testSeekToOffsetSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin seekToOffset:[self createTestURLCommand:@[playerID, @2.5]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSeekToOffsetFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin seekToOffset:[self createTestURLCommand:@[playerID, @2.5]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSeekToOffsetUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(mockResultCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.005];

    [self setPlayerActionCallback:errorForTesting()];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin seekToOffset:[self createTestURLCommand:@[@"sfasdfasdfsdfaasfasdfasdfasfda", @2.5]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getIsPlaying

- (void)testGetIsPlaying
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@0];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin getIsPlaying:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark setIsPlaying

- (void)testSetIsPlayingSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin setIsPlaying:[self createTestURLCommand:@[playerID, @0]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetIsPlayingFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin setIsPlaying:[self createTestURLCommand:@[playerID, @0]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getTargetBitrate

- (void)testGetTargetBitrate
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@2];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            XCTAssertEqualObjects(result.message, @2);
            responseArrived = YES;
        }];

        [plugin getTargetBitrate:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark setTargetBitrate

- (void)testSetTargetBitrateSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin setTargetBitrate:[self createTestURLCommand:@[playerID, @1]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetTargetBitrateFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin setTargetBitrate:[self createTestURLCommand:@[playerID, @2]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getDiskCacheSizeLimit

- (void)testGetDiskCacheSizeLimit
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@2000];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            XCTAssertEqualObjects(result.message, @2000);
            responseArrived = YES;
        }];

        [plugin getDiskCacheSizeLimit:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark setDiskCacheSizeLimit

- (void)testSetDiskCacheSizeLimit
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin setDiskCacheSizeLimit:[self createTestURLCommand:@[playerID, @4000]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getVolume

- (void)testGetVolume
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@0.5];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin getVolume:[self createTestURLCommand: @[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetVolumeUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin getVolume:[self createTestURLCommand:@[@"asdfsdfsdf"]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark setVolume

- (void)testSetVolumeSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:nil];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin setVolume:[self createTestURLCommand:@[playerID, @0.5]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetVolumeFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:errorForTesting()];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin setVolume:[self createTestURLCommand:@[playerID, @0.5]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetVolumeUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        XCTFail(@"AudioPlayer should not exist");
    } afterDelayInSeconds:0.005];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin setVolume:[self createTestURLCommand:@[@"asdfasfsdf", @0.5]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getRepeat

- (void)testGetRepeat
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@0];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin getRepeat:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark setRepeat

- (void)testSetRepeat
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin setRepeat:[self createTestURLCommand:@[playerID, @0]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getShuffle

- (void)testGetShuffle
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@0];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin getShuffle:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark setShuffle

- (void)testSetShuffle
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin setShuffle:[self createTestURLCommand:@[playerID, @0]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getLoggedIn

- (void)testGetLoggedIn
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin getLoggedIn:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetLoggedInUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin getLoggedIn:[self createTestURLCommand:@[@2]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getQueueSize

- (void)testGetQueueSize
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin getQueueSize:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getTrackListSize

- (void)testGetTrackListSize
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin getTrackListSize:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}
#pragma mark getTrackMetadata

- (void)testGetTrackMetadata
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@{@"SPAudioStreamingMetadataTrackName": @"Emerge",
                                                  @"SPAudioStreamingMetadataTrackURI": @"spotify:track:3vyKSb9sAdXl0kQ1KnS9fY",
                                                  @"SPAudioStreamingMetadataArtistName": @"Fischerspooner",
                                                  @"SPAudioStreamingMetadataArtistURI": @"spotify:artist:5R7K1GezC0jy24v1R2n4x3",
                                                  @"SPAudioStreamingMetadataAlbumName": @"#1",
                                                  @"SPAudioStreamingMetadataAlbumURI": @"spotify:album:3OCiJ6mbOzJdzTrk8R9hy2",
                                                  @"SPAudioStreamingMetadataTrackDuration": @"288.306"}];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            NSDictionary *expected = @{@"name": @"Emerge",
                                       @"uri": @"spotify:track:3vyKSb9sAdXl0kQ1KnS9fY",
                                       @"artist": @{@"name": @"Fischerspooner",
                                                    @"uri": @"spotify:artist:5R7K1GezC0jy24v1R2n4x3"},
                                       @"album": @{@"name": @"#1",
                                                   @"uri":@"spotify:album:3OCiJ6mbOzJdzTrk8R9hy2"},
                                       @"duration": @"288.306"};

            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            XCTAssertEqualObjects(result.message, expected);

            responseArrived = YES;
        }];

        [plugin getTrackMetadata:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetTrackMetadataInTrackListAbsolute
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:@{@"SPAudioStreamingMetadataTrackName": @"Emerge",
                                        @"SPAudioStreamingMetadataTrackURI": @"spotify:track:3vyKSb9sAdXl0kQ1KnS9fY",
                                        @"SPAudioStreamingMetadataArtistName": @"Fischerspooner",
                                        @"SPAudioStreamingMetadataArtistURI": @"spotify:artist:5R7K1GezC0jy24v1R2n4x3",
                                        @"SPAudioStreamingMetadataAlbumName": @"#1",
                                        @"SPAudioStreamingMetadataAlbumURI": @"spotify:album:3OCiJ6mbOzJdzTrk8R9hy2",
                                        @"SPAudioStreamingMetadataTrackDuration": @"288.306"}];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            NSDictionary *expected = @{@"name": @"Emerge",
                                       @"uri": @"spotify:track:3vyKSb9sAdXl0kQ1KnS9fY",
                                       @"artist": @{@"name": @"Fischerspooner",
                                                    @"uri": @"spotify:artist:5R7K1GezC0jy24v1R2n4x3"},
                                       @"album": @{@"name": @"#1",
                                                   @"uri":@"spotify:album:3OCiJ6mbOzJdzTrk8R9hy2"},
                                       @"duration": @"288.306"};

            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            XCTAssertEqualObjects(result.message, expected);

            responseArrived = YES;
        }];

        [plugin getTrackMetadata:[self createTestURLCommand:@[playerID, @4]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetTrackMetadataInTrackListRelative
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [self setPlayerActionCallback:@{@"SPAudioStreamingMetadataTrackName": @"Emerge",
                                        @"SPAudioStreamingMetadataTrackURI": @"spotify:track:3vyKSb9sAdXl0kQ1KnS9fY",
                                        @"SPAudioStreamingMetadataArtistName": @"Fischerspooner",
                                        @"SPAudioStreamingMetadataArtistURI": @"spotify:artist:5R7K1GezC0jy24v1R2n4x3",
                                        @"SPAudioStreamingMetadataAlbumName": @"#1",
                                        @"SPAudioStreamingMetadataAlbumURI": @"spotify:album:3OCiJ6mbOzJdzTrk8R9hy2",
                                        @"SPAudioStreamingMetadataTrackDuration": @"288.306"}];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            NSDictionary *expected = @{@"name": @"Emerge",
                                       @"uri": @"spotify:track:3vyKSb9sAdXl0kQ1KnS9fY",
                                       @"artist": @{@"name": @"Fischerspooner",
                                                    @"uri": @"spotify:artist:5R7K1GezC0jy24v1R2n4x3"},
                                       @"album": @{@"name": @"#1",
                                                   @"uri":@"spotify:album:3OCiJ6mbOzJdzTrk8R9hy2"},
                                       @"duration": @"288.306"};

            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            XCTAssertEqualObjects(result.message, expected);

            responseArrived = YES;
        }];

        [plugin getTrackMetadata:[self createTestURLCommand:@[playerID, @4, [NSNumber numberWithBool:YES]]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetTrackMetadataUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");

        responseArrived = YES;
    }];

    [plugin getTrackMetadata:[self createTestURLCommand:@[@2]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark getCurrentPlaybackPosition

- (void)testGetCurrentPlaybackPosition
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@45.12];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            XCTAssertEqual(((NSNumber *)result.message).doubleValue, 45.12);
            responseArrived = YES;
        }];

        [plugin getCurrentPlaybackPosition:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetCurrentPlaybackPositionNotPlaying
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextMethodReturn:@0.0];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            XCTAssertEqual(((NSNumber *)result.message).doubleValue, 0.0);
            responseArrived = YES;
        }];

        [plugin getCurrentPlaybackPosition:[self createTestURLCommand:@[playerID]]];
    }];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetCurrentPlaybackPositionUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin getCurrentPlaybackPosition:[self createTestURLCommand:@[@2]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma mark Convenience methods

- (CDVInvokedUrlCommand *)createTestURLCommand:(NSArray *)args
{
    return [[CDVInvokedUrlCommand alloc]initWithArguments:args callbackId:@"test" className:nil methodName:nil];
}

- (void)loginAudioPlayer:(void (^) (NSString * playerID))callback
{
    __block BOOL responseArrived = NO;

    NSArray *args = @[@"RandomClientId", codeSession];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
        callback((NSString *)[result message]);
    }];

    [self setPlayerActionCallback:nil];

    [plugin createAudioPlayerAndLogin:[self createTestURLCommand:args]];

    waitForSecondsOrDone(30, &responseArrived);
}

- (void)setPlayerActionCallback:(id)result
{
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(result);
    } afterDelayInSeconds:0.005];
}

@end
