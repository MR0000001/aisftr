({
    doInit : function(component, event, helper) {
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        console.log('recordTypeId NEW->'+recordTypeId);
        if (recordTypeId != 'null' && recordTypeId != 'undefined' ) {
            component.set("v.recordTypeId", recordTypeId);
            component.set("v.isVisibleRecordEditForm", true);
        }
    },

    checkSkillRequired: function(component, event, helper){
        var skillId = component.get("v.mapSkillDocument.skillId");
        if(skillId != null && skillId != ''){
            this.checkNotSameDocument(component,event,helper);
        }
        else{
           helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_SkillRequired"), "error"); 
        }
    },
    
    checkNotSameDocument : function(component, event, helper){
        if((component.get("v.mapSkillDocument.listOfDocumentAND") != "" && component.get("v.mapSkillDocument.listOfDocumentAND") != null) 
           || (component.get("v.mapSkillDocument.listOfDocumentOR")!= "" && component.get("v.mapSkillDocument.listOfDocumentOR")!= null )){
            
            var listDocumentA = '';
            var listDocumentO = '';
            
            var isSameDocument = false;
            
            if(component.get("v.mapSkillDocument.listOfDocumentAND") != "" && component.get("v.mapSkillDocument.listOfDocumentAND") != null) {
                
                listDocumentA = component.get("v.mapSkillDocument.listOfDocumentAND").split(';');        
                for (var i = 0; i < listDocumentA.length ; i++){
                    if(listDocumentO.includes(listDocumentA[i])){
                        helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_SameDocument"), "error");
                        isSameDocument = true;
                        break;
                    }
                }   
            } 
            
            if(component.get("v.mapSkillDocument.listOfDocumentOR") != "" && component.get("v.mapSkillDocument.listOfDocumentOR") != null) {
                
                listDocumentO = component.get("v.mapSkillDocument.listOfDocumentOR").split(';');        
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
        var mapSkillDocument = new Map();
        mapSkillDocument = component.get("v.mapSkillDocument");
        var action = component.get("c.saveSkillDocumentAssociation");
        
        action.setParams({
            'mapSkillDocument' : JSON.stringify(mapSkillDocument),
            'recordTypeId' : component.get("v.recordTypeId")        
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                if(result.success){
                    helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_Success") , "Success"); 
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                    this.closeCurrentTab(component, event, helper, result.recordId);
                }
                else{
                    helper.showToast(component, event, helper, result.resultMessage, "error");
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
        $A.get("e.force:closeQuickAction").fire();
    },
    
    closeCurrentTab : function(component, event, helper, toRedirect) {
        var workspaceAPI = component.find("workspace");
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": toRedirect, "slideDevName": "detail", "isredirect": true });    
        navigateEvent.fire();
    },
    
    goBack : function(component, even) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId}); 
        })
    },
    
})