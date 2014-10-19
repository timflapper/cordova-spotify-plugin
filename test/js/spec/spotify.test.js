describe('core', function() {
  describe('#createAudioPlayer', function() {
    var AudioPlayer;

    before(function() {
      AudioPlayer = require('com.timflapper.spotify.audio-player');
    });

    it('should return an AudioPlayer object', function() {
      var player = spotify.createAudioPlayer('amazingCompany', 'amazingApp');

      expect(player).to.be.an.instanceof(AudioPlayer);
    });
  });
});
