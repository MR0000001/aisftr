({
	init : function(component, event, helper) {
		component.set("v.spinnerControl", true);
		let recordId = component.get("v.recordId");
        
        let actionAsset = component.get('c.createContract');
        actionAsset.setParams({
            recordId: recordId
        });

        actionAsset.setCallback(this, function (response) {
            let state = response.getState();
            if (state = "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result'+result);
                console.log('Result'+result.RecordTypeId);
                console.log('Result'+result.segment);
                console.log('Result'+result.legalntity);
                if(result.Status=='OK'){
                    component.set("v.spinnerControl", true);
                    console.log('recordType'+result.RecordTypeId);
                     let createContract = $A.get("e.force:createRecord");
                            createContract.setParams({
                                "entityApiName": "Contract",
                                "RecordTypeId": result.RecordTypeId,
                                "defaultFieldValues": {
                                    "Opportunity__c": result.Opportunity,
                                    "XC_Segment__c": result.segment,
                                    "XC_LegalEntity__c": result.legalntity,
                                    "RecordTypeId": result.RecordTypeId,
                                    "AccountId": result.Account

                                }
                            });
                            createContract.fire();

                }
                if(result.Status == 'KO'){
                this.showToastError(component,result.Message,result.ErrorMessage);
                }

            }
        });
        $A.enqueueAction(actionAsset);
	},

    newRequest: function (component) {

        let accountId = component.get('v.accountId');
        let contactId = component.get('v.contactId');
        let recordId = component.get("v.recordId");
        let recordTypeXC = component.get('v.recordTypeCase');
        let originXC = component.get('v.originUser');
        
        let createCase = $A.get("e.force:createRecord");
        createCase.setParams({
            "entityApiName": "Case",
            "defaultFieldValues": {
                "AccountId": accountId,
                "ContactId": contactId,
                "AssetId": recordId,
                "RecordTypeId": recordTypeXC,
                "Origin": originXC
            }
        });
        createCase.fire();
    },
     showToastError : function(component,oMessage,oHeader) {
         console.log(component.error);
         $A.get("e.force:closeQuickAction").fire();
                                      component.find('notifLib').showToast({
                                          "variant": "error",
                                          "title": oHeader,
                                          "message": oMessage
                                      });
                                  }




})