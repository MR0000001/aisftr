({
    doInit : function(component, event) {   
        let recordId = component.get("v.recordId"); 
        let recordTypeId  = component.get('v.recordTypeToReturn');     
        component.set('v.spinnerControl', true);
        let action = component.get("c.retrieveData");
        action.setParams({
            'recordId': recordId,
            'recordTypeId': recordTypeId 
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = JSON.parse(a.getReturnValue());
                console.log('****result****',result);
                component.set("v.techConfiguration", result);
                
                
                component.set('v.leadRecord', result.existingRecord); 

                
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set('v.spinnerControl', false);
                    }), 1000
                );
                let fieldLabelMap = {};

                component.set('v.initFinished', true);
                component.set('v.requiredFields', JSON.parse(result.listMandatory));
                this.populateFieldsFromFieldSet(component,event, result.fsPersonalData, 'v.body0', fieldLabelMap)
                
                component.set('v.fieldLabelMap', fieldLabelMap);
            }            
        });
        $A.enqueueAction(action);  
    }, 
    
    populateFieldsFromFieldSet: function(component, event, fieldSet, bodyName, fieldLabelMap) {  
        let cmp = component;
        let leadRecord = {};
        
        if(JSON.stringify(component.get('v.leadRecord'))){
            leadRecord = JSON.parse(JSON.stringify(component.get('v.leadRecord'))); 
        }
        
        let requiredFields = component.get('v.requiredFields'); 
        for(let i=0;i<fieldSet.length;i++){
            let labelMap = {};
            labelMap[fieldSet[i].fieldPath] = fieldSet[i].label;   
            fieldLabelMap[fieldSet[i].fieldPath] = fieldSet[i].label;
            let a = fieldSet[i]; 
            let className = '';
            if(requiredFields.indexOf(a.fieldPath)>-1 && a.fieldPath != 'XC_GDPRThirdParties__c'){
                className = 'customRequired';
            }
            
            let fieldObject = {};
            
            if(leadRecord && leadRecord.hasOwnProperty(a.fieldPath) && leadRecord[a.fieldPath]){
                fieldObject = {
                    "aura:id": a.fieldPath,
                    "fieldName": a.fieldPath,
                    "class" : className,//"customRequired" 
                    "value" : leadRecord[a.fieldPath]
                }
            } else {
                fieldObject = {
                    "aura:id": a.fieldPath,
                    "fieldName": a.fieldPath,
                    "class" : className,//"customRequired" 
                }
            } 
            
            
            $A.createComponents([
                ["lightning:layoutItem",{
                    "flexibility":"auto", 
                    "size":"12",
                    "smallDeviceSize":"5",
                    "mediumDeviceSize":"5",
                    "largeDeviceSize":"6",
                    "padding" : "horizontal-small"
                    //"aura:id": a.fieldPath
                }],
                ["lightning:inputField",fieldObject]
            ],
                                function(components, status, errorMessage){ 
                                    let layout = components[0];
                                    let input = components[1];  
                                    layout.set("v.body", input);
                                    let div1 = component.get(bodyName);
                                    div1.push(layout);                                       
                                    cmp.set(bodyName, div1);                    
                                } 
                               );
        }
    },
    
    assignLeadCheckedHelper : function(component, event) {
        sforce.console.openPrimaryTab(null, 'http://www.salesforce.com', false,

                'salesforce', null, 'salesforceTab');
        
        let controlCheck = component.get('v.assignLeadCheckBox');
        if(controlCheck) {
            component.set('v.assignLeadCheckBox', false);
        }
        else{
            component.set('v.assignLeadCheckBox', true);
        }
    },
    
    closeCurrentTab : function(component, event, toRedirect) {
        let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
                        let focusedTabId = response.tabId;
                        component.set("v.recordId",toRedirect);
                        workspaceAPI.closeTab({tabId: focusedTabId});
                        workspaceAPI.openTab({
                            recordId: toRedirect,
                            focus: true
                        }).then(function(response) {
                            workspaceAPI.focusTab({
                                tabId: response
                            });
                            setTimeout(function(){
                                $A.get('e.force:refreshView').fire();
                            }, 1); 

                        })
                        .catch(function(error) {
                            console.log(error);
                        });

                    });
        
       
 
          
          
          
      },
    
    onSubmitHelper : function(component, event) {
        
        let fieldToControl;
        if(event && event.getParam("fields")) {
            fieldToControl = JSON.parse(JSON.stringify(event.getParam("fields")));
            component.set('v.fieldMap',JSON.stringify(event.getParam("fields")));
            component.set('v.fieldToControl', fieldToControl);
            console.log('@@@ ' + component.get('v.fieldMap'));
            console.log('@@@ ' + event.getParam("fields"));
            console.log('@@@ ' + fieldToControl);

            this.fieldFilledControl(component, event, fieldToControl);

            this.removeRedBox(component, event);
            event.preventDefault();        
        }

            this.submitHelperUtil(component,event);
    },

    submitHelperUtil : function (component,event) {
        
        let canInsert = component.get('v.canInsert');
        console.log('canInsert:'+canInsert);
        
        if(canInsert) {
            let action = component.get("c.createRecord");
            component.set('v.spinnerControl', true);
              
            action.setParams({
                'fieldMapStringLead': component.get('v.fieldMap'),
                'assignLead'        : component.get('v.assignLeadCheckBox'),
                'recordTypeId'      : component.get("v.recordTypeToReturn"),
                'existingLeadId'    : component.get('v.recordId')
            });
            action.setCallback(this, function(a) {
                
                let result = a.getReturnValue();
                let toastEvent = $A.get("e.force:showToast")            
                if(result && result.success) {
                    console.log('CREATO ' + toastMessage);
                    let recordIdToRedirect = (result.convertedAccountId) ? (result.convertedAccountId) : result.recordId; 
                    console.log('recordIdToRedirect ' + recordIdToRedirect);
                    
                    let errorMessage;

                    if(component.get('v.recordId')){
                        errorMessage = $A.get("$Label.c.XC_CL_ContactUpdated");;
                    }
                    else{
                        errorMessage = $A.get("$Label.c.XC_CL_ContactCreated");
                    }
                     
                    toastEvent.setParams({
                        title : errorMessage,
                        message: ' ',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible',

                    });
                    
                    this.closeCurrentTab(component, event, recordIdToRedirect);
                    
                    component.set('v.spinnerControl', false);
                    toastEvent.fire();
                     
                }
                else if (result && result.errorMessage) {
                  
                    toastEvent.setParams({
                        title : $A.get("$Label.c.XC_CL_Warning"),
                        message: result.errorMessage,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible',
                    });
                    toastEvent.fire(); 
                    this.showErrorOnField(component, result.fieldName);
                    component.set('v.spinnerControl', false);
                }
                
            });
            $A.enqueueAction(action);       
        }  
    },
    
    openTab : function(component, event, recordId) {
        let workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: recordId,
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
                console.log("The url for this tab is: " + tabInfo.url);
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    /*
    retrieveMandatoryFields : function(component, event, fieldToControl) {
        
        var action = component.get("c.checkCommercialVisit");
        var prodCat = fieldToControl.XC_ProductCategoryOfInterest__c;
        action.setParams({
            'productCategory': prodCat,
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = JSON.parse(a.getReturnValue());
                component.set('v.requiredFields', result);
            }            
        });
        $A.enqueueAction(action);  
    },*/
    
    showErrorOnField : function(component, fieldName){  
        
        let cmpTarget = component.find(fieldName);
        console.log('result.fieldName->' + fieldName);
        $A.util.addClass(cmpTarget, 'slds-has-error ');
    },
    
    fieldFilledControl : function(component, event, objectField) {
        
        if(component.get('v.fieldLabelMap')) {
            let fieldLabel = JSON.parse(JSON.stringify(component.get('v.fieldLabelMap')));
            let fieldSet = component.get('v.requiredFields');
            let jsonfieldSet = JSON.parse(JSON.stringify(fieldSet))
            let canInsertControl = true;
            
            let isCorrectEmail = this.checkValidityEmail(component, event, component.get('v.fieldMap'));
            
            let emailErrorMsg = '';
            
            if(!isCorrectEmail) {
                emailErrorMsg = "\n" + $A.get("$Label.c.XC_CL_Email_Incorrect");
            }
            
            let errorMessageTotal = [];
            for (let i = 0; i < fieldSet.length; i++) {
                if(!objectField[fieldSet[i]]) {
                    
                    errorMessageTotal.push(fieldLabel[jsonfieldSet[i]]);
                    canInsertControl = false;
                    this.showErrorOnField(component, fieldSet[i]);
                    component.set('v.canInsert', false);
                }
            }
            if(canInsertControl) {
                component.set('v.canInsert', true);
            }
            else{
                let finalMessageLabel;
                let errorMessageFinal = errorMessageTotal.join(', ');
                if(errorMessageTotal.length > 1){
                    finalMessageLabel = $A.get("$Label.c.XC_CL_MandatoryPlural");
                }
                else{
                    finalMessageLabel = $A.get("$Label.c.XC_CL_Mandatory");
                }
                component.set("v.showToastMessage", true);
                component.set("v.type", "error");
                let errorMessage =  $A.get("$Label.c.XC_CL_Error") + " " + errorMessageFinal+ " \n"+ finalMessageLabel + emailErrorMsg;
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.c.XC_CL_Warning"),
                    message: errorMessage,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible',

                });
                toastEvent.fire();

            }
        } 
             
    },
    
    removeRedBox : function(component, event) {
        
        let mapField = component.get('v.fieldLabelMap');
        for(let i in mapField){
            console.log('i->'+i);
            let cmpTarget = component.find(i);
            $A.util.removeClass(cmpTarget, 'slds-has-error ');
        }
    },
    
    checkValidityEmail :  function(component, event, mapField){
        let emailFieldValue = (JSON.parse(mapField))["Email"];
        let isValidEmail;
        let regExpEmailformat = new RegExp('^(([^<>()\\[\\]\\\\.,;:\s@"]+(\\.[^<>()\\[\\]\\\\.,;:\s@"]+)*)' + 
                                            '|(".+"))@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}])' +
                                            '|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$');  

        if($A.util.isEmpty(emailFieldValue)){ 
            isValidEmail = true;
        }
        else{   
            if(emailFieldValue.match(regExpEmailformat)){
                isValidEmail = true;
            }else{
                isValidEmail = false;
            }
        }	 return isValidEmail;
        
    },
    
    
    
})