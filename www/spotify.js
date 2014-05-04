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
    
  if (callback === undefined) callback = scopes, scopes = ['login'];
      
  spotify.exec( 'authenticate',
                [ clientId, tokenExchangeURL, scopes ],
                callback );
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