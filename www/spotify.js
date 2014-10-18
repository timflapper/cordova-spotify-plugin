
var utils = require('./utils')
  , AudioPlayer = require('./audio-player')
  , request = require('./request')
  , exec = utils.exec
  , noop = utils.noop;

var spotify = exports;

spotify.authenticate = function(clientId, tokenExchangeURL, scopes, callback) {
  if (callback === undefined) callback = scopes, scopes = ['streaming'];

  exec('authenticate', clientId, tokenExchangeURL, scopes, callback);
};

spotify.createAudioPlayer = function(companyName, appName) {
  return new AudioPlayer(companyName, appName);
};

spotify.playlists = require('./playlists');

spotify.request = request.meta;
spotify.search = request.search;

/**
 * FEATURES TODO:
 *
 * - Playlist endpoints
 *   + create / add tracks, update details.
 *   + get starred playlist.
 * - Refresh authentication.
 * - Check if all possible AudioPlayer features are implemented.
 *   + Multiple track playback.
 *   + Track queuing.
 *   + shuffle / repeat
 *   + skip
 *   + Bitrate
 *   + DiskCacheSizeLimit
 *   + ...
 * - User information
 * - Update API wiki
 * - Your music stuff
 */
