
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

function AudioPlayer(companyName, appName) {
  AudioPlayer.init.call(this, companyName, appName);
}

module.exports = AudioPlayer;

AudioPlayer.init = function(companyName, appName) {
  this._id = undefined;
  this._companyName = companyName;
  this._appName = appName;
  this._events = undefined;
  this._destroyed = false;
  this._events = {};
}

AudioPlayer.prototype.dispatchEvent = function(event, args) {
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
}

AudioPlayer.prototype.__eventListener = function(error, result) {
  if (error) {
      this.dispatchEvent.call(this, 'error', error);
      return;
  }

  this.dispatchEvent.call(this, result.type, result.args);
}

AudioPlayer.prototype.addEventListener = function(event, listener) {
  if (this._destroyed)
      throw new Error('AudioPlayer has been destroyed');

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
  callback = this.loginCallback(callback);
  exec('createAudioPlayerAndLogin', this._companyName, this._appName, session, callback);
}

AudioPlayer.prototype.loginCallback = function(callback) {
  var self = this;

  return function(error, id) {
    if (error !== null) {
      if (! callback)
        return self.dispatchEvent(EVENT_ERROR, [error]);

      return callback(error);
    }

    self._id = id;

    exec('addAudioPlayerEventListener', self._id, self.__eventListener.bind(self));

    if (! callback)
      return self.dispatchEvent(EVENT_LOGIN);

    callback(null);
  };
}

AudioPlayer.prototype.playURI = function(uri, callback) {
 exec('playURI', this._id, uri, callback);
}

AudioPlayer.prototype.seekToOffset = function(offset, callback) {
  exec('seekToOffset', this._id, offset, callback);
}

AudioPlayer.prototype.getIsPlaying = function(callback) {
  exec('getIsPlaying', this._id, callback);
}

AudioPlayer.prototype.setIsPlaying = function(status, callback) {
  exec('setIsPlaying', this._id, status, callback);
}

AudioPlayer.prototype.getVolume = function(callback) {
  exec('getVolume', this._id, callback);
}

AudioPlayer.prototype.setVolume = function(volume, callback) {
  exec('setVolume', this._id, volume, callback);
}

AudioPlayer.prototype.getLoggedIn = function(callback) {
  exec('getLoggedIn', this._id, callback);
}

AudioPlayer.prototype.getCurrentTrack = function(callback) {
  exec('getCurrentTrack', this._id, callback);
}

AudioPlayer.prototype.getCurrentPlaybackPosition = function(callback) {
  exec('getCurrentPlaybackPosition', this._id, callback);
}
