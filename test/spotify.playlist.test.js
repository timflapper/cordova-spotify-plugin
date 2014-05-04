'use strict';

var should = require('should');

var world = require('./lib/world')
  , session = world.session
  , createPlaylist = world.createPlaylist
  , spotify = world.spotify;


describe('playlist.setName', function() {
  it('should return a modified spotify.Playlist object', function(done) {
    var playlist = createPlaylist();
    
    playlist.setName('My amazing new name', session, callback);
    
    function callback(error, object) {
      (error === null).should.be.true;
      
      object.should.be.an.instanceOf(spotify.Playlist);
      object.name.should.eql('My amazing new name');
      done();
    }
  });
});

describe('playlist.setDescription', function() {
  it('should return a modified spotify.Playlist object', function(done) {
    var playlist = createPlaylist();
    
    playlist.setDescription('My amazing Playlist description', session, callback);
    
    function callback(error, object) {
      (error === null).should.be.true;
      
      object.should.be.an.instanceOf(spotify.Playlist);
      done();
    }
  });
});

describe('playlist.setCollaborative', function() {
  it('should return a modified spotify.Playlist object', function(done) {
    var playlist = createPlaylist();
    
    playlist.setCollaborative(true, session, callback);
    
    function callback(error, object) {
      (error === null).should.be.true;
      
      object.should.be.an.instanceOf(spotify.Playlist);
      object.collaborative.should.be.true;
      done();
    }
  });
});

describe('playlist.addTracks', function() {
  it('should return a modified spotify.Playlist object', function(done) {
    var playlist = createPlaylist();
    
    playlist.addTracks(['spotify:track:0F0MA0ns8oXwGw66B2BSXm'], session, callback);
    
    function callback(error, object) {
      var tracks = object.tracks;
      
      (error === null).should.be.true;
          
      object.should.be.an.instanceOf(spotify.Playlist);
            
      tracks.should.be.an.instanceOf(Array).and.have.lengthOf(1);
      
      done();
    }
  });
});

describe('playlist.delete', function() {
  it('should not return with an error', function(done) {
    var playlist = createPlaylist();
    
    playlist.delete(session, callback);
    
    function callback(error) {
      (error === null).should.be.true;

      done();
    }
  });
});
