'use strict';

var should = require('should');

var world = require('./lib/world')
  , session = world.session
, spotify = world.spotify
, createAudioPlayer = world.createAudioPlayer;

var player = undefined;

beforeEach(function() {
  player = createAudioPlayer();
});

describe('audioPlayer.login()', function() {
  it('should login the user with callback', function(done) {
    player.login(session, callback);
    
    function callback(error) {      
      (error === null).should.be.true;
      done();
    }
  });

  it('and with event', function(done) {    
    player.addEventListener('login', listener);
    player.login(session);
    
    function listener(error) {
      player.removeEventListener('login', listener);
      (error === undefined).should.be.true;
      done();
    }    
  });
});

describe('audioPlayer.playURI()', function() {
  it('should not return an error', function(done) {
    player.playURI('spotify:track:0F0MA0ns8oXwGw66B2BSXm', callback);
    
    function callback(error) {
      (error === null).should.be.true;
      done();
    }
  });
});

describe('audioPlayer.seekToOffset()', function() {
  it('should not return an error', function(done) {  
    player.seekToOffset(25.0, callback);
  
    function callback(error) {
      (error === null).should.be.true;
      done();
    }
  });
});

describe('audioPlayer.getIsPlaying()', function() {
  it('should return a boolean value', function(done) {  
    player.getIsPlaying(callback);
  
    function callback(error, status) {
      (error === null).should.be.true;
      
      status.should.be.type('boolean');
      
      done();
    }
  });  
});

describe('audioPlayer.setIsPlaying()', function() {
  it('should not return an error', function(done) {
    var player = createAudioPlayer();
  
    player.setIsPlaying(true, callback);
  
    function callback(error) {
      (error === null).should.be.true;
      done();
    }
  });  
});

describe('audioPlayer.getVolume()', function() {
  it('should return a number between 0.0 and 1.0', function(done) {  
    player.getVolume(callback);
  
    function callback(error, volume) {
      (error === null).should.be.true;
      
      volume.should.be.within(0, 1);
      
      done();
    }
  });    
});

describe('audioPlayer.setVolume()', function() {
  it('should not return an error', function(done) {
    player.setVolume(0.5, callback);
  
    function callback(error) {
      (error === null).should.be.true;
      done();
    }
  });   
});

describe('audioPlayer.getLoggedIn()', function() {
  it('should return a boolean value', function(done) {
    player.getLoggedIn(callback);
  
    function callback(error, status) {
      (error === null).should.be.true;
      
      status.should.be.type('boolean');
      
      done();
    }
  });   
});

describe('audioPlayer.getCurrentTrack()', function() {
  it('should return an object', function(done) {
    player.getCurrentTrack(callback);

    function callback(error, track) {
      (error === null).should.be.true;
     
      track.should.be.type('object')
            .and.have.keys('name', 'uri', 'album', 'artist', 'duration');
          
      done();
    }
  });
});

describe('audioPlayer.getCurrentPlaybackPosition()', function() {
  it('should return a number', function(done) {
    player.getCurrentPlaybackPosition(callback);

    function callback(error, offset) {
      (error === null).should.be.true;
     
      offset.should.be.a.Number;
          
      done();
    }      
  });
});