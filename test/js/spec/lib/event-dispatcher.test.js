describe('EventDispatcher', function() {
  var EventDispatcher;

  beforeEach(function() {
    EventDispatcher = EventDispatcher || require('com.timflapper.spotify.event-dispatcher');

    this.eventCallback = sinon.spy();

    this.eventDispatcher = new EventDispatcher();
    this.eventDispatcher.addEventListener('test', this.eventCallback);
  });

  describe('listening to event', function() {
    beforeEach(function() {
      this.eventDispatcher.dispatchEvent('test');
    });

    it('should have been called', function() {
      expect(this.eventCallback).to.have.been.calledWith();
    });
  });

  describe('removing event', function() {
    beforeEach(function() {
      this.eventDispatcher.removeEventListener('test', this.eventCallback);
      this.eventDispatcher.dispatchEvent('test');
    });

    it('should not have been called', function() {
      expect(this.eventCallback).to.not.have.been.called;
    });
  });

});
