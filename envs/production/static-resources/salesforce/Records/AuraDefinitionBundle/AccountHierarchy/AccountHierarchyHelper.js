({
  CONSTANTS: {},

  controllers: {
    hierarchy: "LC_AccountHierarchy"
  },

  getRecordId: function(cmp) {
    return cmp.get("v.recordId");
  },

  init: function(cmp) {
    var self = this;
    var params = {
      actionName: "getHierarchy",
      recordId: this.getRecordId(cmp)
    };

    this.executeApex(cmp, {
      controllerName: this.controllers.hierarchy,
      params: params
    })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          console.log(res);
          cmp.set("v.hierarchy", res);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          self.isLoading(cmp, false);
          self.showServerError(cmp, err);
        })
      );
  }
});