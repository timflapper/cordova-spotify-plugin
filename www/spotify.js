var exec = require('cordova/exec')
  , spotify = exports;

spotify.exec = function(action, params, callback) {
  function onResult(result) { callback(null, result); }
  function onError(error) { callback(error); }
  
  exec( onResult, onError, service, 'SpotifyPlugin', params );
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