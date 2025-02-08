({	
    fetchData: function(component) {
        var actions = [
            {label: 'Delete', name: 'delete'}
        ]; 
        component.set('v.columns', [
            {label: 'Skill Name', fieldName: 'name', type: 'text' },
            {label: 'Skill Level', fieldName: 'level', type: 'number'},
            //{label: 'Skill Id', fieldName: 'ParentId', type: 'text'},    
            {type: 'action', typeAttributes: {rowActions: actions}}
        ]);
        
        var action = component.get("c.getTableData"); 
        action.setParams({
            recordId : component.get("v.recordId")
        }); 
        console.log('@@@ recordId -> ' + component.get("v.recordId"));
        action.setCallback(this, function(response) {        
            var data = response.getReturnValue();
            if(response.getState() == "SUCCESS") {
                component.set('v.data', response.getReturnValue()); 
            }
            console.log(data);
        });     
        $A.enqueueAction(action); 
    },
    
    initializeRecord: function(component){ 
        component.set('v.modalLabel','New Skill Requirement');
        component.set("v.recordError",""); 
        component.set('v.toggleModalInsert', true);
        this.getInputFieldDefault(component);
        /*component.find("recordUpsertHandler").getNewRecord(
            "XC_ProductSkillRequired__c", // sObject type (entityAPIName)
            null,      // recordTypeId
            false,
            $A.getCallback(function() {
                var rec = component.get("v.recordToUpsert");
                var error = component.get("v.recordError");
                if(error || (rec === null)) {
                    console.log("@@@ Error initializing record template: " + error);
                }
                else {
                    console.log("@@@ Record template initialized: " + rec.apiName);
                }
            }) 
        );    */  
	},

    getInputFieldDefault: function(component) {        
        component.set("v.inputFields.XC_Skill_Level__c", 1); 
        component.set("v.inputFields.XC_Skill_Id__c", ""); 
    },
    
    handleSaveRecord: function(component) {
        /** Fix - Salvatore Agrillo 18/04/2019 */
        var resultsToast = $A.get("e.force:showToast");
        var newRecordFields = component.get("v.inputFields");

        if($A.util.isEmpty(newRecordFields.XC_Skill_Level__c) == false && $A.util.isEmpty(newRecordFields.XC_Skill_Id__c) == false) {
            var mapSkill = {
                'productCategoryOfInterest': component.get("v.recordId"),
                'skillLevel': newRecordFields.XC_Skill_Level__c,
                'skillName': newRecordFields.Name,
                'skillId': newRecordFields.XC_Skill_Id__c
            }
            console.log('@@@ mapSkill ---> ', mapSkill);
            var mapSkillString = JSON.stringify(mapSkill);
            var action = component.get("c.saveResults"); 
            action.setParams({
                mapSkillString : mapSkillString
            }); 
            action.setCallback(this, function(response) {        
                var data = response.getReturnValue();
                if(response.getState() == "SUCCESS") {
                    if(data) {
                        console.log("Record inserted.");
                        resultsToast.setParams({
                            title: 'Success!',
                            message: 'Record inserted.',
                            type: 'success'
                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();
                    } else {
                        console.log("Record not inserted.");
                        resultsToast.setParams({
                            title: 'Error!',
                            message: 'Impossible insert new record.',
                            type: 'error'
                        });
                        resultsToast.fire();
                    }
                } else {
                    console.log("Record not inserted.");
                    resultsToast.setParams({
                        title: 'Error!',
                        message: 'Impossible insert new record.',
                        type: 'error'
                    });
                    resultsToast.fire();
                }
            });     
            $A.enqueueAction(action); 
        } else {
            resultsToast.setParams({
                title: 'Error!',
                message: 'Insert required field.',
                type: 'error'
            });
            resultsToast.fire();
        }
        







        /*var helper = this;  
        var newRecordFields = component.get("v.inputFields");  

        class ObjectWrapper {
            constructor(XC_Skill_Level__c, XC_Skill_Name__c, XC_Skill_Id__c, XC_ProductCategoryOfInterest__c) {
                this.XC_ProductCategoryOfInterest__c = XC_ProductCategoryOfInterest__c;
                this.XC_Skill_Level__c = XC_Skill_Level__c;
                this.XC_Skill_Name__c = XC_Skill_Name__c;
                this.XC_Skill_Id__c = XC_Skill_Id__c;
            }
        }
        var wrapper = new ObjectWrapper(newRecordFields.XC_Skill_Level__c, newRecordFields.Name, newRecordFields.XC_Skill_Id__c, component.get("v.recordId"));
        component.set("v.recordToUpsertFields", wrapper);
        /*component.set("v.recordToUpsertFields.XC_Skill_Level__c", skillLevel);
        component.set("v.recordToUpsertFields.XC_Skill_Name__c", newRecordFields.Name);
        component.set("v.recordToUpsertFields.XC_Skill_Id__c", newRecordFields.XC_Skill_Id__c);   
        component.set("v.recordToUpsertFields.XC_ProductCategoryOfInterest__c", component.get("v.recordId")); */
        //console.log(JSON.parse(JSON.stringify(component.get("v.recordToUpsertFields"))));*/
       
        /*if(helper.validateForm(component)){
            console.log('@@@ For object ---> ', JSON.parse(JSON.stringify(component.get("v.recordToUpsertFields"))));
            component.find("recordUpsertHandler").saveRecord((function(results) {
                console.log('@@@ Saving record...');
                var resultsToast = $A.get("e.force:showToast");                
                if(results.state === "SUCCESS" || results.state === "DRAFT") {
                    console.log("@@@ Record inserted.");
    	    		component.set('v.toggleModalInsert', false);
                    helper.fetchData(component);
                    resultsToast.setParams({
                        title: 'Saved!',
                        message: 'The record was saved.',
                        type: 'success'
                    });
                } else {
                    console.log('9999999');
                    console.log('@@@ Record not inserted. Result -> ', results.error);
                    resultsToast.setParams({
                        title: 'Error!',
                        message: 'The record was not saved.',
                        type: 'error'
                    });
                }
                resultsToast.fire();
            }));
        }*/
    }, 
    
    handleDeleteRecord: function(component, recordToDeleteId) {
        var helper = this;
    	var action = component.get("c.deleteRecord"); 
        action.setParams({
            recordToDeleteId : recordToDeleteId
        }); 
        action.setCallback(this, function(response) {
            console.log(response);
            helper.fetchData(component);
        });
        $A.enqueueAction(action);
	},

    validateForm: function(component) {
        component.set("v.recordError",""); 
        var isValid = true; 
        var skilllId = component.get("v.recordToUpsertFields.XC_Skill_Id__c");
        if($A.util.isEmpty(skilllId)) {
            isValid = false;
            component.set("v.recordError","Please select a valid skill."); 
        }

        var skilllLevel = component.get("v.recordToUpsertFields.XC_Skill_Level__c");
        if($A.util.isEmpty(skilllLevel)) {
            skilllLevel = 1;
        }

        var ProducatCategory = component.get("v.recordToUpsertFields.XC_ProductCategoryOfInterest__c");
        console.log('@@@ XC_ProductCategoryOfInterest__c ---> ' + ProducatCategory);
        if($A.util.isEmpty(ProducatCategory)) {
            isValid = false;
        }
        return(isValid);  
    },
    
    handleClickCancelHelper: function(component) {
        component.set("v.recordError",""); 
        component.set('v.toggleModalInsert', false);  
    },
    
    handleRowActionHelper: function(component, event) {
        var operation = event.getParam('action');
        var row = event.getParam('row'); 
        switch (operation.name) {
            case 'delete': 
                this.handleDeleteRecord(component, row.id);
                break;
        } 
    } 
})