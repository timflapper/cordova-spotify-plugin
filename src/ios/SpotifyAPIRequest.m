//
//  SpotifyAPIRequest.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//
//

#import "SpotifyAPIRequest.h"

static NSString *const API_URL_BASE = @"https://api.spotify.com/v1";
static NSString *const API_URL_PATTERN = @"%@/%@/%@";

@implementation SpotifyAPIRequest
+(void)getObjectFromURI:(NSString *)uri callback:(SpotifyRequestBlock)callback
{
    NSArray * uriArray = [uri componentsSeparatedByString:@":"];
    
    NSString * endpoint = [SpotifyJSON searchTypeForObjectType:[uriArray objectAtIndex:1]];
    NSString * objectID = [uriArray objectAtIndex:2];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:API_URL_PATTERN, API_URL_BASE, endpoint, objectID]];
    
    [self getResultFromURL: url callback:callback];
}
+(void)searchObjectsWithQuery:(NSString *)query type:(NSString *)searchType offset:(NSInteger)offset callback:(SpotifyRequestBlock)callback
{
    NSString *queryString = [NSString stringWithFormat:@"?q=%@&limit=%d&offset=%d&type=%@", query, 0, 0, searchType];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:API_URL_PATTERN, API_URL_BASE, @"search", queryString]];
    
    [self getResultFromURL: url callback:callback];
}

+(void)getResultFromURL:(NSURL *)url callback:(SpotifyRequestBlock)callback
{
    NSURLSessionConfiguration *sessConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration: sessConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    [[urlSession dataTaskWithURL:url
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   
                   if (error) {
                       NSLog(@"getObjectFromURI error %@", error);
                       callback(error, nil);
                       return;
                   }
                   
                   @try {
                       NSDictionary *object = [SpotifyJSON parseData:data];
                       
                       callback(nil, object);
                   }
                   @catch(NSException *excepton) {
                       NSLog(@"getObjectFromURI error %@", error);
                       
                       NSString *desc = NSLocalizedString(@"JSON data conversion failed", "");
                       
                       NSError *jsonError = [NSError errorWithDomain:ERROR_DOMAIN code:-101 userInfo: @{NSLocalizedDescriptionKey: desc}];
                       
                       callback(jsonError, nil);
                       return;
                   }
                   
               }] resume];
}
@end
