({
    doInit : function(component, event, helper) {

        helper.doInit(component,event,helper);
        helper.subscribe(component,event,helper);
 
    },

    manageCommChangeEvt : function(component,event,helper){

        let eventAction = event.getParam("eventAction");
        console.log('EVENT ACTION RECEIVED ' + eventAction);
        if(eventAction == 'COMMERCIAL_CHANGE_START'){
            component.set("v.isChangingOffer",true);
        }else if(eventAction == 'COMMERCIAL_CHANGE_FINISH'){
            component.set("v.isChangingOffer",false);
        }
    },

    refreshView : function(component,event,helper){
        component.set("v.showItems",false);
        helper.doInit(component,event,helper);
    },

    handleAdditionalFieldEvent : function(component,event,helper){

        let evtData = event.getParam("Data");
        console.log("evtData >>> " + JSON.stringify(evtData));
        evtData["orderId"] = component.get("v.recordId");
        console.log('EVENT DATA RECIVED:: ' + JSON.stringify(evtData));
        helper.updateAdditionalInfos(component,event,helper,evtData);

    }

})