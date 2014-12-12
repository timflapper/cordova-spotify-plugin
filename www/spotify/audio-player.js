
var utils = require('./utils');

var exec = utils.exec
  , noop = utils.noop;


var EVENT_LOGIN = 'login'
  , EVENT_LOGOUT = 'logout'
  , EVENT_PERMISSION_LOST = 'permissionLost'
  , EVENT_ERROR = 'error'
  , EVENT_MESSAGE = 'message'
  , EVENT_PLAYBACK_STATUS = 'playbackStatus'
  , EVENT_SEEK_TO_OFFSET = 'seekToOffset';

function AudioPlayer(clientId) {
  AudioPlayer.init.call(this, clientId);
}
module.exports = AudioPlayer;

AudioPlayer.create = function(clientId) {
  return new AudioPlayer(clientId);
}

AudioPlayer.init = function(clientId) {
  this._id = undefined;
  this._clientId = clientId;
  this._events = undefined;
  this._destroyed = false;
  this._events = {};
};

AudioPlayer.prototype.__dispatchEvent = function(event, args) {
  if (this._destroyed) return;

  var i, listeners;

  args = args || [];

  if ((event in this._events) === false) {
    if (event === EVENT_ERROR)
      throw new Error(args[0]);

    if (event === EVENT_MESSAGE)
      alert(args[0]);

    return;
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
};

AudioPlayer.prototype.__eventListener = function(error, result) {
  if (error) {
      this.__dispatchEvent.call(this, 'error', error);
      return;
  }

  this.__dispatchEvent.call(this, result.type, result.args);
};

AudioPlayer.prototype.addEventListener = function(event, listener) {
  if (this._destroyed)
      throw new Error('AudioPlayer has been destroyed');

  if (typeof listener !== 'function')
    throw new Error('listener must be a function');

  if ((event in this._events) === false)
    this._events[event] = [];

  this._events[event].push(listener);
};

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
};

AudioPlayer.prototype.login = function(session, callback) {
  callback = this.__loginCallback(callback);
  exec('createAudioPlayerAndLogin', this._clientId, session, callback);
};

AudioPlayer.prototype.__loginCallback = function(callback) {
  var self = this;

  return function(error, id) {
    if (error) {
      if (! callback)
        return self.__dispatchEvent(EVENT_ERROR, [error]);

      return callback(error);
    }

    self._id = id;

    exec('addAudioPlayerEventListener', self._id, self.__eventListener.bind(self));

    if (! callback)
      return self.__dispatchEvent(EVENT_LOGIN);

    callback(null);
  };
};

AudioPlayer.prototype.play = function(data, fromIndex, callback) {
  if (callback === undefined && typeof fromIndex === 'function')
    callback = fromIndex, fromIndex = 0;

  exec('play', this._id, data, fromIndex, callback);
};

AudioPlayer.prototype.queue = function(data, clearQueue, callback) {
  if (callback === undefined && typeof clearQueue === 'function')
    callback = clearQueue, clearQueue = 0;

  exec('queue', this._id, data, clearQueue, callback);
};

AudioPlayer.prototype.skipNext = function(callback) {
  exec('skipNext', this._id, callback);
};

AudioPlayer.prototype.skipPrevious = function(callback) {
  exec('skipPrevious', this._id, callback);
};

AudioPlayer.prototype.seekToOffset = function(offset, callback) {
  exec('seekToOffset', this._id, offset, callback);
};

AudioPlayer.prototype.getIsPlaying = function(callback) {
  exec('getIsPlaying', this._id, callback);
};

AudioPlayer.prototype.setIsPlaying = function(status, callback) {
  exec('setIsPlaying', this._id, status, callback);
};

AudioPlayer.prototype.getVolume = function(callback) {
  exec('getVolume', this._id, callback);
};

AudioPlayer.prototype.setVolume = function(volume, callback) {
  exec('setVolume', this._id, volume, callback);
};

AudioPlayer.prototype.getRepeat = function(callback) {
  exec('getRepeat', this._id, callback);
};

AudioPlayer.prototype.setRepeat = function(repeat, callback) {
  exec('setRepeat', this._id, repeat, callback);
};

AudioPlayer.prototype.getShuffle = function(callback) {
  exec('getShuffle', this._id, callback);
};

AudioPlayer.prototype.setShuffle = function(shuffle, callback) {
  exec('setShuffle', this._id, shuffle, callback);
};

AudioPlayer.prototype.getDiskCacheSizeLimit = function(callback) {
  exec('getDiskCacheSizeLimit', this._id, callback);
};

AudioPlayer.prototype.setDiskCacheSizeLimit = function(diskCacheSizeLimit, callback) {
  exec('setDiskCacheSizeLimit', this._id, diskCacheSizeLimit, callback);
};

AudioPlayer.prototype.getTargetBitrate = function(callback) {
  exec('getTargetBitrate', this._id, callback);
}

AudioPlayer.prototype.setTargetBitrate = function(bitrate, callback) {
  exec('setTargetBitrate', this._id, bitrate, callback);
}

AudioPlayer.prototype.getLoggedIn = function(callback) {
  exec('getLoggedIn', this._id, callback);
};

AudioPlayer.prototype.getTrackMetadata = function(trackID, relative, callback) {
  var args = ['getTrackMetadata', this._id];

  if (trackID) {
    args.push(trackID);

    if (relative) args.push(relative);
  }

  args.push(callback);

  exec.apply(this, args);
};

AudioPlayer.prototype.getCurrentPlaybackPosition = function(callback) {
  exec('getCurrentPlaybackPosition', this._id, callback);
};
