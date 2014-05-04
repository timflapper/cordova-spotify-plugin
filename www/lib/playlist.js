var spotify = require('../spotify');

var defaultProps = {
  name: null,
  version: null,
  uri: null,
  collaborative: null,
  creator: null,
  tracks: null,
  dateModified: null
};

function Playlist(obj) {
  var self = this;

  Object.keys(defaultProps).forEach(function(prop, index) {
    Object.defineProperty(self, prop, {
      value: obj[prop] || defaultProps[prop],
      enumerable: true
    });
  });

}

module.exports = Playlist;

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

Playlist.prototype.setCollaborative = function(collaborative, session, callback) {
  spotify.exec( 'setPlaylistCollaborative', 
                [ this.uri, collaborative, session ],
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