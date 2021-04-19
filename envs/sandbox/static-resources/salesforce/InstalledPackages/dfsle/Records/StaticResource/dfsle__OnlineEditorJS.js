/* global jQuery, RemoteActions, Configuration, Labels, DSEditor, Visualforce, $Lightning  */
/* exported prepareOnlineEditorDocumentGenerator, prepareSendForSignature, cancelGeneration, exportHtmlDocument  */
jQuery.noConflict();

var prepareOnlineEditorDocumentGenerator;// eslint-disable-line no-unused-vars
var prepareSendForSignature;// eslint-disable-line no-unused-vars
var cancelGeneration;// eslint-disable-line no-unused-vars
var exportHtmlDocument;// eslint-disable-line no-unused-vars

// FIXME: Split JS file between edit and generate VF pages. Can share common functions in 3rd JS file.
// FIXME: Use consistent variable naming matching those in Apex layer.
jQuery(document).ready(function ($) {

  var _currentProgressStep = null;
  var _toastComponent;
  var _userEvents;
  var _sessionType;
  var _layoutMap = {};

  var EventLabels = Object.freeze({
    CREATE_TEMPLATE: 'Create Gen Template',
    UPDATE_TEMPLATE: 'Update Gen Template',
    PUBLISH_BUTTON: 'Publish Gen Button',
    PREVIEW_DOCUMENT: 'Preview Gen Document',
    GENERATE_DOCUMENT: 'Generate Gen Document'
  });

  var Elements = Object.freeze({
    spinner1: $('#ds-spinner'),
    buttons: {
      cancelPublish: $('#onlineEditorPublishCancel'),
      cancelTemplate: $('#onlineEditorTemplateCancel'),
      publish: $('#onlineEditorPublish'),
      saveClose: $('#onlineEditorSaveClose')
    }
  });

  if (Configuration.template) {
    $('#fileNameInput').val(Configuration.template.fileName);
    if (Configuration.template.fileSuffix) $('#fileSuffix').val(Configuration.template.fileSuffix);
  }

  var _editor = navUtils.isIE() ? null : new DSEditor({
    api: {
      getMergeFields: getMergeFields,
      getEntityRecords: getEntityRecords,
      getMergeData: getMergeData,
    },
    resourcePath: Configuration.translationPath,
  });

  displayStartupElements();
  hideAll();
  hideAllButtons();

  initializeUserEvents(Configuration.template ? Configuration.template.sourceObject : undefined)
    .then(function (userEvents) {
      _userEvents = userEvents;

      if (Configuration.isGenerating) _sessionType = EventLabels.GENERATE_DOCUMENT;
      else _sessionType = Configuration.isEditing ? EventLabels.UPDATE_TEMPLATE : EventLabels.CREATE_TEMPLATE;

      userEvents.time(_sessionType);

      if (navUtils.isIE()) $('#IEWarning').show();
      else if (Configuration.hasInitError) {
        createToastComponent(Configuration.initError, 'error');
        _userEvents.error(
          _sessionType,
          {},
          'Initialization error'
        );
      } else if (!Configuration.isGenerating) handleStepNavigation(1).onStart();
    })
    .catch(function (err) {
      createToastComponent(err, 'error');
    });

  function getSpringTemplateIdToString(template) {
    return template && template.springTemplateId ? template.springTemplateId.value : null;
  }

  function getMessage(message) {
    // TODO: Check other types. Get response body or other error details.
    if (message instanceof Response) {
      return message.statusText;
    }
    return message;
  }

  function createToastComponent(message, mode, detail) {
    if (_toastComponent) _toastComponent.destroy();
    $Lightning.use(Configuration.namespace + ':LightningOutApp', function () {
      $Lightning.createComponent(Configuration.namespace + ':Toast',
        {
          showToast: true,
          visualforce: true,
          message: getMessage(message),
          mode: mode,
          detail: $A.util.isEmpty(detail) ? null : detail
        },
        'toastNotificationContainer',
        function (cmp) {
          _toastComponent = cmp;
          if (_toastComponent && mode === 'success') {
            window.setTimeout($A.getCallback(function () {
              if (_toastComponent) {
                _toastComponent.destroy();
                _toastComponent = null;
              }
            }), 3000);
          }
        }
      );
    });
  }

  function initializeUserEvents(sourceObject) {
    return new Promise(function (resolve, reject) {
      try {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.getUserProperties,
          function (result, event) {
            if (event && event.status) {
              var userEvents = new UserEvents(
                result.application,
                result.version,
                result.environment,
                result.accountIdHash,
                result.userIdHash);
              userEvents.addProperties({
                'Product': 'Gen',
                'Template Type': 'Online Editor',
                'Source Object': stringUtils.sanitizeObjectName(sourceObject)
              });
              resolve(userEvents);
            } else {
              reject(event.message);
            }
          });
      } catch (err) {
        reject(err);
      }
    });
  }

  function getMergeFields() {
    return new Promise(
      function (resolve, reject) {
        if (!Configuration.template.sourceObject) reject(Labels.templateInvalidSourceLabel);
        try {
          Visualforce.remoting.Manager.invokeAction(
            RemoteActions.getMergeFields,
            Configuration.template.sourceObject,
            function (result, event) {
              if (event.status) {
                resolve(result);
              } else {
                _userEvents.error(
                  EventLabels.PREVIEW_DOCUMENT,
                  {},
                  'Failed to preview'
                );
                createToastComponent(event.message, 'error');
                reject(event.message);
              }
            });
        } catch (err) {
          _userEvents.error(
            EventLabels.PREVIEW_DOCUMENT,
            {},
            'Failed to preview'
          );
          createToastComponent(err, 'error');
          reject(err);
        }
      }
    );
  }

  function getMergeData(sourceId, queryTree) {
    return new Promise(
      function (resolve, reject) {
        if (!sourceId) reject(Labels.templateInvalidSourceLabel);
        try {
          var convertedQuery = convertQuery(queryTree);
          Visualforce.remoting.Manager.invokeAction(
            RemoteActions.getMergeData,
            sourceId,
            convertedQuery.queryTree,
            convertedQuery.useCurrentDate,
            function (result, event) {
              if (event.status) {
                resolve(result);
              } else {
                _userEvents.error(
                  EventLabels.PREVIEW_DOCUMENT,
                  {},
                  'Get merge data error'
                );
                createToastComponent(event.message, 'error', Labels.UnauthorizedQueryMessage);
                reject(event.message);
              }
            });
        } catch (err) {
          _userEvents.error(
            EventLabels.PREVIEW_DOCUMENT,
            {},
            'Get merge data error'
          );
          createToastComponent(err, 'error');
          reject(err);
        }
      }
    );
  }

  function convertQuery(queryTree) {
    var useCurrentDate = false;
    queryTree.fields = queryTree.fields ? queryTree.fields.filter(function(f) {
      if (f.name === 'CurrentDate') useCurrentDate = true;
      return f.name !== 'CurrentDate';
    }) : [];
    return {
      queryTree: JSON.stringify(queryTree),
      useCurrentDate: useCurrentDate
    }
  }


  function getEntityRecords(index, searchValue) {
    return new Promise(
      function (resolve, reject) {
        try {
          var pageIndex = index === undefined || index === null ? 0 : index;
          Visualforce.remoting.Manager.invokeAction(
            RemoteActions.getEntityRecords,
            Configuration.template.sourceObject,
            pageIndex,
            searchValue || '',
            function (entityRecords, event) {
              if (event.status) {
                _userEvents.success(
                  EventLabels.PREVIEW_DOCUMENT,
                  {}
                );
                resolve(entityRecords);
              } else {
                _userEvents.error(
                  EventLabels.PREVIEW_DOCUMENT,
                  {},
                  'Get entity records error'
                );
                createToastComponent(event.message, 'error');
                reject(event.message);
              }
            },
            {
              escape: false
            });
        } catch (err) {
          _userEvents.error(
            EventLabels.PREVIEW_DOCUMENT,
            {},
            'Get entity records error'
          );
          createToastComponent(err, 'error');
          reject(err);
        }
      }
    );
  }

  function deleteTemplate(templateId, isEditing) {
    return new Promise(
      function (resolve, reject) {
        if (isEditing || !templateId) {
          resolve(false);
        } else {
          try {
            Visualforce.remoting.Manager.invokeAction(
              RemoteActions.deleteTemplate,
              templateId,
              function (result, event) {
                if (event.status) {
                  resolve(result);
                } else {
                  reject(event.message);
                }
              });
          } catch (err) {
            reject(err);
          }
        }
      });
  }

  function getObjectLayouts(sourceObject) {
    return new Promise(
      function (resolve, reject) {
        try {
          Visualforce.remoting.Manager.invokeAction(
            RemoteActions.getLayouts,
            sourceObject,
            function (result, event) {
              if (event.status) {
                resolve(result);
              } else {
                reject(event.message);
              }
            });
        } catch (err) {
          reject(err);
        }
      });
  }

  function getTemplateFolderId() {
    return new Promise(function (resolve, reject) {
      try {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.getTemplateFolderId,
          function (result, event) {
            if (event.status) {
              resolve(result);
            } else {
              reject(event.message);
            }
          });
      } catch (err) {
        reject(err);
      }
    });
  }

  function generateUploadToken(entityId) {
    return new Promise(function (resolve, reject) {
      try {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.generateUploadToken,
          entityId,
          function (result, event) {
            if (event.status) {
              resolve(result);
            } else {
              reject(event.message);
            }
          });
      } catch (err) {
        reject(err);
      }
    });
  }

  function updateTemplateIdInSalesforce(springTemplateIdUUID) {
    var clonedTemplateConfiguration = Object.assign({}, Configuration.template);
    clonedTemplateConfiguration.springTemplateId = springTemplateIdUUID;
    var templateJson = JSON.stringify(clonedTemplateConfiguration);
    return new Promise(function (resolve, reject) {
      try {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.updateTemplateIdInSalesforce,
          templateJson,
          function (result, event) {
            if (event.status) {
              resolve(Object.freeze(result));
            } else {
              reject(event.message);
            }
          });
      } catch (err) {
        reject(err);
      }
    });
  }

  function getSpringTemplateIdInUUIDFormat(springTemplateId) {
    return new Promise(function (resolve, reject) {
      try {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.getSpringTemplateIdInUUIDFormat,
          springTemplateId,
          function (result, event) {
            if (event.status) {
              resolve(result);
            } else {
              reject(event.message);
            }
          });
      } catch (err) {
        reject(err);
      }
    });
  }

  function updateObjectLayouts(sourceObject, selectedLayouts, parameters) {
    return new Promise(function (resolve, reject) {
      try {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.updateLayouts,
          sourceObject,
          JSON.stringify(selectedLayouts),
          JSON.stringify(parameters),
          function (result, event) {
            if (event.status) {
              resolve(result);
            } else {
              reject(event.message);
            }
          });
      } catch (err) {
        reject(err);
      }
    });
  }

  function updateFileDetailsInSalesforce(fileName, fileSuffix) {
    var clonedTemplateConfiguration = Object.assign({}, Configuration.template);
    clonedTemplateConfiguration.fileName = fileName;
    clonedTemplateConfiguration.fileSuffix = fileSuffix;
    var templateJson = JSON.stringify(clonedTemplateConfiguration);
    return new Promise(function (resolve, reject) {
      try {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.updateFileDetailsInSalesforce,
          templateJson,
          function (result, event) {
            if (event.status) {
              resolve(Object.freeze(result));
            } else {
              reject(event.message);
            }
          });
      } catch (err) {
        reject(err);
      }
    });
  }

  function generateDownloadToken(springTemplateId) {
    return new Promise(function (resolve, reject) {
      try {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.generateDownloadToken,
          springTemplateId,
          function (result, event) {
            if (event.status) {
              resolve(result);
            } else {
              reject(event.message);
            }
          });
      } catch (err) {
        reject(err);
      }
    });
  }

  function launchOnlineEditor(element, template, isEditing) {
    return isEditing && template && template.springTemplateId
      ? generateDownloadToken(getSpringTemplateIdToString(template))
        .then(function (accessToken) {
          return renderEditor(accessToken, element, template.name, null, false);
        })
        .then(function () {
          return template;
        })
      : new Promise(function (resolve, reject) {
        try {
          _editor.render(element, false, getLocaleString());
          resolve(template);
        } catch (err) {
          reject(err);
        }
      });
  }

  function exportDocument(type) {
    return _editor.exportDocument(type)
      .then(function (data) {
        if (data && data.success) {
          return data.data;
        }
        throw data ? data.errors : Labels.templateExportDataIsUndefinedLabel;
      });
  }

  function addOnlineEditorActions(layout, buttonApiName, buttonLabelName) {
    layout.actions = [];
    layout.actions.push({
      type: Configuration.layoutActionType,
      name: buttonApiName,
      label: buttonLabelName
    });
    return layout;
  }

  function removeOnlineEditorActions(layout) {
    layout.actions = [];
    return layout;
  }

  function hasOnlineEditorAction(layout, templateId) {
    if (layout.actions && layout.actions.length !== 0) {
      for (var j = 0; j < layout.actions.length; j++) {
        if (layout.actions[j].type === Configuration.layoutActionType && layout.actions[j].name.indexOf(templateId) >= 0) {
          return true;
        }
      }
    }
    return false;
  }

  //UI Handlers
  function handleStepNavigation(step) {
    if (step === null || step === undefined || step > 2 || step < 1) {
      createToastComponent(Labels.templateInvalidPathLabel, 'error');
      _userEvents.error(
        _sessionType,
        {},
        'Navigation step error'
      );
      return;
    }

    _currentProgressStep = step;

    var activeClassName = 'slds-is-active';
    var currentClassName = 'slds-is-current';
    var completedClassName = 'slds-is-complete';
    var incompleteClassName = 'slds-is-incomplete';

    var progressStepElements = [
      $('#onlineEditorStep1'),
      $('#onlineEditorStep2')
    ];

    progressStepElements.forEach(function (stepElement, index) {
      var stepNum = index + 1;
      if (stepNum === step) {
        stepElement.addClass(activeClassName);
        stepElement.addClass(currentClassName);
        stepElement.removeClass(completedClassName);
        stepElement.removeClass(incompleteClassName);
      } else if (stepNum < step) {
        stepElement.removeClass(activeClassName);
        stepElement.removeClass(currentClassName);
        stepElement.addClass(completedClassName);
        stepElement.removeClass(incompleteClassName);
      } else {
        stepElement.removeClass(activeClassName);
        stepElement.removeClass(currentClassName);
        stepElement.removeClass(completedClassName);
        stepElement.addClass(incompleteClassName);
      }
    });

    switch (step) {
      case 1:
        return {
          onStart: function () {
            hideAll();
            showSpinner();
            renderOnlineEditor()
              .then(function () {
                $('#onlineEditorToolBar').show();
                $('#topPanel').show();
                $('#onlineEditor').show();
                Elements.spinner1.hide();
                //Buttons
                //Step 1
                Elements.buttons.cancelTemplate.show();
                Elements.buttons.saveClose.show();
                //Step 2
                Elements.buttons.cancelPublish.hide();
                Elements.buttons.publish.hide();
              })
              .catch(function (err) {
                _userEvents.error(
                  _sessionType,
                  {},
                  'Editor render error'
                );
                createToastComponent(err, 'error');
              });
          }
        };
      case 2:
        return {
          onStart: function () {
            $('#onlineEditorToolBar').hide();
            showSpinner();
          },

          onEnd: function () {
            $('#onlineEditorToolBar').show();
            Elements.spinner1.hide();
            $('#inputFilePanel').show();
            //Step 1
            Elements.buttons.cancelTemplate.hide();
            Elements.buttons.saveClose.hide();
            //Step 2
            Elements.buttons.cancelPublish.show();
            Elements.buttons.publish.show();
          }
        };
    }
  }

  function renderOnlineEditor() {
    return launchOnlineEditor(document.getElementById('onlineEditor'), Configuration.template, Configuration.isEditing);
  }

  function hideAllButtons() {
    //Step 1
    Elements.buttons.cancelTemplate.hide();
    Elements.buttons.saveClose.hide();
    //Step 2
    Elements.buttons.cancelPublish.hide();
    Elements.buttons.publish.hide();
  }

  function setLayoutOptions(layouts, templateId) {
    return new Promise(
      function (resolve, reject) {
        try {
          var layoutsById = {};
          for (var i = 0; i < layouts.length; i++) {
            var layout = layouts[i];
            layoutsById[layout.id] = layout;
            var checked = !Configuration.isEditing || hasOnlineEditorAction(layout, templateId) ? 'checked' : '';
            $('#layoutCheckboxes').append('<div class="slds-form-element slds-p-bottom--small"><div class="slds-form-element__control"><div class="slds-checkbox"><input type="checkbox" class="layout-checkbox" name="layoutCheckboxI" id="' + layout.id + '" value="' + layout.id + '" ' + checked + '/><label class="slds-checkbox__label" for="' + layout.id + '"><span class="slds-checkbox_faux layout-default"></span><span class="slds-form-element__label onlineEditorContentText">' + layout.name + '</span></label></div></div></div>');
          }
          resolve(layoutsById);
        } catch (err) {
          reject(err);
        }
      });
  }

  function hideAll() {
    $('#onlineEditorGenerator').hide();
    $('#onlineEditor').hide();
    $('#topPanel').hide();
    $('#onlineEditorToolBar').hide();
    $('#inputFilePanel').hide();
    $('#namingHelp').hide();
  }

  function displayStartupElements() {
    $('.hide-on-start-up').removeClass('hide-on-start-up');
  }

  function showSpinner() {
    hideAll();
    Elements.spinner1.show();
  }

  //Navigate back to step 1
  function editOnlineEditorTemplateDetails() {
    var navStep = handleStepNavigation(1);
    navStep.onStart();
  }

  cancelGeneration = function () {
    if (Configuration.isGenerating && _userEvents) _userEvents.cancel(EventLabels.GENERATE_DOCUMENT);
  };

  Elements.buttons.cancelTemplate.click(function () {
    deleteTemplate(Configuration.template.id, Configuration.isEditing)
      .then(function () {
        if (Configuration.isGenerating || !Configuration.isEditing) _userEvents.cancel(_sessionType);
        navUtils.navigateToUrlOnlineEditor(Configuration.templateListUrl, true);
      })
      .catch(function (error) {
        createToastComponent(error, 'error');
        _userEvents.error(
          _sessionType,
          {},
          'Cancel template error'
        );
      });
  });

  function getUploadEntityId(templateId) {
    return templateId ? new Promise(function (resolve) {
      resolve(templateId);
    }) : getTemplateFolderId();
  }

  function onlineEditorSaveClose(templateId, springTemplateId, isEditing, templateName) {
    var navStep = handleStepNavigation(2);
    navStep.onStart();
    var editorData;
    // FIXME: Consolidate some of these actions.
    exportDocument()
      .then(function (data) {
        editorData = data;
        return getUploadEntityId(springTemplateId);
      })
      .then(function (entityId) {
        return generateUploadToken(entityId);
      })
      .then(function (token) {
        return isEditing
          ? SpringCM.Methods.Upload.uploadNewDocumentVersionBytes(
            token.apiUploadBaseUrl,
            token.token,
            token.accountId.value,
            token.entityId.value,
            editorData,
            templateName + '.adft')
          : SpringCM.Methods.Upload.uploadNewDocumentBytes(
            token.apiUploadBaseUrl,
            token.token,
            token.accountId.value,
            token.entityId.value,
            editorData,
            templateName + '.adft');
      })
      .then(function (response) {
        if (!response || !response.Href) throw Labels.templateSCMHrefUndefinedLabel;
        return response.Href.substring(response.Href.lastIndexOf('/') + 1);
      })
      .then(function (springTemplateGUID) {
        return getSpringTemplateIdInUUIDFormat(springTemplateGUID);
      })
      .then(function (springTemplateIdUUID) {
        return updateTemplateIdInSalesforce(springTemplateIdUUID);
      })
      .then(function (t) {
        Configuration.template = t;
        return getObjectLayouts(t.sourceObject);
      })
      .then(function (layouts) {
        if (!$('#layoutCheckboxes').is(':empty')) return null;
        return setLayoutOptions(layouts, Configuration.template.id);
      })
      .then(function (layoutsById) {
        _layoutMap = layoutsById;
        createToastComponent((isEditing ? Labels.templateUpdatedLabel : Labels.templateCreatedLabel).replace('{0}', Configuration.template.name), 'success');
        _userEvents.success(
          _sessionType,
          {}
        );
        navStep.onEnd();
      })
      .catch(function (error) {
        Elements.spinner1.hide();
        _userEvents.error(
          _sessionType,
          {},
          'Save error'
        );
        createToastComponent(error, 'error');
      });
  }

  function onlineEditorPublish(template, buttonLabel) {
    var buttonApiName = template.id;
    var selectedLayouts = [];

    return new Promise(function (resolve, reject) {
      if (!template) reject(Labels.templateUndefinedLabel);

      showSpinner();

      updateFileDetailsInSalesforce($('#fileNameInput').val(), $('#fileSuffix').val())
        .then(function (t) {
          Configuration.template = t;
          buttonApiName = Configuration.layoutActionName + buttonApiName;

          $.each($('input[name="layoutCheckboxI"]:checked'), function () {
            var layout = _layoutMap[$(this).val()];
            delete _layoutMap[$(this).val()];
            selectedLayouts.push(addOnlineEditorActions(layout, buttonApiName, buttonLabel));
          });

          for (var layoutId in _layoutMap) {
            if (_layoutMap.hasOwnProperty(layoutId)) {
              selectedLayouts.push(removeOnlineEditorActions(_layoutMap[layoutId]));
            }
          }

          var parameters = {
            genButtonApiName: buttonApiName,
            genButtonLabel: buttonLabel,
            genTemplateId: t.id
          };

          return updateObjectLayouts(template.sourceObject, selectedLayouts, parameters);
        })
        .then(function () {
          resolve(selectedLayouts.length);
        });
    });
  }

  function onlineEditorPublishCancel(templateId, isEditing) {
    deleteTemplate(templateId, isEditing)
      .then(function () {
        if (!isEditing) _userEvents.cancel(_sessionType);
        navUtils.navigateToUrlOnlineEditor(Configuration.templateListUrl, true);
      })
      .catch(function (error) {
        _userEvents.error(
          _sessionType,
          {},
          'Cancel publish error'
        );
        createToastComponent(error, 'error');
      });
  }

  Elements.buttons.cancelPublish.click(function () {
    onlineEditorPublishCancel(Configuration.template.id, Configuration.isEditing);
  });

  Elements.buttons.saveClose.click(function () {
    onlineEditorSaveClose(Configuration.template.id, getSpringTemplateIdToString(Configuration.template),
      Configuration.isEditing, Configuration.template.name);
  });

  Elements.buttons.publish.click(function () {
    _userEvents.time(EventLabels.PUBLISH_BUTTON);
    onlineEditorPublish(Configuration.template, $('#onlineEditorButtonNameInput').val())
      .then(function (layoutCount) {
        _userEvents.success(
          EventLabels.PUBLISH_BUTTON,
          {
            Layouts: layoutCount
          }
        );
        createToastComponent(Labels.templatePublishedLabel.replace('{0}', Configuration.template.name), 'success');
        window.setTimeout(function () {
          if (_toastComponent) _toastComponent.destroy();
          navUtils.navigateToSObject(Configuration.template.id);
        }, 3000);
      })
      .catch(function (error) {
        _userEvents.error(
          _sessionType,
          {},
          'Button publish error'
        );
        createToastComponent(error, 'error');
      });
  });


  //Step 1
  $('#onlineEditorStepLink1').click(function () {
    hideAll();
    editOnlineEditorTemplateDetails();
  });

  //Step 2
  $('#onlineEditorStepLink2').click(function () {
    if (_currentProgressStep === 2) return;
    var template = Configuration.template;
    if (!template || !template.id || !template.springTemplateId || !template.sourceObject) {
      _userEvents.error(
        _sessionType,
        {},
        'Template undefined'
      );
      createToastComponent(Labels.templateSaveValidationLabel, 'error');
      return;
    }
    hideAll();
    var navStep = handleStepNavigation(2);
    navStep.onStart();
    if (!$('#layoutCheckboxes').is(':empty')) {
      navStep.onEnd();
    } else {
      getObjectLayouts(template.sourceObject)
        .then(function (result) {
          return setLayoutOptions(result, template.id);
        })
        .then(function (layoutsById) {
          _layoutMap = layoutsById;
          navStep.onEnd();
        })
        .catch(function (error) {
          createToastComponent(error, 'error');
          _userEvents.error(
            _sessionType,
            {
              layouts: Object.keys(_layoutMap)
            },
            'Button publish error'
          );
        });
    }
  });

  // OnlineEditor document generation
  prepareOnlineEditorDocumentGenerator = (function () {
    if (!Configuration.isGenerating) return;
    return function () {
      return new Promise(function (resolve, reject) {
        if (Configuration.template) {
          $('#onlineEditorGenerator').show();
          generateDownloadToken(getSpringTemplateIdToString(Configuration.template))
            .then(function (accessToken) {
              return renderEditor(accessToken, document.getElementById('onlineEditorGenerator'), Configuration.template.name, Configuration.sourceId, true);
            })
            .then(function (response) {
              resolve(response);
            })
            .catch(function (err) {
              createToastComponent(err, 'error', Labels.UnauthorizedQueryMessage);
              _userEvents.error(
                _sessionType,
                {},
                'Failed to initialize online editor');
              reject(err);
            });
        } else {
          createToastComponent(Labels.templateUndefinedLabel, 'error');
          _userEvents.error(
            _sessionType,
            {},
            'Template undefined'
          );
          reject(Labels.templateUndefinedLabel);
        }
      });
    };
  })();

  function parseError(response) {
    if (!response || !response.json) return Promise.resolve('');

    return new Promise(function (resolve, reject) {
      response.json()
        .then(function (body) {
          var hasError = body && body.Error;
          resolve(stringUtils.format(Labels.apiError_3,
            hasError && body.Error.HttpStatusCode ? body.Error.HttpStatusCode : 0,
            hasError && body.Error.UserMessage ? body.Error.UserMessage : Labels.templateExportDataIsUndefinedLabel,
            hasError && body.Error.ReferenceId ? body.Error.ReferenceId : ''));
        })
        .catch(function () {
          reject(Labels.templateExportDataIsUndefinedLabel);
        });
    });
  }

  function renderEditor(limitedAccessToken, element, templateName, sourceId, isGenerating) {
    return new Promise(function (resolve, reject) {
      new SpringCM.Widgets.Download.downloadDocument(
        limitedAccessToken.apiDownloadBaseUrl,
        limitedAccessToken.token,
        limitedAccessToken.accountId.value,
        limitedAccessToken.entityId.value,
        templateName + '.adft',
        false)
        .then(function (data) {
          var reader = new FileReader();
          reader.readAsArrayBuffer(data);
          reader.onloadend = function () {
            // FIXME: Typed arrays not available in ES5, but no good alternative here.
            var fileBytes = new Uint8Array(reader.result); // eslint-disable-line no-undef
            _editor.importDocument(fileBytes, sourceId).then(function () {
              _editor.render(element, isGenerating, getLocaleString());
              resolve(true);
            });
          };
        })
        .catch(function (err) {
          return parseError(err).then(function (msg) {
            reject(msg);
          });
        });
    });
  }

  $('#onlineEditorCancelGeneration').click(function () {
    navUtils.navigateToSObject(Configuration.sourceId);
  });

  function getPlaceholderRecipients(templateName) {
    var rs = _editor.getRecipients();
    return {
      templateName: templateName,
      recipients: rs ? rs.filter(function (r) {
        return r && r.recipientId;
      }).map(function (r) {
        return {
          envelopeRecipientId: r.recipientId,
          role: r.placeholderName
        };
      }) : null
    };
  }

  prepareSendForSignature = (function () {
    return function (scmFile) {
      hideAll();
      var size = 0;
      var pageUrl = Configuration.sendingUrl;
      if (pageUrl.indexOf('?') !== -1) {
        pageUrl += '&';
      } else {
        pageUrl += '?';
      }
      // noinspection SpellCheckingInspection
      pageUrl += 'sId=' + encodeURIComponent(Configuration.sourceId)
        + '&phrs=' + encodeURIComponent(JSON.stringify(getPlaceholderRecipients()))
        + '&files=' + encodeURIComponent(scmFile)
        + '&lock=1'
        + '&loadDefaultContacts=0'
        + '&sendNow=1';
      _userEvents.success(_sessionType, {'Size': size});
      window.open(pageUrl, '_self');
    };
  })();

  var renderTemplateDetails = function () {
    window.location.reload();
  };

  exportHtmlDocument = (function () {
    return function () {
      return exportDocument('html');
    };
  })();

  $('#onlineEditorEdit').click(function () {
    $Lightning.use(Configuration.namespace + ':LightningOutApp', function () {
      $Lightning.createComponent(Configuration.namespace + ':OnlineEditorTemplateEdit',
        {
          recordId: Configuration.template.id,
          namespace: Configuration.namespace,
          renderTemplateDetails: renderTemplateDetails
        },
        'editModal',
        function () {
        }
      );
    });
  });

  function getLocaleString() {
    switch (Configuration.userLanguage.toLowerCase()) {
      case 'pt_br':
      case 'zh_cn':
      case 'zh_tw':
        return Configuration.userLanguage.replace('_', '-');
      default:
        return Configuration.userLanguage.split('_')[0];
    }
  }
});
