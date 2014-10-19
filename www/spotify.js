
var AudioPlayer = require('./audio-player');

var spotify = exports;

spotify.createAudioPlayer = function(companyName, appName) {
  return new AudioPlayer(companyName, appName);
};

/**
 *
 * TODO:
 * - Finish writing specs
 * - Optimize WebAPI calling stuff*
 * - Custom callback URI as variable for install
 * - Update README.md
 * - Update API wiki
 *
 **/
