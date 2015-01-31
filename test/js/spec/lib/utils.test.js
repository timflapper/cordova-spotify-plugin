describe('utils', function() {
  var utils;

  before(function() {
    utils = require('com.timflapper.spotify.utils');
  });

  describe('#exec', function() {
    context('no parameters', function() {
      it('should call xhr and return a message', function() {
        var onRequest = sinon.spy()
          , callback = sinon.spy();

        mockExec(1, true, onRequest);
        utils.exec('test', callback);

        expect(onRequest).to.have.been.calledWith(['SpotifyPlugin', 'test', []]);

        expect(callback).to.have.been.calledWith(null, true);
      });
    });

    context('with parameters', function() {
      it('should call xhr and return a message', function() {
        var onRequest = sinon.spy()
          , callback = sinon.spy();

        mockExec(1, 'message', onRequest);
        utils.exec('test', 'something', callback);

        expect(onRequest).to.have.been.calledWith(['SpotifyPlugin', 'test', ['something']]);

        expect(callback).to.have.been.calledWith(null, 'message');
      });
    });
  });
});
