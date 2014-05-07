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
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSearchArtistsCorrect
{
 
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-artists.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"Good+String" type:@"artist" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];

    NSTimeInterval timeout = 2;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
   
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearchAlbumsCorrect
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-albums.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"Good+String" type:@"album" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];
    
    NSTimeInterval timeout = 2;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearchTracksCorrect
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-tracks.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"Good+String" type:@"track" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNil(err);
        XCTAssertNotNil(data);
    }];
    
    NSTimeInterval timeout = 2;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearchTypeIncorrect
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"Good+String" type:@"bla" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    NSTimeInterval timeout = 2;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearchEmptyQuery
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"" type:@"albums" offset:0 limit:1 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    NSTimeInterval timeout = 2;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearchLimitZero
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"" type:@"albums" offset:0 limit:0 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    NSTimeInterval timeout = 2;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearchLimitTooHigh
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"bla" type:@"albums" offset:0 limit:80 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    NSTimeInterval timeout = 2;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}

- (void)testSearchOffsetNegative
{
    
    __block BOOL responseArrived = NO;
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"api.spotify.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        return [OHHTTPStubsResponse responseWithData: getDataFromTestDataFile(@"search-invalid.json")
                                          statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [SpotifyAPIRequest searchObjectsWithQuery:@"bla" type:@"albums" offset:-10 limit:30 callback:^(NSError *err, NSData *data) {
        
        responseArrived = YES;
        
        XCTAssertNotNil(err);
        XCTAssertNil(data);
    }];
    
    NSTimeInterval timeout = 2;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!responseArrived && ([timeoutDate timeIntervalSinceNow]>0))
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
    
    [OHHTTPStubs removeAllStubs];
}


@end
