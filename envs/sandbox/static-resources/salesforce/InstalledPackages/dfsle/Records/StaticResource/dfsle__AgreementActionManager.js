var generateComponent = function(anchor, component, componentName, attributes) {
  return new Promise(function(resolve, reject) {
    try {
      // FIXME: No hardcoded strings that may be user-visible
      if (!anchor || !component || !componentName || !attributes)
        reject('invalid parameters');
      $A.createComponent(componentName, attributes, function(result, err, msg) {
        if (err && msg) reject(msg);
        var container = component.find(anchor);
        if (container && container.isValid()) {
          var body = container.get('v.body');
          body.push(result);
          container.set('v.body', body);
          resolve(result);
        } else {
          reject('cant find container');
        }
      });
    } catch (err) {
      reject('error generating component: ' + err);
    }
  });
};

var AgreementComponents = Object.freeze({
  Upload: 'AgreementsUploadNewVersion',
  Delete: 'AgreementsDelete',
  InternalApproval: 'AgreementsInternalApproval',
  ExternalReview: 'AgreementsExternalReview',
  Rename: 'AgreementsRename',
  Share: 'AgreementsShareLink',
  Download: 'AgreementDownload',
  ExportToSalesforce:'AgreementsExport'
});

function AgreementActionManager(anchor, namespace) {
  this.anchor = anchor;
  this.namespace = namespace;
  this.activeScope = null;
}

AgreementActionManager.prototype.getAgreement = function(
  component,
  agreementId
) {
  var action = component.get('c.getAgreement');

  return new Promise(function(resolve, reject) {
    action.setParams({
      agreementId: agreementId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        resolve(response.getReturnValue());
      } else if (state === 'ERROR') {
        reject(response.getError());
      }
    });
    $A.enqueueAction(action);
  });
};

AgreementActionManager.prototype.getDocumentPreviewLink = function(
  component,
  agreementId,
  sourceId
) {
  var action = component.get('c.getAgreementShareLink');

  return new Promise(function(resolve, reject) {
    action.setParams({
      agreementId: agreementId,
      sourceId: sourceId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        resolve(response.getReturnValue());
      } else if (state === 'ERROR') {
        reject(response.getError());
      }
    });
    $A.enqueueAction(action);
  });
};

AgreementActionManager.prototype.getComponentName = function(name) {
  return this.namespace + ':' + name;
};

AgreementActionManager.prototype.upload = function(
  agreementDetails,
  sourceId, 
  component
  ) {
  if (this.activeScope) this.activeScope.destroy();
  var self = this;
  generateComponent(
    this.anchor,
    component,
    this.getComponentName(AgreementComponents.Upload),
    {
      showModal: true,
      agreementDetails: agreementDetails,
      sourceId: sourceId
    }
  )
  .then(function(modalComponent) {
    self.activeScope = modalComponent;
  })
  .catch(function(err) {
    throw err;
  });
};

AgreementActionManager.prototype.delete = function(
  agreementDetails,
  component
) {
  if (this.activeScope) this.activeScope.destroy();
  var self = this;
  generateComponent(
    this.anchor,
    component,
    this.getComponentName(AgreementComponents.Delete),
    {
      showModal: true,
      agreementDetails: agreementDetails
    }
  )
  .then(function(modalComponent) {
    self.activeScope = modalComponent;
  })
  .catch(function(err) {
    throw err;
  });
};

AgreementActionManager.prototype.rename = function(
  agreementDetails,
  component
) {
  if (this.activeScope) this.activeScope.destroy();
  var self = this;
  generateComponent(
    this.anchor,
    component,
    this.getComponentName(AgreementComponents.Rename),
    {
      showModal: true,
      agreementDetails: agreementDetails
    }
  )
  .then(function(modalComponent) {
    self.activeScope = modalComponent;
  })
  .catch(function(err) {
    throw err;
  });
};

AgreementActionManager.prototype.internalApproval = function(
  agreementDetails,
  sourceId,
  component
) {
  if (this.activeScope) this.activeScope.destroy();
  var self = this;
  generateComponent(
    this.anchor,
    component,
    this.getComponentName(AgreementComponents.InternalApproval),
    {
      showModal: true,
      agreementDetails: agreementDetails,
      sourceId: sourceId
    }
  )
  .then(function(modalComponent) {
    self.activeScope = modalComponent;
  })
  .catch(function(err) {
    throw err;
  });
};

AgreementActionManager.prototype.externalReview = function(
  agreementDetails,
  sourceId, 
  component
) {
  if (this.activeScope) this.activeScope.destroy();
  var self = this;
  generateComponent(
    this.anchor,
    component,
    this.getComponentName(AgreementComponents.ExternalReview),
    {
      showModal: true,
      agreementDetails: agreementDetails,
      sourceId: sourceId
    }
  )
  .then(function(modalComponent) {
    self.activeScope = modalComponent;
  })
  .catch(function(err) {
    throw err;
  });
};

AgreementActionManager.prototype.share = function(agreementDetails, sourceId, component) {
  if (this.activeScope) this.activeScope.destroy();
  var self = this;
  generateComponent(
    this.anchor,
    component,
    this.getComponentName(AgreementComponents.Share),
    {
      showModal: true,
      agreementDetails: agreementDetails,
      onLoad: self.getDocumentPreviewLink.bind(self, component, agreementDetails.id.value, sourceId)
    }
  )
  .then(function(modalComponent) {
    self.activeScope = modalComponent;
  })
  .catch(function(err) {
    throw err;
  });
};

AgreementActionManager.prototype.download = function(agreementDetails, component, downloadWithRedlines) {
  if (this.activeScope) this.activeScope.destroy();
  var self = this;
  generateComponent(
    this.anchor,
    component,
    this.getComponentName(AgreementComponents.Download),
    {
      showModal: true,
      agreementDetails: agreementDetails,
      downloadWithRedlines: downloadWithRedlines
    }
  )
  .then(function(modalComponent) {
    self.activeScope = modalComponent;
  })
  .catch(function(err) {
    throw err;
  });
};

AgreementActionManager.prototype.exportToSalesforce = function(
  agreementDetails,
  sourceId,
  component
) {
  if (this.activeScope) this.activeScope.destroy();
  var self = this;
  generateComponent(
    this.anchor,
    component,
    this.getComponentName(AgreementComponents.ExportToSalesforce),
    {
      showModal: true,
      sourceId: sourceId,
      agreementDetails: agreementDetails
    }
  )
    .then(function(modalComponent) {
      self.activeScope = modalComponent;
    })
    .catch(function(err) {
      throw err;
    });
};
window.AgreementActionManager = AgreementActionManager;
