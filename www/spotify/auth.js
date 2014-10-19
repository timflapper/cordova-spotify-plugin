var utils = require('./utils')
  , exec = utils.exec
  , noop = utils.noop;

var auth = exports;

auth.authenticate = function(clientId, tokenExchangeURL, scopes, callback) {
  if (callback === undefined) callback = scopes, scopes = ['streaming'];

  exec('authenticate', clientId, tokenExchangeURL, scopes, callback);
};

auth.renewSession = function(session, tokenRefreshURL, forceRenew, callback) {
  if (callback === undefined && typeof forceRenew === 'function')
    callback = forceRenew, forceRenew = false;

  if (forceRenew === true)
    return renewSession(session, tokenRefreshURL, callback);

  auth.isSessionValid(session, function(err, valid) {
    if (err) return callback(err);
    if (valid) return callback(null, session);

    renewSession(session, tokenRefreshURL, callback);
  });
};

auth.isSessionValid = function(session, callback) {
  exec('isSessionValid', session, callback);
};

/* Private methods */
function renewSession(session, tokenRefreshURL, callback) {
  exec('renewSession', session, tokenRefreshURL, callback);
};

/**
 *
 * TODO:
 * - Finish writing specs
 * - Optimize WebAPI calling stuff*
 * - Custom callback URI as variable for install
 * - Update README.md
 * - Update API wiki
 *
 **/
