/**
 * This fires various events that are expected to be handled in a ancestor component (e.g. RootContainer). Supported events:
 * - Loading: overlay spinner.
 * - Toast: success and error notifications.
 * - User: track success, error, or cancel events.
 * @param loadingEvent {function<Event>} Function that returns the LoadingEvent for a component.
 * @param toastEvent {function<Event>} Function that returns the ToastEvent for a component.
 * @param userEvent {function<Event>} Function that returns the UserEvent for a component.
 * @returns {Readonly<{hideToast: hideToast, invokeAction: invokeAction, trackSuccess: trackSuccess, trackCancel: trackCancel, setLoading: setLoading, trackError: trackError, showToast: showToast, timeEvent: timeEvent, ToastMode: {SUCCESS: string, ERROR: string, WARNING: string}, getErrorMessage: (function(Response): string)}>}
 * @constructor Creates a UIHelper instance.
 */
window.UIHelper = function (loadingEvent, toastEvent, userEvent) {
  /**
   * Fires a component loading event.
   * @param isLoading {boolean} Whether or not the component is in a loading state.
   */
  var setLoading = function (isLoading) {
    var event = loadingEvent();
    if (event && event.setParams && event.fire) {
      event.setParams({
        isLoading: isLoading === true
      });
      event.fire();
    }
  };

  /**
   * Enumeration of possible toast notification display modes.
   * @type {{SUCCESS: string, ERROR: string, WARNING: string}}
   */
  var ToastMode = Object.freeze({
    SUCCESS: 'success', WARNING: 'warning', ERROR: 'error'
  });

  /**
   * Displays a toast notification.
   * @param message {string} The message to display.
   * @param mode {ToastMode} The mode of the toast notification.
   * @param detail {string|string[]} Additional context or detail.
   */
  var showToast = function (message, mode, detail) {
    var event = toastEvent();
    if (event && event.setParams && event.fire) {
      event.setParams({
        show: true,
        mode: mode,
        message: message,
        detail: detail
      });
      event.fire();
    }
  };

  /**
   * Hides a toast notification.
   */
  var hideToast = function () {
    var event = toastEvent();
    if (event && event.setParams) {
      event.setParams({
        show: false
      });
      event.fire();
    }
  };

  /**
   * Gets the error message from a remote action response.
   * @param response {Response} The remote action response.
   * @returns {string} The error message.
   */
  var getErrorMessage = function (response) {
    var message = '';
    if (response) {
      var errors = response.getError();
      message = errors;
      if (!$A.util.isEmpty(errors)) {
        message = errors[0].message;
      }
    }
    return message;
  };

  /**
   * Invokes a remote action and calls back with results. This handles loading spinners and toast notifications in a
   * standard way.
   * @param action {Object} The remote action.
   * @param params {Object} Parameters to pass into the remote action method.
   * @param onSuccess {function<Object>} Success callback.
   * @param onError {function<Object[]>} Error callback.
   * @param onComplete {function<Response>} Completion callback.
   */
  var invokeAction = function (action, params, onSuccess, onError, onComplete) {
    hideToast();
    setLoading(true);
    if (action) {
      if (params) action.setParams(params);
      action.setCallback(this, function (response) {
        if (response.getState() === 'SUCCESS') {
          if (onSuccess) onSuccess(response.getReturnValue());
        } else {
          showToast(getErrorMessage(response), ToastMode.ERROR);
          if (onError) onError(response.getError());
        }
        setLoading(false);
        if (onComplete) onComplete(response);
      });
      $A.enqueueAction(action);
    }
  };

  /**
   * Event status enumeration.
   * @type {Readonly<{SUCCESS: string, CANCELED: string, ERROR: string}>}
   */
  var Status = Object.freeze({
    SUCCESS: 'success',
    ERROR: 'failure',
    CANCELED: 'canceled'
  });

  /**
   * Adds common event properties. Anything undefined, null, or empty will be omitted.
   * @param properties {object}
   */
  var addEventProperties = function (properties) {
    var event = userEvent();
    if (event && event.setParams && event.fire) {
      event.setParams({
        action: 'addProperties',
        properties: properties
      });
      event.fire();
    }
  };

  /**
   * Starts an event timer.
   * @param name {string} The name of the event to time.
   */
  var timeEvent = function (name) {
    var event = userEvent();
    if (event && event.setParams && event.fire) {
      event.setParams({
        action: 'time',
        name: name
      });
      event.fire();
    }
  };

  /**
   * Dispatches a success tracking event.
   * @param name {string} The name of the event.
   * @param properties {Object} The event properties.
   */
  var trackSuccess = function (name, properties) {
    var event = userEvent();
    if (event && event.setParams && event.fire) {
      event.setParams({
        action: 'track',
        name: name,
        properties: properties,
        status: Status.SUCCESS
      });
      event.fire();
    }
  };

  /**
   * Dispatches an error tracking event.
   * @param name {string} The name of the event.
   * @param properties {Object} The event properties.
   * @param error {string} The error associated with the event.
   */
  var trackError = function (name, properties, error) {
    var event = userEvent();
    if (event && event.setParams && event.fire) {
      event.setParams({
        action: 'track',
        name: name,
        properties: properties,
        status: Status.ERROR,
        error: error
      });
      event.fire();
    }
  };

  /**
   * Dispatches a cancel tracking event.
   * @param name {string} The name of the event.
   * @param properties {Object} The event properties.
   */
  var trackCancel = function (name, properties) {
    var event = userEvent();
    if (event && event.setParams && event.fire) {
      event.setParams({
        type: 'track',
        name: name,
        properties: properties,
        status: Status.CANCELED
      });
      event.fire();
    }
  };

  return Object.freeze({
    ToastMode: ToastMode,
    setLoading: setLoading,
    showToast: showToast,
    hideToast: hideToast,
    getErrorMessage: getErrorMessage,
    invokeAction: invokeAction,
    addEventProperties: addEventProperties,
    timeEvent: timeEvent,
    trackSuccess: trackSuccess,
    trackError: trackError,
    trackCancel: trackCancel
  });
};
