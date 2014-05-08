//
//  SpotifyShared.h
//


#import "SpotifyPluginError.h"

#define LIMIT_MIN 1
#define LIMIT_DEFAULT 20
#define LIMIT_MAX 50

#define OFFSET_MIN 0
#define OFFSET_DEFAULT OFFSET_MIN
#define OFFSET_MAX 999999999

typedef void (^SpotifyEventCallback)(NSArray *args);