({
	doInit : function(component,event,helper) {
		
		let phoneKey = component.get("v.interactionRecord.XC_Phone__c");
		console.log("PHONEKEY FOR SEARCH RECORDS " + phoneKey);

		/*SEARCHING RECORDS AMONG LEADS/CONTACTS*/
		component.set('v.spinnerControl',true);

		let action = component.get("c.lookUpByPhone");
		action.setParams({
			phoneKey:phoneKey
		});

		action.setCallback(this,function(resp){
			if(resp.getState()=="SUCCESS" && component.isValid()){
				
				component.set('v.spinnerControl',false);
				let responseMatch = resp.getReturnValue();
				
				component.set("v.leadMatches",responseMatch.leadFound);
				component.set("v.contactMatches",responseMatch.contactFound);

				if(responseMatch.leadFound.length>0 || responseMatch.contactFound.length>0){
					component.set("v.hasNoMatch",false);
				}

				console.log('CTI MATCHES RECORDS FOUND::: ' + JSON.stringify(responseMatch));

				/*putting data in tables*/
				helper.setLeadColumns(component,event,helper);
				helper.setContactColumns(component,event,helper);
			}
		});

		$A.enqueueAction(action);

	},

	setLeadColumns : function(component,event,helper){

		//TODO Use custom Labels
		component.set("v.leadColumns",[
			{label: $A.get("$Label.c.XC_CL_CTIMultipleMatchColFirstName"), fieldName : 'FirstName'},
			{label: $A.get("$Label.c.XC_CL_CTIMultipleMatchColLastName"), fieldName : 'LastName'},
			{label: $A.get("$Label.c.XC_CL_CTIMultipleMatchColEmail"),fieldName:'Email'}
		]);
	},

	setContactColumns : function(component,event,helper){

		//TODO Use custom labels
		component.set("v.contactColumns",[
			{label: $A.get("$Label.c.XC_CL_CTIMultipleMatchColFirstName"), fieldName : 'FirstName'},
			{label: $A.get("$Label.c.XC_CL_CTIMultipleMatchColLastName"), fieldName : 'LastName'},
			{label: $A.get("$Label.c.XC_CL_CTIMultipleMatchColEmail"),fieldName:'Email'}
		]);
	},

	onContactSelected : function(component,event,helper){

		let alreadySelectedRecord = component.get("v.rowSelected");

		
		if(alreadySelectedRecord===true){
			helper.showToast('Error', $A.get("$Label.c.XC_CL_Record_Selected"),'error');
			return;
		}

		let allContacts = component.get("v.contactMatches");
		let contactRecordId = event.getParam('selectedRows')[0].Id;
		let accountId;

		for(let i =0; i<allContacts.length; i++){
			if(allContacts[i].Id==contactRecordId){
				accountId = allContacts[i].AccountId
			}
		}

		component.set("v.rowSelected",true);
		component.set("v.interactionRecord.XC_ContactId__c",contactRecordId);
		if(accountId){
			component.set("v.interactionRecord.XC_AccountId__c",accountId);
		}
		helper.updateInteraction(component,event,helper);

	},

	onLeadSelected : function(component,event,helper){
		
		let alreadySelectedRecord = component.get("v.rowSelected");


		if(alreadySelectedRecord===true){
			helper.showToast('Error', $A.get("$Label.c.XC_CL_Record_Selected"),'error');
			component.set("v.leadSelectedRows",[]);
			return;
		}

		let leadRecordId = event.getParam('selectedRows')[0].Id;
		component.set("v.rowSelected",true);
		component.set("v.interactionRecord.XC_LeadId__c",leadRecordId);
		helper.updateInteraction(component,event,helper);
	},

	updateInteraction : function(component,event,helper){
		/*Saving interaction record after field update*/
		component.set("v.interactionRecord.XC_HasMultipleMatch__c",false);
		component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
				
				console.log("Save completed successfully.");
				helper.showToast('Success', $A.get("$Label.c.XC_CL_Record_Updated"),'success');
				$A.get('e.force:refreshView').fire();

            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                            JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));

	},

	createNewLead : function(component,event,helper){

		/*Redirect to new lead lightning component in a new tab inside console*/
		let workspace = component.find('workspace');
		workspace.openTab({
			pageReference : {
				"type":"standard__component",
				"attributes":{
					"componentName" : "c__XC_LCP002_NewLead"
				}
			},
			focus : true
		}).then((response)=>{
			workspace.setTabLabel({
				tabId:response,
				label:"New Lead"
			});
		}).catch((err)=>{
			console.log(err);
		});

	},

	showToast : function(title, message, type) {
        console.log('HELPER,SHOW TOAST');
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': title,
            'message': message,
            'type': type,
            'mode': 'dismissible',
            'duration' : 10000
        });
        toastEvent.fire();
	}


})