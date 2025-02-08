({
    getInitInformation: function (cmp, evt, hlp) {    
        let action = cmp.get("c.getInitInformation");
        cmp.set("v.showSpinner",true);
        action.setParams({
            "recordId": cmp.get('v.recordId')
        });
        action.setCallback(this, function (resp) {
            let state = resp.getState();
            if (state === "SUCCESS"){
                cmp.set("v.showSpinner",false);
                let result = resp.getReturnValue();
                let objInfo = [];
   
                hlp.getDataInit(cmp, evt, hlp);
                
                if(result.success){
                    objInfo = JSON.parse(result.objectInfo);
                    cmp.set("v.isCommunity", objInfo['isCommunity']);
                    cmp.set("v.sessionId",objInfo["sessionId"]);
                    //hlp.subscribe(cmp, evt, hlp);
                }
            }else{
                cmp.set("v.showSpinner",false);
                let errorMessage = resp.getError()[0].message;
                console.log('ERROR ON INIT LCP DOCUMENT SIGNATURE ' + errorMessage);
            }
            
        });



        $A.enqueueAction(action);
    },

    /*
    subscribe: function (cmp, evt, hlp) {
        const channel = '/event/XC_DigitalSignature__e'
        const empApi = cmp.find('empApi')
        const recordId = cmp.get('v.recordId')

        empApi.onError($A.getCallback(error => {
            console.error('TestSte - EMP API error: ', error)
        }))
        empApi.subscribe(channel, -1, $A.getCallback(e => {
            console.log('TestSte - received event ', JSON.stringify(e))
            if (e.data.payload.XC_SignerId__c == recordId) hlp.getData(cmp, evt, hlp)
        }))
            .then(subscription => {
                console.log('TestSte - subscribed to channel ', subscription.channel)
            })
    },
    */

    getData: function (cmp, evt, hlp) {
        /*hlp.callMethod(cmp, 'getDocumentSignatures', { recordId: cmp.get('v.recordId') })
            .then(r => {
                cmp.set('v.data', r);
                $A.get('e.force:refreshView').fire();
            })
            .catch(e => {
                hlp.notifyError(e)
            })*/
        
        let action = cmp.get("c.getDocumentSignatures");
        action.setParams({recordId : cmp.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                cmp.set("v.showSpinner",false);
                cmp.set('v.data',response.getReturnValue());
            }else{
                cmp.set("v.showSpinner",false);
                let error = response.getError()[0].message;
                console.log('ERROR :: ' + error);
            }
            
        });
        
        $A.enqueueAction(action);
        
    },

    getDataInit: function (cmp, evt, hlp) {
        hlp.callMethod(cmp, 'getDocumentSignatures', { recordId: cmp.get('v.recordId') })
            .then(r => {
                cmp.set('v.data', r);
            })
            .catch(e => {
                hlp.notifyError(e)
            })
    },
        
    subscribe: function(cmp, evt, hlp){
        
        let cometDNotConnected = $.cometd.isDisconnected();
        let recordId = cmp.get("v.recordId");

        if (cometDNotConnected) {
            $.cometd.websocketEnabled = false;
            let sid = cmp.get("v.sessionId");
            $.cometd.init({
                url: '/cometd/47.0/',
                requestHeaders: { Authorization: 'OAuth ' + sid },
                appendMessageTypeToURL: false
            });
        }

        //subscription management
        $.cometd.subscribe('/event/XC_DigitalSignature__e',function(message){
            if (message.data.payload.XC_SignerId__c == recordId){
                console.log('opt Platform Event Received ' + JSON.stringify(message.data.payload));
                cmp.set("v.showSpinner",true);
                hlp.getData(cmp, message, hlp);
            }
        });
    },


})