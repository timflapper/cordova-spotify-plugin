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

+ (void)getObjectByID:(NSString *)objectID type:(NSString *)objectType callback:(SpotifyRequestBlock)callback {
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:API_URL_PATTERN, API_URL_BASE, objectType, objectID]];
    
    [self getResultFromURL: url callback:callback];
}

+ (void)searchObjectsWithQuery:(NSString *)query type:(NSString *)searchType offset:(int)offset limit:(int)limit callback:(SpotifyRequestBlock)callback
{
    NSError *error;
    
    NSString *cleanQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([cleanQuery length] == 0) {
        error = [SpotifyPluginError errorWithCode:SpotifyPluginEmptyQueryError description:@"Query cannot be empty"];
    } else if (limit < LIMIT_MIN) {
        error = [SpotifyPluginError errorWithCode:SpotifyPluginBadLimitError description:@"Limit needs to be larger than 0"];
    } else if (limit > LIMIT_MAX) {
        error = [SpotifyPluginError errorWithCode:SpotifyPluginBadLimitError description:@"Limit too large"];
    } else if (offset < OFFSET_MIN) {
        error = [SpotifyPluginError errorWithCode:SpotifyPluginBadOffsetError description:@"Offset needs to be larger than 0"];
    } else if (offset > OFFSET_MAX) {
        error = [SpotifyPluginError errorWithCode:SpotifyPluginBadOffsetError description:@"Offset too large"];
    } else if ([[SpotifyJSON objectTypes] indexOfObject:searchType] == NSNotFound) {
        error = [SpotifyPluginError errorWithCode:SpotifyPluginBadSearchTypeError description:@"Search type is invalid"];
    }

    if (error != nil) {
        callback(error, nil);
        return;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"?q=%@&limit=%d&offset=%d&type=%@", query, limit, offset, searchType];
    
    NSString *urlString = [NSString stringWithFormat:API_URL_PATTERN, API_URL_BASE, @"search", [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    [self getResultFromURL: url callback:callback];
}

+ (void)getResultFromURL:(NSURL *)url callback:(SpotifyRequestBlock)callback
{
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:[[NSURLRequest alloc] initWithURL:url]
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   
                   if (error) {
                       //NSLog(@"getResultFromURI error %@", error);
                       callback(error, nil);
                       return;
                   }
                   
                   callback(nil, data);
                   
               }] resume];
}

@end
