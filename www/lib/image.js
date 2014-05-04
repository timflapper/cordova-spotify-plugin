var defaultProps = {
  url: null,
  width: null,
  height: null
};

function ImageData() {}
function Image(data) {
  var image = new ImageData()
    , props = {
      url: data.imageURL,
      width: data.width,
      height: data.height
    };
    
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(image, prop, {
      get: function() { return props[prop] || defaultProps[prop]; },
      enumerable: true
    });
  });
  
  return image;
}

Image.prototype = {};
ImageData.prototype = Object.create(Image.prototype);
ImageData.prototype.constructor = ImageData;

module.exports = function(plugin) {
  spotify = plugin;
  
  return Image;
}