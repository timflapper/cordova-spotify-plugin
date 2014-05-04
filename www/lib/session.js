var spotify = undefined;

var defaultProps = {
  username: null,
  credential: null
};

function SessionData() {}
function Session(data) {
  var session = new SessionData()
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
  
  return session;
}

Session.prototype = {};
SessionData.prototype = Object.create(Session.prototype);
SessionData.prototype.constructor = SessionData;

module.exports = function(plugin) {
  spotify = plugin;
  
  return Session;
}