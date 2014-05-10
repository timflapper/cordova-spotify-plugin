//
//  SpotifyAPIRequestTests.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 07/05/14.
//
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "SpotifyAPIRequest.h"
#import "testShared.h"

@interface SpotifyAPIRequestTests : XCTestCase {
    BOOL done;
}

@end

@implementation SpotifyAPIRequestTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    
    [super tearDown];
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearchArtistsCorrect
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-artists.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"Good+String" type:@"artist" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testSearchAlbumsCorrect
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-albums.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"Good+String" type:@"album" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

    
}

- (void)testSearchTracksCorrect
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-tracks.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"Good+String" type:@"track" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}

- (void)testSearchTypeIncorrect
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"Good+String" type:@"bla" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testSearchEmptyQuery
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"" type:@"albums" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    XCTAssertTrue(responseArrived, "Time Out before result arrived");
    
}

- (void)testSearchLimitZero
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"" type:@"albums" offset:0 limit:0 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testSearchLimitTooHigh
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"bla" type:@"albums" offset:0 limit:80 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}

- (void)testSearchOffsetNegative
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"bla" type:@"albums" offset:-10 limit:30 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}


- (void)testGetObjectByIDTrack
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"track.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest getObjectByID:@"5TTRvmYwjbeDPB1FzbUfk5" type:@"track" callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

}


- (void)testGetObjectByIDAlbum
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"album.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest getObjectByID:@"14ic9WwfMl5PfOa04bLZQP" type:@"album" callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);
    
    XCTAssertTrue(responseArrived, "Time Out before result arrived");

    
}

- (void)testGetObjectByIDArtist
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"artist.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest getObjectByID:@"02uYdhMhCgdB49hZlYRm9o" type:@"artist" callback:^(NSError *err, NSData *data) {
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];
    
    waitForSecondsOrDone(2, &responseArrived);

    XCTAssertTrue(responseArrived, "Time Out before result arrived");
}
@end
