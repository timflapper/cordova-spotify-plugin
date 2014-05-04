var exec = require('cordova/exec');

var spotify = module.exports = {};

spotify.AudioPlayer = require('./lib/audio-player');
spotify.Album = require('./lib/album');
spotify.Artist = require('./lib/artist');
spotify.Playlist = require('./lib/playlist');
spotify.Session = require('./lib/session');
spotify.Track = require('./lib/track');
spotify.Image = require('./lib/image');

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
    
    var sess = new spotify.Session(data);
    
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

spotify.getObjectFromURI = function(uri, session, callback) {
  var action, objectType, matches;

  matches = /^spotify:(?:(?:user:[^:]*:)(?=playlist:[a-zA-Z0-9]*$)|(?:(?=artist|album|track)))(playlist|artist|album|track):[a-zA-Z0-9]*$/.exec(uri);
    
  if (matches === null)
    return callback(new Error('URI appears to be invalid %s', uri));
    
  objectType = matches[1];
  
  spotify.exec( 'getObjectFromURI',
                [ uri, session ], 
                done );
  
  function done(error, data) {
    var res;
        
    switch(objectType) {
      case 'track':
        res = new spotify.Track(data);
        break;
      case 'album':
        res = new spotify.Album(data);
        break;
      case 'artist':
        res = new spotify.Artist(data);
        break;
      case 'playlist':
        res = new spotify.Playlist(data);
        break;
    }
    
    callback(null, res);
  }
}

spotify.getPlaylistsForUser = function(username, session, callback) {
  spotify.exec( 'getPlaylistsForUser', 
                [ username, session ],
                callback );    
}

spotify.createPlaylist = function(name, session, callback) {
  spotify.exec( 'createPlaylist', 
                [ name, session ],
                done );
                
  function done(error, data) {
    var playlist;
    
    if (error)
      return callback(error);
    
    playlist = new spotify.Playlist(data);
    
    callback(null, playlist);
  }
}