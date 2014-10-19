
var AudioPlayer = require('./audio-player');

module.exports = {
  createAudioPlayer: function(companyName, appName) {
    return new AudioPlayer(companyName, appName);
  }
};

/**
 *
 * TODO:
 * - Finish writing specs
 * - Custom callback URI as variable for install
 * - Update README.md
 * - Update API wiki
 *
 **/
