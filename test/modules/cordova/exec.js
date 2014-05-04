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
    case 'createPlaylist':
      createPlaylist(onSuccess, onError, args);
      break;
    case 'setPlaylistName':
      setPlaylistName(onSuccess, onError, args);
      break;
    case 'setPlaylistDescription':
      setPlaylistDescription(onSuccess, onError, args);
      break;
    case 'setPlaylistCollaborative':
      setPlaylistCollaborative(onSuccess, onError, args);
      break;
    case 'addTracksToPlaylist':
      addTracksToPlaylist(onSuccess, onError, args);
      break;
    case 'deletePlaylist':
      deletePlaylist(onSuccess, onError, args);
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

function createPlaylist(onSuccess, onError, args) {
  var data = {
    name: args[0],
    version: 1,
    uri: 'spotify:user:testuser:playlist:s0M3ranD0MiD',
    collaborative: false,
    creator: 'testuser',
    tracks: [],
    dateModified: new Date()    
  };
  
  onSuccess(data);
}

function setPlaylistName(onSuccess, onError, args) {
  var data = {
    name: args[1],
    version: 2,
    uri: args[0],
    collaborative: false,
    creator: 'testuser',
    tracks: [],
    dateModified: new Date()    
  };
  
  onSuccess(data);
}

function setPlaylistDescription(onSuccess, onError, args) {
  var data = {
    name: 'My Amazing Playlist',
    version: 2,
    uri: args[0],
    collaborative: false,
    creator: 'testuser',
    tracks: [],
    dateModified: new Date()    
  };
  
  onSuccess(data);
}

function setPlaylistCollaborative(onSuccess, onError, args) {
  var data = {
    name: 'My Amazing Playlist',
    version: 2,
    uri: args[0],
    collaborative: true,
    creator: 'testuser',
    tracks: [],
    dateModified: new Date()    
  };
  
  onSuccess(data);
}

function addTracksToPlaylist(onSuccess, onError, args) {
  var tracks = args[1];
  
  var data = {
    name: 'My Amazing Playlist',
    version: 2,
    uri: args[0],
    collaborative: true,
    creator: 'testuser',
    tracks: [
      {name: 'Let\'s Dance - 1999 Digital Remaster', uri: tracks[0]}  
    ],
    dateModified: new Date()    
  };
    
  onSuccess(data);
}

function deletePlaylist(onSuccess, onError, args) {
  onSuccess();
}