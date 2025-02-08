({
    doInit : function(component, event) {  
        var action = component.get("c.setFieldsValues");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                if(result){
                    component.set("v.listOfDocumentAND", result.XC_ListOfDocumentAND__c); 
                    component.set("v.listOfDocumentOR", result.XC_ListOfDocumentOR__c); 
                    component.set("v.skillId", result.XC_SkillId__c);
                    component.set("v.recordTypeId", result.RecordTypeId);
                    
                }
            }             
        });
        $A.enqueueAction(action); 
        
    },
    
    checkSkillRequired: function(component, event, helper){
        var skillId = component.get("v.skillId");
        if(skillId != null && skillId != ''){
            this.checkNotSameDocument(component,event,helper);
        }
        else{
           helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_SkillRequired"), "error"); 
        }
    },
    
    checkNotSameDocument : function(component, event, helper){
        if((component.get("v.listOfDocumentAND") != "" && component.get("v.listOfDocumentAND") != null) 
           || (component.get("v.listOfDocumentOR")!= "" && component.get("v.listOfDocumentOR")!= null )){
            
            var listDocumentA = '';
            var listDocumentO = '';
            
            var isSameDocument = false;
            
            if(component.get("v.listOfDocumentAND") != "" && component.get("v.listOfDocumentAND") != null) {
                
                listDocumentA = component.get("v.listOfDocumentAND").split(';');        
                for (var i = 0; i < listDocumentA.length ; i++){
                    if(listDocumentO.includes(listDocumentA[i])){
                        helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_SameDocument"), "error");
                        isSameDocument = true;
                        break;
                    }
                }   
            } 
            
            if(component.get("v.listOfDocumentOR") != "" && component.get("v.listOfDocumentOR") != null) {
                
                listDocumentO = component.get("v.listOfDocumentOR").split(';');        
                for (var i = 0; i < listDocumentO.length ; i++){
                    if(listDocumentA.includes(listDocumentO[i])){
                        helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_SameDocument"), "error");
                        isSameDocument = true;
                        break;
                    }
                }
            } 
            
            if(!isSameDocument){
                this.saveSkillDocumentAssociation(component, event, helper);
            }
        }
        else {
            helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_AtLeastOneDocument"), "error");
        }
    },
    
    saveSkillDocumentAssociation : function(component, event, helper){
        var action = component.get("c.saveSkillDocumentAssociation");
        console.log('recordId: '+component.get("v.recordId")+
                    'listOfDocumentAND :'+component.get("v.listOfDocumentAND")+
                    'listOfDocumentOR: '+component.get("v.listOfDocumentOR")+
                    'skillId: '+component.get("v.skillId")+
                    'skillName: '+component.get("v.skillName")); 

        // Modifica Salvatore Agrillo (06/05/2019)
        var mapDocumentAss = {
            'recordId' : component.get("v.recordId"),
            'listOfDocumentAND' : component.get("v.listOfDocumentAND"),
            'listOfDocumentOR' : component.get("v.listOfDocumentOR"),
            'skillId' : component.get("v.skillId"), 
            'skillName' : component.get("v.skillName"),
            'recordTypeId' : component.get("v.recordTypeId")
        }
        var mapDocumentAssString = JSON.stringify(mapDocumentAss);
        action.setParams({
            'mapDocumentAssString': mapDocumentAssString
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                if(result.success){
                    helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_Success") , "Success"); 

                    this.closeCurrentTab(component, event, helper, result.recordId);
                    
                    //$A.get("e.force:closeQuickAction").fire();
                    //$A.get("e.force:refreshView").fire();
                }
                else{
                    helper.showToast(component, event, helper, result.resultMessage, "error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    closeCurrentTab : function(component, event, helper, toRedirect) {
        
   		var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
        
        //var workspaceAPI = component.find("workspace");
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": toRedirect, "slideDevName": "detail", "isredirect": true });    
        navigateEvent.fire();
    },
    
    goBack : function(component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId}); 
        })
    },
    
    showToast : function(component, event, helper, message, type) {
        component.set("v.spinnerControl",false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get("e.force:closeQuickAction").fire();
    }
})