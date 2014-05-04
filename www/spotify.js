var exec = require('cordova/exec');

var spotify = {};

spotify.Album = require('./lib/album');
spotify.Artist = require('./lib/artist');
spotify.AudioPlayer = require('./lib/audio-player');
spotify.Image = require('./lib/image');
spotify.Playlist = require('./lib/playlist');
spotify.Session = require('./lib/Session');
spotify.Track = require('./lib/Track');

spotify.exec = function(action, params, callback) {
  if (typeof params === 'function') {
      if (callback !== undefined) {
        throw new Error('Only action and callback allowed if parameters are omitted. Third argument of type ' + (typeof callback) + 'detected.');
      }

      callback = params, params = [];
  } else if (callback === undefined) {
    throw new Error('Callback is a mandatory argument');    
  }
  
  function onSuccess(result) { callback(null, result); }
  function onError(error) { callback(error); }
  
  exec( onSuccess, onError, 'SpotifyPlugin', action, params );
};

spotify.authenticate = function(clientId, tokenExchangeURL, scopes, callback) {
  var params;
    
  if (callback === undefined) callback = scopes, scopes = ['login'];
  
  function done(error, data) {    
    if (error !== null)
      return callback(error);
    
    var sess = spotify.Session(data);
    
    callback(null, sess);
  }
    
  spotify.exec( 'authenticate',
                [ clientId, tokenExchangeURL, scopes ],
                done );
};

spotify.search = function(query, searchType, offset, session, callback) {
  if (typeof session === 'function') {
    if (callback !== undefined) {
      throw new Error('Only query, searchType, session and callback allowed if offset is omitted. Fifth argument of type ' + (typeof callback) + 'detected.');
    }
    
    callback = session, session = offset, offset = 0;
  }

  spotify.exec( 'search', 
                [ query, searchType, offset, session ], 
                callback );
};

spotify.getPlaylistsForUser = function(username, session, callback) {
  spotify.exec( 'getPlaylistsForUser', 
                [ username, session ],
                callback );    
}



module.exports = spotify;