//
//  SpotifyJSON.m
//  SpotifyPlugin
//
//  Created by Tim Flapper on 05/05/14.
//
//

#import "SpotifyJSON.h"
#import "SpotifyShared.h"

NSString *const imageSizes[] = { @"small", @"medium", @"large", @"xlarge" };

NSString *const searchTypes[] = { @"artists", @"albums", @"tracks" };

NSString *const objectTypes[] = { @"artist", @"album", @"track" };

@implementation SpotifyJSON
+(instancetype)defaultInstance
{
    static dispatch_once_t once;
    static SpotifyJSON *instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}
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

+(NSObject *)parseData:(NSData *)data error:(NSError **)error
{
    
    NSError *serializeError;
    
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializeError];
    
    if (serializeError != nil) {
        NSLog(@"parseData error: %@", serializeError);
        
        *error = [SpotifyPluginError errorWithCode:SpotifyPluginInvalidJSONError description:@"Data is not valid JSON"];
        
        return nil;
    }
    
    if ([object objectForKey:@"error"] != nil) {
        return object;
    }
    
    if ([object objectForKey:@"type"] != nil) {
        return [self parseObject:object withObjectType:[object valueForKey:@"type"]];
        
    } else {
        
        NSMutableDictionary *result = [NSMutableDictionary new];
        
        [[self searchTypes] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([object objectForKey:obj] != nil)
                [result setObject:[self parseObjectFromSearch:[[object objectForKey:obj] objectForKey:@"items"]
                                   withArrayOfObjectType:[self objectTypeFromSearchType: obj]]
                           forKey:obj];
        }];
//        }
        
        return result;
    }
}

+(NSArray *)parseObjectFromSearch:(NSArray *)objects withArrayOfObjectType:(NSString *)objectType
{
    NSMutableArray *result = [NSMutableArray new];

    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *item = [self parseObjectFromSearch:obj withObjectType:objectType];
        
        [result addObject:item];
    }];
    
    return result;
}

+(NSArray *)parseObject:(NSArray *)objects withArrayOfObjectType:(NSString *)objectType
{
    NSMutableArray *result = [NSMutableArray new];
    
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *item = [self parseObject:obj withObjectType:objectType];
        
        [result addObject:item];
    }];
    
    return result;
}

+(NSDictionary *)parseObjectFromSearch:(NSDictionary *)object withObjectType:(NSString *)objectType
{
    if ([objectType isEqualToString:@"artist"])
        return [self parseArtist:object];
    
    if ([objectType isEqualToString:@"album"])
        return [self parsePartialAlbum:object];
    
    if ([objectType isEqualToString:@"track"])
        return [self parseTrack:object];
    
    return nil;
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
    NSArray *images = [artist objectForKey:@"images"];
    
    return @{@"type": @"artist",
             @"name": [artist valueForKey:@"name"],
             @"uri": [artist valueForKeyPath:@"uri"],
             @"sharingURL": [artist valueForKeyPath:@"external_urls.spotify"],
             @"genres": [artist objectForKey:@"genres"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images],
             @"popularity": [artist valueForKey:@"popularity"]};
}

+(NSDictionary *)parseAlbum:(NSDictionary *)album
{
    
    NSMutableArray *tracks = [NSMutableArray new];
    
    [[[album objectForKey:@"tracks"] objectForKey:@"items"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [tracks addObject:[self parsePartialTrack:obj]];
    }];
    
    NSArray *images = [album objectForKey:@"images"];
    
    return @{@"type": @"album",
             @"name": [album valueForKey:@"name"],
             @"uri": [album valueForKeyPath:@"uri"],
             @"sharingURL": [album valueForKeyPath:@"external_urls.spotify"],
             @"externalIds": [album objectForKey:@"external_ids"],
             @"availableTerritories": [album objectForKey:@"available_markets"],
             @"artists": [self PartialsFromArray:[album objectForKey:@"artists"]],
             @"tracks": tracks,
             @"releaseDate": [album objectForKey:@"release_date"],
             @"albumType": [album valueForKey:@"album_type"],
             @"genres": [album objectForKey:@"genres"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images],
             @"popularity": [album valueForKey:@"popularity"]};
}

+(NSDictionary *)parsePartialAlbum:(NSDictionary *)album
{
    
    NSArray *images = [album objectForKey:@"images"];
    
    return @{@"name": [album valueForKey:@"name"],
             @"uri": [album valueForKeyPath:@"uri"],
             @"sharingURL": [album valueForKeyPath:@"external_urls.spotify"],
             @"type": [album objectForKey:@"album_type"],
             @"images": images,
             @"smallestImage": [self findSmallestImage:images],
             @"largestImage": [self findLargestImage:images]};
}


+(NSDictionary *)parseTrack:(NSDictionary *)track
{
    
    return @{@"type": @"track",
             @"name": [track valueForKey:@"name"],
             @"uri": [track valueForKeyPath:@"uri"],
             @"sharingURL": [track valueForKeyPath:@"external_urls.spotify"],
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
             @"uri": [track valueForKeyPath:@"uri"],
             @"sharingURL": [track valueForKeyPath:@"external_urls.spotify"],
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
             @"uri": [item valueForKeyPath:@"uri"]};
}

+(NSDictionary *)findSmallestImage:(NSArray *)images
{
    __block int smallestSize = INFINITY;
    
    __block NSDictionary *smallest = nil;
    
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int size = (int)[obj valueForKey:@"width"] * (int)[obj valueForKey:@"height"];
        
        if (smallest == nil || size < smallestSize) {
            smallestSize = size;
            smallest = obj;
        }
    }];
    
    if (smallest != nil) return smallest;
    return @{};
    
}

+(NSDictionary *)findLargestImage:(NSArray *)images
{
    __block int largestSize = 0;
    
    __block NSDictionary *largest = nil;
    
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int size = (int)[obj valueForKey:@"width"] * (int)[obj valueForKey:@"height"];
        
        if (largest == nil || size > largestSize) {
            largestSize = size;
            largest = obj;
        }
    }];
    
    if (largest != nil) return largest;
    return @{};

}

@end
