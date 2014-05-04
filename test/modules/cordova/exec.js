'use strict';

var data = require('./data');

module.exports = function(onSuccess, onError, service, action, args) {
    
  switch (action) {
    case 'doTestAction':
      return onSuccess([true]);
      break;
    case 'authenticate':
      authenticate(onSuccess, onError, args);
      break;
    case 'search':
      search(onSuccess, onError, args);
      break;
    case 'getPlaylistsForUser':
      getPlaylistsForUser(onSuccess, onError, args);
      break;
    case 'getObjectFromURI':
      getObjectFromURI(onSuccess, onError, args);
      break;
    default:
      return onError(new Error('Invalid action'));
  }
}


function authenticate(onSuccess, onError, args) {
  onSuccess({
    username: 'testuser',
    credential: 'someR4nd0mCr3d3nt14ls'
  });
}

function search(onSuccess, onError, args) {
  var result = [
    {name: 'Ben Folds', uri: 'spotify:artist:55tif8708yyDQlSjh3Trdu'}
  ];
    
  onSuccess(result);
}

function getPlaylistsForUser(onSuccess, onError, args) {
  var result = [
    {name: 'Some Playlist', uri: 'spotify:user:testuser:playlist:nOT1A2rEaL3uRL'}
  ];
  
  onSuccess(result);
}

function getObjectFromURI(onSuccess, onError, args) {    
  var uri = args[0]
    , matches
    , obj;

    matches = /^spotify:(?:(?:user:[^:]*:)(?=playlist:[a-zA-Z0-9]*$)|(?:(?=artist|album|track)))(playlist|artist|album|track):[a-zA-Z0-9]*$/.exec(uri);

  if (matches === null)
    return onError(new Error('Invalid uri'));

  switch(matches[1]) {
    case 'artist':
      obj = data.artists[uri];
      break;
    case 'album':
      obj = data.albums[uri];      
      break;
    case 'track':
      obj = data.tracks[uri];
      break;
    case 'playlist':
      obj = data.playlists[uri];
      break;
  }
  
  onSuccess(obj);
}