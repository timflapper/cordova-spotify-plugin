function createExpirationDate(date) {
  date = date || new Date();

  return date.getUTCFullYear() + "-" + date.getUTCMonth() + "-" + date.getUTCDate() + " " + date.getUTCHours() + ":" + date.getUTCMinutes() + ":" + date.getUTCSeconds() + " GMT";
}

var session = {canonicalUsername: 'antman', accessToken: 'Xcd4r234234fdfa_dfsadf3', encryptedRefreshToken: 'sdfsdfds724dfsdf234dsf', expirationDate: createExpirationDate()};

function sharedRemoteTests() {
  it('should load the request', function() {
    expect(this.callback).to.have.been.calledWith(null, this.request.response);
  });
}

function sharedHooks() {
  beforeEach(function() {
    var self = this;
    this.server.respondWith(function(xhr, id) {
      var request = self.request;

      if (xhr.method === request.method && xhr.url === request.url) {
        self.requestHeaders = xhr.requestHeaders;
        self.requestBody = xhr.requestBody;
        xhr.respond(200, { 'Content-Type': 'application/json' }, JSON.stringify(request.response));
      }
    });
  });
}

describe('remote', function() {
  var remote;

  before(function() { remote = require('com.timflapper.spotify.remote'); });

  beforeEach(function() {
    this.callback = sinon.spy();
    this.server = sinon.fakeServer.create();
  });

  afterEach(function () { this.server.restore(); });

  describe('empty options', function() {
    it('should throw an error', function() {
      var subject = function() { remote(); }

      expect(subject).to.throw('This method requires two arguments (options, callback)');
    });
  });

  describe('basic options', function() {
    sharedHooks();

    beforeEach(function() {
      this.request = { method: 'GET', url: 'https://api.spotify.com/v1/bla', response: {test: 'get'} };
      remote({uri: '/bla'}, this.callback);
      this.server.respond();
    });

    sharedRemoteTests();
  });

  describe('different method', function() {
    sharedHooks();

    beforeEach(function() {
      this.request = { method: 'POST', url: 'https://api.spotify.com/v1/blabla', response: {test: 'post'} };
      remote({uri: '/blabla', method: 'post'}, this.callback);
      this.server.respond();
    });

    sharedRemoteTests();
  });

  describe('url instead of uri', function() {
    sharedHooks();

    beforeEach(function() {
      this.request = { method: 'GET', url: 'http://google.com/blabla', response: {test: 'url'} };
      remote({url: 'http://google.com/blabla'}, this.callback);
      this.server.respond();
    });

    sharedRemoteTests();
  });

  describe('with session', function() {
    sharedHooks();

    beforeEach(function() {
      this.request = { method: 'GET', url: 'https://api.spotify.com/v1/session', response: {test: 'session'} };
      remote({uri: '/session', session: session}, this.callback);
      this.server.respond();
    });

    sharedRemoteTests();

    it('should send the Bearer token as part of the request', function() {
      expect(this.requestHeaders).to.have.property('Authorization', 'Bearer '+session.accessToken);
    });
  });

  describe('with data', function() {
    sharedHooks();

    beforeEach(function() {
      this.request = { method: 'POST', url: 'https://api.spotify.com/v1/data', response: {test: 'data'} };
      remote({uri: '/data', method: 'POST', data: 'DATA'}, this.callback);
      this.server.respond();
    });

    sharedRemoteTests();

    it('should send the Bearer token as part of the request', function() {
      expect(this.requestBody).to.equal('DATA');
    });
  });

  describe('pagination', function() {
    beforeEach(function() {
      this.nextUrl = 'http://next.url';
      this.prevUrl ='http://previous.url';
    });

    describe('on root object', function() {
      beforeEach(function() {
        this.responseBody = { next: this.nextUrl, prev: this.prevUrl };
        this.findPaginated = function(data) { return data; };
      });

      shared.paginatedTests();
    });

    describe('artists', function() {
      beforeEach(function() {
        this.responseBody = { artists: { next: this.nextUrl, prev: this.prevUrl } };
        this.findPaginated = function(data) { return data.artists; };
      });

      shared.paginatedTests();
    });

    describe('albums', function() {
      beforeEach(function() {
        this.responseBody = { albums: { next: this.nextUrl, prev: this.prevUrl } };
        this.findPaginated = function(data) { return data.albums; };
      });

      shared.paginatedTests();
    });

    describe('tracks', function() {
      beforeEach(function() {
        this.responseBody = { tracks: { next: this.nextUrl, prev: this.prevUrl } };
        this.findPaginated = function(data) { return data.tracks; };
      });

      shared.paginatedTests();
    });

    describe('tracks in an array of albums', function() {
      beforeEach(function() {
        var self = this;
        this.responseBody = { albums: [{ tracks: { next: this.nextUrl, prev: this.prevUrl } }, { tracks: {next: null, prev: null} }, { tracks: { next: this.nextUrl, prev: this.prevUrl } }] };
      });

      describe('first album', function() {
        beforeEach(function() { this.findPaginated = function(data) { return data.albums[0].tracks; }; });
        shared.paginatedTests();
      });

      describe('second album', function() {
        beforeEach(function() { this.findPaginated = function(data) { return data.albums[1].tracks; }; });

        shared.hooksForPagination();

        it('should not modify the previous and next objects', function(done) {
          var findPaginated = this.findPaginated;
          remote({uri: '/paginate'}, function(err, data) {
            data = findPaginated(data);
            expect(data.next).to.be.null;
            expect(data.prev).to.be.null;
            done();
          });
          this.server.respond();
        });
      });

      describe('third album', function() {
        beforeEach(function() { this.findPaginated = function(data) { return data.albums[2].tracks; }; });
        shared.paginatedTests();
      });
    });
  });
});
