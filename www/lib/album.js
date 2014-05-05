var spotify = undefined;

var defaultProps = {
  name: null,
  uri: null,
  sharingURL: null,
  externalIds: null,
  availableTerritories: null,
  artists: null,
  tracks: null,
  releaseDate: null,
  type: null,
  genres: null,
  covers: null,
  largestCover: null,
  smallestCover: null,
  popularity: null
};

function Album(obj) {    
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
  
  return Album;
}