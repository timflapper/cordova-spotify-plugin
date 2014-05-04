var should = require('should');

var spotify = require('../www/spotify');

describe('spotify.exec', function() {
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

describe('spotify.authenticate', function() {
  it('should return a spotify.Session object with scopes ["login"]', function(done) {
    
    spotify.authenticate( 'someClientId', 'http://localhost:1234/swap', ['login'], onResult);
    
    function onResult(error, result) {
      (error === null).should.be.true;
      
      result.should.be.an.instanceOf(spotify.Session);
      done();
    }    
  });
  
  it('should return a spotify.Session object without scopes', function(done) {
    
    spotify.authenticate( 'someClientId', 'http://localhost:1234/swap', onResult);
    
    function onResult(error, result) {
      (error === null).should.be.true;
      
      result.should.be.an.instanceOf(spotify.Session);
      done();
    }    
  });
});