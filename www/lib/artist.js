var spotify = undefined;

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

function ArtistData() {}
function Artist(uri, session, callback) {
  var callback = callback || null
    , props = {}
    , artist = new ArtistData();
  
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(artist, prop, {
      get: function() { return props[prop] || defaultProps[prop]; },
      enumerable: true
    });
  });

  spotify.exec( 'artistFromURI',
              [ uri, session ],
              done );
              
  function done(error, data) {
    if (error)
      return callback(error);
  
    props = data;
      
    callback(null, artist);
  }
}

Artist.prototype = {};
ArtistData.prototype = Object.create(Artist.prototype);
ArtistData.prototype.constructor = ArtistData;

module.exports = function(plugin) {
  spotify = plugin;
  
  return Artist;
}