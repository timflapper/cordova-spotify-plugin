(function(window) {

var shared = window.shared = window.shared || {};

shared.hooksForPagination = function() {
  beforeEach(function() {
    var body = JSON.stringify(this.responseBody);
    this.server.respondWith('GET', 'https://api.spotify.com/v1/paginate',
      [200, { 'Content-Type': 'application/json' },
        body]);
  });
}

shared.paginatedTests = function() {
  var remote;

  before(function() { remote = require('com.timflapper.spotify.remote'); });

  beforeEach(function() {
    this.server.respondWith('GET', this.prevUrl,
      [200, { 'Content-Type': 'application/json' },
        JSON.stringify({page: 'previous'})]);

    this.server.respondWith('GET', this.nextUrl,
      [200, { 'Content-Type': 'application/json' },
        JSON.stringify({page: 'next'})]);
  });

  shared.hooksForPagination();

  it('should modify the previous and next objects', function(done) {
    var findPaginated = this.findPaginated;
    remote({uri: '/paginate'}, function(err, data) {
      data = findPaginated(data);
      expect(data.next).to.be.a('function');
      expect(data.prev).to.be.a('function');
      done();
    });
    this.server.respond();
  });

  it('should be calling the correct previous url', function(done) {
    var self = this;
    var findPaginated = this.findPaginated;

    remote({uri: '/paginate'}, function(err, data) {
      data = findPaginated(data);
      data.prev(self.callback);
      self.server.respond();
      expect(self.callback).to.have.been.calledWith(null, {page: 'previous'});
      done();
    });
    this.server.respond();
  });

  it('should be calling the correct next url', function(done) {
    var self = this;
    var findPaginated = this.findPaginated;

    remote({uri: '/paginate'}, function(err, data) {
      data = findPaginated(data);
      data.next(self.callback);
      self.server.respond();
      expect(self.callback).to.have.been.calledWith(null, {page: 'next'});
      done();
    });
    this.server.respond();
  });
}

})(window);
