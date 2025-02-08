({
    manageEvent : function(component,event,helper,platformEvent) {
        let currentUserId = $A.get("$SObjectType.CurrentUser.Id");
        if(platformEvent.XC_ContextUserId__c==currentUserId 
        && platformEvent.XC_ContextRecordId__c == component.get("v.recordId")
        ){

            if(platformEvent.XC_EventType__c == 'SCRIPT_GENERATED' && platformEvent.XC_ScriptTaskId__c){

                console.log("VOCAL SCRIPT GENERATED --> Showing script " + JSON.stringify(platformEvent));

                let action = component.get("c.retrieveScriptTextFromTask");
                let params = {"recordId" : component.get("v.recordId") , "taskId" : platformEvent.XC_ScriptTaskId__c};
                action.setParams({"params" : params});
                action.setCallback(this,function(response){
                    if(response.getState()==="SUCCESS"){
                        let result = response.getReturnValue();
                        if(result.success){
                            setTimeout(function(){
                                component.set("v.showTextInModal",true);
                                component.set("v.scriptText",result.text);
                            },2000);
                        }
                    }else{
                        console.log("ERROR RETRIEVING CALL SCRIPT::: " + response.getError()[0].message);
                    }
                });
                $A.enqueueAction(action);

            }else if(platformEvent.XC_EventType__c == 'TRIGGER_SCRIPT_GENERATED'){

                let action = component.get("c.retrieveCongaTriggerAttachments");
                action.setParams({"orderId" : component.get("v.recordId")});
                action.setCallback(this,function(response){
                    if(response.getState()==="SUCCESS"){
                        let result = response.getReturnValue();
                        if(result.scripts){
                            component.set("v.congaTriggerScripts",result.scripts);
                        }
                    }else{
                        console.log("ERROR RETRIEVING CALL SCRIPT::: " + response.getError()[0].message);
                    }
                });
                $A.enqueueAction(action);

            }


        }
    }
})