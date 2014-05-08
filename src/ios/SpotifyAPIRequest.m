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

+ (void)getObjectFromURI:(NSString *)uri callback:(SpotifyRequestBlock)callback
{
    
    NSError *error = nil;
    NSString * objectType;
    NSString * objectID;
    
    NSString *pattern = @"^spotify:(?:(?:user:[^:]*:)(?=playlist:[a-zA-Z0-9]*$)|(?:(?=artist|album|track)))(playlist|artist|album|track):([a-zA-Z0-9]*)$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:&error];
    
    if (error) {
//        NSLog(@"REGEX ERROR %@", error);
        
        callback(error, nil);
        return;
    }
    
    NSTextCheckingResult *match = [regex firstMatchInString:uri options:0 range:NSMakeRange(0, uri.length)];

    if (match == nil) {
        error = [SpotifyPluginError errorWithCode:SpotifyPluginInvalidSpotifyURIError description:[NSString stringWithFormat:@"URI appears to be invalid %@", uri]];
        
        callback(error, nil);
        return;
    }
    

    objectType = [uri substringWithRange: [match rangeAtIndex:1]];

    objectID = [uri substringWithRange: [match rangeAtIndex:2]];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:API_URL_PATTERN, API_URL_BASE, objectType, objectID]];

    [self getResultFromURL: url callback:callback];
}

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
                       NSLog(@"getResultFromURI error %@", error);
                       callback(error, nil);
                       return;
                   }
                   
                   callback(nil, data);
                   
               }] resume];
}

@end
