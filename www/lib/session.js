var exec = require('cordova/exec');

var defaultProps = {
  username: null,
  credential: null
};

function Session(props) {
  var session = this;
  
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(session, prop, {
      get: function() { return props[prop] || defaultProps[prop]; },
      enumerable: true
    });
  });
}

module.exports = Session;