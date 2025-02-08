({

    doInit: function (component, event, helper) {

        //call init and subscribe to platform events

        let action = component.get("c.initScriptContainerCmp");
        let recordId = component.get("v.recordId");
        action.setParams({objectId : recordId});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result.showComponent){

                    //show the markup and subscribe
                    component.set("v.showComponent",true);
                    component.set("v.useCongaTrigger",result.useCongaTrigger);

                    if(result.scripts){
                        component.set("v.congaTriggerScripts",result.scripts);
                    }

                    const empApi = component.find("empApi");
                    empApi.setDebugFlag(true);
                    empApi.onError($A.getCallback(error => {
                        console.error('EMP ERROR ON CTI EVENT ', error);
                    }));
            
                    //subscribe on CTI Platform Events
                    const replayId = -1;
                    const channel = component.get("v.evtChannel");
                    empApi.subscribe(channel, replayId, $A.getCallback(message => {
                        console.log('CTI PLATFORM EVENT RECEIVED ' + JSON.stringify(message));
                        helper.manageEvent(component,event,helper,message.data.payload);
                    })).then(subscription => {
                        console.log('CTI PLATFORM EVENT SUBSCRIPTION OK ' + subscription.channel);
                    });

                }
            }else{
                console.log('ERROR ON INIT SCRIPT CMP::: ' + response.getError()[0].message);
            }

        });
        $A.enqueueAction(action);
    },

    showScript: function (component, event, helper) {
        if(component.get("v.useCongaTrigger")){
            component.set("v.showCongaTrCmp",true);
        }else{
            component.set("v.showScriptModal", true);
        }
    }
})