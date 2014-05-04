'use strict';

var spotify = exports.spotify = require('../../www/spotify');

exports.session = new spotify.Session({
  username: 'testuser',
  credential: 's0m3th1ngR4nd0mL1k3'
});


exports.createPlaylist = function() {
  return new spotify.Playlist({
    name: 'My Amazing Playlist',
    version: 1,
    uri: 'spotify:user:testuser:playlist:s0M3ranD0MiD',
    collaborative: false,
    creator: 'testuser',
    tracks: [],
    dateModified: new Date()    
  });
};

exports.createAudioPlayer = function() {
  return new spotify.AudioPlayer('my-company', 'my-app');
}