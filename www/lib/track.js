var exec = require('cordova/exec');

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

function TrackData() {}
function Track(uri, callback) {
  var callback = callback || null
    , props = {}
    , track = new TrackData();
  
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(track, prop, {
      get: function() { return props[prop] || defaultProps[prop]; },
      enumerable: true
    });
  });

  function onSuccess(data) {
    props = data;
    
    if (callback) 
      return callback(null, track);
  }

  function onError(error) {
    if (callback)
      return callback(error);
  }
  
  spotify.exec( 'trackFromURI', 
                [ uri ],
                callback );
  
  return track;
}

Track.prototype = {};
TrackData.prototype = Object.create(Track.prototype);
TrackData.prototype.constructor = TrackData;

module.exports = Track;