({
    doInit : function(component,event,helper) {

        let woId = component.get("v.caseRecord.XC_WorkOrder__c");
        //call apex to retrieve dictamen ID information
        let action=component.get("c.getDictamenRecordId");
        action.setParams({
            workOrderId : woId
        });
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                
                component.set("v.dictamenId",response.getReturnValue());
                //get fields dynamically using fieldsets
                helper.getFieldSet(component,event,helper);
            }else{
                console.log('ERROR IN LOAD COMPONENT ' + response.getErrors());
            }
        });


        $A.enqueueAction(action);
    },

    getFieldSet : function(component,event,helper){

        let fieldSetAction = component.get("c.getFields");
        fieldSetAction.setParams({
            fieldSetName : "XC_FS_ESP_Dictamen",
            sObjectType : "XC_DictamenItem__c"
        });

        fieldSetAction.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){

                component.set("v.dictamenFields",response.getReturnValue());
                console.log('FIELDSET RESULT::: ' + component.get("v.dictamenFields"));

            }else{
                console.log('ERROR IN LOAD FIELDSET::: ' + response.getErrors());
            }

        });

        $A.enqueueAction(fieldSetAction);


    }

})