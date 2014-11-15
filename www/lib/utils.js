var exec = require('cordova/exec');

var noop = function() {};

var utils = module.exports = {
  noop: noop,
  exec: function(/*action, [params], [callback]*/) {
    var action, args = [], callback = noop;
    var i, argsLength = arguments.length;

    if (arguments.length === 0) throw new Error('No arguments received 1 or more expected.');
    action = arguments[0];

    for (i=1;i < argsLength;i++) args[i] = arguments[i];

    if (args.length > 0 && typeof args.slice(-1)[0] === 'function') {
      callback = args.splice(-1, 1)[0];
    }

    function onSuccess(result) { callback(null, result); }
    function onError(error) { callback(error); }

    exec(onSuccess, onError, 'SpotifyPlugin', action, args);
  }
};
