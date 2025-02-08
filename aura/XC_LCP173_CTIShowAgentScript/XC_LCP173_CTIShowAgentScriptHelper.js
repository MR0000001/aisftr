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


    retrieveScriptUrl : function(component,event,helper){
        //avoid multiple conga calls
        if(!component.get("v.showText")){
            let action = component.get("c.getDynamicScriptInfo");
            let params = {
                "objectName" : component.get("v.sObjectName"),
                "recordId" : component.get("v.recordId")
            }
            action.setParams({paramsMap : params});
            action.setCallback(this,function(response){
                if(response.getState()==="SUCCESS"){
                    let result = response.getReturnValue();
                    console.log("CONGA URL RETRIEVAL RESULT::: " + JSON.stringify(result));
                    if(result.success){
                        let finalUrl = result.congaUrl1+'{!API.Partner_Server_URL_370}'+result.congaUrl2;
                        component.set("v.congaURL",finalUrl);
                        component.set("v.showDocFrame",true);
                    }
                }else{
                    console.log("ERROR ON RETRIEVING CONGA URL " + response.getError()[0].message);
                }
            })
            $A.enqueueAction(action);
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