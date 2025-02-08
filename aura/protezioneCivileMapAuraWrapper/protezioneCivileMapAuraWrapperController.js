({
  closeQA: function (component, event, helper) {
    $A.get('e.force:closeQuickAction').fire();
  },

  doInit: function (component, event, helper) {
    var rec = component.get('v.recordId');
    console.log('il tuo record id ', rec);
  }
});