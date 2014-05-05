//
//  SpotifyJSON.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//
//

#import "SpotifyJSON.h"

NSString *const imageSizes[] = { @"small", @"medium", @"large", @"xlarge" };

NSString *const searchTypes[] = { @"artists", @"albums", @"tracks" };

@implementation SpotifyJSON
+(NSArray *)imageSizes
{
    static NSArray *sizes;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        int len = sizeof(imageSizes)/sizeof(imageSizes[0]);
        
        sizes = [NSArray arrayWithObjects:imageSizes count:len];
    });
    
    return sizes;
}

+(NSArray *)searchTypes
{
    static NSArray *types;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        int len = sizeof(searchTypes)/sizeof(searchTypes[0]);
        
        types = [NSArray arrayWithObjects:searchTypes count:len];
    });
    
    return types;
}

+(NSObject *)parseData:(NSData *)data
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    NSError *error;
    NSString *type;
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    [[self searchTypes] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([object objectForKey:obj] != nil)
            [result setObject:obj forKey:[self parseObject:object withArrayOfType:obj]];
    }];
    
    type = [object valueForKey:@"type"];
    
    if ([type isEqualToString:@"artist"])
        return [self parseArtist:object];
    
    if ([type isEqualToString:@"album"])
        return [self parseAlbum:object];
    
    if ([type isEqualToString:@"track"])
        return [self parseTrack:object];
    
    
    return nil;
}

+(NSArray *)parseObject:(NSDictionary *)object withArrayOfType:(NSString *)type
{
    NSMutableArray *result = [NSMutableArray new];
    
    
    
    return result;
}

+(NSDictionary *)parseArtist:(NSDictionary *)artist
{
    NSDictionary *images = [self parseImages: [artist objectForKey:@"images"]];
    
    return @{@"name": [artist valueForKey:@"name"],
             @"uri": [artist valueForKey:@"uri"],
             @"sharingURL": [artist valueForKeyPath:@"self.web"],
             @"genres": [artist valueForKey:@"genres"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images],
             @"popularity": @0};
}

+(NSDictionary *)parseAlbum:(NSDictionary *)album
{
    
    NSMutableArray *tracks = [NSMutableArray new];
    
    [[album objectForKey:@"tracks"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tracks addObject:[self parsePartialTrack:obj]];
    }];
    
    NSDictionary *images = [self parseImages: [album objectForKey:@"images"]];
    
    return @{@"name": [album valueForKey:@"name"],
             @"uri": [album valueForKey:@"uri"],
             @"sharingURL": [album valueForKeyPath:@"self.web"],
             @"externalIds": [album objectForKey:@"external_ids"],
             @"availableTerritories": [album objectForKey:@"available_markets"],
             @"artists": [self PartialsFromArray:[album objectForKey:@"artists"]],
             @"tracks": tracks,
             @"releaseDate": [album objectForKey:@"release_date"],
             @"type": [album objectForKey:@"album_type"],
             @"genres": [album valueForKey:@"genres"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images],
             @"popularity": [album valueForKey:@"popularity"]};
}

+(NSDictionary *)parsePartialAlbum:(NSDictionary *)album
{
    
    NSDictionary *images = [self parseImages: [album objectForKey:@"images"]];
    
    return @{@"name": [album valueForKey:@"name"],
             @"uri": [album valueForKey:@"uri"],
             @"sharingURL": [album valueForKeyPath:@"self.web"],
             @"type": [album objectForKey:@"album_type"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images]};
}


+(NSDictionary *)parseTrack:(NSDictionary *)track
{
    
    return @{@"name": [track valueForKey:@"name"],
             @"uri": [track valueForKey:@"uri"],
             @"sharingURL": [track valueForKeyPath:@"self.web"],
             @"previewURL": [track valueForKey:@"preview_url"],
             @"duration": [track valueForKey:@"duration_ms"],
             @"artists": [self PartialsFromArray:[track objectForKey:@"artists"]],
             @"album": [self parsePartialAlbum:[track objectForKey:@"album"]],
             @"trackNumber": [track valueForKey:@"track_number"],
             @"discNumber": [track valueForKey:@"disc_number"],
             @"popularity": [track valueForKey:@"popularity"],
             @"flaggedExplicit": [track valueForKey:@"explicit"],
             @"externalIds": [track objectForKey:@"external_ids"],
             @"availableTerritories": [track objectForKey:@"available_markets"]};
}

+(NSDictionary *)parsePartialTrack:(NSDictionary *)track
{
    
    return @{@"name": [track valueForKey:@"name"],
             @"uri": [track valueForKey:@"uri"],
             @"sharingURL": [track valueForKeyPath:@"self.web"],
             @"previewURL": [track valueForKey:@"preview_url"],
             @"duration": [track valueForKey:@"duration_ms"],
             @"artists": [self PartialsFromArray:[track objectForKey:@"artists"]],
             @"trackNumber": [track valueForKey:@"track_number"],
             @"discNumber": [track valueForKey:@"disc_number"],
             @"flaggedExplicit": [track valueForKey:@"explicit"]};
}


+(NSArray *)PartialsFromArray:(NSArray *)array
{
    NSMutableArray *partials;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [partials addObject: [self partialFromItem:obj]];
    }];
    
    return partials;
}

+(NSDictionary *)partialFromItem:(NSDictionary *)item
{
    return @{@"name": [item valueForKey:@"name"],
             @"uri": [item valueForKeyPath:@"self.uri"]};
}

+(NSDictionary *)parseImages:(NSDictionary *)images
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    [images enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *image = @{@"url": [obj valueForKey:@"image_url"],
                                @"width": [obj valueForKey:@"width"],
                                @"height": [obj valueForKey:@"height"]};
        
        [result setObject:image forKey:key];
    }];
    
    return result;
}

+(NSDictionary *)findSmallestImage:(NSDictionary *)images
{
    id key = nil;
    
    NSEnumerator *enumerator = [[self imageSizes] objectEnumerator];
    
    while (key = [enumerator nextObject])
        if ([images objectForKey:key] != nil)
            return [images objectForKey:key];
    
    return @{};
    
}

+(NSDictionary *)findLargestImage:(NSDictionary *)images
{
    id key = nil;
    
    NSEnumerator *enumerator = [[self imageSizes] reverseObjectEnumerator];
    
    while (key = [enumerator nextObject])
        if ([images objectForKey:key] != nil)
            return [images objectForKey:key];
    
    return @{};
}

@end
