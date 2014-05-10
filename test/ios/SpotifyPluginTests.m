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
#import "SpotifyAudioPlayer+Testing.h"

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
    
    plugin = [[SpotifyPlugin alloc] init];
    [plugin pluginInitialize];
    
    commandDelegate = [[MockCommandDelegate alloc] init];
    
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
    
    NSArray *args = @[@"spotify-ios-sdk-beta", @"http://foo.bar:1234/swap", @[@"login"]];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"foo.bar"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"session.json")
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
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
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
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSearchArtists
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-artists.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin search:[self createTestURLCommand:@[@"Some artist", @"artist", @0, session]]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSearchAlbums
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-albums.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin search:[self createTestURLCommand:@[@"Some album", @"album", @0, session]]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSearchTracks
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-tracks.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin search:[self createTestURLCommand:@[@"Some track", @"track", @0, session]]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSearchError
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-error.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin search:[self createTestURLCommand:@[@"Some track", @"track", @0, session]]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetPlaylistsForUserSuccess
{
    
    NSArray *args = @[@"justafakeuser", session];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"ws.spotify.com"] || [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSDictionary *headers = @{@"Content-Type": @"application/json; charset=\"utf-8\""};
        
        OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"playlists.json")
                                                                   statusCode:200 headers:headers];
        return response;
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin getPlaylistsForUser:[self createTestURLCommand:args]];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetPlaylistsForUserFailed
{
    
    NSArray *args = @[@"anotherfakeuser", session];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"ws.spotify.com"] || [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSDictionary *headers = @{@"Content-Type": @"application/json; charset=\"utf-8\""};
        
        OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithData: [@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                                   statusCode:403 headers:headers];
        return response;
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin getPlaylistsForUser:[self createTestURLCommand:args]];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testRequestItemAtURITrack
{
    NSArray *args = @[@"spotify:track:0F0MA0ns8oXwGw66B2BSXm", session];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"track.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin requestItemAtURI:[self createTestURLCommand:args]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testRequestItemAtURIAlbum
{
    NSArray *args = @[@"spotify:album:0UrDDTOre9XuD3xJHTFEJg", session];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"album.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin requestItemAtURI:[self createTestURLCommand:args]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testRequestItemAtURIArtist
{
    NSArray *args = @[@"spotify:artist:0k17h0D3J5VfsdmQ1iZtE9", session];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"artist.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin requestItemAtURI:[self createTestURLCommand:args]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testRequestItemAtURINotFound
{
    NSArray *args = @[@"spotify:artist:0k17h0D3J5VfsdmQ1iZt", session];
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"not-found.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin requestItemAtURI:[self createTestURLCommand:args]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

#pragma AudioPlayer tests

- (void)testCreateAudioPlayerAndLoginCorrect
{
    __block BOOL responseArrived = NO;
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(nil);
    } afterDelayInSeconds:0.3];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin createAudioPlayerAndLogin:[self createTestURLCommand:@[@"TestCompany", @"TestApp", session]]];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
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
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testAddAudioPlayerEventListenerAndEvent
{
    __block int responses = 0;
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
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
    
    [SpotifyAudioPlayer setNextCallback:^(SpotifyEventCallback callback) {
        /* We're using setNextMethodReturn for the playbackDelegate */
        callback(nil);
    } afterDelayInSeconds:0.3];
    
    [plugin addAudioPlayerEventListener:[self createTestURLCommand:@[@1]]];
    
    [plugin playURI:[self createTestURLCommand: @[@1, @"spotify:track:0F0MA0ns8oXwGw66B2BSXm"]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testAddAudioPlayerEventListenerUndefinedPlayer
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SpotifyEventCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.3];
    
    [plugin addAudioPlayerEventListener:[self createTestURLCommand:@[@2]]];
    
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
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(nil);
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin playURI:[self createTestURLCommand: @[@1, @"spotify:track:0F0MA0ns8oXwGw66B2BSXm"]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURIFailed
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(errorForTesting());
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin playURI:[self createTestURLCommand: @[@1, @"spotify:bla:bla"]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testPlayURIUndefinedPlayer
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SpotifyEventCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.3];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin playURI:[self createTestURLCommand: @[@2, @"spotify:bla:bla"]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSeekToOffsetSuccess
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(nil);
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin seekToOffset:[self createTestURLCommand:@[@1, @2.5]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSeekToOffsetFailed
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(errorForTesting());
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin seekToOffset:[self createTestURLCommand:@[@1, @2.5]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSeekToOffsetUndefinedPlayer
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SpotifyEventCallback callback) {
        XCTFail(@"Should never be called");
    } afterDelayInSeconds:0.3];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(errorForTesting());
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin seekToOffset:[self createTestURLCommand:@[@2, @2.5]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetIsPlaying
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextMethodReturn:@0];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin getIsPlaying:[self createTestURLCommand:@[@1]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetIsPlayingUndefinedPlayer
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin getIsPlaying:[self createTestURLCommand:@[@2]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetIsPlayingSuccess
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(nil);
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin setIsPlaying:[self createTestURLCommand:@[@1, @0]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetIsPlayingFailed
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(errorForTesting());
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin setIsPlaying:[self createTestURLCommand:@[@1, @0]]];
    
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
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextMethodReturn:@0.5];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin getVolume:[self createTestURLCommand:@[@1]]];
    
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
    
    [plugin getVolume:[self createTestURLCommand:@[@2]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetVolumeSuccess
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(nil);
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin setVolume:[self createTestURLCommand:@[@1, @0.5]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetVolumeFailed
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(errorForTesting());
    } afterDelayInSeconds:0.1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin setVolume:[self createTestURLCommand:@[@1, @0.5]]];
    
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
    
    [plugin setVolume:[self createTestURLCommand:@[@2, @0.5]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}


- (void)testGetLoggedIn
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextMethodReturn:@1];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin getLoggedIn:[self createTestURLCommand:@[@1]]];
    
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


- (void)testGetCurrentTrack
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
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
    
    [plugin getCurrentTrack:[self createTestURLCommand:@[@1]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetCurrentTrackNotPlaying
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextMethodReturn:nil];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        XCTAssertEqualObjects(result.message, nil);
        
        responseArrived = YES;
    }];
    
    [plugin getCurrentTrack:[self createTestURLCommand:@[@1]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetCurrentTrackUndefinedPlayer
{
    __block BOOL responseArrived = NO;
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        
        responseArrived = YES;
    }];
    
    [plugin getCurrentTrack:[self createTestURLCommand:@[@2]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetCurrentPlaybackPosition
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextMethodReturn:@45.12];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        XCTAssertEqual(((NSNumber *)result.message).doubleValue, 45.12);
        responseArrived = YES;
    }];
    
    [plugin getCurrentPlaybackPosition:[self createTestURLCommand:@[@1]]];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testGetCurrentPlaybackPositionNotPlaying
{
    __block BOOL responseArrived = NO;
    
    [self loginAudioPlayer];
    
    [SpotifyAudioPlayer setNextMethodReturn:@0.0];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        XCTAssertEqual(((NSNumber *)result.message).doubleValue, 0.0);
        responseArrived = YES;
    }];
    
    [plugin getCurrentPlaybackPosition:[self createTestURLCommand:@[@1]]];
    
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

#pragma Single Playlist tests

- (void)testCreatePlaylistSuccess
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"new-playlist.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin createPlaylist: [self createTestURLCommand: @[@"My New Playlist", session]]];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testCreatePlaylistFailed
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"playlist-error.json")
                                          statusCode:400 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin createPlaylist: [self createTestURLCommand: @[@"", session]]];
    
    waitForSecondsOrDone(4, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}


- (void)testSetPlaylistNameSuccess
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"single-playlist.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];

    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin setPlaylistName: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", @"My New Playlist Name", session]]];
    
    waitForSecondsOrDone(4, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetPlaylistNameFailed
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"playlist-error.json")
                                          statusCode:400 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin setPlaylistName: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", @"", session]]];
    
    waitForSecondsOrDone(4, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSetPlaylistDescriptionSuccess
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"single-playlist.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin setPlaylistDescription: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", @"My New Playlist Description", session]]];
    
    waitForSecondsOrDone(4, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testSetPlaylistDescriptionFailed
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"playlist-error.json")
                                          statusCode:400 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin setPlaylistDescription: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", @"", session]]];
    
    waitForSecondsOrDone(4, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
    
}

- (void)testSetPlaylistCollaborativeSuccess
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"single-playlist.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin setPlaylistCollaborative: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", @0, session]]];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
    
}

- (void)testSetPlaylistCollaborativeFailed
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"playlist-error.json")
                                          statusCode:400 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    [plugin setPlaylistCollaborative: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", @0, session]]];
    
    waitForSecondsOrDone(10, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testAddTracksToPlaylistSuccess
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"single-playlist.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [plugin addTracksToPlaylist: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", @[@"spotify:track:0F0MA0ns8oXwGw66B2BSXm"], session]]];
    
    waitForSecondsOrDone(10, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testAddTracksToPlaylistFailed
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"playlist-error.json")
                                          statusCode:400 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [plugin addTracksToPlaylist: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", @[@"spotify:track:0F0MA0ns8oXwGw66B2BSXm"], session]]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
    
}

- (void)testDeletePlaylistSuccess
{
/* TODO: Implement once adding / deleting playlist works */
}

- (void)testDeletePlaylistFailed
{
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: [@"method not allowed" dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:405 headers:@{@"Content-Type":@"text/html"}];
    }];
    
    [plugin deletePlaylist: [self createTestURLCommand: @[@"spotify:user:justafakeuser:playlist:1ie3JnJzdYR9XwjDrq32zF", session]]];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_ERROR, @"Command status should be ERROR");
        responseArrived = YES;
    }];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
    
}

#pragma mark Convenience methods

- (CDVInvokedUrlCommand *)createTestURLCommand:(NSArray *)args
{
    return [[CDVInvokedUrlCommand alloc]initWithArguments:args callbackId:@"test" className:nil methodName:nil];
}

- (void)loginAudioPlayer
{
    __block BOOL responseArrived = NO;
    
    NSArray *args = @[@"TestCompany", @"TestApp", session];
    
    [commandDelegate mockPluginResult:^(CDVPluginResult *result, NSString *callbackId) {
        XCTAssertEqual(result.status.intValue, CDVCommandStatus_OK, @"Command status should be OK");
        responseArrived = YES;
    }];
    
    [SpotifyAudioPlayer setNextCallback:^(SPTErrorableOperationCallback callback) {
        callback(nil);
    }];
    
    [plugin createAudioPlayerAndLogin:[self createTestURLCommand:args]];
    
    waitForSecondsOrDone(4, &responseArrived);
{
    
}

    
    return;
}


@end
