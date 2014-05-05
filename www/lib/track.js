var spotify = undefined;

var defaultProps = {
  name: null,
  uri: null,
  sharingURL: null,
  previewURL: null,
  duration: null,
  artists: null,
  album: null,
  trackNumber: null,
  discNumber: null,
  popularity: null,
  flaggedExplicit: null,
  externalIds: null,
  availableTerritories: null
};

function Track(obj) {
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
  
  return Track;
}