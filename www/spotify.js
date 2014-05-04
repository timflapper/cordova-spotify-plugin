var exec = require('cordova/exec')
  , spotify = exports;

spotify.exec = function(action, params, callback) {
  if (typeof params === 'function') {
      if (callback !== undefined) {
        throw new Error('Only action and callback allowed if parameters are omitted. Third argument of type ' + (typeof callback) + 'detected.');
      }

      callback = params, params = [];
  }
  
  function onSuccess(result) { callback(null, result); }
  function onError(error) { callback(error); }
  
  exec( onSuccess, onError, service, 'SpotifyPlugin', params );
};

spotify.authenticate =function(clientId, tokenExchangeURL, scopes, callback) {
  var params;
    
  if (! callback) callback = scopes, scopes = ['login'];
      
  spotify.exec( 'authenticate',
                [ clientId, tokenExchangeURL, scopes ],
                callback );
};

spotify.search = function(query, type, offset, callback) {
  offset = offset || 0;
  
  spotify.exec( 'search', 
                [ query, type, offset ], 
                callback );
};

spotify.getPlaylistsForUser = function(session, username, callback) {
  var args;
  
  if (typeof username === 'function') {
    if (callback !== undefined) {
      throw new Error('Only session and callback allowed if username is omitted. Third argument of type ' + (typeof callback) + 'detected.');
    }
    
    callback = username, username = undefined;
  }
  
  if (username === undefined) {
    args = [];
  } else {
    args = [username];
  }
    
  spotify.exec( 'getPlaylistsForUser', 
                args, 
                callback );    
}