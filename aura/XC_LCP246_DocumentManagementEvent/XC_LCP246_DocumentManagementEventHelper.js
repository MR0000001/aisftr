/**
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date 24/03/2021
  * @description XC_LCP246_DocumentManagementHelperEvent - Javascript Helper for LCP246 Event
*/

({
    doInit : function(component, event, helper) {
        //let cometDNotConnected = $.cometd.isDisconnected();
        let orderId = component.get("v.orderId");
        //if(cometDNotConnected) {
            $.cometd.websocketEnabled = false;
            let sid = component.get("v.sessionId");
            $.cometd.init({
                url: '/cometd/47.0/',
                requestHeaders: {Authorization: 'OAuth ' + sid},
                appendMessageTypeToURL: false
            });
        //}

        $.cometd.subscribe('/data/XC_DocumentType__ChangeEvent',function(message) {
            if(message.data.payload.XC_Configuration__c == orderId) {
                component.set('v.documentReceived', component.get('v.documentReceived')+1);
            }
        });
    },

    createEventDocumentOk : function(component, event, helper) {
        let documentReceivedEvent = $A.get("e.c:XC_LCE246_Event");
        documentReceivedEvent.fire();
    }
})