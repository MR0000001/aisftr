({
    doInit : function(component, event, helper) {
        
        var recordId = component.get("v.recordId"); 

        /* Set the columns of the lightning:datatable */
        component.set("v.columns", [
                        {label : $A.get("$Label.c.XC_CL_Name"), fieldName : 'name', type : 'text'},
                        {label : $A.get("$Label.c.XC_CL_SkillLevel"), fieldName : 'skillLevel', type : 'number', cellAttributes: { alignment: 'left' }},
            			{label : $A.get("$Label.c.XC_CL_StartDate"), fieldName : 'startDate', editable : true, type : 'date' , typeAttributes: { year:"numeric", month:"2-digit", day:"2-digit"}},
            			{label : $A.get("$Label.c.XC_CL_EndDate"), fieldName : 'endDate', editable : true, type : 'date', typeAttributes: { year:"numeric", month:"2-digit", day:"2-digit"}},
            			{label : $A.get("$Label.c.XC_CL_CertificationStartDate"), fieldName : 'certStartDate', editable : false, type : 'date' , typeAttributes: { year:"numeric", month:"2-digit", day:"2-digit"}},
            			{label : $A.get("$Label.c.XC_CL_CertificationEndDate"), fieldName : 'certEndDate', editable : false, type : 'date', typeAttributes: { year:"numeric", month:"2-digit", day:"2-digit"}}
                        ]);

        var action = component.get("c.retrieveData");
        action.setParams({
            'recordId': recordId,
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {   
                var result = JSON.parse(a.getReturnValue());
                console.log('****result****',result);
                component.set("v.data", result.listWrapperSrS);
                component.set("v.hideNewButton", result.isCommunity);
            }
        });
        $A.enqueueAction(action);       
    },
    
    updateRecord : function(component, event, helper) {

        var objUpdated = component.find("datatableID").get("v.draftValues");
        objUpdated = JSON.parse(JSON.stringify(objUpdated));
        
        //var objToUpdate = JSON.parse(JSON.stringify(component.get("v.globalObjectString")));
        var columns = JSON.parse(JSON.stringify(component.get("v.data")));

        var indexUpdated;
        var indexUpdatedInt;
        var fieldNameUpdated;
        var row = {};
        var listSRSkill = [];

        for(row in objUpdated) {     
            console.log(row);
            indexUpdated = objUpdated[row]["id"].substring(4,objUpdated[row]["id"].length);         
            indexUpdatedInt = parseInt(indexUpdated);                                               
            fieldNameUpdated = columns[indexUpdatedInt]["Field"];                                    
            //objToUpdate[fieldNameUpdated] = objUpdated[row]["Value"];    
            columns[indexUpdatedInt]["startDate"] = objUpdated[row]["startDate"] != undefined ? objUpdated[row]["startDate"] : null;                      
            columns[indexUpdatedInt]["endDate"] = objUpdated[row]["endDate"] != undefined ? objUpdated[row]["endDate"] : null;                      
            listSRSkill.push(columns[indexUpdatedInt]);
        }

        console.log(listSRSkill);

        var actionUpdate = component.get("c.callToUpdate");
        actionUpdate.setParams({
            'jsonUpdate' : JSON.stringify(listSRSkill)
        });

        actionUpdate.setCallback(this, function(a) {
            let result = a.getReturnValue();
            var res = JSON.parse(result);
            if(res.errorMessage === "") {
                console.log('@result-->' +result.errorMessage);

                $A.get('e.force:refreshView').fire();
                helper.showToast(component, event, helper,$A.get("$Label.c.XC_CL_SkillUpdated"), "Success");
                component.find("datatableID").set("v.draftValues", null);
                helper.doInit(component, event, helper);
            } else {
                $A.get('e.force:refreshView').fire();
                helper.showToast(component, event, helper,res.errorMessage, "Error");
                component.find("datatableID").set("v.draftValues", null);
                helper.doInit(component, event, helper);
            }

        });
        $A.enqueueAction(actionUpdate);
    },

    onSave : function(component, event, helper) {
        if(component.get("v.skillId") == '' || component.get("v.skillId") == null ||
            component.get("v.assignmentStartDate") == null || component.get("v.assignmentEndDate") == null || component.get("v.skillLevel") == null){
            component.set("v.spinnerControl", false);
            helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_SkillFieldsRequired") , "Error"); 
            return;
        }
        component.set("v.spinnerControl", true);   
        var mapResourcesSkills = {
            'recordId' : component.get("v.recordId"),
            'skillId' : component.get("v.skillId"),
            'skillLevel' : component.get("v.skillLevel"),
            'assignmentStartDate' : component.get("v.assignmentStartDate"),
            'assignmentEndDate' : component.get("v.assignmentEndDate")
        }
        let action = component.get("c.saveServiceResourceSkill");
        
        action.setParams({
            'mapResourcesSkills' : JSON.stringify(mapResourcesSkills),
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = a.getReturnValue();
                if(result.success){
                    component.set("v.spinnerControl", false);  
                    helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_ResourceSkillCreated") , "Success"); 
                    component.set("v.showModal", false);
                    component.set("v.skillId", '');
                    component.set("v.skillLevel", null);
                    component.set("v.assignmentStartDate", null);
                    component.set("v.assignmentEndDate", null);
                    helper.doInit(component, event, helper);
                    $A.get("e.force:refreshView").fire();
                }
                else{
                    component.set("v.spinnerControl", false);
                    helper.showToast(component,event, helper,result.resultMessage, "error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(component, event, helper, message, type) {
        component.set("v.spinnerControl",false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }   
})