module.exports = function(driver) {

  before(function() {
    return driver
      .elementById('loginPlayerLink')
        .click()
      .waitForConditionInBrowser("document.getElementById('loginPlayerStatus').style.display !== 'none';", 30000)
  });

  it('should have a logged in player', function() {
    return driver
      .elementById('loginPlayerStatus')
        .text()
          .should.eventually.equal('success');
  });

  context('playing a song', function() {
    before(function() {
      return driver
        .elementById('playSongLink')
          .click()
        .waitForConditionInBrowser("document.getElementById('playSongStatus').style.display !== 'none';", 30000);
    });

    it('should be able to play a song', function() {
      return driver
        .elementById('playSongStatus')
          .text()
            .should.eventually.equal('success');
    });

    context('volume', function() {
      before(function() {
        return driver
          .elementById('muteLink')
            .click()
          .waitForConditionInBrowser("document.getElementById('muteStatus').style.display !== 'none';", 30000)
      });

      it('should be able to change the volume', function() {
        return driver
          .elementById('muteStatus')
            .text()
              .should.eventually.equal('success');
      });
    });

    context('playback position', function() {
      before(function() {
        return driver
          .sleep(5000)
          .elementById('playbackPositionLink')
            .click()
          .waitForConditionInBrowser("document.getElementById('playbackPosition').style.display !== 'none';", 30000)
      });

      it('should be able to get the playback position', function() {
        return driver
          .elementById('playbackPosition')
            .text()
              .should.eventually.match(/^\d+\.\d+$/);
      });
    })
  });

};
