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
@property NSDictionary *session;
@end

@implementation SpotifyPluginTests
@synthesize plugin, commandDelegate, session;
- (void)setUp
{
    [super setUp];

    plugin = [SpotifyPlugin new];
    [plugin pluginInitialize];

    commandDelegate = [MockCommandDelegate new];

    plugin.commandDelegate = commandDelegate;

    session = @{@"username": @"justsomefakeuser", @"credential": @"a3mFAyzr0JlUCtipI39eDoq41xHY54WOUMoY3KmIJIrzyaywru94mEr8A7Tb8W_Yb75DZmpUKZF0plTxFN96UNZHowOVl98YQWyzqShOrQoKXzOcAgA6XQoLLX0HLAFjhGvDgIHRojSLhsL"};
}

- (void)tearDown
{
    [super tearDown];

    [OHHTTPStubs removeAllStubs];

    [SpotifyAudioPlayer clearTestValues];
}

- (void)testAuthenticateSuccess
{

    NSArray *args = @[@"spotify-ios-sdk-beta", @"http://foo.bar:1234/swap", @[@"streaming"]];

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
        responseArrived = YES;
    }];

    [plugin authenticate:[self createTestURLCommand:args]];

    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURL *callbackURL = [NSURL URLWithString:@"spotify-ios-sdk-beta://callback?code=NQpvC5h6MnausBFRG2hJjXifw2CZrXzQIh4S_SgBfpcVi6svpZKXpwYyoLRYhWN8g4L-zoZqYK0hfFNFgMqTpESGvodAuXGngZFiKc16y7oeMRJTZaY3-_1BgnSO9cLwzgMOztqUCRJV23LjtmEurM9_BEhSm-smLgqQHUrLtXldCz-JpDOkckA"];

        [[NSNotificationCenter defaultCenter]
         postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification
                                                        object:callbackURL]];
    });

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testAuthenticateAborted
{
    __block BOOL responseArrived = NO;

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"foo.bar"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        XCTAssert(NO, "Swap server should never be called");

        return [OHHTTPStubsResponse responseWithError: errorForTesting()];
    }];

    [plugin authenticate:[self createTestURLCommand:@[@"spotify-ios-sdk-beta", @"http://foo.bar:1234/swap", @[@"login"]]]];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURL *callbackURL = [NSURL URLWithString:@"spotify-ios-sdk-beta://callback?error=access_denied"];

        [[NSNotificationCenter defaultCenter]
         postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification
                                                        object:callbackURL]];
    });

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma AudioPlayer tests

- (void)testCreateAudioPlayerAndLoginCorrect
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(nil);
    } afterDelayInSeconds:0.1];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];

    [plugin createAudioPlayerAndLogin:[self createTestURLCommand:@[@"TestCompany", @"TestApp", session]]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testCreateAudioPlayerAndLoginFailure
{
    NSArray *args = @[@"TestCompany", @"TestApp", session];

    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(errorForTesting());
    } afterDelayInSeconds:0.3];

    [plugin createAudioPlayerAndLogin:[self createTestURLCommand:args]];

    waitForSecondsOrDone(8, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

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

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testAddAudioPlayerEventListenerUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(mockResultCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.3];

    [plugin addAudioPlayerEventListener:[self createTestURLCommand:@[@"12423424234dfadsf"]]];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURISuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(nil);
        } afterDelayInSeconds:0.1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin play:[self createTestURLCommand: @[playerID, @"spotify:track:0F0MA0ns8oXwGw66B2BSXm"]]];

    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURIFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(errorForTesting());
        } afterDelayInSeconds:0.1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin play:[self createTestURLCommand: @[playerID, @"spotify:bla:bla"]]];
    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURIUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(mockResultCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.3];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin play:[self createTestURLCommand: @[@"afsdfsdasdf324242", @"spotify:bla:bla"]]];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSeekToOffsetSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(nil);
        } afterDelayInSeconds:0.1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin seekToOffset:[self createTestURLCommand:@[playerID, @2.5]]];
    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSeekToOffsetFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(errorForTesting());
        } afterDelayInSeconds:0.1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin seekToOffset:[self createTestURLCommand:@[playerID, @2.5]]];
    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSeekToOffsetUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(mockResultCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.3];

    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(errorForTesting());
    } afterDelayInSeconds:0.1];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin seekToOffset:[self createTestURLCommand:@[@"sfasdfasdfsdfaasfasdfasdfasfda", @2.5]]];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

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

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetIsPlayingUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin getIsPlaying:[self createTestURLCommand:@[@"asdfasfasdfsdf"]]];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetIsPlayingSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(nil);
        } afterDelayInSeconds:0.1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin setIsPlaying:[self createTestURLCommand:@[playerID, @0]]];
    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetIsPlayingFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(errorForTesting());
        } afterDelayInSeconds:0.1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin setIsPlaying:[self createTestURLCommand:@[playerID, @0]]];
    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetIsPlayingUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        XCTFail(@"AudioPlayer should not exist");
    } afterDelayInSeconds:0.1];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin setIsPlaying:[self createTestURLCommand:@[@2, @0]]];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}


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

    waitForSecondsOrDone(2, &responseArrived);

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

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetVolumeSuccess
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(nil);
        } afterDelayInSeconds:0.1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
            responseArrived = YES;
        }];

        [plugin setVolume:[self createTestURLCommand:@[playerID, @0.5]]];
    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetVolumeFailed
{
    __block BOOL responseArrived = NO;

    [self loginAudioPlayer:^(NSString *playerID) {
        [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
            callback(errorForTesting());
        } afterDelayInSeconds:0.1];

        [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
            XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
            responseArrived = YES;
        }];

        [plugin setVolume:[self createTestURLCommand:@[playerID, @0.5]]];
    }];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetVolumeUndefinedPlayer
{
    __block BOOL responseArrived = NO;

    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        XCTFail(@"AudioPlayer should not exist");
    } afterDelayInSeconds:0.1];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];

    [plugin setVolume:[self createTestURLCommand:@[@"asdfasfsdf", @0.5]]];

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}


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

    waitForSecondsOrDone(2, &responseArrived);

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

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}


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

    waitForSecondsOrDone(2, &responseArrived);

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

    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

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

    waitForSecondsOrDone(2, &responseArrived);

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

    waitForSecondsOrDone(2, &responseArrived);

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

    waitForSecondsOrDone(2, &responseArrived);

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

    NSArray *args = @[@"TestCompany", @"TestApp", session];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
        callback((NSString *)[result message]);
    }];

    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(nil);
    } afterDelayInSeconds:0.05];

    [plugin createAudioPlayerAndLogin:[self createTestURLCommand:args]];

    waitForSecondsOrDone(30, &responseArrived);
}


@end
