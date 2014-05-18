//
//  SpotifyJSONTests.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 07/05/14.
//
//

#import <XCTest/XCTest.h>
#import "SpotifyJSON.h"
#import "testShared.h"

@interface SpotifyJSONTests : XCTestCase

@end

@implementation SpotifyJSONTests

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

- (void)testParseDataReturnsDictionaryForSearchWithAlbums
{
    NSError *error;
    
    NSDictionary *result = [SpotifyJSON parseData:getDataFromTestDataFile(@"search-albums.json") error:&error];
    
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertNil(error);
}

- (void)testParseDataReturnsDictionaryForJSONWithArtists
{
    NSError *error;
    
    NSDictionary *result = [SpotifyJSON parseData:getDataFromTestDataFile(@"search-artists.json") error:&error];
    
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertNil(error);
}

- (void)testParseDataReturnsDictionaryForJSONWithTracks
{
    NSError *error;
    
    NSDictionary *result = [SpotifyJSON parseData:getDataFromTestDataFile(@"search-tracks.json") error:&error];
    
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertNil(error);
}

- (void)testParseDataReturnsDictionaryForJSONWithErrorKey
{
    NSError *error;
    
    NSDictionary *result = [SpotifyJSON parseData:getDataFromTestDataFile(@"search-error.json") error:&error];
    
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertNil(error);
}


- (void)testParseDataReturnsNilAndSetsErrorForInvalidJSON
{
    NSError *error;
    
    NSDictionary *result = [SpotifyJSON parseData:getDataFromTestDataFile(@"invalid.json") error:&error];
    
    XCTAssertNil(result);
    
    XCTAssertTrue([error isKindOfClass:[NSError class]]);
}

- (void)testParseDataReturnsDictionaryForAlbum
{
    NSError *error;
    
    NSDictionary *result = [SpotifyJSON parseData:getDataFromTestDataFile(@"album.json") error:&error];
    
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertNil(error);
}

- (void)testParseDataReturnsDictionaryForArtist
{
    NSError *error;
    
    NSDictionary *result = [SpotifyJSON parseData:getDataFromTestDataFile(@"artist.json") error:&error];
    
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertNil(error);
}

- (void)testParseDataReturnsDictionaryForTrack
{
    NSError *error;
    
    NSDictionary *result = [SpotifyJSON parseData:getDataFromTestDataFile(@"track.json") error:&error];
    
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertNil(error);
}


@end
