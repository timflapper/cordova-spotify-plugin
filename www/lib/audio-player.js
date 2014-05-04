var spotify = undefined;

var EVENT_LOGIN = 'login'
  , EVENT_LOGOUT = 'logout'
  , EVENT_PERMISSION_LOST = 'permissionLost'
  , EVENT_ERROR = 'error'
  , EVENT_MESSAGE = 'message'
  , EVENT_PLAYBACK_STATUS = 'playbackStatus'
  , EVENT_SEEK_TO_OFFSET = 'seekToOffset';

function AudioPlayer(playerId) {  
  AudioPlayer.init.call(this, playerId);
}

AudioPlayer.prototype._id = undefined;
AudioPlayer.prototype._events = undefined;

AudioPlayer.init = function(id) {
  this._id = id;
  
  this._events = {};
  
  spotify.exec('addAudioPlayerEventListener', [this._id], this.__eventListener);
}

AudioPlayer.destroy = function(callback) {
  spotify.exec('destroyAudioPlayer', [this._id], callback);
}

AudioPlayer.prototype.dispatchEvent = function(event) {
  var i, args, listeners;

  if ((event in this._events) === false) {
    if (event === EVENT_ERROR)
      throw new Error(arguments[1]);
      
    if (event === EVENT_MESSAGE) {
      alert(arguments[1]);
    }
    
    return;
  }
  
  if (arguments.length > 1) {
    args = arguments.slice(1);
  } else {
    args = [];
  }
  
  if (listeners.length === 1) {
    listeners[0].apply(this, args);
  } else {  
    listeners = this._events[event].slice();
  
    listeners.forEach(function(item, index) {
      item.apply(this, args);
    });
  }
}

AudioPlayer.prototype.addEventListener = function(event, listener) {  
  if (typeof callback !== 'function') 
    throw new Error('listener must be a function');
  
  if ((event in this._events) === false)
    this._events[event] = [];
    
  this._events[event].push(listener);
}

AudioPlayer.prototype.playURI = function(uri, callback) {
 spotify.exec('playURI', [this._id, uri], callback); 
}

AudioPlayer.prototype.seekToOffset = function(offset, callback) {
  spotify.exec('seekToOffset', [this._id, offset], callback);
}

AudioPlayer.prototype.getIsPlaying = function(callback) {
  spotify.exec('getIsPlaying', [this._id], callback);
}

AudioPlayer.prototype.setIsPlaying = function(status, callback) {
  spotify.exec('setIsPlaying', [this._id, status], callback);
}

AudioPlayer.prototype.getVolume = function(callback) {
  spotify.exec('getVolume', [this._id], callback);
}

AudioPlayer.prototype.setVolume = function(volume, callback) {
  spotify.exec('setVolume', [this._id, volume], callback);
}

AudioPlayer.prototype.getLoggedIn = function(callback) {
  spotify.exec('getLoggedIn', [this._id], callback);
}
    
AudioPlayer.prototype.getCurrentTrack = function(callback) {
  spotify.exec('getCurrentTrack', [this._id], callback);
}
    
AudioPlayer.prototype.getCurrentPlaybackPosition = function(callback) {
  spotify.exec('getCurrentPlaybackPosition', [this._id], callback);
}

AudioPlayer.prototype.__eventListener = function(error, result) {
  this.dispatchEvent.apply(this, result);
}

function requestAudioPlayer(companyName, appName, session, callback) {
  function done(error, playerId) {
    if (error)
      return callback(error, null);
      
    var player = new AudioPlayer(playerId);
    
    callback(null, player);
  }
  
  spotify.exec( 'requestAudioPlayer',
                [ companyName, appName, session ],
                done );
}

module.exports = function(plugin) {
  spotify = plugin;
  
  return requestAudioPlayer;
}