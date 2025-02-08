({
    doInit : function(component, event, helper) {

        if(!component.get("v.scripts") || component.get("v.scripts").length===0){
            component.set("v.showSpinner",true);
        }else if(component.get("v.scripts") && component.get("v.scripts").length===1){
            component.set("v.multiple",false);
        }

        helper.openModal(component,event,helper);
        helper.checkRecordingConf(component,event,helper);

    },

    handleCancel : function(component,event,helper){
        
        component.set("v.openModal",false);
        let cmpTarget = component.find('Modalbox');
        let cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 

    },

    handleScriptsChange : function(component,event,helper){
        component.set("v.showSpinner",false);
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