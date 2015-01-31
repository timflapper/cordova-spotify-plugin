var remote = require('./remote');

var REMOTE_IDS = 0x0001
  , REMOTE_ID_IN_URL = 0x0002
  , REMOTE_USERNAME_IN_URL = 0x0004
  , REMOTE_DATA = 0x0008
  , REMOTE_DATA_JSON = REMOTE_DATA + 0x0010
  , REMOTE_SESSION = 0x0100
  , REMOTE_POST = 0x1000
  , REMOTE_PUT = 0x2000
  , REMOTE_DELETE = 0x4000;

var requestMethods = {
  search:                     ['/search',                       REMOTE_DATA],
  getAlbum:                   ['/albums/$I',                    REMOTE_ID_IN_URL],
  getAlbums:                  ['/albums',                       REMOTE_IDS],
  getArtist:                  ['/artists/$I',                   REMOTE_ID_IN_URL],
  getArtists:                 ['/artists',                      REMOTE_IDS],
  getAlbumsOfArtist:          ['/artists/$I/albums',            REMOTE_ID_IN_URL],
  getTrack:                   ['/tracks/$I',                    REMOTE_ID_IN_URL],
  getTracks:                  ['/tracks',                       REMOTE_IDS],
  getProfile:                 ['/me',                           REMOTE_SESSION],
  getSavedTracks:             ['/me/tracks',                    REMOTE_SESSION],
  getSavedTracksContain:      ['/me/tracks/contains',           REMOTE_SESSION + REMOTE_IDS],
  saveTracks:                 ['/me/tracks',                    REMOTE_SESSION + REMOTE_IDS + REMOTE_PUT],
  removeTracks:               ['/me/tracks',                    REMOTE_SESSION + REMOTE_IDS + REMOTE_DELETE],
  getStarred:                 ['/users/$U/starred',             REMOTE_SESSION],
  getPlaylists:               ['/users/$U/playlists',           REMOTE_SESSION],
  getPlaylist:                ['/users/$U/playlists/$I',        REMOTE_SESSION + REMOTE_ID_IN_URL],
  createPlaylist:             ['/users/$U/playlists',           REMOTE_SESSION + REMOTE_DATA_JSON + REMOTE_POST],
  changePlaylistDetails:      ['/users/$U/playlists/$I',        REMOTE_SESSION + REMOTE_DATA_JSON + REMOTE_PUT    + REMOTE_ID_IN_URL],
  addTracksToPlaylist:        ['/users/$U/playlists/$I/tracks', REMOTE_SESSION + REMOTE_DATA_JSON + REMOTE_POST   + REMOTE_ID_IN_URL, ['uris']],
  replaceTracksOnPlaylist:    ['/users/$U/playlists/$I/tracks', REMOTE_SESSION + REMOTE_DATA_JSON + REMOTE_PUT    + REMOTE_ID_IN_URL, ['uris']],
  removeTracksFromPlaylist:   ['/users/$U/playlists/$I/tracks', REMOTE_SESSION + REMOTE_DATA_JSON + REMOTE_DELETE + REMOTE_ID_IN_URL, ['tracks']]
};

Object.keys(requestMethods).forEach(function(key) {
  module.exports[key] = createRemoteMethod.apply(null, requestMethods[key]);
});

function createRemoteMethod(uri, type, dataKeys) {
  return function() {
    var options = {uri: uri}
      , args = Array.prototype.slice.call(arguments)
      , callback = args.pop();

    if (type & REMOTE_POST) {
      options.method = 'post';
    } else if (type & REMOTE_PUT) {
      options.method = 'put';
    } else if (type & REMOTE_DELETE) {
      options.method = 'delete';
    }

    if (type & REMOTE_SESSION) {
      options.session = args.pop();
      options.uri = options.uri.replace('$U', session.canonicalUsername);
    }

    if (type & REMOTE_ID_IN_URL)
      options.uri = options.uri.replace('$I', spotifyUriToId(args.shift()));

    if (type & REMOTE_IDS)
      options.uri = uriWithIds(options.uri, args.shift());

    if (type & REMOTE_DATA) {
      if (dataKeys) {
        options.data = {};

        dataKeys.forEach(function(key) {
          options.data[key] = args.shift();
        });
      } else {
        options.data = args.shift();
      }

      if (type & REMOTE_DATA_JSON)
        options.data = JSON.stringify(options.data);
    }

    remote(options, callback);
  };
}

function uriWithIds(uri, ids) {
  return uri + "?ids=" + spotifyUriToId(ids).join(',');;
}

function spotifyUriToId(uri) {
  if (Array.isArray(uri)) {
    var id, result = [];

    items.forEach(function(uri) {
      if (id = spotifyUriToId(uri))
        result.push(id);
    });

    return result;
  }

  if (matches = /^spotify:[^:]*:(.*)$/.exec(uri))
    return matches[1];

  return uri;
}
