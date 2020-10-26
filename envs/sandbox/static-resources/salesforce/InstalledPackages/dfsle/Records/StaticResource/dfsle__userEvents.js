/* global Promise, $A */
/**
 * Publisher for timing and tracking user events. This respects the user's "do not track" browser setting.
 * NOTE: This must NOT be used to transmit any PII.
 * @param application {string} Application name.
 * @param version {string} Application version.
 * @param environment {string} DocuSign environment name.
 * @param accountIdHash {string} DocuSign account ID hash.
 * @param userIdHash {string} DocuSign user ID hash.
 * @returns {Readonly<{Status: Readonly<{SUCCESS: string, CANCELED: string, ERROR: string}>, cancel: cancel, success: success, time: time, error: error}>|Readonly<{Status: Readonly<{SUCCESS: string, CANCELED: string, ERROR: string}>, cancel: trackCancel, success: trackSuccess, time: time, error: trackError}>}
 * @constructor Creates a user event publisher.
 */
window.UserEvents = function (application, version, environment, accountIdHash, userIdHash) {

  if (!application || !version) {
    throw Error('Cannot initialize monitoring: one or more arguments is undefined.');
  }

  /**
   * Event status enumeration.
   * @type {Readonly<{SUCCESS: string, CANCELED: string, ERROR: string}>}
   */
  var Status = Object.freeze({
    SUCCESS: 'success',
    ERROR: 'failure',
    CANCELED: 'canceled'
  });

  // Respect do not track.
  // Stub out functions if no DS user is defined.
  if (!userIdHash || userIdHash === '' || navigator.doNotTrack === '1') return Object.freeze({
    Status: Status,
    addProperties: function () {
    },
    time: function () {
    },
    success: function () {
    },
    error: function () {
    },
    cancel: function () {
    }
  });

  if (!String.prototype.includes) { // IE polyfill
    String.prototype.includes = function (search, start) {
      if (search instanceof RegExp) {
        throw TypeError('first argument must not be a RegExp');
      }
      if (start === undefined) {
        start = 0;
      }
      return this.indexOf(search, start) !== -1;
    };
  }

  var deviceProperties = (function () {
    var ua = navigator.userAgent;
    var browser = (function () {
      var vendor = navigator.vendor || ''; // vendor is undefined for at least IE9
      var opera = window['opera'];
      if (opera || ua.includes(' OPR/')) return ua.includes('Mini') ? 'Opera Mini' : 'Opera';
      if (/(BlackBerry|PlayBook|BB10)/i.test(ua)) return 'BlackBerry';
      if (ua.includes('IEMobile') || ua.includes('WPDesktop')) return 'Internet Explorer Mobile';
      if (ua.includes('Edge')) return 'Microsoft Edge';
      if (ua.includes('FBIOS')) return 'Facebook Mobile';
      if (ua.includes('Chrome')) return 'Chrome';
      if (ua.includes('CriOS')) return 'Chrome iOS';
      if (ua.includes('UCWEB') || ua.includes('UCBrowser')) return 'UC Browser';
      if (ua.includes('FxiOS')) return 'Firefox iOS';
      if (vendor.includes('Apple')) return ua.includes('Mobile') ? 'Mobile Safari' : 'Safari';
      if (ua.includes('Android')) return 'Android Mobile';
      if (ua.includes('Konqueror')) return 'Konqueror';
      if (ua.includes('Firefox')) return 'Firefox';
      if (ua.includes('MSIE') || ua.includes('Trident/')) return 'Internet Explorer';
      if (ua.includes('Gecko')) return 'Mozilla';
      return '';
    })();

    return Object.freeze({
      os: (function () {
        if (/Windows/i.test(ua)) return (/Phone/.test(ua) || /WPDesktop/.test(ua)) ? 'Windows Phone' : 'Windows';
        if (/(iPhone|iPad|iPod)/.test(ua)) return 'iOS';
        if (/Android/.test(ua)) return 'Android';
        if (/(BlackBerry|PlayBook|BB10)/i.test(ua)) return 'BlackBerry';
        if (/Mac/i.test(ua)) return 'Mac OS X';
        if (/Linux/.test(ua)) return 'Linux';
        if (/CrOS/.test(ua)) return 'Chrome OS';
        return '';
      })(),
      browser: browser,
      browserVersion: (function () {
        var versionRegexs = {
          'Internet Explorer Mobile': /rv:(\d+(\.\d+)?)/,
          'Microsoft Edge': /Edge\/(\d+(\.\d+)?)/,
          'Chrome': /Chrome\/(\d+(\.\d+)?)/,
          'Chrome iOS': /CriOS\/(\d+(\.\d+)?)/,
          'UC Browser': /(UCBrowser|UCWEB)\/(\d+(\.\d+)?)/,
          'Safari': /Version\/(\d+(\.\d+)?)/,
          'Mobile Safari': /Version\/(\d+(\.\d+)?)/,
          'Opera': /(Opera|OPR)\/(\d+(\.\d+)?)/,
          'Firefox': /Firefox\/(\d+(\.\d+)?)/,
          'Firefox iOS': /FxiOS\/(\d+(\.\d+)?)/,
          'Konqueror': /Konqueror:(\d+(\.\d+)?)/,
          'BlackBerry': /BlackBerry (\d+(\.\d+)?)/,
          'Android Mobile': /android\s(\d+(\.\d+)?)/,
          'Internet Explorer': /(rv:|MSIE )(\d+(\.\d+)?)/,
          'Mozilla': /rv:(\d+(\.\d+)?)/
        };
        var regex = versionRegexs[browser];
        if (regex === undefined) {
          return null;
        }
        var matches = ua.match(regex);
        if (!matches) {
          return null;
        }
        return parseFloat(matches[matches.length - 2]);
      })(),
      device: (function () {
        if (/Windows Phone/i.test(ua) || /WPDesktop/.test(ua)) return 'Windows Phone';
        if (/iPad/.test(ua)) return 'iPad';
        if (/iPod/.test(ua)) return 'iPod Touch';
        if (/iPhone/.test(ua)) return 'iPhone';
        if (/(BlackBerry|PlayBook|BB10)/i.test(ua)) return 'BlackBerry';
        if (/Android/.test(ua)) return 'Android';
        return '';
      })()
    });
  })();

  var currentUrl = (function () {
    if (!window.location.href) return 'undefined';

    // Anonymize URL
    var url = window.location.href.split(/[?#]/)[0];
    var index = url.indexOf('://');
    if (index >= 0 && (index + 3) < url.length) url = url.substring(index + 3);
    index = url.indexOf('/');
    return 'https://salesforce.com' + (index >= 0 ? url.substring(index) : '/');
  })();

  var baseProperties = Object.freeze({
    token: '92d714bc30f2a218ea91d4b6ed23cac8',
    distinct_id: userIdHash,
    $current_url: currentUrl,
    $os: deviceProperties.os,
    $browser: deviceProperties.browser,
    $browser_version: deviceProperties.browserVersion,
    $device: deviceProperties.device,
    $screen_height: screen.height,
    $screen_width: screen.width,
    $referrer: 'https://salesforce.com',
    $referring_domain: 'salesforce.com',
    $device_id: userIdHash,
    mp_lib: application,
    $lib_version: version,
    Application: application,
    Version: version,
    Environment: environment && environment !== '' ? environment : 'undefined',
    'Account ID': accountIdHash && accountIdHash !== '' ? accountIdHash : 'undefined'
  });

  /**
   * @typedef {Object} UserEvent
   * @property {string} event The event name.
   * @property {Object} properties The event properties.
   */

  /**
   * @type {{_timers: {}, values: (function(): any), startTimer: startTimer, clear: clear, _key: string, push: push}}
   */
  var PendingEvents = {
    _key: application,
    _timers: {},

    /**
     * Adds an event to be sent.
     * @param events {UserEvent[]} The events to queue.
     */
    enqueue: function (events) {
      if (!events) return;

      var evts = PendingEvents.dequeue();
      Array.prototype.push.apply(evts, events);
      localStorage.setItem(PendingEvents._key, JSON.stringify(evts));
    },

    dequeue: function () { // Get and remove values here to prevent race condition with pending http callout
      var vals = localStorage.getItem(PendingEvents._key);
      localStorage.removeItem(PendingEvents._key);
      return JSON.parse(vals || '[]');
    },

    /**
     * Starts a timer for an event.
     * @param eventName {string} The event name.
     */
    startTimer: function (eventName) {
      // set start time and add event to pending events
      PendingEvents._timers[eventName] = new Date().getTime();
    },

    /**
     * Adds an event to be sent.
     * @param event {UserEvent} The event to queue.
     */
    push: function (event) {
      if (event) {
        if (PendingEvents._timers[event.event]) {
          var msDuration = new Date().getTime() - PendingEvents._timers[event.event];
          event.properties['$duration'] = parseFloat((msDuration / 1000).toFixed(3));
          delete PendingEvents._timers[event.event];
        }
        var events = PendingEvents.dequeue();
        events.push(event);
        localStorage.setItem(PendingEvents._key, JSON.stringify(events));
      }
    },

    /**
     * Clears all pending events from the queue.
     */
    clear: function () {
      localStorage.removeItem(PendingEvents._key);
    }
  };

  /**
   * Sends all queued events.
   * @returns {Promise<Object>} A promise for the result of posting the event.
   */
  function sendEvents() {
    var events = PendingEvents.dequeue();
    return httpPost(events)
      .catch(function (error) {
        if ($A && $A.log) $A.log(error);
        PendingEvents.enqueue(events);
      });
  }

  /**
   * Base64 encodes a string.
   * @param s {string} The input string.
   * @returns {string} The base64-encoded string.
   */
  function base64Encode(s) {
    return window.btoa(unescape(encodeURIComponent(s)));
  }

  /**
   * Wraps a function with $A.getCallback if $A is defined.
   * @param f The function to wrap.
   * @returns {*} The wrapped function.
   */
  function wrapCallback(f) {
    return typeof $A !== 'undefined' && $A.getCallback ? $A.getCallback(f) : f;
  }

  /**
   * Sends one or more events.
   * @param data {Array<Object>} The events to send.
   */
  function httpPost(data) {
    var url = 'https://api.mixpanel.com/track';
    return new Promise(wrapCallback(function (resolve, reject) {
      if (!data || !data.length) {
        reject({
          url: url,
          status: 400,
          body: 'No data'
        });
      }

      var xhr = new XMLHttpRequest();
      xhr.open('POST', url);
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
      xhr.withCredentials = true;
      xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
          if (xhr.status === 200 || xhr.status === 201 || (xhr.status === 0 && xhr.responseText !== '')) {
            resolve({
              url: url,
              status: 201,
              body: xhr.responseText || ''
            });
          } else {
            reject({
              url: url,
              status: xhr.status,
              body: xhr.responseText || ''
            });
          }
        }
      };
      // ip=1&data=<base64, URL-encoded data>
      xhr.send('ip=1&data=' + encodeURIComponent(base64Encode(JSON.stringify(data))) + '&_=' + (new Date().getTime()));
    }));
  }

  /**
   * Generates a new distinct_id (code lifted from Mixpanel js).
   * @returns {string} new UUID (example 01234567-89ab-cdef-0123-456789abcdef)
   */
  function randomUUID() {
    /**
     * Time/ticks information
     * 1*new Date() is a cross browser version of Date.now()
     * @return {string}
     */
    var T = function () {
      var d = 1 * new Date(),
        i = 0;

      // this while loop figures how many browser ticks go by
      // before 1*new Date() returns a new number, ie the amount
      // of ticks that go by per millisecond
      while (d === 1 * new Date()) {
        i++;
      }

      return d.toString(16) + i.toString(16);
    };
    /**
     * Math.Random entropy
     * @return {string}
     */
    var R = function () {
      return Math.random().toString(16).replace('.', '');
    };

    // User agent entropy
    // This function takes the user agent string, and then xors
    // together each sequence of 8 bytes.  This produces a final
    // sequence of 8 bytes which it returns as hex.
    /**
     * User agent entropy. This function takes the user agent string, and then xors together each sequence of 8 bytes.
     * This produces a final sequence of 8 bytes which it returns as hex.
     * @return {string}
     */
    var UA = function () {
      var ua = navigator.userAgent,
        i, ch, buffer = [],
        ret = 0;

      function xor(result, byte_array) {
        var j, tmp = 0;
        for (j = 0; j < byte_array.length; j++) {
          tmp |= (buffer[j] << j * 8);
        }
        return result ^ tmp;
      }

      for (i = 0; i < ua.length; i++) {
        ch = ua.charCodeAt(i);
        buffer.unshift(ch & 0xFF);
        if (buffer.length >= 4) {
          ret = xor(ret, buffer);
          buffer = [];
        }
      }

      if (buffer.length > 0) {
        ret = xor(ret, buffer);
      }

      return ret.toString(16);
    };

    var se = (screen.height * screen.width).toString(16);
    return (T() + '-' + R() + '-' + UA() + '-' + se + '-' + T());
  }

  /**
   * Creates a new object merging two objects' properties. No empty properties are copied.
   * @param obj1 {Object} The first object.
   * @param obj2 {Object} The second object.
   * @return {Object} A new object containing properties from both input object.
   */
  function merge(obj1, obj2) {
    var result = {};
    Object.keys(obj1 || {}).forEach(function (key) {
      var value = obj1[key];
      if (typeof value !== 'undefined' && value !== null && value !== '') {
        result[key] = value;
      }
    });
    Object.keys(obj2 || {}).forEach(function (key) {
      var value = obj2[key];
      if (typeof value !== 'undefined' && value !== null && value !== '') {
        result[key] = value;
      }
    });
    return result;
  }

  /**
   * Adds properties common to all emitted events. Any null, undefined, or empty properties will be removed.
   * @param properties Common event properties.
   */
  var addProperties = function (properties) {
    if (properties && typeof properties === 'object') {
      baseProperties = merge(baseProperties, properties);
    }
  };

  /**
   * Starts an event timer.
   *
   * @param eventName {string} The name of the event.
   */
  var time = function (eventName) {
    if (!eventName || eventName === '') throw new Error('Invalid event name');

    PendingEvents.startTimer(eventName);
  };

  /**
   * Tracks an event.
   * @param eventName {string} The name of the event.
   * @param properties {Object} The event properties.
   * @param status {Status} The event status.
   * @param error {string} The error associated with the event, if any.
   */
  var track = function (eventName, properties, status, error) {
    if (!eventName || eventName === '') throw new Error('Invalid event name');
    if (properties && typeof properties !== 'object') throw new TypeError('Parameters must be an object');

    var event = {
      event: eventName,
      properties: merge(baseProperties, properties)
    };
    if (status) {
      event.properties['Status'] = status;
    }
    if (error) {
      event.properties['Error'] = error;
    }
    PendingEvents.push(event);

    sendEvents();
  };

  /**
   * Tracks a success event.
   * @param eventName {string} The name of the event.
   * @param properties {Object} The event properties.
   */
  var trackSuccess = function (eventName, properties) {
    track(eventName, properties, Status.SUCCESS, null);
  };

  /**
   * Tracks an error event.
   * @param eventName {string} The name of the event.
   * @param properties {Object} The event properties.
   * @param error {string} The error associated with the event.
   */
  var trackError = function (eventName, properties, error) {
    track(eventName, properties, Status.ERROR, error);
  };

  /**
   * Tracks a cancel event.
   * @param eventName {string} The name of the event.
   * @param properties {Object} The event properties.
   */
  var trackCancel = function (eventName, properties) {
    track(eventName, properties, Status.CANCELED, null);
  };

  // Send data when loaded or back online.
  window.addEventListener('load', sendEvents, {passive: true});
  window.addEventListener('online', sendEvents, {passive: true});

  // First event identifies the user.
  track('$identify', {
    $anon_distinct_id: randomUUID(),
    distinct_id: userIdHash,
    $user_id: userIdHash
  }, null, null);

  return Object.freeze({
    Status: Status,
    addProperties: addProperties,
    time: time,
    success: trackSuccess,
    error: trackError,
    cancel: trackCancel
  });
};




