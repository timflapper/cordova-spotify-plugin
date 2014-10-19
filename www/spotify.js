
var AudioPlayer = require('./audio-player');

var spotify = exports;

spotify.createAudioPlayer = function(companyName, appName) {
  return new AudioPlayer(companyName, appName);
};

/**
 *
 * TODO:
 * - Optimize pagination with remote
 * - Finish writing specs
 * - Custom callback URI as variable for install
 * - Update README.md
 * - Update API wiki
 *
 **/
