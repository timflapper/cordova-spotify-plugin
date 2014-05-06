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

NSString *const objectTypes[] = { @"artist", @"album", @"track" };

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

+(NSArray *)objectTypes
{
    static NSArray *types;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        int len = sizeof(objectTypes)/sizeof(objectTypes[0]);
        
        types = [NSArray arrayWithObjects:objectTypes count:len];
    });
    
    return types;
}

+(NSString *)objectTypeFromSearchType:(NSString *)type
{
    NSUInteger index = [[self searchTypes] indexOfObject:type];
    
    if (index == NSNotFound)
        return nil;
    
    return [[self objectTypes] objectAtIndex: index];
}

+(NSString *)searchTypeForObjectType:(NSString *)type
{
    NSUInteger index = [[self objectTypes] indexOfObject:type];
    
    if (index == NSNotFound)
        return nil;
    
    return [[self searchTypes] objectAtIndex: index];

}

+(NSObject *)parseData:(NSData *)data
{
    NSError *error;
    
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSLog(@"parseData error %@", error);
    
    if ([object objectForKey:@"type"] != nil) {
        NSLog(@"It's a single object");
        
        return [self parseObject:object withObjectType:[object valueForKey:@"type"]];
    } else {
        NSLog(@"It's a list of object");
        
        NSMutableDictionary *result = [NSMutableDictionary new];
        
        [[self searchTypes] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([object objectForKey:obj] != nil)
                [result setObject:[self parseObject:object withArrayOfSearchType:obj] forKey:obj];
        }];
        
        return result;
    }
}

+(NSArray *)parseObject:(NSDictionary *)object withArrayOfSearchType:(NSString *)searchType
{
    NSMutableArray *result = [NSMutableArray new];
    
    NSString *objectType = [self objectTypeFromSearchType:searchType];
    
    [[object objectForKey:searchType] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", obj);
        
        NSDictionary *item = [self parseObject:obj withObjectType:objectType];
        
        [result addObject:item];
    }];
    
    return result;
}

+(NSDictionary *)parseObject:(NSDictionary *)object withObjectType:(NSString *)objectType
{
    if ([objectType isEqualToString:@"artist"])
        return [self parseArtist:object];

    if ([objectType isEqualToString:@"album"])
        return [self parseAlbum:object];

    if ([objectType isEqualToString:@"track"])
        return [self parseTrack:object];

    return nil;
}

+(NSDictionary *)parseArtist:(NSDictionary *)artist
{
    NSDictionary *images = [artist objectForKey:@"images"];
    
    return @{@"name": [artist valueForKey:@"name"],
             @"uri": [artist valueForKeyPath:@"self.uri"],
             @"sharingURL": [artist valueForKeyPath:@"self.web"],
             @"genres": [artist objectForKey:@"genres"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images],
             @"popularity": [artist valueForKey:@"popularity"]};
}

+(NSDictionary *)parseAlbum:(NSDictionary *)album
{
    
    NSMutableArray *tracks = [NSMutableArray new];
    
    [[album objectForKey:@"tracks"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tracks addObject:[self parsePartialTrack:obj]];
    }];
    
    NSDictionary *images = [album objectForKey:@"images"];
    
    return @{@"name": [album valueForKey:@"name"],
             @"uri": [album valueForKeyPath:@"self.uri"],
             @"sharingURL": [album valueForKeyPath:@"self.web"],
             @"externalIds": [album objectForKey:@"external_ids"],
             @"availableTerritories": [album objectForKey:@"available_markets"],
             @"artists": [self PartialsFromArray:[album objectForKey:@"artists"]],
             @"tracks": tracks,
             @"releaseDate": [album objectForKey:@"release_date"],
             @"type": [album valueForKey:@"album_type"],
             @"genres": [album objectForKey:@"genres"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images],
             @"popularity": [album valueForKey:@"popularity"]};
}

+(NSDictionary *)parsePartialAlbum:(NSDictionary *)album
{
    
    NSDictionary *images = [album objectForKey:@"images"];
    
    return @{@"name": [album valueForKey:@"name"],
             @"uri": [album valueForKeyPath:@"self.uri"],
             @"sharingURL": [album valueForKeyPath:@"self.web"],
             @"type": [album objectForKey:@"album_type"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images]};
}


+(NSDictionary *)parseTrack:(NSDictionary *)track
{
    
    return @{@"name": [track valueForKey:@"name"],
             @"uri": [track valueForKeyPath:@"self.uri"],
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
             @"uri": [track valueForKeyPath:@"self.uri"],
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
    NSMutableArray *partials = [NSMutableArray new];
    
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
