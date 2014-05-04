'use strict';

var should = require('should');

var world = require('./lib/world')
  , session = world.session
  , spotify = world.spotify;

describe('spotify.exec()', function() {
  it('should call the callback function with a result if the action is correct', function(done) {    
    spotify.exec('doTestAction', [], function(error, result) {
      (error === null).should.be.true;
      result.should.be.an.instanceOf(Array).and.eql([true]);
      
      done();
    });
  });

  it('should call the callback function with an error if the action is incorrect', function(done) {    
    spotify.exec('veryMuchIncorrectAction', [], function(error, result) {
      error.should.be.an.instanceOf(Error);
      (result === undefined).should.be.true;
      done();
    });
  });
  
  it('should throw error when callback is omitted', function(done) {
    (function() {
      spotify.exec('doTestAction', []);      
    }).should.throw();
          
    done(); 
  });
});

describe('spotify.authenticate()', function() {
  it('should return a spotify.Session object with scopes ["login"]', function(done) {
    
    spotify.authenticate( 'someClientId', 'http://localhost:1234/swap', ['login'], onResult);
    
    function onResult(error, result) {
      (error === null).should.be.true;
      
      result.should.be.an.instanceOf(spotify.Session);
      done();
    }    
  });
  
  it('should return a spotify.Session object without scopes', function(done) {
    
    spotify.authenticate( 'someClientId', 'http://localhost:1234/swap', callback);
    
    function callback(error, result) {
      (error === null).should.be.true;
      
      result.should.be.an.instanceOf(spotify.Session);
      done();
    }    
  });
});

describe('spotify.search()', function() {  
  it('Should return an array with all parameters filled', function(done) { 
    spotify.search('Ben Folds', 'artist', 20, session, callback);
    
    function callback(error, result) {
      (error === null).should.be.true;
      
      result.should.be.an.instanceOf(Array);
      done();
    }
  });
  
  it('And should return an array without offset', function(done) {
    spotify.search('Ben Folds', 'artist', session, callback);
    
    function callback(error, result) {
      (error === null).should.be.true;
      
      result.should.be.an.instanceOf(Array);
      done();
    }    
  });
});

describe('spotify.getObjectFromURI()', function() {
  it('should find an artist', function(done) {
      
    spotify.getObjectFromURI('spotify:artist:55tif8708yyDQlSjh3Trdu', session, callback);
    
    function callback(error, obj) {
      (error === null).should.be.true;
      obj.should.be.an.instanceOf(spotify.Artist);
      
      done();
    }
  });

  it('should find an album', function(done) {
      
    spotify.getObjectFromURI('spotify:album:4FtOLTQqwnxpaABrJWYdBy', session, callback);
    
    function callback(error, obj) {
      (error === null).should.be.true;
      obj.should.be.an.instanceOf(spotify.Album);
      
      done();
    }
  });

  it('should find a track', function(done) {
    
    spotify.getObjectFromURI('spotify:track:0F0MA0ns8oXwGw66B2BSXm', session, callback);
  
    function callback(error, obj) {
      (error === null).should.be.true;
      obj.should.be.an.instanceOf(spotify.Track);
    
      done();
    }
  });

  it('should find a playlist', function(done) {
    
    spotify.getObjectFromURI('spotify:user:testuser:playlist:87234DfaD43fdsdfDx', session, callback);
  
    function callback(error, obj) {
      (error === null).should.be.true;
      obj.should.be.an.instanceOf(spotify.Playlist);
    
      done();
    }
  });

});

describe('spotify.getPlaylistsForUser()', function() {
  
  it('should return an array with all parameters filled', function(done) {
    spotify.getPlaylistsForUser('testUser', session, callback);
    
    function callback(error, result) {
      (error === null).should.be.true;
      
      result.should.be.an.instanceOf(Array);
      done();
    };
  });
});