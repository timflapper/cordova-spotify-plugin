describe('AudioPlayer', function() {
  function createExpirationDate(date) {
    date = date || new Date();

    return date.getUTCFullYear() + "-" + date.getUTCMonth() + "-" + date.getUTCDate() + " " + date.getUTCHours() + ":" + date.getUTCMinutes() + ":" + date.getUTCSeconds() + " GMT";
  }

  var session = {canonicalUsername: 'antman', accessToken: 'Xcd4r234234fdfa_dfsadf3', encryptedRefreshToken: 'sdfsdfds724dfsdf234dsf', expirationDate: createExpirationDate()};

  beforeEach(function() {
    this.player = spotify.createAudioPlayer('randomClientId');
    this.callback = sinon.spy();
    this.onRequest = sinon.spy();
  });

  afterEach(function() {
    restoreMockExec();
  });

  describe('spotify.createAudioPlayer', function() {
    var EventDispatcher;

    before(function() {
      EventDispatcher = require('com.timflapper.spotify.event-dispatcher');
    });

    it('should be an EventDispatcher', function() {
      expect(this.player).to.be.an.instanceof(EventDispatcher);
    });
  });

  describe('#login', function() {
    describe('with callback', function() {
      beforeEach(function() {
        this.eventCallback = sinon.spy();
        this.onMessageResult = sinon.spy();
        this.player.addEventListener(spotify.AudioPlayer.EVENT_MESSAGE, this.eventCallback);
        mockExec(1, 3, this.onRequest);
        mockExec(1, {type: spotify.AudioPlayer.EVENT_MESSAGE, args: ['Test Message']}, this.onMessageResult);
        this.player.login(session, this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'createAudioPlayerAndLogin', ['randomClientId', session]
        ]);
      });

      it('should login successfully', function() {
        expect(this.callback).to.have.been.calledWith(null);
      });

      it('should subscribe to native events', function() {
        expect(this.onMessageResult).to.have.been.calledWith([
          'SpotifyPlugin', 'addAudioPlayerEventListener', [3]
        ]);
      });

      it('should be able to dispatch events', function() {
          expect(this.eventCallback).to.have.been.calledWith('Test Message');
      });
    });

    describe('without callback', function() {
      beforeEach(function() {
        this.loginEventCallback = sinon.spy();
        this.messageEventCallback = sinon.spy();
        this.onMessageResult = sinon.spy();
        this.player.addEventListener(spotify.AudioPlayer.EVENT_LOGIN, this.loginEventCallback);
        this.player.addEventListener(spotify.AudioPlayer.EVENT_MESSAGE, this.messageEventCallback);
        mockExec(1, 3, this.onRequest);
        mockExec(1, {type: spotify.AudioPlayer.EVENT_MESSAGE, args: ['Test Message']}, this.onMessageResult);
        this.player.login(session);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'createAudioPlayerAndLogin', ['randomClientId', session]
        ]);
      });

      it('should login successfully', function() {
        expect(this.loginEventCallback).to.have.been.calledWith();
      });

      it('should subscribe to native events', function() {
        expect(this.onMessageResult).to.have.been.calledWith([
          'SpotifyPlugin', 'addAudioPlayerEventListener', [3]
        ]);
      });

      it('should be able to dispatch events', function() {
          expect(this.messageEventCallback).to.have.been.calledWith('Test Message');
      });
    });
  });

  describe('#logout', function() {
    beforeEach(function() {
      this.eventCallback = sinon.spy();
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
    });

    describe('with callback', function() {
      beforeEach(function() {
        this.player.logout(this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'audioPlayerLogout', [1]
        ]);
      });

      it('should logout successfully', function() {
        expect(this.callback).to.have.been.calledWith(null);
      });
    });

    describe('without callback', function() {
      beforeEach(function() {
        this.player.addEventListener(spotify.AudioPlayer.EVENT_LOGOUT, this.eventCallback);
        this.player.logout();
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'audioPlayerLogout', [1]
        ]);
      });

      it('should logout successfully', function() {
        expect(this.eventCallback).to.have.been.calledWith();
      });
    });
  });

  describe('#play', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
    });

    describe('playing single object', function() {
      beforeEach(function() {
        this.player.play('spotify:track:3XpXhVtZwqh2eM5d9ieXT5', this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'play', [1, 'spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 0]
        ]);
      });

      it('should play successfully', function() {
        expect(this.callback).to.have.been.calledWith(null);
      });
    });

    describe('playing single object with index', function() {
      beforeEach(function() {
        this.player.play('spotify:album:36k5aXpxffjVGcNce12GLZ', 4, this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'play', [1, 'spotify:album:36k5aXpxffjVGcNce12GLZ', 4]
        ]);
      });

      it('should play successfully', function() {
        expect(this.callback).to.have.been.calledWith(null);
      });
    });

    describe('playing array of objects', function() {
      beforeEach(function() {
        this.player.play(['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'play', [1, ['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], 0]
        ]);
      });

      it('should play successfully', function() {
        expect(this.callback).to.have.been.calledWith(null);
      });
    });

    describe('playing array of objects with index', function() {
      beforeEach(function() {
        this.player.play(['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], 1, this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'play', [1, ['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], 1]
        ]);
      });

      it('should play successfully', function() {
        expect(this.callback).to.have.been.calledWith(null);
      });
    });
  });

  describe('#setURIs', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.setURIs(['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'setURIs', [1, ['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs']]
      ]);
    });

    it('should setURIs successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#playURIsFromIndex', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.playURIsFromIndex(65, this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'playURIsFromIndex', [1, 65]
      ]);
    });

    it('should playURIsFromIndex successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#queue', function() {
    describe('without clearQueue', function() {
      beforeEach(function() {
        mockExec(1, null, this.onRequest);
        this.player.id = 1;
        this.player.queue(['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'queue', [1, ['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], false]
        ]);
      });

      it('should queue successfully', function() {
        expect(this.callback).to.have.been.calledWith(null);
      });
    });

    describe('with clearQueue', function() {
      beforeEach(function() {
        mockExec(1, null, this.onRequest);
        this.player.id = 1;
        this.player.queue(['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], true, this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'queue', [1, ['spotify:track:3XpXhVtZwqh2eM5d9ieXT5', 'spotify:track:0IqKeD8ZSP72KbGYyzEcAs'], true]
        ]);
      });

      it('should queue successfully', function() {
        expect(this.callback).to.have.been.calledWith(null);
      });
    });
  });

  describe('#queuePlay', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.queuePlay(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'queuePlay', [1]
      ]);
    });

    it('should queuePlay successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#queueClear', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.queueClear(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'queueClear', [1]
      ]);
    });

    it('should queuePlay successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#stop', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.stop(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'stop', [1]
      ]);
    });

    it('should stop successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#skipNext', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.skipNext(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'skipNext', [1]
      ]);
    });

    it('should skipNext successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#skipPrevious', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.skipPrevious(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'skipPrevious', [1]
      ]);
    });

    it('should skipPrevious successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#seekToOffset', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.seekToOffset(3, this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'seekToOffset', [1, 3]
      ]);
    });

    it('should seekToOffset successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#getIsPlaying', function() {
    beforeEach(function() {
      mockExec(1, true, this.onRequest);
      this.player.id = 1;
      this.player.getIsPlaying(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getIsPlaying', [1]
      ]);
    });

    it('should getIsPlaying successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, true);
    });
  });

  describe('#setIsPlaying', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.setIsPlaying(true, this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'setIsPlaying', [1, true]
      ]);
    });

    it('should setIsPlaying successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#getVolume', function() {
    beforeEach(function() {
      mockExec(1, 0.5, this.onRequest);
      this.player.id = 1;
      this.player.getVolume(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getVolume', [1]
      ]);
    });

    it('should getVolume successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, 0.5);
    });
  });

  describe('#setVolume', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.setVolume(0.75, this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'setVolume', [1, 0.75]
      ]);
    });

    it('should setVolume successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#getRepeat', function() {
    beforeEach(function() {
      mockExec(1, true, this.onRequest);
      this.player.id = 1;
      this.player.getRepeat(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getRepeat', [1]
      ]);
    });

    it('should getRepeat successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, true);
    });
  });

  describe('#setRepeat', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.setRepeat(true, this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'setRepeat', [1, true]
      ]);
    });

    it('should setRepeat successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#getShuffle', function() {
    beforeEach(function() {
      mockExec(1, true, this.onRequest);
      this.player.id = 1;
      this.player.getShuffle(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getShuffle', [1]
      ]);
    });

    it('should getShuffle successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, true);
    });
  });

  describe('#setShuffle', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.setShuffle(true, this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'setShuffle', [1, true]
      ]);
    });

    it('should setShuffle successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#getDiskCacheSizeLimit', function() {
    beforeEach(function() {
      mockExec(1, 3000, this.onRequest);
      this.player.id = 1;
      this.player.getDiskCacheSizeLimit(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getDiskCacheSizeLimit', [1]
      ]);
    });

    it('should getDiskCacheSizeLimit successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, 3000);
    });
  });

  describe('#setDiskCacheSizeLimit', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.setDiskCacheSizeLimit(2524, this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'setDiskCacheSizeLimit', [1, 2524]
      ]);
    });

    it('should setDiskCacheSizeLimit successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#getTargetBitrate', function() {
    beforeEach(function() {
      mockExec(1, 2, this.onRequest);
      this.player.id = 1;
      this.player.getTargetBitrate(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getTargetBitrate', [1]
      ]);
    });

    it('should getTargetBitrate successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, 2);
    });
  });

  describe('#setTargetBitrate', function() {
    beforeEach(function() {
      mockExec(1, null, this.onRequest);
      this.player.id = 1;
      this.player.setTargetBitrate(1, this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'setTargetBitrate', [1, 1]
      ]);
    });

    it('should setTargetBitrate successfully', function() {
      expect(this.callback).to.have.been.calledWith(null);
    });
  });

  describe('#getLoggedIn', function() {
    beforeEach(function() {
      mockExec(1, false, this.onRequest);
      this.player.id = 1;
      this.player.getLoggedIn(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getLoggedIn', [1]
      ]);
    });

    it('should getLoggedIn successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, false);
    });
  });

  describe('#getQueueSize', function() {
    beforeEach(function() {
      mockExec(1, 25, this.onRequest);
      this.player.id = 1;
      this.player.getQueueSize(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getQueueSize', [1]
      ]);
    });

    it('should getQueueSize successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, 25);
    });
  });

  describe('#getTrackListSize', function() {
    beforeEach(function() {
      mockExec(1, 5, this.onRequest);
      this.player.id = 1;
      this.player.getTrackListSize(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getTrackListSize', [1]
      ]);
    });

    it('should getQueueSize successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, 5);
    });
  });

  describe('#getTrackMetadata', function() {
    beforeEach(function() {
      this.currentTrack = {
        name: 'Song 2',
        uri: 'spotify:track:3GfOAdcoc3X5GPiiXmpBjK',
        artist: {
          name: 'Blur',
          uri: 'spotify:artist:7MhMgCo0Bl0Kukl93PZbYS',
        },
        album: {
          name: 'Blur: The Best Of',
          uri: 'spotify:album:1bgkxe4t0HNeLn9rhrx79x',
        },
        duration: 122
      };

      this.player.id = 1;

      mockExec(1, this.currentTrack, this.onRequest);
    });

    describe('current track', function() {
      beforeEach(function() {
        this.player.getTrackMetadata(this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'getTrackMetadata', [1]
        ]);
      });

      it('should getTrackMetadata successfully', function() {
        expect(this.callback).to.have.been.calledWith(null, this.currentTrack);
      });
    });

    describe('with trackID (absolute)', function() {
      beforeEach(function() {
        this.player.getTrackMetadata(3, this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'getTrackMetadata', [1, 3]
        ]);
      });

      it('should getTrackMetadata successfully', function() {
        expect(this.callback).to.have.been.calledWith(null, this.currentTrack);
      });
    });

    describe('with trackID (relative)', function() {
      beforeEach(function() {
        this.player.getTrackMetadata(2, true, this.callback);
      });

      it('should send the correct parameters to native', function() {
        expect(this.onRequest).to.have.been.calledWith([
          'SpotifyPlugin', 'getTrackMetadata', [1, 2, true]
        ]);
      });

      it('should getTrackMetadata successfully', function() {
        expect(this.callback).to.have.been.calledWith(null, this.currentTrack);
      });
    });
  });

  describe('#getCurrentPlaybackPosition', function() {
    beforeEach(function() {
      mockExec(1, 139, this.onRequest);
      this.player.id = 1;
      this.player.getCurrentPlaybackPosition(this.callback);
    });

    it('should send the correct parameters to native', function() {
      expect(this.onRequest).to.have.been.calledWith([
        'SpotifyPlugin', 'getCurrentPlaybackPosition', [1]
      ]);
    });

    it('should getCurrentPlaybackPosition successfully', function() {
      expect(this.callback).to.have.been.calledWith(null, 139);
    });
  });
});
