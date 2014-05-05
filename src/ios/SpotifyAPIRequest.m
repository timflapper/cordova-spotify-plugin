//
//  SpotifyAPIRequest.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//
//

#import "SpotifyAPIRequest.h"

@implementation SpotifyAPIRequest
-(void)test
{
    NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/search?q=David+Bowie&limit=20&offset=0&type=artist"];
    
    NSURLSessionConfiguration *sessConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration: sessConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    [[urlSession dataTaskWithURL:url
     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         
         NSError *jsonError;
         
         NSObject *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
         
         NSLog(@"%@", result);
         
//         NSLog(@"Got response %@ with error %@.\n", response, error);
//         NSLog(@"DATA:\n%@\nEND DATA\n",
//               [[NSString alloc] initWithData: data
//                                     encoding: NSUTF8StringEncoding]);
     }] resume];
}
@end
