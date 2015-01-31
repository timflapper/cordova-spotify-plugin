var utils = require('./utils')
  , EventDispatcher = require('./event-dispatcher');

var exec = utils.exec
  , noop = utils.noop;

function AudioPlayer(clientId) {
  EventDispatcher.call(this);

  this.id = undefined;
  this.clientId = clientId;
}

AudioPlayer.prototype = Object.create(EventDispatcher.prototype);
AudioPlayer.prototype.constructor = AudioPlayer;

module.exports.createAudioPlayer = function(clientId) {
  return new AudioPlayer(clientId);
}

var events = module.exports.AudioPlayer = {
  EVENT_LOGIN: 'login',
  EVENT_LOGOUT: 'logout',
  EVENT_PERMISSION_LOST: 'permissionLost',
  EVENT_ERROR: 'error',
  EVENT_MESSAGE: 'message',
  EVENT_PLAYBACK_STATUS: 'playbackStatus',
  EVENT_SEEK_TO_OFFSET: 'seekToOffset'
};

AudioPlayer.prototype.login = function(session, callback) {
  var self = this;

  exec('createAudioPlayerAndLogin', self.clientId, session, loginCallback);

  function loginCallback(error, id) {
    if (error) {
      if (! callback)
        return self.dispatchEvent(events.EVENT_ERROR, [error]);

      return callback(error);
    }

    self.id = id;

    exec('addAudioPlayerEventListener', self.id, onEventCallback);

    if (! callback)
      return self.dispatchEvent(events.EVENT_LOGIN);

    callback(null);
  };

  function onEventCallback(error, result) {
    if (error)
      return self.dispatchEvent.call(self, events.EVENT_ERROR, [error]);

    self.dispatchEvent.call(self, result.type, result.args);
  }
};

AudioPlayer.prototype.logout = function(callback) {
  var self = this;

  exec('audioPlayerLogout', self.id, logoutCallback);

  function logoutCallback(error) {
    if (error) {
      if (! callback)
        return self.dispatchEvent.call(self, events.EVENT_ERROR, [error]);

      return callback(error);
    }

    if (! callback)
      return self.dispatchEvent.call(self, events.EVENT_LOGOUT);

    callback(null);
  }
};

AudioPlayer.prototype.play = function(data, fromIndex, callback) {
  if (callback === undefined && typeof fromIndex === 'function')
    callback = fromIndex, fromIndex = null;

  if (typeof fromIndex !== 'number') fromIndex = 0;

  exec('play', this.id, data, fromIndex, callback);
};

AudioPlayer.prototype.setURIs = function(data, callback) {
  exec('setURIs', this.id, data, callback);
};

AudioPlayer.prototype.playURIsFromIndex = function(fromIndex, callback) {
  exec('playURIsFromIndex', this.id, fromIndex, callback);
}

AudioPlayer.prototype.queue = function(data, clearQueue, callback) {
  if (callback === undefined && typeof clearQueue === 'function')
    callback = clearQueue, clearQueue = false;

  exec('queue', this.id, data, clearQueue, callback);
};

AudioPlayer.prototype.queuePlay = function(callback) {
  exec('queuePlay', this.id, callback);
}

AudioPlayer.prototype.queueClear = function(callback) {
  exec('queueClear', this.id, callback);
}

AudioPlayer.prototype.stop = function(callback) {
  exec('stop', this.id, callback);
}

AudioPlayer.prototype.skipNext = function(callback) {
  exec('skipNext', this.id, callback);
};

AudioPlayer.prototype.skipPrevious = function(callback) {
  exec('skipPrevious', this.id, callback);
};

AudioPlayer.prototype.seekToOffset = function(offset, callback) {
  exec('seekToOffset', this.id, offset, callback);
};

AudioPlayer.prototype.getIsPlaying = function(callback) {
  exec('getIsPlaying', this.id, callback);
};

AudioPlayer.prototype.setIsPlaying = function(status, callback) {
  exec('setIsPlaying', this.id, status, callback);
};

AudioPlayer.prototype.getVolume = function(callback) {
  exec('getVolume', this.id, callback);
};

AudioPlayer.prototype.setVolume = function(volume, callback) {
  exec('setVolume', this.id, volume, callback);
};

AudioPlayer.prototype.getRepeat = function(callback) {
  exec('getRepeat', this.id, callback);
};

AudioPlayer.prototype.setRepeat = function(repeat, callback) {
  exec('setRepeat', this.id, repeat, callback);
};

AudioPlayer.prototype.getShuffle = function(callback) {
  exec('getShuffle', this.id, callback);
};

AudioPlayer.prototype.setShuffle = function(shuffle, callback) {
  exec('setShuffle', this.id, shuffle, callback);
};

AudioPlayer.prototype.getDiskCacheSizeLimit = function(callback) {
  exec('getDiskCacheSizeLimit', this.id, callback);
};

AudioPlayer.prototype.setDiskCacheSizeLimit = function(diskCacheSizeLimit, callback) {
  exec('setDiskCacheSizeLimit', this.id, diskCacheSizeLimit, callback);
};

AudioPlayer.prototype.getTargetBitrate = function(callback) {
  exec('getTargetBitrate', this.id, callback);
}

AudioPlayer.prototype.setTargetBitrate = function(bitrate, callback) {
  exec('setTargetBitrate', this.id, bitrate, callback);
}

AudioPlayer.prototype.getLoggedIn = function(callback) {
  exec('getLoggedIn', this.id, callback);
};

AudioPlayer.prototype.getQueueSize = function(callback) {
  exec('getQueueSize', this.id, callback);
}

AudioPlayer.prototype.getTrackListSize = function(callback) {
  exec('getTrackListSize', this.id, callback);
}

AudioPlayer.prototype.getTrackMetadata = function(trackID, relative, callback) {
  if (callback === undefined) {
    if (relative && typeof relative === 'function')
      callback = relative, relative = null;
    else if (trackID && typeof trackID === 'function')
      callback = trackID, trackID = null;
  }

  var args = ['getTrackMetadata', this.id];

  if (trackID) {
    args.push(trackID);

    if (relative) args.push(relative);
  }

  args.push(callback);

  exec.apply(this, args);
};

AudioPlayer.prototype.getCurrentPlaybackPosition = function(callback) {
  exec('getCurrentPlaybackPosition', this.id, callback);
};
