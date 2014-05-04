var defaultProps = {
  username: null,
  credential: null
};

function Session(data) {
  var session = this
    , props = {
      username: data.username,
      credential: data.credential
    };
  
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(session, prop, {
      get: function() { return props[prop] || defaultProps[prop]; },
      enumerable: true
    });
  });
}

module.exports = Session;