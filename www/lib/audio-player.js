var spotify = undefined;

var noop = function() {};

var EVENT_LOGIN = 'login'
  , EVENT_LOGOUT = 'logout'
  , EVENT_PERMISSION_LOST = 'permissionLost'
  , EVENT_ERROR = 'error'
  , EVENT_MESSAGE = 'message'
  , EVENT_PLAYBACK_STATUS = 'playbackStatus'
  , EVENT_SEEK_TO_OFFSET = 'seekToOffset';

function AudioPlayer(companyName, appName) {  
  AudioPlayer.init.call(this, companyName, appName);
}

module.exports = function(parent) {
  spotify = parent;
  
  return AudioPlayer;
}
AudioPlayer.prototype._id = undefined;
AudioPlayer.prototype._companyName = undefined;
AudioPlayer.prototype._appName = undefined;
AudioPlayer.prototype._events = undefined;

AudioPlayer.init = function(companyName, appName) {
  
  this._companyName = companyName;
  this._appName = appName;
  
  this._events = {};  
}

AudioPlayer.prototype.destroy = function(callback) {
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
  
  listeners = this._events[event];
  
  if (listeners.length === 1) {
    listeners[0].apply(this, args);
  } else {  
    listeners = this._events[event].slice();
  
    listeners.forEach(function(item, index) {
      item.apply(this, args);
    });
  }
}

AudioPlayer.prototype.__eventListener = function(error, result) {
  this.dispatchEvent.apply(this, result);
}

AudioPlayer.prototype.addEventListener = function(event, listener) {  
  if (typeof listener !== 'function') 
    throw new Error('listener must be a function');
  
  if ((event in this._events) === false)
    this._events[event] = [];
    
  this._events[event].push(listener);
}

AudioPlayer.prototype.removeEventListener = function(event, listener) {
  if (typeof listener !== 'function') 
    throw new Error('listener must be a function');
 
  if ((event in this._events) === false)
    return;
  
  var updatedArray = [];
  
  this._events[event].forEach(function(func, index) {
    if (func === listener) 
      return;
    
    updatedArray.push(func);
  });
  
  this._events[event] = updatedArray;
}

AudioPlayer.prototype.login = function(session, callback) {
  var self = this, callback = callback || noop;
  
  function done(error, id) {
    self._id = id;
    
    if (error !== null) {
      self.dispatchEvent(EVENT_ERROR, error);

      return callback(error);
    }
    
    spotify.exec('addAudioPlayerEventListener', [self._id], self.__eventListener.bind(self)); 
    
    self.dispatchEvent(EVENT_LOGIN);
    
    callback(null);
  }
  
  spotify.exec( 'createAudioPlayerAndLogin',
                [ this._companyName, this._appName, session ],
                done );
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