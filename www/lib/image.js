var spotify = undefined;

var defaultProps = {
  url: null,
  width: null,
  height: null
};

function Image(obj) {  
  var self = this;
    
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(self, prop, {
      value: obj[prop] || defaultProps[prop],
      enumerable: true
    });
  });
}

module.exports = function(parent) {
  spotify = parent;
  
  return Image;
}