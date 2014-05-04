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

function AlbumData() {}
function Album(uri, session, callback) {
  var callback = callback || null
    , props = {}
    , album = new AlbumData();
    
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(album, prop, {
      get: function() { return props[prop] || defaultProps[prop]; },
      enumerable: true
    });
  });

  spotify.exec( 'albumFromURI',
                [ uri, session ],
                done );
                
  function done(error, data) {
    if (error)
      return callback(error);
    
    props = data;
    
    console.log(data);
    
    callback(null, album);
  }
}

Album.prototype = {};
AlbumData.prototype = Object.create(Album.prototype);
AlbumData.prototype.constructor = AlbumData;

module.exports = function(plugin) {
  spotify = plugin;
  
  return Album;
}