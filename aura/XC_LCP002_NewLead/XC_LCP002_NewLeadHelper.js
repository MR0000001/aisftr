({
    doInit : function(component, event) {   
        
        let myPageRef = component.get("v.pageReference"); 
        if(myPageRef){
            component.set("v.socialPersonaId", myPageRef.state.c__socialPersonaId);
            component.set("v.recordTypeToReturn",myPageRef.state.c__qRecordType);
            component.set("v.ctiInteractionPhone",myPageRef.state.c__Phone);
            component.set("v.ctiInteractionPhonePref",myPageRef.state.c__PhonePrefix);
        }

        this.isSystemAdminInit(component);
        
        console.log('SOCIAL PERSONA Id IN INIT ='+component.get('v.socialPersonaId'));
        let recordId = component.get("v.recordId"); 
        let recordTypeId  = component.get('v.recordTypeToReturn');    
        console.log('RECORDTYPE IN INIT ='+recordTypeId);
        component.set('v.spinnerControl', true);
        
        this.retrieveDataInit(component, recordId, recordTypeId);



    }, 
    
    
    isSystemAdminInit : function(component){
        let action = component.get("c.isSystemAdmin");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue)  {
                component.set("v.isSystemAdmin",true);
                component.set("v.disableCheckBox",false);
                component.set("v.assignLeadCheckBox", true);
            }
        }); 
        $A.enqueueAction(action);
    },

    retrieveDataInit : function(component, recordId, recordTypeId){
        let action2 = component.get("c.retrieveData");
        action2.setParams({
            'recordId': recordId, //can be a Lead in edit or can be a Case in case of Social Studio Lead
            'recordTypeId': recordTypeId 
        });
        action2.setCallback(this, function(a) {
            let state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                let result = JSON.parse(a.getReturnValue());
                console.log('****result****',result);
                component.set("v.techConfiguration", result);
                this.getChannelFromUserInit(component);
                component.set('v.leadRecord', result.existingRecord);
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set('v.spinnerControl', false);
                    }), 1000
                );
                let fieldLabelMap = {};

                component.set('v.initFinished', true);
                component.set('v.requiredFields', JSON.parse(result.listMandatory));
                component.set('v.leadRTName', result.recordTypeName);
                let rt = result.recordTypeName;
                if(rt=='XC_GLO_Lead_Residential'){
                    component.set('v.leadTitle', $A.get("$Label.c.XC_CL_ResidentialInfo"));
                }else if(rt=='XC_GLO_Lead_Condominium'){
                    component.set('v.leadTitle', $A.get("$Label.c.XC_CL_CondominiumInfo"));
                }else if(rt=='XC_GLO_Lead_Soho'){
                    component.set('v.leadTitle', $A.get("$Label.c.XC_CL_SohoInfo"));
                }else if(rt.includes('SFM')){
                    component.set('v.isSFMLead', true);
                    component.set('v.leadTitle', $A.get("$Label.c.XC_CL_LeadLabel")); 
                }
                // this.populateFieldsFromFieldSet(component,event, result.fsAddress, 'v.body0', fieldLabelMap)
                this.populateFieldsFromFieldSet(component,event, result.fsPersonalData, 'v.body1', fieldLabelMap);
                if(component.get("v.leadRTName")==='XC_GLO_Lead_Residential'){
                    this.populateFieldsFromFieldSet(component,event, result.fsDocumentData, 'v.body2', fieldLabelMap);
                }
                this.populateFieldsFromFieldSet(component,event, result.fsOpportunity, 'v.body3', fieldLabelMap);
                this.populateFieldsFromFieldSet(component,event, result.fsSource, 'v.body4', fieldLabelMap);
                this.populateFieldsFromFieldSet(component,event, result.fsContactData, 'v.body6', fieldLabelMap);
                if((component.get("v.leadRTName")==='XC_GLO_B2B' || component.get("v.leadRTName")==='XC_GLO_B2G' || component.get("v.leadRTName")==='XC_Global') && component.get("v.userCountry") != 'Chile' && component.get("v.userCountry")!= 'Colombia'){
                    this.populateFieldsFromFieldSet(component,event, result.fsCampaign, 'v.body7', fieldLabelMap);
                }
                component.set('v.fieldLabelMap', fieldLabelMap);
                if (component.get("v.techConfiguration").defaultPrefLanguage !== '' && component.get("v.techConfiguration").defaultPrefLanguage !== null) {
                    component.find("XC_Preference_Language__c").set("v.value", component.get("v.techConfiguration").defaultPrefLanguage);
                }

               
            }            
        });
        $A.enqueueAction(action2);
    },

    getChannelFromUserInit : function(component){
        let action3 = component.get("c.getChannelFromUser");
        action3.setCallback(this, function(response) {
            let state3 = response.getState();
            let retValue3 = response.getReturnValue();
            if(state3 === "SUCCESS" && retValue3!=''){
                component.set("v.rchannel",     retValue3.fieldName);
                component.set("v.userCountry",  retValue3.objectInfo);
                component.set("v.leadRecord.Country__c",  retValue3.objectInfo);
                component.set("v.leadRecord.XC_Country__c",  retValue3.objectInfo);
                //dpalamides
                $A.createComponent(
                            "c:XC_LCP163_CreateConsents",
                            {
                                "aura:id": "inpId",
                                "recordId": component.get("v.recordId"),
                                "objectType" : "Lead",
                                "sObjectData" : component.get("v.leadRecord"),
                                "recordTypeId" : component.get("v.recordTypeToReturn")
                            },
                            function(newInp, status, errorMessage){
                                if (status === "SUCCESS") {
                                    var body = component.get("v.bodyConsents");
                                    body.push(newInp);
                                    component.set("v.bodyConsents", body);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                }
                                    else if (status === "ERROR") {
                                        console.log("Error: " + errorMessage);
                                    }
                            }
                        );

                console.log('Country = '+retValue3.objectInfo);
                if(retValue3.objectInfo != '' && retValue3.objectInfo != null ) {
                    component.find("XC_DocumentCountry__c").set("v.value", retValue3.objectInfo);
                    if(component.find("XC_DocumentType__c")){
                        component.find("XC_DocumentType__c").set("v.disabled", false);
                    }
                }
                let docCountry = component.find("XC_CDocCountry__c");
                if(docCountry != null && docCountry != '') {
                    component.find("XC_CDocCountry__c").set("v.value", retValue3.objectInfo);
                }
                //component.find("XC_ContactDocumentCountry__c").set("v.value", retValue3.objectInfo);

                if(component.get("v.userCountry") == 'Spain'){
                    component.set("v.setDependent",false);
                    if(!component.get('v.ctiInteractionPhonePref')) {
                        component.find("XC_PhonePrefix__c").set("v.value", '+34');
                    }
                    component.find("XC_MobilePrefix__c").set("v.value", '+34');
                   // component.find("XC_Nationality__c").set("v.value", 'Spanish');
                    component.set("v.setDependent",true);
                }

                else if(component.get("v.userCountry") == 'Chile'){
                    component.set("v.setDependent",false);
                    if(!component.get('v.ctiInteractionPhonePref')) {
                    	component.find("XC_PhonePrefix__c").set("v.value", '+56');
                    }
                    component.find("XC_MobilePrefix__c").set("v.value", '+56');
                    // component.find("XC_Nationality__c").set("v.value", 'Spanish');
                    component.find("XC_Country__c").set("v.value", retValue3.objectInfo);
                    //component.find("XC_ContactDocumentCountry__c").set("v.value", retValue3.objectInfo);
                
                    component.set("v.setDependent",true);
                }
                else if(component.get("v.userCountry") == 'Colombia'){
                    component.set("v.setDependent",false);
                    if(!component.get('v.ctiInteractionPhonePref')) {
                    	component.find("XC_PhonePrefix__c").set("v.value", '+57');
                    }
                    component.find("XC_MobilePrefix__c").set("v.value", '+57');
                    // component.find("XC_Nationality__c").set("v.value", 'Spanish');
                    component.find("XC_Country__c").set("v.value", retValue3.objectInfo);
                    //component.find("XC_ContactDocumentCountry__c").set("v.value", retValue3.objectInfo);
                
                    component.set("v.setDependent",true);
                } else {
                   // component.set("v.setDependent", false);
                    let techResult = component.get("v.techConfiguration");
                    if (!component.get('v.ctiInteractionPhonePref')) {
                        component.find("XC_PhonePrefix__c").set("v.value", techResult.defaultPhonePrefix);
                    }
                    component.find("XC_MobilePrefix__c").set("v.value", techResult.defaultPhonePrefix);
                    component.find("XC_Nationality__c").set("v.value", techResult.defaultNationality);
                    component.find("XC_Country__c").set("v.value", retValue3.objectInfo);
                   
                  
                   // component.set("v.setDependent", true);
                }
                if((component.get("v.leadRTName")==='XC_GLO_B2B' || component.get("v.leadRTName")==='XC_GLO_B2G'|| component.get("v.leadRTName")==='XC_Global') && component.get("v.userCountry") != 'Chile' && component.get("v.userCountry")!= 'Colombia'){
                    component.set('v.showCampaignSection', true);
                    if(component.get("v.leadRTName")!='XC_Global'){
                    	component.set('v.showAddress', true);
                    	component.set('v.showAddressButton', false);
                    }
                }

            }
        }); 
        $A.enqueueAction(action3);
    },
    
    
    changePickVal : function(component, event) {
        let picklistValue = component.get("v.picklistValue");
        console.log("entrato in changePickVal con valore "+picklistValue);
        if(picklistValue==$A.get("$Label.c.XC_CL_Condominium")){
            component.set("v.isCondominium",true);
            component.set("v.isSmallBusiness",false);
        }else if(picklistValue==$A.get("$Label.c.XC_CL_SmallBusiness")){
            component.set("v.isSmallBusiness",true);
            component.set("v.isCondominium",false);
        }else{
            component.set("v.isCondominium",false);
            component.set("v.isSmallBusiness",false); 
        }
        
        
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

            if (requiredFields.indexOf(a.fieldPath) > -1) {
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
                if(a.fieldPath == 'XC_Channel__c'){
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class" : className,//"customRequired" 
                        "value" : component.getReference("v.rchannel"),
                        "disabled" : true
                    }
                }
                else if(a.fieldPath == 'XC_DocumentType__c'){
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class" : className,//"customRequired" 
                        "value" : leadRecord[a.fieldPath],
                        "onchange": component.getReference("c.checkIfNIE")
                    }
                } else if(a.fieldPath == 'XC_LeadPhone__c' && component.get('v.ctiInteractionPhone')){
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class" : className,//"customRequired" 
                        "value" : component.get('v.ctiInteractionPhone'),
                    }
                }else if(a.fieldPath == 'XC_PhonePrefix__c' && component.get('v.ctiInteractionPhonePref')){
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class" : className,//"customRequired" 
                        "value" : component.get('v.ctiInteractionPhonePref'), 
                    }
                }else{
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class" : className,//"customRequired" 
                    }
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
        
        let controlCheck = component.get('v.assignLeadCheckBox');
        if(controlCheck) {
            component.set('v.assignLeadCheckBox', true);
        } else{
            component.set('v.assignLeadCheckBox', false);
        }
    },
    
    onSubmitHelper : function(component, event, helper) {

        let mandatory = component.get("v.addressMandatoryFields");
        let address = component.get("v.addressFromEvent");
        let fieldsMissing = []; 
        let check;
        
        if(address){
            for (var j in mandatory) { 
                check = false;
                for (var i in address) { 
                    if(i == mandatory[j] && address[i]){
                        check = true;
                    }   
                }

                if(!check){
                    fieldsMissing.push(mandatory[j]);
                }
            }
        }
        
        if(fieldsMissing.length>0){
            let toastEventError = $A.get("e.force:showToast");
            toastEventError.setParams({
                title : $A.get("$Label.c.XC_CL_Warning"),
                message: "Missing the following fields in address section: " + fieldsMissing,
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '15000'
            });
            toastEventError.fire(); 
            return;
        }

       	event.preventDefault();   
        component.set('v.fieldMap',JSON.stringify(event.getParam("fields")));
        
        check = true ;

        console.log('@@@ showAddress -> ' + component.get("v.showAddress"));
        console.log('@@@ addressFromEvent -> ' + component.get("v.addressFromEvent"));
        console.log('@@@ withoutValidate -> ' + component.get("v.withoutValidate"));
        
        if(((component.get("v.showAddress") && component.get("v.addressFromEvent") === null) || 
            (component.get("v.showAddress") && component.get("v.addressFromEvent") !== null && !component.get("v.addressFromEvent").validate) ) 
            && !component.get("v.withoutValidate") ) { 
                    
            check = false;
            console.log('@@@ Address Missing Validation');
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : $A.get("$Label.c.XC_CL_Warning"),
                message: $A.get("$Label.c.XC_CL_Address_MissingValidation"),
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '6000'
            });
            toastEvent.fire();
            component.set('v.spinnerControl', false);
            return;
        }
        
        let thirdPartiesCheck = component.get("v.thirdPartiesCheck")
        let consentsLE = component.get("v.consentsLE");
        //let hasDuplicated = false;
        let hasMoreThenOneLE = consentsLE.length>1;
        /*if(consentsLE.length>1){
        	let unicLE = [];
            for(let le of consentsLE){
                for(let unicItem of unicLE){
                    if(le.XC_LegalEntity__c === unicItem.XC_LegalEntity__c && 
                       le.XC_LeCountry__c === unicItem.XC_LeCountry__c){
                        hasDuplicated = true;
                        break;
                    }
				};
                if(hasDuplicated){
                    break;
                }else{
					unicLE.push(le);
                }
			};
        }*/
        if(hasMoreThenOneLE){ //hasDuplicated || 
            /*let message = (hasDuplicated) ? $A.get("$Label.c.XC_CL_LegalEntityDuplicated")
                                          : $A.get("$Label.c.XC_CL_OnlyOneLegalEntityForLead"); */
            let toastEventDuplicated = $A.get("e.force:showToast");
            toastEventDuplicated.setParams({
                title : $A.get("$Label.c.XC_CL_Warning"),
                message: $A.get("$Label.c.XC_CL_OnlyOneLegalEntityForLead"),
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '6000'
            });
            toastEventDuplicated.fire();
            component.set('v.spinnerControl', false);
        }
        
        let fieldToControl;
        if(event && event.getParam("fields") && check && !hasMoreThenOneLE) { //hasDuplicated
            fieldToControl = JSON.parse(JSON.stringify(event.getParam("fields")));
            component.set('v.fieldMap',JSON.stringify(event.getParam("fields")));
            component.set('v.fieldToControl', fieldToControl);
            console.log('@@@ ' + component.get('v.fieldMap'));
            this.retrieveMandatoryFields(component, event, fieldToControl);
            
            event.preventDefault();   
        }
        let canInsert = component.get('v.canInsert');
        if(canInsert && check && !hasMoreThenOneLE) {//&& control == '1') { //!hasDuplicated
            
            this.removeRedBox(component, event); 
            
            component.set('v.spinnerControl', true);
            let accountName;

            let eventFields = component.get('v.fieldMap');
            console.log('eventFields@@@@@@@@ ='+eventFields); 
            let controlCheck = component.get('v.assignLeadCheckBox');  

            let addressFields =  component.get("v.addressFromEvent");
            
            let recordTypeId = component.get("v.recordTypeToReturn");
            let contestLead = component.get('v.recordId');
            let picklistValue = component.get("v.picklistValue");
            if(picklistValue=="Condominium"){
                accountName=component.get("v.condominiumName");
            }else if(picklistValue=="Small Business"){
                accountName=component.get("v.companyName");
            }else{
                accountName='';
            }

            let mapLead = {
                'fieldMapStringLead': eventFields,
                'assignLead': controlCheck,
                'recordTypeId': recordTypeId,
                'existingLeadId': contestLead,
                'fullName': accountName,
                'addressFields': JSON.stringify(addressFields),
                'socialPersonaId': component.get('v.socialPersonaId'),
                'robinsonCustomer': component.get('v.robinsonCustomer'),
                'thirdPartiesCheck': thirdPartiesCheck,
                'thirdPartiesVersion': component.get("v.thirdPartiesVersion"),
                'consentsLE': JSON.stringify(consentsLE), 
                'releaseDate' : component.get('v.releaseDate'),
                'withoutValidate' : component.get('v.withoutValidate'),
                'consentsWrapper' : JSON.stringify(component.get('v.saveConsentsWrapper')) //dpalamides
            }
            console.log('@@@ mapLead ---> ', mapLead);
            let mapLeadString = JSON.stringify(mapLead);
            this.actionMapLead(component, event, helper, mapLeadString)  
        }  
    },
    
    
    closeCurrentTab : function(component, event, helper, toRedirect) {
        if(component.get('v.isCommunity') && component.get("v.leadRTName")==='XC_GLO_B2B'){
            let windowRedirect = window.location.href;
            window.location.href = windowRedirect;
        } else if(component.get('v.socialPersonaId')){
           
            let navigateEvent = $A.get("e.force:navigateToSObject");
            navigateEvent.setParams({ "recordId": toRedirect, "slideDevName": "detail", "isredirect": true });    
            navigateEvent.fire();
                  
        }else{
            component.set('v.tabLabel', 'Lead');
            let targetPageReference = {
                type: 'standard__recordPage',
                attributes: {
                    "recordId": toRedirect,
                    "actionName": "view"
                },
                state: {
                    "c__recordId": toRedirect,
                    //"c__isMobile" : isMobile,
                    "c__closeSource" : true
                }
            };
            component.set("v.targetPageReference", targetPageReference);
            helper.executeAptNavigation(component, event, helper);
        }

    },

    actionMapLead : function(component, event, helper, mapLeadString){
        let action = component.get("c.createRecord");
        action.setParams({
            'mapLeadString': mapLeadString
        });


        action.setCallback(this, function(a) {
            let state = a.getState();
            let result = a.getReturnValue();
            let toastMessage = $A.get("$Label.c.XC_CL_LeadCreated");
            console.log('LEAD CREATO ' + toastMessage);
            console.log('@@@result', result);
            if(result.success) {
                console.log('@@@ Lead has to update!');
                console.log('a='+result.recordId);
                let recordIdToRedirect = (result.convertedAccountId) ? (result.convertedAccountId) : result.recordId; 

                let errorMessage;
                
                if(component.get('v.recordId')){
                    errorMessage = $A.get("$Label.c.XC_CL_LeadUpdated");;
                }
                else{
                    errorMessage = toastMessage;
                }
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : errorMessage,
                    message: ' ',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible' 
                });
                this.closeCurrentTab(component, event, helper, recordIdToRedirect);
                
                component.set('v.spinnerControl', false);
                toastEvent.fire();
            }
            else{
                console.log('@@@ leadToUpdate --> ', result.leadToUpdate);
                if(result.leadUpdated && result.leadToUpdate && result.leadToUpdate.Id != null) {
                    console.log('@@@ Redirect to Lead');
                    let toastEventError = $A.get("e.force:showToast");
                    toastEventError.setParams({
                        title : $A.get("$Label.c.XC_CL_Warning"),
                        message: $A.get("$Label.c.XC_CL_LeadUpdatedWIthKey") + result.key,
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'dismissible'
                    });
                    toastEventError.fire();
                    /*var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result.leadToUpdate.Id
                    });
                    navEvt.fire();*/
                    this.closeCurrentTab(component, event, helper, result.leadToUpdate.Id);
                }
                else if(result && result.errorMessage) {
                    let errorMessageResult = result.errorMessage;
                    let toastEventError = $A.get("e.force:showToast");
                    toastEventError.setParams({
                        title : $A.get("$Label.c.XC_CL_Warning"),
                        message: errorMessageResult,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible',
                        duration: '15000'
                    });
                    toastEventError.fire();
                    
                    console.log('@@@fieldName'+result.fieldName);
                    this.showErrorOnField(component, result.fieldName);
                    component.set('v.spinnerControl', false);
                    
                    
                } else {
                    let toastEventWarn = $A.get("e.force:showToast");
                    toastEventWarn.setParams({
                        title : $A.get("$Label.c.XC_CL_Warning"),
                        message: $A.get("$Label.c.XC_CL_ErrorsOccurred"),
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible',
                        duration: '15000'
                    });
                    toastEventWarn.fire();
                    component.set('v.spinnerControl', false);
                }
            }
        });
        $A.enqueueAction(action); 
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
    
    retrieveMandatoryFields : function(component, event, fieldToControl) {
    
        let fieldToCont = component.get('v.fieldToControl');
        this.fieldFilledControl(component, event, fieldToCont);
        /*address no longer mandatory for commercial visit*/
        /* var action = component.get("c.checkCommercialVisit");
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
        $A.enqueueAction(action);  */
    },
    
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
            //let isCorrectBirthdate = this.checkBirthdate(component, event, component.get('v.fieldMap'));
            let isCorrectEmail = this.checkValidityEmail(component, event, component.get('v.fieldMap'));
            let birthdateErrorMsg = '';
            let emailErrorMsg = '';
            let checkContactEmailOrPhone = this.checkContactEmailMobileOrPhone(component, event, component.get('v.fieldMap'));
            let identityOrEmailPhone='';
            let checkMobilePhone = this.checkValidityMobilePhone(component, event, component.get('v.fieldMap'));
            let validMobilePhone = '';
            let checkPhone = this.checkValidityPhone(component, event, component.get('v.fieldMap'));
            let validPhone = '';
            let recordTypeName = component.get('v.leadRTName');
            let validCondominium = '';
            let leFilled = this.checkLegalEntity(component, event);
            let leErrorMsg = '';
            let checkCondominum = this.checkValidCondominium(component, event, component.get('v.fieldMap'));
            
            
            if(!checkCondominum && !component.get('v.isSFMLead')) {
                if(recordTypeName == 'XC_GLO_Lead_Condominium'){
                    validCondominium = $A.get("$Label.c.XC_CL_CondominiumRequired"); 
                }else if(recordTypeName == 'XC_GLO_Lead_Residential'){
                    validCondominium = $A.get("$Label.c.XC_CL_FirstNameRequired");
                }else if(recordTypeName == 'XC_GLO_Lead_Soho' || recordTypeName == 'XC_GLO_B2B' || recordTypeName == 'XC_GLO_B2G' || recordTypeName == 'XC_Global'){
                    validCondominium = $A.get("$Label.c.XC_CL_CompanyRequired");
                }
                canInsertControl = false;
            }
            
            if(!checkPhone && !component.get('v.isSFMLead') && recordTypeName != 'XC_GLO_B2B' && recordTypeName != 'XC_GLO_B2G' && recordTypeName != 'XC_Global') {
                validPhone = $A.get("$Label.c.XC_CL_Account_PhoneFormat");
                canInsertControl = false;
            }
            if(!checkMobilePhone && !component.get('v.isSFMLead')) {
                validMobilePhone = $A.get("$Label.c.XC_CL_Account_ValidMobilePhone");
                canInsertControl = false;
            }
            if(checkContactEmailOrPhone && !component.get('v.isSFMLead')) {
                identityOrEmailPhone = $A.get("$Label.c.XC_CL_Account_InsertPhoneMail");
                canInsertControl = false;
            }
            /*if(!isCorrectBirthdate) {
                birthdateErrorMsg = $A.get("$Label.c.XC_CL_Lead_Agewarning");
                canInsertControl=false;
            }*/
            if(!isCorrectEmail && !component.get('v.isSFMLead')) {
                emailErrorMsg = $A.get("$Label.c.XC_CL_Account_ValidMail");
                canInsertControl=false;
            }
            if(!leFilled && !component.get('v.isSFMLead')){
                leErrorMsg = $A.get("$Label.c.XC_CL_ConsentsToFill");
                canInsertControl=false;
            }
            
            let errorMessageTotal = [];
            console.log('Mandatory fields-->' + fieldSet);
            for (let i = 0; i < fieldSet.length; i++) {
                if(!objectField[fieldSet[i]]) {
                    errorMessageTotal.push(fieldLabel[jsonfieldSet[i]]);
                    canInsertControl = false;
                    console.log('@@@fieldSet'+fieldSet[i]);
                    this.showErrorOnField(component, fieldSet[i]);
                    component.set('v.canInsert', false);
                    break;
                }
            }
            console.log('ErrorMessageTotal-->' + errorMessageTotal);
            if(canInsertControl) {
                component.set('v.canInsert', true);
               
            }
            else{

                let errorMessageFinal = errorMessageTotal.join(', ');
                if(errorMessageTotal.length > 1){
                    errorMessageFinal = errorMessageFinal + ' ' + $A.get("$Label.c.XC_CL_MandatoryPlural");
                }
                if(errorMessageTotal.length == 1){
                    errorMessageFinal = errorMessageFinal + ' ' + $A.get("$Label.c.XC_CL_Mandatory");
                }
                
                       
                component.set("v.showToastMessage", true);
                component.set("v.type", "error");
                
                let errorMessageList = [identityOrEmailPhone,validCondominium, validMobilePhone, validPhone,  errorMessageFinal, birthdateErrorMsg, emailErrorMsg, leErrorMsg];
                console.log('First Error List: '+ errorMessageList);
                let errorMessageListFinal = [];
                for (let index = 0; index < errorMessageList.length; index++){
                    if (errorMessageList[index] !== null && errorMessageList[index] != "" ){
                        errorMessageListFinal.push(errorMessageList[index]);
                    }
                }
                console.log('Error List: '+ errorMessageListFinal);
                if(errorMessageListFinal.length > 1 ){
                    if(errorMessageListFinal[errorMessageListFinal.length - 1] == errorMessageFinal
                       && !errorMessageListFinal[errorMessageListFinal.length - 1].includes($A.get("$Label.c.XC_CL_GiveDataToEndesa") + ' ' + $A.get("$Label.c.XC_CL_Mandatory"))){
                        errorMessageListFinal[errorMessageListFinal.length - 1] = $A.get("$Label.c.XC_CL_Lead_Also") + ' ' + 
                                                                                  errorMessageListFinal[errorMessageListFinal.length - 1];
                    }
                    else if(errorMessageListFinal[errorMessageListFinal.length - 1].includes($A.get("$Label.c.XC_CL_GiveDataToEndesa") + ' ' + $A.get("$Label.c.XC_CL_Mandatory"))){
                        errorMessageListFinal[errorMessageListFinal.length - 1] = $A.get("$Label.c.XC_CL_Lead_Also") + ' ' + $A.get("$Label.c.XC_CL_GiveDataToEndesaIsMandatory");
                    }
                        else{
                            errorMessageListFinal[errorMessageListFinal.length - 1] = $A.get("$Label.c.XC_CL_Lead_Also") + ' ' + 
                                                                                      errorMessageListFinal[errorMessageListFinal.length - 1].charAt(0).toLowerCase() + 
                                                                                      errorMessageListFinal[errorMessageListFinal.length - 1].slice(1);
                        }
                }
                let errorMessage = errorMessageListFinal.join('. ');
                
                
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.c.XC_CL_Warning"),
                    message: errorMessage,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible',
                    duration: '15000'
                });
                toastEvent.fire();

            }
        } 
               
    },
    
    removeRedBox : function(component, event) {
        
        let mapField = component.get('v.fieldLabelMap');
        for(let i in mapField){ 
            let cmpTarget = component.find(i);
            $A.util.removeClass(cmpTarget, 'slds-has-error ');
        }
    },

    checkLegalEntity :  function(component, event){
        let consentsLE = component.get("v.consentsLE");
        if(consentsLE.length===0){
            return true; //dpalamides
        }
        return true;
    },
    
    checkValidityEmail :  function(component, event, mapField){
        let emailFieldValue = (JSON.parse(mapField))["Email"];
        let isValidEmail;
        let regExpEmailformat = new RegExp('^(([^<>()\\[\\]\\\\.,;:\\s@"]+(\\.[^<>()\\[\\]\\\\.,;:\\s@"]+)*)' + 
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
        }	 
        return isValidEmail;
    },
    
    
    checkContactEmailMobileOrPhone : function(component, event, mapField) { 
        let email = (JSON.parse(mapField))["Email"];
        let phone = (JSON.parse(mapField))["XC_LeadPhone__c"];
        let mobilePhone = (JSON.parse(mapField))["XC_LeadMobile__c"];
        let mobilePrefix = (JSON.parse(mapField))["XC_MobilePrefix__c"]; 
        let phonePrefix = (JSON.parse(mapField))["XC_PhonePrefix__c "];        
        if(!email && (!phone && !phonePrefix) && (!mobilePhone && !mobilePrefix)) {
            return true;
        }        
        return false;        
    },
    
    checkValidCondominium :  function(component, event, mapField){ 
        let cname;
        let recordTypeName = component.get('v.leadRTName');
        console.log('RECORDTYPENAME = '+recordTypeName);
        if(recordTypeName == 'XC_GLO_Lead_Condominium'){
            cname = (JSON.parse(mapField))["XC_CondominiumName__c"];
        }else if(recordTypeName == 'XC_GLO_Lead_Residential'){
            cname = (JSON.parse(mapField))["FirstName"];
        }else if(recordTypeName == 'XC_GLO_Lead_Soho' || recordTypeName == 'XC_GLO_B2B' || recordTypeName == 'XC_GLO_B2G' || recordTypeName == 'XC_Global' ){
            cname = (JSON.parse(mapField))["Company"];
        }
        if($A.util.isEmpty(cname)){
            return false;
        } else{
            return true;
        }
    },
    
    checkValidityPhone :  function(component, event, mapField){
        let mobilePhoneFieldValue = (JSON.parse(mapField))["Phone"];
        let isValidMobilePhone;
        let regExpPhoneFormat = /^(\+34|0034|34)?[\s|\-|\.]?[9][\s|\-|\.]?([0-9][\s|\-|\.]?){8}$/;  
        let regExpMobilePhoneFormat = /^(\+34|0034|34)?[\s|\-|\.]?[6|7][\s|\-|\.]?([0-9][\s|\-|\.]?){8}$/;  
        if($A.util.isEmpty(mobilePhoneFieldValue)){ 
            isValidMobilePhone = true;
        }
        else{   
            if(mobilePhoneFieldValue.match(regExpMobilePhoneFormat) || mobilePhoneFieldValue.match(regExpPhoneFormat)){
                isValidMobilePhone = true;
            }else{
                isValidMobilePhone = false;
            }
        }    
        return isValidMobilePhone;
    },
    
    checkValidityMobilePhone :  function(component, event, mapField){
        let mobilePhoneFieldValue = (JSON.parse(mapField))["MobilePhone"];
        let isValidMobilePhone;
        let regExpPhoneFormat = /^(\+34|0034|34)?[\s|\-|\.]?[9][\s|\-|\.]?([0-9][\s|\-|\.]?){8}$/;  
        let regExpMobilePhoneFormat = /^(\+34|0034|34)?[\s|\-|\.]?[6|7][\s|\-|\.]?([0-9][\s|\-|\.]?){8}$/;  
        if($A.util.isEmpty(mobilePhoneFieldValue)){ 
            isValidMobilePhone = true;
        }
        else{   
            if(mobilePhoneFieldValue.match(regExpMobilePhoneFormat) || mobilePhoneFieldValue.match(regExpPhoneFormat)){
                isValidMobilePhone = true;
            }else{
                isValidMobilePhone = false;
            }
        }    
        return isValidMobilePhone;
    },
    
    goBack : function(component, event) { 
        console.log('entrato in go Back');
        let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId}); 
        })
    },
    
    
    checkBirthdate : function(component, event, mapField) {
        
        let birthdate = (JSON.parse(mapField))["XC_Birthdate__c"];
        if(birthdate) {
            let birth = new Date(birthdate);
            
            let ageDifMs = Date.now() - birth.getTime();
            let ageDate = new Date(ageDifMs); // miliseconds from epoch
            if(Math.abs(ageDate.getUTCFullYear() - 1970) < 16) {
                console.log('PIPPO:'+(Math.abs(ageDate.getUTCFullYear() - 1970)));
                return false;
            }else{
                return true;
            }
        } else{
            return true; 
        }    
    }
})