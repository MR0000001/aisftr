/*
 * @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
 * @date Creation  09/10/2018
 * @date Modification 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_LCP000_RedirectLogicNewSobject – Helper for component to redirect Login "New Sobject"
**/

({
    
    doInit : function(component, event) {  
        let recordTypeId = component.get('v.recordTypeId');
        let objectName = component.get('v.objectName');
        console.log('@@@ In init of LCP000: recordTypeId -> ' + recordTypeId + ' (object: ' + objectName + ')');
        
        if(!recordTypeId) {
            let action = component.get("c.getDefaultRecordType");
            action.setParams({
                "objectName" : objectName
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                if (component.isValid() && state === "SUCCESS") {
                    let result = JSON.parse(a.getReturnValue());
                    console.log('result->' + result);
                    component.set('v.recordTypeId', result);
                }            
            });
            $A.enqueueAction(action);  
        }
        
        let userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set('v.currentUserId', userId);
        console.log('@@@ currentUserId -> ' + userId);
        if(userId) {

            component.set('v.userIdRetrieved', true); 
        }
    },
    
    verifyUserHelper : function(component, event, helper) {
        console.log(JSON.stringify(component.get('v.record')));
        let userRecord = JSON.parse(JSON.stringify(component.get('v.record')));
        let isXCustomerUser = userRecord.fields.XC_X_Customer_User__c.value;
        component.set('v.isCustUser', isXCustomerUser);
        if(isXCustomerUser) {
            if(component.get("v.objectName")=='Opportunity') {
                //helper.manageOpportunity(component, event, helper);// VDB 15032022 CR758
                helper.segmentOpp(component, event, helper);//VDB 160322 CR 758
                
            }
            else if(component.get("v.objectName")=='Asset') {
                helper.manageAsset(component, event, helper);
                
            }else{
                component.set('v.showCustomNew', true);
            }
        }
        else{
            this.gotoURL(component);
        }
    },
    
    manageOpportunity  : function(component, event, helper) {
        console.log('@@@ -> XC_Contact__c', component.get("v.contactId"));
        console.log('@@@ -> AccountId', component.get("v.accountId"));
        console.log('@@@ -> XC_Address__c', component.get("v.addressId"));
        console.log('@@@ -> XC_CaseId__c',component.get("v.caseId") );
        console.log('@@@ -> XC_ProductCategoryOfInterest__c', component.get("v.productCategory"));
        console.log('@@@ -> StageName',component.get("v.stageName") );
        console.log('@@@ -> CloseDate', component.get("v.closeDate"));
        console.log('@@@ -> XC_ReceivingChannel__c', component.get("v.receivingChannel"));
        console.log('@@@ -> recordTypeId', component.get("v.recordTypeId"));
        console.log('@@@ -> XC_Segment__c', component.get("v.segmentOp")); 
        console.log('@@@ -> XC_ServiceAppointment__c', component.get("v.serviceId"));//CR763
        //START VDB 15032022 CR758
        let nameOpp="";
        let legalopp=component.get("v.legalEntityUser");
        if(component.get("v.segmentOp")==="B2C" || component.get("v.segmentOp")===""){
            nameOpp='Temporary Opportunity - '+ new Date()
            legalopp=component.get("v.legalEntityValue");
        }
        //END VDB 15032022 CR758        
        if( !component.get("v.fromContact")){
            this.showToast(component, event, helper, $A.get("$Label.c.XC_CL_Opportunity_NewStandardNotAllowed") , 'error');
        }else{
            let objectName = component.get('v.objectName');
            let recordTypeId = component.get('v.recordTypeId');
            let createRecordEvent = $A.get("e.force:createRecord");        
            //[BEGIN INC000088500191, GS, 11/06/2022]
            //if(component.get("v.workOrderId") === "" && component.get("v.caseId") === ""){
            if(component.get("v.workOrderId") === "" && component.get("v.caseId") === "" && component.get("v.serviceId") !== "" && component.get("v.serviceId") !== null ){
            //[END INC000088500191, GS, 11/06/2022]
                console.log("CreateREcord Event workOrderId Empty");
                createRecordEvent.setParams({
                    "entityApiName": objectName,
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                        //"Name" : 'Temporary Opportunity - '+ new Date(),//VDB 15032022 CR758
                        "Name":nameOpp,//VDB 15032022 CR758
                        "XC_Contact__c" : component.get("v.contactId"),
                        "AccountId" : component.get("v.accountId"),
                        "XC_Address__c" : component.get("v.addressId"),
                        "XC_ResidentialAddress__c" : component.get("v.addressIdResidential"),
                        "XC_ProductCategoryOfInterest__c" : component.get("v.productCategory"),
                        //"XC_LegalEntity__c" : component.get("v.legalEntityValue"),//VDB 17032022 CR758
                        "XC_LegalEntity__c" : legalopp,//VDB 17032022 CR758
                        "StageName" : component.get("v.stageName"),
                        "CloseDate" : component.get("v.closeDate"),
                        "XC_ReceivingChannel__c" :  component.get("v.receivingChannel"),
                        "XC_ServiceAppointment__c":  component.get("v.serviceId") //CR763
                    }
                });
            }
            //[BEGIN INC000088500191, GS, 11/06/2022]
            else if(component.get("v.workOrderId") === "" && component.get("v.caseId") === "" ){
                console.log("CreateREcord Event workOrderId Empty");
                createRecordEvent.setParams({
                    "entityApiName": objectName,
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                        //"Name" : 'Temporary Opportunity - '+ new Date(),//VDB 15032022 CR758
                        "Name":nameOpp,//VDB 15032022 CR758
                        "XC_Contact__c" : component.get("v.contactId"),
                        "AccountId" : component.get("v.accountId"),
                        "XC_Address__c" : component.get("v.addressId"),
                        "XC_ResidentialAddress__c" : component.get("v.addressIdResidential"),
                        "XC_ProductCategoryOfInterest__c" : component.get("v.productCategory"),
                        //"XC_LegalEntity__c" : component.get("v.legalEntityValue"),//VDB 17032022 CR758
                        "XC_LegalEntity__c" : legalopp,//VDB 17032022 CR758
                        "StageName" : component.get("v.stageName"),
                        "CloseDate" : component.get("v.closeDate"),
                        "XC_ReceivingChannel__c" :  component.get("v.receivingChannel"),
                    }
                });
            }
            //[end INC000088500191, GS, 11/06/2022]
            //[BEGIN INC000088500191, GS, 11/06/2022]
            //else if(component.get("v.caseId") !== "" && component.get("v.workOrderId") !== ""){
            else if(component.get("v.caseId") !== "" && component.get("v.workOrderId") !== "" && component.get("v.serviceId") !== "" && component.get("v.serviceId") !== null ){
            //[END INC000088500191, GS, 11/06/2022]
                createRecordEvent.setParams({
                    "entityApiName": objectName,
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                        //"Name" : 'Temporary Opportunity - '+ new Date(),//VDB 15032022 CR758
                        "Name":nameOpp,//VDB 15032022 CR758
                        "XC_Contact__c" : component.get("v.contactId"),
                        "AccountId" : component.get("v.accountId"),
                        "XC_Address__c" : component.get("v.addressId"),
                        "XC_CaseId__c" : component.get("v.caseId"),
                        "XC_WorkOrder__c" : component.get("v.workOrderId"),
                        "XC_ProductCategoryOfInterest__c" : component.get("v.productCategory"),
                        //"XC_LegalEntity__c" : component.get("v.legalEntityValue"),//VDB 17032022 CR758
                        "XC_LegalEntity__c" : legalopp,//VDB 17032022 CR758
                        "StageName" : component.get("v.stageName"),
                        "CloseDate" : component.get("v.closeDate"),
                        "XC_ReceivingChannel__c" :  component.get("v.receivingChannel"),
                        "XC_ServiceAppointment__c":  component.get("v.serviceId") //CR763
                    }
                });
            }
            //[BEGIN INC000088500191, GS, 11/06/2022]
            else if(component.get("v.caseId") !== "" && component.get("v.workOrderId") !== "" ){
                createRecordEvent.setParams({
                    "entityApiName": objectName,
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                        //"Name" : 'Temporary Opportunity - '+ new Date(),//VDB 15032022 CR758
                        "Name":nameOpp,//VDB 15032022 CR758
                        "XC_Contact__c" : component.get("v.contactId"),
                        "AccountId" : component.get("v.accountId"),
                        "XC_Address__c" : component.get("v.addressId"),
                        "XC_CaseId__c" : component.get("v.caseId"),
                        "XC_WorkOrder__c" : component.get("v.workOrderId"),
                        "XC_ProductCategoryOfInterest__c" : component.get("v.productCategory"),
                        //"XC_LegalEntity__c" : component.get("v.legalEntityValue"),//VDB 17032022 CR758
                        "XC_LegalEntity__c" : legalopp,//VDB 17032022 CR758
                        "StageName" : component.get("v.stageName"),
                        "CloseDate" : component.get("v.closeDate"),
                        "XC_ReceivingChannel__c" :  component.get("v.receivingChannel"),
                    }
                });
            }
            //[END INC000088500191, GS, 11/06/2022]
            //[BEGIN INC000088500191, GS, 11/06/2022]
            //else if(component.get("v.caseId") !== ""){
            else if(component.get("v.caseId") !== "" && component.get("v.serviceId")!== "" && component.get("v.serviceId")!== null ){
            //[END INC000088500191, GS, 11/06/2022]
                createRecordEvent.setParams({
                    "entityApiName": objectName,
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                       // "Name" : 'Temporary Opportunity - '+ new Date(),// VDB 15032022 CR758
                       "Name":nameOpp,//VDB 15032022 CR758
                        "XC_Contact__c" : component.get("v.contactId"),
                        "AccountId" : component.get("v.accountId"),
                        "XC_Address__c" : component.get("v.addressId"),
                        "XC_CaseId__c" : component.get("v.caseId"),
                        "XC_ProductCategoryOfInterest__c" : component.get("v.productCategory"),
                        //"XC_LegalEntity__c" : component.get("v.legalEntityValue"),//VDB 17032022 CR758
                        "XC_LegalEntity__c" : legalopp,//VDB 17032022 CR758
                        "StageName" : component.get("v.stageName"),
                        "CloseDate" : component.get("v.closeDate"),
                        "XC_ReceivingChannel__c" :  component.get("v.receivingChannel"),
                        "XC_ServiceAppointment__c":  component.get("v.serviceId") //763
                    }
                });
            }
            //[BEGIN INC000088500191, GS, 11/06/2022]
            else if(component.get("v.caseId") !== "" ){
                createRecordEvent.setParams({
                    "entityApiName": objectName,
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                       // "Name" : 'Temporary Opportunity - '+ new Date(),// VDB 15032022 CR758
                       "Name":nameOpp,//VDB 15032022 CR758
                        "XC_Contact__c" : component.get("v.contactId"),
                        "AccountId" : component.get("v.accountId"),
                        "XC_Address__c" : component.get("v.addressId"),
                        "XC_CaseId__c" : component.get("v.caseId"),
                        "XC_ProductCategoryOfInterest__c" : component.get("v.productCategory"),
                        //"XC_LegalEntity__c" : component.get("v.legalEntityValue"),//VDB 17032022 CR758
                        "XC_LegalEntity__c" : legalopp,//VDB 17032022 CR758
                        "StageName" : component.get("v.stageName"),
                        "CloseDate" : component.get("v.closeDate"),
                        "XC_ReceivingChannel__c" :  component.get("v.receivingChannel"),
                    }
                });
            }
            //[END INC000088500191, GS, 11/06/2022]
            //[BEGIN INC000088500191, GS, 11/06/2022]
            //else{
            else if(component.get("v.serviceId")!== "" && component.get("v.serviceId")!== null ){
            //[END INC000088500191, GS, 11/06/2022]
                console.log("CreateREcord Event workOrderIdNot Empty");
                createRecordEvent.setParams({
                    "entityApiName": objectName,
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                       // "Name" : 'Temporary Opportunity - '+ new Date(),// VDB 15032022 CR758
                       "Name":nameOpp,//VDB 15032022 CR758
                        "XC_Contact__c" : component.get("v.contactId"),
                        "AccountId" : component.get("v.accountId"),
                        "XC_WorkOrder__c" : component.get("v.workOrderId"),
                        "StageName" : component.get("v.stageName"),
                        "CloseDate" : component.get("v.closeDate"),
                        "XC_ReceivingChannel__c" :  component.get("v.receivingChannel"),
                        "XC_ServiceAppointment__c":  component.get("v.serviceId") //CR763
                    }
                    
                });
            }
            //[BEGIN INC000088500191, GS, 11/06/2022]
            else{
            //[END INC000088500191, GS, 11/06/2022]
                console.log("CreateREcord Event workOrderIdNot Empty");
                createRecordEvent.setParams({
                    "entityApiName": objectName,
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                        // "Name" : 'Temporary Opportunity - '+ new Date(),// VDB 15032022 CR758
                        "Name":nameOpp,//VDB 15032022 CR758
                        "XC_Contact__c" : component.get("v.contactId"),
                        "AccountId" : component.get("v.accountId"),
                        "XC_WorkOrder__c" : component.get("v.workOrderId"),
                        "StageName" : component.get("v.stageName"),
                        "CloseDate" : component.get("v.closeDate"),
                        "XC_ReceivingChannel__c" :  component.get("v.receivingChannel"),
                    }
                    
                });
            }
            //[END INC000088500191, GS, 11/06/2022]
            createRecordEvent.fire();
            
            component.set("v.spinner", false);
        }
    },
    
    manageAsset  : function(component, event, helper) {
        if( !component.get("v.fromContact")){
            this.showToast(component, event, helper, $A.get("$Label.c.XC_CL_Asset_NewStandardNotAllowed") , 'error');
        }else{
            let objectName = component.get('v.objectName');
            let recordTypeId = component.get('v.recordTypeId');
            let createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": objectName,
                "recordTypeId" : recordTypeId,
                "defaultFieldValues": {
                    "ContactId" : component.get("v.contactId"),
                    "AccountId" : component.get("v.accountId"),
                    "XC_Catalog__c" : component.get("v.catalog"),
                    "XC_CatalogCategory__c" : component.get("v.catalogCategory"),
                    "XC_Address__c" : component.get("v.podId"),
                    "Status" : $A.get("$Label.c.XC_CL_Asset_StatusActive"),
                    "XC_Product_Type__c" : $A.get("$Label.c.XC_CL_ProductTypeEquipment"),
                    "Description" : component.get("v.description"),
                    "XC_Model__c" : component.get("v.modelValue")
                }
                
            });
            createRecordEvent.fire();
        }
    },
    
    gotoURL : function (component) {
        let objectName = component.get('v.objectName');
        let recordTypeId = component.get('v.recordTypeId');
        let createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": objectName,
            "recordTypeId" : recordTypeId
        });
        createRecordEvent.fire();
    }, 
    
    showToast : function(component, event, helper, message, messageType) {
        console.log('quaaaa'+component.get("v.recordId"));
        let navService = component.find("navService");
        let workspaceAPI = component.find("workspace");
        let pageReferenceN = {
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Opportunity",
                actionName: "list"
            },
            state: {
                filterName: "Recent"
            }
        };
        navService.navigate(pageReferenceN);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": messageType
        });
        
        workspaceAPI.getFocusedTabInfo().then(function(response){
            var oldTabId = response.tabId;
            //workspaceAPI.openTab({
            //  pageReference : pageReferenceN,
            //focus: true
            // }).then(function(response) {
            workspaceAPI.closeTab({tabId: oldTabId});
        });
        // });
    },
    //START VDB 160322 CR 758
    segmentOpp: function (component, event, helper) {  
            var action = component.get("c.opportunitySegment"); 
            action.setParams({
            'recordTypeId': component.get("v.recordTypeId")           
        });               
        action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set('{!v.segmentOp}', response.getReturnValue());
                    console.log('@@@ -> segmentOp', component.get("v.segmentOp"));
                    helper.oppLegalEntity(component, event, helper);
                }
            });
      
            $A.enqueueAction(action);
   },
    //END VDB 15032022 CR758
    //START VDB 170322 CR 758
    oppLegalEntity: function (component, event, helper) {  
        var action = component.get("c.opportunityLegalEntity"); 
        console.log('@@@-->segmentopp',component.get("v.segmentOp"));
        action.setParams({
        'segmentOp': component.get("v.segmentOp")           
    });               
    action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('{!v.legalEntityUser}', response.getReturnValue());
                console.log('@@@ -> legalEntityUser', component.get("v.legalEntityUser"));
                helper.manageOpportunity(component, event, helper);
            }
        });
  
        $A.enqueueAction(action);
        
}
//END VDB 17032022 CR758
})