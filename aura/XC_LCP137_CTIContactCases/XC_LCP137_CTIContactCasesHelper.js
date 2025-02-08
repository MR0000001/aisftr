({
    doInit : function(component,event,helper) {

        //retrieve dei case correlati

        let action= component.get("c.retrieveCasePage");

        let contactRecId = component.get("v.interactionRecord.XC_ContactId__c");
        let pSize = component.get("v.pageSize");
        let pNum =  component.get("v.pageNumber");
        let dataSize = component.get("v.dataSize");

        helper.setCaseColumns(component,event,helper);

        console.log("ACTION PARAMS:: CID " + contactRecId + " PSIZE " + pSize + " PNUM " + pNum)

        action.setParams({
            pageSize : pSize,
            pageNumber : pNum,
            contactId : contactRecId
        });
        action.setCallback(this,function(response){


            if(component.isValid() && response.getState()==="SUCCESS"){
                
                let resultData = response.getReturnValue().casesMatch;
                let totalCases = response.getReturnValue().totalSize;
                
                //(v.pageNumber-1)*v.pageSize+v.dataSize)
                let lastIndexOnPage = (pNum-1)*pSize+resultData.length;



                component.set("v.caseMatches",resultData);
                component.set("v.totalCases",totalCases);

                if((resultData.length < component.get("v.pageSize")) || (lastIndexOnPage == totalCases)){
                    component.set("v.isLastPage",true)
                }else{
                    component.set("v.isLastPage",false);
                }

                component.set("v.dataSize",resultData.length);

            }

        });
        $A.enqueueAction(action);

    },

    setCaseColumns : function(component,event,helper){
        
        component.set("v.caseColumns",[
			{label: $A.get("$Label.c.XC_CL_CTIContactCase_ColNum"), fieldName : 'CaseNumber'},
            {label: $A.get("$Label.c.XC_CL_CTIContactCase_ColReason"), fieldName : 'Reason'},
            {label: $A.get("$Label.c.XC_CL_CTIContactCase_ColStatus"), fieldName : 'Status'},
			{label: $A.get("$Label.c.XC_CL_CTIContactCase_ColDate"),fieldName:'CreatedDate',type:'date-local'}
        ]);
        
    },

    onCaseSelected : function(component,event,helper){
		let caseRecordId = event.getParam('selectedRows')[0].Id;


        // console.log("CASE SELECTED: " + caseRecordId);
        // component.set('v.interactionRecord',caseRecordId);
      
        // component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
        //     if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
				
		// 		console.log("Save completed successfully.");
		// 		helper.showToast('Success','Record Successfully Updated','success');
		// 		//$A.get('e.force:refreshView').fire();

        //     } else if (saveResult.state === "INCOMPLETE") {
        //         console.log("User is offline, device doesn't support drafts.");
        //     } else if (saveResult.state === "ERROR") {
        //         console.log('Problem saving record, error: ' + 
        //                     JSON.stringify(saveResult.error));
        //     } else {
        //         console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
        //     }
        // }));

        var navEvt = $A.get("event.force:navigateToSObject");
        navEvt.setParams({
            "recordId": caseRecordId,
            "slideDevName": "detail"
        });
        navEvt.fire();


    },

    handleCreateCase : function(component,event,helper){

        let workspace = component.find('workspace');
        let contactId = component.get('v.interactionRecord.XC_ContactId__c');
        let caseComp = 'c__XC_LCP120_NewCase';

        //open the new case component in a new subtab

        workspace.getEnclosingTabId().then((resp)=>{
            
            let params = {
                contactId : contactId,
                parentTab : resp,
                componentName : caseComp,
                tabLabel : 'New Case',
                sobjecttype : 'Contact'
            }

            helper.openNewCase(component,event,helper,params);


        });

    },

    openNewCase : function(component,event,helper,params){

        if(component.get('v.interactionRecord.XC_InteractionStatus__c')=='Close'){

            let msg = $A.get('$Label.c.XC_CL_CTINoCaseOnClosedInteraction');
            helper.showToast('Error',msg,'error');
            return;
        }


        let parentId = params.parentTab;
        let contactId = params.contactId;
        let componentName = params.componentName;
        let tabLabel = params.tabLabel;
        let sobj = params.sobjecttype;
        let workspace = component.find('workspace');

        workspace.openSubtab({
			parentTabId : parentId,
			pageReference : {
				"type":"standard__component",
				"attributes":{
					"componentName" : componentName
				},
				"state":{
                    "c__contactId" : contactId,
                    "c__sobjectType" : sobj
				}
			},
			focus : true
		}).then((response)=>{
			
			console.log('OPENSUBTAB SUCCESS::' + JSON.stringify(response));

			workspace.setTabLabel({
				tabId:response,
				label:tabLabel
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