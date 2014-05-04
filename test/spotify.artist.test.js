'use strict';

var should = require('should');

var world = require('./lib/world')
  , session = world.session
  , spotify = world.spotify;

describe('spotify.Artist()', function() {
  it('should return an Artist', function(done) {
    spotify.Artist('spotify:artist:55tif8708yyDQlSjh3Trdu', session, callback);
    
    function callback(error, artist) {
      (error === null).should.be.true;
      
      artist.should.be.an.instanceOf(spotify.Artist);
      
      done();
    }
  });
});