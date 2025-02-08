({
    doInit : function(component, event, helper) {
        if(component.get("v.cmpOrigin")=='QuickAction'){
            component.set("v.showSpinner",true);
            helper.updateConf(component,event,helper);
        }else if(component.get("v.cmpOrigin")=='RecordPage'){
            helper.getOrderInfo(component,event,helper);
        }
    },

    updateConf : function(component,event,helper){
        component.set("v.showSpinner",true);
        component.set("v.showCard",false);
        helper.updateConf(component,event,helper,false);
    },


    closeCartConf : function(component,event,helper){
        component.set("v.showSpinner",true);
        component.set("v.showCard",false);
        helper.updateConf(component,event,helper,true);
    }

    // manageCheckoutEvt : function(component,event,helper){
    //     let eventAction = event.getParam('action');
    //     if(eventAction == 'checkout'){
    //         var navEvt = $A.get("e.force:navigateToSObject");
    //         navEvt.setParams({
    //           "recordId": component.get("v.recordId"),
    //           "slideDevName": "detail"
    //         });
    //         navEvt.fire();
    //     }
    // }


})