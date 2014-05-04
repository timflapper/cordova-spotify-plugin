var defaultProps = {
  username: null,
  credential: null
};

function Session(obj) {
  var self = this;

  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(self, prop, {
      value: obj[prop] || defaultProps[prop],
      enumerable: true
    });
  });
}

module.exports = Session;