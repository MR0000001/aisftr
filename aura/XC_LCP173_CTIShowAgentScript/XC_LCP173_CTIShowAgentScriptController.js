({
    doInit : function(component, event, helper) {
        helper.openModal(component,event,helper);
        helper.retrieveScriptUrl(component,event,helper);
        helper.checkRecordingConf(component,event,helper);
    },

    handleCancel : function(component,event,helper){
        
        component.set("v.openModal",false);
        let cmpTarget = component.find('Modalbox');
        let cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 

    },

    openModal : function(component,event,helper){

        if(component.get("v.openModal")){

            let cmpTarget = component.find('Modalbox');
            // let cmpBack = component.find('Modalbackdrop');
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            // $A.util.addClass(cmpBack, 'slds-backdrop--open');
        }else{
            let cmpTarget = component.find('Modalbox');
            // let cmpBack = component.find('Modalbackdrop');
            // $A.util.removeClass(cmpBack,'slds-backdrop--open');
            $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        }

    },

    manageShowText : function(component,event,helper){

        if(component.get("v.showText")){
            component.set("v.showDocFrame",false);
        }else{
            component.set("v.showDocFrame",true);
        }
        
    },

    sendRemoteStartRecording : function(component,event,helper){
        let currentBtn = event.getSource();
        currentBtn.set("v.disabled",true);
        let stopBtn = component.find("stopRec");
        stopBtn.set("v.disabled",false);
        helper.startRemoteRec(component,event,helper);

    },

    sendRemoteStopRecording : function(component,event,helper){
        let currentBtn = event.getSource();
        currentBtn.set("v.disabled",true);
        let startBtn = component.find("startRec");
        startBtn.set("v.disabled",false);
        helper.stopRemoteRec(component,event,helper);
    }

})