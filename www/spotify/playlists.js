
var utils = require('./utils')
  , remote = require('./remote');

var playlists = exports;

playlists.getPlaylists = function(session, callback) {
  remote({
    uri: '/users/' + session.username + '/playlists',
    session: session
  }, onRemoteResult);

  function onRemoteResult(err, data) {
    if (err) return callback(err);

    paginate(data, session);
    callback(null, data);
  }
}

playlists.getPlaylist = function(id, session, callback) {
  remote({
    uri: '/users/' + session.username + '/playlists/' + id,
    session: session
  }, onRemoteResult);

  function onRemoteResult(err, data) {
    if (err) return callback(err);

    paginate(data.tracks, session);
    callback(null, data);
  }
};

playlists.getStarred = function(session, callback) {
  remote({
    uri: '/users/' + session.username + '/starred',
    session: session
  }, callback);
};

playlists.createPlaylist = function(name, pub, session, callback) {
  remote({
    uri: '/users/' + session.username + '/playlists',
    method: 'post',
    session: session,
    data: JSON.stringify({ 'name': name, 'public': pub })
  }, callback);
};

playlists.addTracksToPlaylist = function(id, uris, session, callback) {
  remote({
    uri: '/users/' + session.username + '/playlists/'+id+'/tracks',
    method: 'post',
    session: session,
    data: JSON.stringify(uris)
  }, callback);
};

playlists.removeTracksFromPlaylist = function(id, tracks, session, callback) {
  remote({
    uri: '/users/' + session.username + '/playlists/'+id+'/tracks',
    method: 'delete',
    data: JSON.stringify({tracks: tracks}),
    session: session
  }, callback);
};

playlists.replaceTracksOnPlaylist = function(id, uris, session, callback) {
  remote({
    uri: '/users/' + session.username + '/playlists/'+id+'/tracks',
    method: 'put',
    data: JSON.stringify({uris: uris}),
    session: session
  }, callback);
};

playlists.changePlaylistDetails = function(id, name, pub, session, callback) {
  remote({
    uri: '/users/' + session.username + '/playlists/' + id,
    method: 'put',
    data: JSON.stringify({ 'name': name, 'public': pub }),
    session: session
  }, callback);
};
