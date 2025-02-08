({
    init : function(component, event, helper) {
        let myPageRef = component.get("v.pageReference"); 
        if(myPageRef){
            component.set("v.sobjecttype",myPageRef.state.c__sobjectType);
            component.set("v.recordId",myPageRef.state.c__contactId);
        }
        if(component.get("v.sobjecttype") === undefined || component.get("v.sobjecttype") === ''){
            component.set("v.fromCaseList", true); 
        }
        if(component.get("v.sobjecttype") === 'Contact' || component.get("v.sobjecttype") === 'Zuora__ZInvoice__c'){
            component.set("v.showSpinner", true);
            let action = component.get("c.getRelatedAccountId"); //getInvoiceAccountId //param_name> <zinvoiceId
            action.setParams({
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS"){
                    let result = response.getReturnValue();
                    if(result.success){
                        let objData = [];
                        objData = JSON.parse(result.objectInfo);
                        if(objData && objData !== ''){
                            component.set("v.isCommunity", objData['isCommunity']);
                        }
                        component.set("v.accountSegment", objData['segment']);
                        //if(component.get("v.sobjecttype") === 'Contact' && result.objectInfo != "B2C"){
                        if(component.get("v.sobjecttype") === 'Contact' && objData && objData !== '' &&  objData['segment'] != "B2C"){
                            component.set("v.accountSelectionDisabled", false); 
                            let accountData = [];
                            let optsAccount = [];
                            accountData = JSON.parse(result.fieldName);
                            accountData.forEach(function (entry) {
                                optsAccount.push({
                                    value: entry['key'],
                                    label: entry['value']
                                });
                            });
                            component.set("v.accountOptions", optsAccount);
                        }else{
                            component.set("v.relatedAccountId",result.recordId); //invoiceAccountId
                        }
                    }
                }
                component.set("v.showSpinner", false); 
            });
            $A.enqueueAction(action);
        }
        else if(component.get("v.sobjecttype") === 'Opportunity' || component.get("v.sobjecttype") === 'Account' || 
                component.get("v.sobjecttype") === 'Asset' || component.get("v.sobjecttype") === 'WorkOrder'){
            component.set("v.showSpinner", true);
            let action = component.get("c.getConfigInformation");
            action.setParams({
                'recordId'    : component.get("v.recordId"),
                'sObjectName' : component.get("v.sobjecttype")
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                let objInfo = [];
                let contactData = [];
                if (state === "SUCCESS"){
                    let result = response.getReturnValue();
                    if(result.success){
                        objInfo = JSON.parse(result.objectInfo);
                        component.set("v.isCommunity", objInfo['isCommunity']);
                        component.set("v.contactSelectionDisabled", objInfo['onlyPrimaryContact']);
                        component.set("v.accountSegment", objInfo['segment']);
                        if(component.get("v.sobjecttype") === 'Asset'){
                            component.set("v.relatedAccountId", objInfo['accountId']);
                            component.set("v.contactValue", objInfo['contactId']);
                            component.set("v.isLogic", objInfo['isLogic']);
                            component.set("v.isTechnical", objInfo['isTechnical']);
                            if(component.get("v.isLogic") || component.get("v.isTechnical")){
                                component.set("v.address", objInfo['address']);
                                component.set("v.commercialAsset", objInfo['commercialAsset']);
                                component.set("v.businessLine", objInfo['businessLine']);
                            }
                        }
                        //Contact List
                        contactData = objInfo['contactData'];
                        if(contactData){
                            let optsContact = [];
                            contactData.forEach(function (entry) {
                                optsContact.push({
                                    value: entry['key'],
                                    label: entry['value']
                                });
                            });
                            component.set('v.contactOptions', optsContact);
                        }
                    }
                }
                component.set("v.showSpinner", false); 
            });
            $A.enqueueAction(action);
            //DeAv 05.07.2022 - NR2330 START 
            let recordId = component.get("v.recordId");
            let filterAddress;
            let filterAsset;
            if(component.get('v.sobjecttype')==='Account') {                                
                filterAddress = "XC_Account__c = '"+recordId +"'";
                filterAsset = "AccountId = '"+recordId +"' AND RecordType.Developername IN ('TAM_Support','TAM_SwitchBoard','TAM_Lamp','TAM_Network')";  
                component.set("v.filterAddress", filterAddress);
                component.set("v.filterAsset", filterAsset);               
            }else if(component.get('v.sobjecttype')==='Asset'){
                let accData = [];
                let action2 = component.get("c.searchAccountFromAsset");
                action2.setParams({
                    'recordId' : recordId
                });           
                action2.setCallback(this, function(response) {
                    let state = response.getState();
                    let objInfo = [];
                    if (state === "SUCCESS"){
                        let result = response.getReturnValue();
                        if(result.success){
                            objInfo = JSON.parse(result.objectInfo);
                            accData = objInfo['accFromAssetId'];
                            component.set("v.filterAddress", "XC_Account__c = '"+accData +"'");
                            component.set("v.caseAsset", recordId);
                        }
                    }
                });
                $A.enqueueAction(action2);           
            }      
            //DeAv 05.07.2022 - NR2330 END
        }else if(component.get("v.sobjecttype") === 'Case'){
            component.set("v.showSpinner", true);
            let action = component.get("c.getCaseSegment");
            action.setParams({
                'recordId'    : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS"){
                    let result = response.getReturnValue();
                    let objInfo = [];
                    objInfo = JSON.parse(result.objectInfo);
                    component.set("v.isCommunity", objInfo['isCommunity']);
                    //if(result == 'B2B' || result == 'B2G'){
                    /*if(objInfo['segment'] == 'B2B' || objInfo['segment'] == 'B2G'){
                        component.set("v.accountAndContactSelectionDisabled", false);
                    }*/ //Fix MC 20201020
                    component.set("v.accountSegment", objInfo['segment']);
                }
                component.set("v.showSpinner", false); 
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.showSpinner", true);
            let action = component.get("c.getInitInfo");
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS"){
                    let result = response.getReturnValue();
                    let objInfo = [];
                    objInfo = JSON.parse(result.objectInfo);
                    component.set("v.isCommunity", objInfo['isCommunity']);
                }
                component.set("v.showSpinner", false); 
            });
            $A.enqueueAction(action);
        }
    },
 
	checkRecordType : function(component, event, helper) {
        if( !component.get('v.contactSelectionDisabled') &&
            (component.get('v.sobjecttype')==='Opportunity' || component.get('v.sobjecttype')==='Account') ){
            if(!component.get("v.caseReason") || !component.get("v.contactValue")){
                return;
            }
        }
        if( component.find('relatedContactAccount') && (!component.get('v.relatedAccountId') || !component.get('v.caseReason'))){
            return;
        }
        if( component.get('v.fromCaseList') && 
          (!component.get("v.caseReason") || !component.get('v.relatedAccountId') || !component.get("v.contactValue")) ){
            return;
        }
        console.log('parentId = '+component.get("v.recordId"));
        console.log('sobjecttype = '+component.get("v.sobjecttype")); 
		let reason = component.get("v.caseReason"); 
        if(reason!=''){
        console.log('@@@@ caseReason' + reason); //DeAv 30.06.2022 - NR2330
        component.set('v.showSpinner' , true);
        let action = component.get("c.getCaseRecordType");
        action.setParams({
            'caseReason' : reason,
            'accountSegment' : component.get("v.accountSegment")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let res = response.getReturnValue();

            if(res && res.success && res.recordId!=null){
                component.set('v.rtCase' , res.recordId); //DeAv 02.07.2022 - NR2330
                component.set('v.rtDevName' , res.rtDevName); //DeAv 04.07.2022 - NR2330
                console.log('@@@recordType -->'+res.resultMessage);
                let createRecordEvent = $A.get("e.force:createRecord");
                if(component.get('v.sobjecttype')==='Account'){
                    let contactId = (component.get('v.contactSelectionDisabled')) ? null : component.get("v.contactValue");
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {
                            "Reason" : reason,
                            "AccountId" : component.get("v.recordId"),
                            "ContactId" : contactId
                        }
                    });
                }
                else if(component.get('v.sobjecttype')==='Contact'){
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {
                            "Reason" : reason,
                            "ContactId" : component.get("v.recordId"),
                            "AccountId" : component.get("v.relatedAccountId") // component.find("accountId").get("v.value")
                            
                        }
                    });
                }
                else if(component.get('v.sobjecttype')==='Case'){
                    console.log('parentId = '+component.get("v.recordId"));
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {
                            "Reason" : reason,
                            "ContactId" : component.find("contactId").get("v.value"),
                            "AccountId" : component.find("accountId").get("v.value"),
                            "ParentId" : component.get("v.recordId")
                            
                        }
                    });
                }
                else if(component.get('v.sobjecttype')==='Opportunity'){
                    let contactId = (component.get('v.contactSelectionDisabled')) ? component.find("contactId").get("v.value") : component.get("v.contactValue");
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {
                            "Reason" : reason,
                            "ContactId" : contactId,
                            "AccountId" : component.find("accountId").get("v.value"),
                            "XC_Opportunity__c" : component.get("v.recordId")
                            
                        }
                    });
                }
                else if(component.get('v.sobjecttype')==='Asset'){
                    /*let actionGet = component.get("c.getRelatedAccountAndContactId");
                    actionGet.setParams({
                        'recordId' : component.get("v.recordId")
                    });
                    actionGet.setCallback(this, function(response) {
                        let res2 = response.getReturnValue();
                        if(res2){
                            let resOBj = JSON.parse(res2);*/
                    if(component.get("v.isLogic") || component.get("v.isTechnical")){
                        createRecordEvent.setParams({
                            "entityApiName": 'Case',
                            "recordTypeId" : res.recordId,
                            'defaultFieldValues': {
                                "Reason"               : reason,
                                "ContactId"            : component.get("v.contactValue"),
                                "AccountId"            : component.get("v.relatedAccountId"),
                                "XC_BusinessLine__c"   : component.get("v.businessLine"),
                                "XC_TechnicalAsset__c" : component.get("v.recordId"),
                                "XC_Address__c"        : component.get("v.address"),
                                "XC_Segment__c"        : component.get("v.accountSegment"),
                                "AssetId"              : component.get("v.commercialAsset")

                            }
                        });
                    }else{
                        createRecordEvent.setParams({
                            "entityApiName": 'Case',
                            "recordTypeId" : res.recordId,
                            'defaultFieldValues': {
                                "Reason" : reason,
                                "ContactId" : component.get("v.contactValue"),
                                "AccountId" : component.get("v.relatedAccountId"),
                                "XC_Segment__c" : component.get("v.accountSegment"),
                                "AssetId"   : component.get("v.recordId")
                            }
                        });
                    }

                    //DeAv 02.07.2022 - NR2330 Added if condition START
                    if(component.get('v.sobjecttype')==='Asset' && (reason !== 'XCMOT002' || (reason == 'XCMOT002' && component.get('v.rtDevName') !== 'XC_B2B_EnelXItalia_Management_Case' && component.get('v.rtDevName') !== 'XC_B2G_EnelXItalia_Management_Case'))){
                        $A.get("e.force:closeQuickAction").fire();
                        createRecordEvent.fire();
                    }
                    //DeAv 02.07.2022 - NR2330 Added if condition END

                        /*}
                    }); 
                    $A.enqueueAction(actionGet);*/
                } 
                else if(component.get('v.sobjecttype')==='WorkOrder'){
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {
                            "Reason" : reason,
                            "ContactId" : component.find("contactId").get("v.value"),
                            "AccountId" : component.find("accountId").get("v.value"),
                            "XC_Order__c":component.find('configurationId').get("v.value"),
                            "XC_WorkOrder__c" : component.get("v.recordId")
                        }
                    });    
                }
                else if(component.get('v.sobjecttype')==='Zuora__ZInvoice__c' ){
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {
                            "Reason" : reason,
                            "AccountId" :  component.get("v.relatedAccountId"), //invoiceAccountId
                            "XC_Invoice__c" : component.get("v.recordId")
                            
                        }
                    });
                }
                else if(component.get('v.sobjecttype')==='project_cloud__Project_Task__c'){
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {    
                            "Reason" : reason,
                            "AccountId" :  component.get("v.relatedAccountId"), 
                            "project_cloud__Project_Task__c": component.get("v.recordId")
                        }
                    });
                }
                else if( component.get('v.fromCaseList')){
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {
                            "Reason" : reason,
                            "ContactId" : component.get("v.contactValue"),
                            "AccountId" : component.get('v.relatedAccountId')
                        }
                    });
                }
                else{
                    createRecordEvent.setParams({
                        "entityApiName": 'Case',
                        "recordTypeId" : res.recordId,
                        'defaultFieldValues': {
                            "Reason" : reason
                            
                        }
                    });
                }
                //DeAv 28.07.2022 - NR2330: Add if else if START
                if(component.get('v.sobjecttype')==='Account' && (reason !== 'XCMOT002' || (reason == 'XCMOT002' && component.get('v.rtDevName') !== 'XC_B2B_EnelXItalia_Management_Case' && component.get('v.rtDevName') !== 'XC_B2G_EnelXItalia_Management_Case'))){
                    $A.get("e.force:closeQuickAction").fire();
                    createRecordEvent.fire();
                }else if(component.get('v.sobjecttype')!='Asset' && component.get('v.sobjecttype')!='Account'){ 
                    $A.get("e.force:closeQuickAction").fire(); 
                    createRecordEvent.fire(); 
                }
                //DeAv 28.07.2022 - NR2330: Add if else if END
            }else{
                let errMess = (res && res.resultMessage) ? res.resultMessage : $A.get('$Label.c.XC_CL_OperationNotAllowed');
                this.showToast(component, errMess, "error");
            }/*else{
                    this.showMessage(component, "error", "Warning", res.resultMessage );
                }*/
            component.set('v.showSpinner' , false);
        });
        $A.enqueueAction(action);
        }
    },
    
    searchContactToSelect : function(component, event, helper) {
        component.set("v.showSpinner", true);
        let accountValue = component.find("caseAccountId").get("v.value");
        if(accountValue && accountValue[0]){
            let action = component.get("c.searchContactForAccount");
            action.setParams({
                'accountId' : accountValue[0]
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                let objInfo = [];
                let contactData = [];
                if (state === "SUCCESS"){
                    let result = response.getReturnValue();
                    if(result.success){
                        objInfo = JSON.parse(result.objectInfo);
                        component.set("v.accountSegment", objInfo['accountSegment']);

                        //Contact List
                        if(objInfo['onlyPrimaryContact']){
                            contactData = objInfo['primaryContact'];
                        }else{
                            contactData = objInfo['contactData'];
                        }
                        if(contactData){
                            let optsContact = [];
                            contactData.forEach(function (entry) {
                                optsContact.push({
                                    value: entry['key'],
                                    label: entry['value']
                                });
                            });
                            component.set('v.contactOptions', optsContact);
                        }
                    }
                }
                component.set("v.showSpinner", false);
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.contactOptions', []);
            component.set('v.relatedAccountId', null);
            component.set('v.contactValue', null);
            component.set("v.showSpinner", false);
        }
    },
    
    /*showMessage : function(component, variante, title, mess){
        component.find('notifLib').showNotice({
            "variant": variante,
            "header": title,
            "message": mess,
            
        });
    },*/
    
    showToast : function(component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },

    //DeAv 01.07.2022 - NR2330 START
    createCase: function (component, event, helper) {
        let createRecordEvent = $A.get("e.force:createRecord");
        let rtCase = component.get('v.rtCase'); 
        let reason = component.get("v.caseReason"); 
        let address = component.get("v.caseAddress");
        let asset = component.get("v.caseAsset");
        if(component.get('v.sobjecttype')==='Account'){
            let contactId = (component.get('v.contactSelectionDisabled')) ? null : component.get("v.contactValue");
            createRecordEvent.setParams({
                "entityApiName": 'Case',
                "recordTypeId" : rtCase,
                'defaultFieldValues': {
                    "Reason" : reason,
                    "AccountId" : component.get("v.recordId"),
                    "ContactId" : contactId,
                    "XC_Address__c" : address,
                    "XC_TechnicalAsset__c" : asset
                }
            });
        }else if(component.get('v.sobjecttype')==='Asset'){
            if(component.get("v.isLogic") || component.get("v.isTechnical")){
                createRecordEvent.setParams({
                    "entityApiName": 'Case',
                    "recordTypeId" : rtCase,
                    'defaultFieldValues': {
                        "Reason"               : reason,
                        "ContactId"            : component.get("v.contactValue"),
                        "AccountId"            : component.get("v.relatedAccountId"),
                        "XC_BusinessLine__c"   : component.get("v.businessLine"),
                        "XC_Segment__c"        : component.get("v.accountSegment"),
                        "AssetId"              : component.get("v.commercialAsset"),
                        "XC_Address__c"        : address,
                        "XC_TechnicalAsset__c" : asset

                    }
                });
            }else{
                createRecordEvent.setParams({
                    "entityApiName": 'Case',
                    "recordTypeId" : rtCase,
                    'defaultFieldValues': {
                        "Reason" : reason,
                        "ContactId" : component.get("v.contactValue"),
                        "AccountId" : component.get("v.relatedAccountId"),
                        "XC_Segment__c" : component.get("v.accountSegment"),
                        "AssetId"   : component.get("v.recordId"),
                        "XC_Address__c"        : address,
                        "XC_TechnicalAsset__c" : asset
                    }
                });
            }
        }
        $A.get("e.force:closeQuickAction").fire();
        createRecordEvent.fire();
    },

    handleCloseNewAddress: function (component, event, helper) {
        console.log('to 504');
        component.set("v.showNewAddress", false);
    }
    //DeAv 01.07.2022 - NR2330 END
    
})