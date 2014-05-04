var defaultProps = {
  name: null,
  uri: null,
  sharingURL: null,
  genres: null,
  images: null,
  smallestImage: null,
  largestImage: null,
  popularity: null
};

function Artist(obj) {    
  var self = this;
    
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(self, prop, {
      value: obj[prop] || defaultProps[prop],
      enumerable: true
    });
  });

}

module.exports = Artist;