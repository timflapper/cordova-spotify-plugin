(function() {
  var exec = require('cordova/exec');

  var xhr, mockResults = [], first = true;

  window.mockExec = function(status, result, onRequest, noCallback) {
    noCallback = noCallback || false;
    if (first) {
      first = false;
      exec.setJsToNativeBridgeMode(exec.jsToNativeModes.XHR_NO_PAYLOAD);
    }

    mockResults.push({
      status: status,
      result: result,
      onRequest: onRequest,
      noCallback: noCallback
    });

    if (! xhr) {
      xhr = sinon.useFakeXMLHttpRequest();

      xhr.onCreate = function(req) {
        var payloads = JSON.parse(exec.nativeFetchMessages());

        while (mockResults.length > 0) {
          var mockResult = mockResults.shift()
            , payload = payloads.shift()
            , callbackId = payload.shift();

          if (mockResult.onRequest) mockResult.onRequest(payload);
          if (! mockResult.noCallback) {
            var more = exec.nativeCallback(callbackId, mockResult.status, mockResult.result, false);

            if (more) {
              payloads = payloads.concat(JSON.parse(more));
            }
          }
        }

        xhr.restore();
        xhr = null;
      };
    }
  };

  window.restoreMockExec = function() {
    if (xhr) {
      xhr.restore();
      xhr = null;
    }

    mockResults = [];
  }
})();
