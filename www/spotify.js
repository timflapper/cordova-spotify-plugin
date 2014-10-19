
var utils = require('./utils')
  , AudioPlayer = require('./audio-player')
  , exec = utils.exec
  , noop = utils.noop;

var spotify = exports;

spotify.authenticate = function(clientId, tokenExchangeURL, scopes, callback) {
  if (callback === undefined) callback = scopes, scopes = ['streaming'];

  exec('authenticate', clientId, tokenExchangeURL, scopes, callback);
};

spotify.renewSession = function(session, tokenRefreshURL, forceRenew, callback) {
  if (callback === undefined && typeof forceRenew === 'function')
    callback = forceRenew, forceRenew = false;

  if (forceRenew === true)
    return renewSession(session, tokenRefreshURL, callback);

  spotify.isSessionValid(session, function(err, valid) {
    if (err) return callback(err);
    if (valid) return callback(null, session);

    renewSession(session, tokenRefreshURL, callback);
  });
};

function renewSession(session, tokenRefreshURL, callback) {
  exec('renewSession', session, tokenRefreshURL, callback);
};

spotify.isSessionValid = function(session, callback) {
  exec('isSessionValid', session, callback);
};

spotify.createAudioPlayer = function(companyName, appName) {
  return new AudioPlayer(companyName, appName);
};

/**
 * TODO:
 * - Optimize WebAPI calling stuff
 * - Flatten API
 * - Update API wiki
 * - Finish writing specs
 * - Custom callback URI as variable for install
 * - install script to download SpotifySDK
 */
