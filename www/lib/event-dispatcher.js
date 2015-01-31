function EventDispatcher() {
  var self = this
    , events = {};

  this.dispatchEvent = function(event, args) {
    var i, listeners;

    args = args || [];

    if ((event in events) === false) {
      if (event === 'error')
        throw new Error(args[0]);

      if (event === 'message')
        alert(args[0]);

      return;
    }

    listeners = events[event];

    if (listeners.length === 1) {
      listeners[0].apply(self, args);
    } else if (listeners.length > 1) {
      listeners = events[event].slice();

      listeners.forEach(function(item) {
        item.apply(self, args);
      });
    }
  };

  this.addEventListener = function(event, listener) {
    if (typeof listener !== 'function')
      throw new Error('listener must be a function');

    if ((event in events) === false)
      events[event] = [];

    events[event].push(listener);
  };

  this.removeEventListener = function(event, listener) {
    if (typeof listener !== 'function')
      throw new Error('listener must be a function');

    if ((event in events) === false)
      return;

    var updatedArray = [];

    events[event].forEach(function(func, index) {
      if (func === listener)
        return;

      updatedArray.push(func);
    });

    events[event] = updatedArray;
  };
}
module.exports = EventDispatcher;
