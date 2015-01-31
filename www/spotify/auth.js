var utils = require('./utils')
  , exec = utils.exec
  , noop = utils.noop;

var auth = exports;

auth.authenticate = function(urlScheme, clientId, responseType, tokenExchangeURL, scopes, callback) {
  if (callback === undefined) {
    if (scopes === undefined) {
      callback = tokenExchangeURL;
      tokenExchangeURL = null;
    } else {
      callback = scopes;
    }

    scopes = ['streaming'];
  }

  args = ['authenticate', urlScheme, clientId, responseType];

  if(responseType == 'code') args.push(tokenExchangeURL);

  args.push(scopes);
  args.push(callback);

  exec.apply(this, args);
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
