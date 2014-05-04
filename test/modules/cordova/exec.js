module.exports = function(onSuccess, onError, service, action, args) {  
  if (service !== 'SpotifyPlugin') {
    return onError(new Error('Invalid service'));
  }
  
  switch (action) {
    case 'doTestAction':
      return onSuccess([true]);
    break;
    case 'authenticate':
      authenticate(args[0], args[1], args[2], function(error, session) {
        if (error !== null) 
          return onError(error);
          
          onSuccess(session);
      });
    break;
    default:
      return onError(new Error('Invalid action'));
    break;
  }
}


function authenticate(clientId, tokenExchangeURL, scopes, callback) {
 if (clientId !== 'someClientId')
   return callback(new Error('Invalid clientId'));
 
  callback(null, {
    username: 'testUser',
    credential: 'someR4nd0mCr3d3nt14ls'
  });
}