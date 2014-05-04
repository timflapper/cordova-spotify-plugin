var defaultProps = {
  imageURL: null,
  imageSize: null,
  aspect: null
};

function Image(data) {
  var image = this
    , props = {
      imageURL: data.imageURL,
      imageSize: data.imageSize,
      aspect: data.aspect
    };
  
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(image, prop, {
      get: function() { return props[prop] || defaultProps[prop]; },
      enumerable: true
    });
  });
}

module.exports = Image;