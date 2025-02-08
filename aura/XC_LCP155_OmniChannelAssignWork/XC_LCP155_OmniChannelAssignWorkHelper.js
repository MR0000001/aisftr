({
    manageWorkAccepted : function(component,event,helper) {

        let caseId = event.getParam('workItemId');
        let caseLoader = component.find("caseLoader");
        console.log('ACCEPTED CASE ID: ' + caseId);

        //check the caseId validity and SObjectType
        if(caseId && caseId.startsWith('500')){
            component.set("v.caseRecordId",caseId);
            caseLoader.reloadRecord(true,function(resp){
                console.log('CASE RECORD: ' , JSON.stringify(component.get("v.caseRecord")));
                component.set("v.caseRecord.Status",$A.get("$Label.c.XC_CL_Case_InProgress"));
                //update case record status
                caseLoader.saveRecord($A.getCallback(function(saveResult){

                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                            console.log("CASE SUCCESSFULLY SAVED");

                            //if we have a parent case, update the status
                            let caseParent = component.get("v.caseRecord.ParentId");

                            if(caseParent){
                                helper.updateParentCaseStatus(component,event,helper,caseParent);
                            }else{
                                $A.get('e.force:refreshView').fire();
                            }

                    } else if (saveResult.state === "INCOMPLETE") {
                        console.log("User is offline, device doesn't support drafts.");
                    } else if (saveResult.state === "ERROR") {
                        console.log('Problem saving record, error: ' + 
                                    JSON.stringify(saveResult.error));
                    } else {
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    }


                }));


            });
        }

    },

    updateParentCaseStatus : function(component,event,helper,parentRecordId){   

        let action = component.get('c.updateParentCaseStatus');
        action.setParams({parentCaseId : parentRecordId});
        action.setCallback(this,function(response){

            if(response.getState()==="SUCCESS"){

                let result = response.getReturnValue();
                if(result){
                    console.log('SUCCESSFUL UPDATE ON PARENT CASE STATUS');
                    $A.get('e.force:refreshView').fire();
                }else{
                    console.log('ERROR ON UPDATE PARENT CASE STATUS:::: ' + result);
                }
            }else{
                let errorMsg = response.getError()[0].message;
                console.log('ERROR ON UPDATE PARENT CASE STATUS:::: ' + errorMsg);
            }
        });
        $A.enqueueAction(action);
    }
})