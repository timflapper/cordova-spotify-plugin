'use strict';

var should = require('should');

var world = require('./lib/world')
  , session = world.session
  , spotify = world.spotify;

describe('spotify.Album()', function() {
  it('should return an Album', function(done) {
    spotify.Album('spotify:album:4FtOLTQqwnxpaABrJWYdBy', session, callback);
    
    function callback(error, album) {
      (error === null).should.be.true;
      
      album.should.be.an.instanceOf(spotify.Album);
      
      done();
    }
  });
});