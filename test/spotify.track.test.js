'use strict';

var should = require('should');

var world = require('./lib/world')
  , session = world.session
  , spotify = world.spotify;

describe('spotify.Track()', function() {
  it('should return a Track', function(done) {
    spotify.Artist('....', session, callback);
    
    function callback(error, track) {
      (error === null).should.be.true;
      
      track.should.be.an.instanceOf(spotify.Track);
      
      done();
    }
  });
});