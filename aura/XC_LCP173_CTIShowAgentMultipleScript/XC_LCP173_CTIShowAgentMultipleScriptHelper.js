({
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

    startRemoteRec : function(component,event,helper){
        let action = component.get("c.sendStartStopRecordingEvent");
        action.setParams({"params" : {"eventType" : "REMOTERECSTART","recordId":component.get("v.recordId")}});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result=response.getReturnValue();
                if(!result.success){
                    console.log('ERROR IN SENDING PLATFORM EVENT FOR REMOTE RECORDING START');
                }
            }else{
                console.log('ERROR IN START REMOTE REC:: ' + response.getError()[0].message);
            }
        })
        $A.enqueueAction(action);
    },


    stopRemoteRec : function(component,event,helper){
        let action = component.get("c.sendStartStopRecordingEvent");
        action.setParams({"params" : {"eventType" : "REMOTERECSTOP"}});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result=response.getReturnValue();
                if(!result.success){
                    console.log('ERROR IN SENDING PLATFORM EVENT FOR REMOTE RECORDING STOP');
                }
            }else{
                console.log('ERROR IN STOP REMOTE REC:: ' + response.getError()[0].message);
            }
        })
        $A.enqueueAction(action);
    },

    checkRecordingConf : function(component,event,helper){
        let action = component.get("c.getIsRecodingEnabled");
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                let result = response.getReturnValue();
                component.set("v.recordingEnabled",result.isEnabled);
            }else{
                console.log('ERROR ON CHECK CALL REC CONFIGURATION:: ' + response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);

    }
})