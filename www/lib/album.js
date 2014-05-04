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

function AlbumData() {}
function Album(uri, callback) {
  var callback = callback || null
    , props = {}
    , album = new AlbumData();
  
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(album, prop, {
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
  
  spotify.exec( 'albumFromURI',
                [ uri ],
                callback );
  
  return track;
}

Album.prototype = {};
AlbumData.prototype = Object.create(Album.prototype);
AlbumData.prototype.constructor = AlbumData;

module.exports = Album;