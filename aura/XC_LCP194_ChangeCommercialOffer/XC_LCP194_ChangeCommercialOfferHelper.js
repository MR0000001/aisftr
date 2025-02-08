({
    updateConf : function(component,event,helper,closed) {
        let recordId = component.get("v.recordId");
        let action = component.get("c.changeCommercialOfferOnOrder");
        action.setParams({
            'configId': component.get("v.recordId"),
            'closed' : closed
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue !== null) {
                if(retValue.success) {
                    console.log('success');
                    helper.showMessage(component, "success", "Success!", "  Action complete  ");
                    
                    if(!closed){
                        let changeOfferEvt = $A.get("e.c:XC_LCE020_OrderCommChangeEvt");
                        changeOfferEvt.setParams({"eventAction" : "COMMERCIAL_CHANGE_START"});
                        changeOfferEvt.fire();
                        component.set("v.isPerformingChange",true);
                    }else{
                        let changeOfferEvt = $A.get("e.c:XC_LCE020_OrderCommChangeEvt");
                        changeOfferEvt.setParams({"eventAction" : "COMMERCIAL_CHANGE_FINISH"});
                        changeOfferEvt.fire();
                        component.set("v.isPerformingChange",false);
                    }

                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    window.location.reload();
                } else {
                    console.log('Error' + retValue.resultMessage);
                    helper.showMessage(component, "error", "Warning", retValue.resultMessage);
                    $A.get("e.force:closeQuickAction").fire();
                   
                   
                }
            } else {
                helper.showMessage(component, "error", "Warning", "");
                $A.get("e.force:closeQuickAction").fire();
            }
            //$A.get("e.force:closeQuickAction").fire();

            
        });
        $A.enqueueAction(action);   
    },



    showMessage: function (component, variante, title, mess) {

        let toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "title": title,
            "message": mess,
            "type": variante
        });
        toastEvent.fire();
       
    },

    getOrderInfo : function(component,event,helper){
        let action = component.get("c.getOrderInfo");
        action.setParams({"configId" : component.get("v.recordId")});
        action.setCallback(this,function(response){

            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                let availableRts = component.get("v.availableForRt");
                let availableLe = component.get("v.availableForLE");
                let availableStatuses = component.get("v.availableForStatuses");

                component.set("v.sessionId",result.sessionId);
                let showCardBool = availableRts.includes(result.rt) && availableLe.includes(result.legalEntity) && availableStatuses.includes(result.status);
                component.set("v.showCard",showCardBool);
                component.set("v.isPerformingChange",result.isChangingOffer);

                if(component.get("v.showCard")){
                    helper.subscribe(component,event,helper);
                }
            }else{
                console.log('ERROR ON INIT CARD OF CHANGE COMMERCIAL OFFER - LCP 194 ' + JSON.stringify(response.getError()[0].message));
            }
        });
        $A.enqueueAction(action);
    },

    subscribe : function(component,event,helper){

        let cometDNotConnected = $.cometd.isDisconnected();
        let recordId = component.get("v.recordId");

        
        if(cometDNotConnected){
            $.cometd.websocketEnabled = false;
            let sid = component.get("v.sessionId");
            $.cometd.init({
                url : '/cometd/47.0/',
                requestHeaders: { Authorization: 'OAuth ' + sid},
                appendMessageTypeToURL: false
            });
        }

        //subscription management
        $.cometd.subscribe('/event/XC_OrderEvent__e',function(message){
            let msgPayload = message.data.payload;
            if (msgPayload.XC_RecordId__c == recordId && msgPayload.XC_Type__c==$A.get("$Label.c.XC_CL_OrderEvent_COMMERCIALCHANGECOMPLETED")){
                console.log('opt Platform Event Received ' + JSON.stringify(message.data.payload));
                component.set("v.isPerformingChange",false);

               // let changeOfferEvent = $A.get("e.c:XC_LCE020_OrderCommChangeEvt");
                let changeOfferEvent = component.getEvent("changeOfferEvent");
                changeOfferEvent.setParams({"eventAction" : "COMMERCIAL_CHANGE_FINISH"});
                changeOfferEvent.fire();

                window.location.reload();
            }
        });
    }

})