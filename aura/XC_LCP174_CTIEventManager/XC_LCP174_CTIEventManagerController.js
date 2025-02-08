({
    init : function(component, event, helper) {

        let action = component.get("c.checkCTIUserEnabled");

        action.setCallback(this, function (a) {
            let result = a.getReturnValue();

            if (result) {

                const empApi = component.find("empApi");
                empApi.setDebugFlag(true);
                empApi.onError($A.getCallback(error=>{
                    console.error('EMP ERROR ON CTI EVENT ' , error);
                }));
        
                //subscribe on CTI Platform Events
                const replayId = -1;
                const channel = component.get("v.evtChannel");
                empApi.subscribe(channel,replayId,$A.getCallback(message =>{
                    console.log('CTI PLATFORM EVENT RECEIVED ' + JSON.stringify(message));
                    helper.manageEvent(component,event,helper,message.data.payload);
                })).then(subscription => {
                    console.log('CTI PLATFORM EVENT SUBSCRIPTION OK ' + subscription.channel);
                });

            } 
            
        });

        $A.enqueueAction(action);
    }
})