({
  initEnvironment: function (component, event, helper) {
    let action = component.get("c.isInCommunity");
    action.setParams({"confItemId" : component.get("v.recordId")});// gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187
    action.setCallback(this, function (a) {
      let state = a.getState();
      if (state === "SUCCESS") {
        let result = a.getReturnValue();
        // START gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187 --> add else
        if(!result.success){
          helper.showToast(component, event, helper, result.resultMessage, 'error');
          $A.get("e.force:closeQuickAction").fire();
        }
        else if(result.isInCommunity){
          component.set("v.isCommunity", result.isInCommunity);
          helper.initSitePrefix(component,event,helper);
       }
      // END gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187 --> 
        else {
          helper.checkPossibilityToCreate(component, event, helper);
        }
      }
    });
    $A.enqueueAction(action);
  },

  initSitePrefix: function (component, event, helper) {
    let action = component.get("c.getVisualforceRelativeURL");
    action.setCallback(this, function (a) {
      let state = a.getState();
      if (state === "SUCCESS") {
        let result = a.getReturnValue();
        if (result != null) {
          component.set("v.sitePrefix", result);
          console.log("URL=" + result);
          helper.checkPossibilityToCreate(component, event, helper);
        }
      }
    });
    $A.enqueueAction(action);
  },

  checkPossibilityToCreate: function (component, event, helper) {
    let recordId = component.get("v.recordId");
    let sitePrefix = component.get("v.sitePrefix");
    let isCommunity = component.get("v.isCommunity");
    if (isCommunity) {
      component.set(
        "v.urlNextStepB2W",
        sitePrefix + "/apex/NE__NextStepPage?Id=" + recordId
      );
    } else {
      component.set(
        "v.urlNextStepB2W",
        "/apex/NE__NextStepPage?Id=" + recordId
      );
    }

    let action = component.get("c.checkOptyCreation");
    action.setParams({ recordId: recordId });
    action.setCallback(this, function (a) {
      let state = a.getState();
      if (state === "SUCCESS") {
        let result = a.getReturnValue();
        if (result.success) {
          let spinner = component.find("mySpinner");
          let delay = 800; //4 seconds
          setTimeout(function () {
            $A.util.toggleClass(spinner, "slds-hide");
          });

          component.set("v.showNextStepModal", true);

          // if(isCommunity){
          //     let url = component.get("v.urlNextStepB2W");
          //     let urlEvent = $A.get("e.force:navigateToURL");
          //     urlEvent.setParams({ "url": url });
          //     urlEvent.fire();
          // }
          // else{
          //     if(typeof sforces != 'undefined' && typeof sforce.one != 'undefined' && sforce.one != null){
          //         sforce.one.navigateToURL(url,true); //("/apex/NE__NextStepPage?Id="+"{!recordId}", true);
          //     }else {
          //         let url = component.get("v.urlNextStepB2W");
          //         $A.get("e.force:closeQuickAction").fire();
          //         window.open(url, "", "left=460,top=200,width=370,height=270,titlebar=0,toolbar=0,status=0,menubar=0,resizable=0,scrollbars=no");
          //     }
          // }
        } else {
          if (result.typeMessage == "noPhone") {
            component.set("v.phoneInsert", result.resultMessage);
            component.set("v.showInsertPhone", true);
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
          } else {
            helper.showToast(
              component,
              event,
              helper,
              result.resultMessage,
              "error"
            );
            $A.get("e.force:closeQuickAction").fire();
          }
        }
      }
    });
    $A.enqueueAction(action);
  },

  createPhoneOnAccount: function (component, event, helper) {
    var action = component.get("c.newPhone");
    var phonePrefix = component.get("v.phonePrefix");
    var phoneNumber = component.get("v.phoneNumber");
    var docInfo = {
      phonePrefix: phonePrefix,
      phoneNumber: phoneNumber,
    };
    var docInfoJSON = JSON.stringify(docInfo);
    action.setParams({
      orderId: component.get("v.recordId"),
      phoneValues: docInfoJSON,
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var retValue = response.getReturnValue();

      if (state === "SUCCESS" && retValue.success) {
        component.set("v.showInsertPhone", false);
        helper.showToast(
          component,
          event,
          helper,
          "Phone inserted correctly",
          "success"
        ); //$A.get("$Label.c.XC_CL_DocumentCreationOK")
        $A.get("e.force:closeQuickAction").fire();
      } else {
        helper.showToast(
          component,
          event,
          helper,
          "Warning: " + retValue.resultMessage,
          "error"
        );
      }
    });

    $A.enqueueAction(action);
  },

  showToast: function (component, event, helper, message, mType) {
    component.find("notifLib").showToast({
      title: message,
      message: "",
      variant: mType,
    });
  },
});