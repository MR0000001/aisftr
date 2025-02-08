({
    doInit : function(component,event,helper) {

        component.set("v.showSpinner",true);
        let action= component.get("c.getIncentiveItems");
        action.setParams({"orderId":component.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = JSON.parse(response.getReturnValue());

                let legalEntity = result.legalEntity;
                let orderItems = result.ois;
                let orderStatus = result.orderStatus;
                let orderRT = result.orderRt;
                let ctiCall = result.isCallOngoing;
                let commChange = result.isInCommercialChange;
                let sid = result.sessionId;

                console.log("INCENTIVE ITEMS FOUND::: " + JSON.stringify(orderItems));
                component.set("v.legalEntity",legalEntity);
                component.set("v.orderRT",orderRT);
                component.set("v.showComponent",(  component.get("v.availableForLE").includes(legalEntity)  && component.get("v.availableForRT").includes(orderRT)));
                component.set("v.orderItems",orderItems);
                component.set("v.showItems",orderItems.length>0);
                component.set("v.orderStatus",orderStatus);
                component.set("v.isChangingOffer",commChange);
                component.set("v.sessionId",sid);
                // component.set("v.isFromCTI",ctiCall);

            }else{
                let msg = response.getError()[0].message;
                console.log("ERROR INIT INCENTIVE VIEW COMPONENT::: " + msg);
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);

    },

    subscribe : function(component,event,helper){

        // const empApi = component.find("empApi");
        // empApi.setDebugFlag(true);
        // empApi.onError($A.getCallback(error=>{
        //     console.error('EMP ERROR ON ORDER EVENT ' , error);
        // }));

        // //subscribe on CTI Platform Events
        // const replayId = -1;
        // const channel = component.get("v.evtChannel");
        // empApi.subscribe(channel,replayId,$A.getCallback(message =>{
        //     console.log('ORDER PLATFORM EVENT RECEIVED ' + JSON.stringify(message));
        //     if(message.data.payload.XC_RecordId__c == component.get("v.recordId")){
        //         helper.doInit(component,event,helper);
        //     }
        // })).then(subscription => {
        //     console.log('ORDER PLATFORM EVENT SUBSCRIPTION OK ' + subscription.channel);
        // });

        // $.cometd.websocketEnabled = false;
        // let sid = component.get("v.sessionId");
        // let recordId = component.get("v.recordId");
        // $.cometd.init({
        //     url : '/cometd/47.0/',
        //     requestHeaders: { Authorization: 'OAuth ' + sid},
        //     appendMessageTypeToURL: false
        // });

        // //subscription management
        // $.cometd.subscribe('/event/XC_OrderEvent__e',function(message){
        //     if (message.data.payload.XC_RecordId__c == recordId){
        //         console.log('opt Platform Event Received ' + JSON.stringify(message.data.payload));
        //         helper.doInit(component,event,helper);
        //     }
        // });
    },

    updateAdditionalInfos : function(component,event,helper,infos){
        let action = component.get("c.propagateAdditionalInfos");
        action.setParams({"paramsMap" : infos});

        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result){
                    component.set("v.showItems",false);
                    helper.doInit(component,event,helper);                }
            }else{
                console.log('ERROR ON SAVING ADDITIONAL INFOS ' + response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
    }

})