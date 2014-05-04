var defaultProps = {
  name: null,
  version: null,
  uri: null,
  collaborative: null,
  creator: null,
  tracks: null,
  dateModified: null
};

function PlaylistData() {}
function Playlist(uri, session, callback) {
  var callback = callback || null
    , props = {}
    , playlist = new PlaylistData();
      
  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(playlist, prop, {
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
  
  spotify.exec( 'playlistFromURI', 
                [ uri, session ],
                callback );
  
  return playlist;
}

Playlist.prototype.setName = function(name, session, callback) {
  spotify.exec( 'setPlaylistName', 
                [ this.uri, name, session ],
                callback );
}

Playlist.prototype.setDescription = function(desc, session, callback) {
  spotify.exec( 'setPlaylistDescription', 
                [ this.uri, name, session ],
                callback );  
}

Playlist.prototype.setCollaborative = function(value, session, callback) {
  spotify.exec( 'setPlaylistCollaborative', 
                [ this.uri, value, session ],
                callback );    
}

Playlist.prototype.addTracks = function(tracks, session, callback) {
  spotify.exec( 'addTracksToPlaylist', 
                [ this.uri, tracks, session ],
                callback );
}

Playlist.prototype.delete = function(session, callback) {
  spotify.exec( 'deletePlaylist', 
                [ this.uri, session ],
                callback );      
}

PlaylistData.prototype = Object.create(Playlist.prototype);
PlaylistData.prototype.constructor = PlaylistData;

module.exports = Playlist;