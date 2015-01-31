describe('auth', function() {
  function createExpirationDate(date) {
    date = date || new Date();

    return date.getUTCFullYear() + "-" + date.getUTCMonth() + "-" + date.getUTCDate() + " " + date.getUTCHours() + ":" + date.getUTCMinutes() + ":" + date.getUTCSeconds() + " GMT";
  }

  var session = {canonicalUsername: 'antman', accessToken: 'Xcd4r234234fdfa_dfsadf3', encryptedRefreshToken: 'sdfsdfds724dfsdf234dsf', expirationDate: createExpirationDate()}
    , newSession = {canonicalUsername: 'antman', accessToken: 'XASDFasdfd4r234234fdfa_dfsdsadfsdf3', encryptedRefreshToken: '4334fsdfdSDF234', expirationDate: createExpirationDate()}

  var auth;

  before(function() {
    auth = require('com.timflapper.spotify.auth');
  });

  beforeEach(function() {
    this.callback = sinon.spy();
    this.onRequest = sinon.spy();
  });

  afterEach(function() {
    restoreMockExec();
  });

  describe('#authenticate', function() {
    describe('succesful authentication', function() {
      beforeEach(function() {
        mockExec(1, session, this.onRequest);
      });

      describe('without scope', function() {
        beforeEach(function() {
          spotify.authenticate('test-scheme', 'aRandomClientId1234', 'code', 'http://tok.en', this.callback);
        });

        it('should send the "streaming" scope to native', function() {
          expect(this.onRequest).to.have.been.calledWith([
            'SpotifyPlugin', 'authenticate', ['test-scheme', 'aRandomClientId1234', 'code', 'http://tok.en', ['streaming']]
          ]);
        });

        it('should call callback with the session', function() {
          expect(this.callback).to.have.been.calledWith(null, session);
        })
      });

      describe('with scope', function() {
        beforeEach(function() {
          spotify.authenticate('test-scheme', 'aRandomClientId1234', 'code', 'http://tok.en', ['somescope'], this.callback);
        });

        it('should send the "somescope" scope to native', function() {
          expect(this.onRequest).to.have.been.calledWith([
            'SpotifyPlugin', 'authenticate', ['test-scheme', 'aRandomClientId1234', 'code', 'http://tok.en', ['somescope']]
          ]);
        });

        it('should call callback with the session', function() {
          expect(this.callback).to.have.been.calledWith(null, session);
        });
      });
    });

    describe('failed authentication', function() {
      beforeEach(function() {
        mockExec(9, 'Login to Spotify failed because of invalid credentials.', this.onRequest);
        spotify.authenticate('test-scheme', 'aRandomClientId1234', 'code', 'http://tok.en', this.callback);
      });

      it('should send back "Login to Spotify failed because of invalid credentials."', function() {
        expect(this.callback).to.have.been.calledWith('Login to Spotify failed because of invalid credentials.');
      });
    });
  });

  describe('#isSessionValid', function() {
    describe('session is valid', function() {
      beforeEach(function() {
        mockExec(1, true, this.onRequest);
        spotify.isSessionValid(session, this.callback);
      });

      it('should send the session to native', function() {
          expect(this.onRequest).to.have.been.calledWith([
            'SpotifyPlugin', 'isSessionValid', [session]
          ]);
      });

      it('should send back true', function() {
        expect(this.callback).to.have.been.calledWith(null, true);
      });
    });

    describe('session is not valid', function() {
      beforeEach(function() {
        mockExec(1, false, this.onRequest);
        spotify.isSessionValid(session, this.callback);
      });

      it('should send the session to native', function() {
          expect(this.onRequest).to.have.been.calledWith([
            'SpotifyPlugin', 'isSessionValid', [session]
          ]);
      });

      it('should send back true', function() {
        expect(this.callback).to.have.been.calledWith(null, false);
      });
    });
  });

  describe('#renewSession', function() {
    describe('when session is still valid', function() {
      beforeEach(function() {
        sinon.stub(auth, "isSessionValid", function(session, callback) {
          callback(null, true);
        });
        mockExec(1, session, this.onRequest);
        spotify.renewSession(session, 'http://tok.en/refresh', this.callback);
      });

      afterEach(function() {
        auth.isSessionValid.restore();
      });

      it('should not send the session and tokenRefreshURL to native', function() {
        expect(this.onRequest).to.not.have.been.calledWith([
          'SpotifyPlugin', 'renewSession', [session, 'http://tok.en/refresh']
        ]);
      });

      it('should send back the same session', function() {
        expect(this.callback).to.have.been.calledWith(null, session);
      });
    });

    describe('when session is invalid', function() {
      beforeEach(function() {
        sinon.stub(auth, "isSessionValid", function(session, callback) {
          callback(null, false);
        });
        mockExec(1, newSession, this.onRequest);
        spotify.renewSession(session, 'http://tok.en/refresh', this.callback);
      });

      afterEach(function() {
        auth.isSessionValid.restore();
      });

      it('should send the session and tokenRefreshURL to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'renewSession', [session, 'http://tok.en/refresh']
        ]);
      });

      it('should send back a different session', function() {
        expect(this.callback).to.have.been.calledWith(null, newSession);
      });
    });


    describe('force renew session', function() {
      beforeEach(function() {
        mockExec(1, newSession, this.onRequest);
        spotify.renewSession(session, 'http://tok.en/refresh', true, this.callback);
      });

      it('should send the session and tokenRefreshURL to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'renewSession', [session, 'http://tok.en/refresh']
        ]);
      });

      it('should send back a different session', function() {
        expect(this.callback).to.have.been.calledWith(null, newSession);
      });
    });
  });
});
