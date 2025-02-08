({
    doInit: function (component, event, helper) {

        
        let myPageRef = component.get("v.pageReference");
        if (myPageRef) {
            component.set("v.recordTypeToReturn", myPageRef.state.c__qRecordType);
            component.set("v.ctiInteractionPhone", myPageRef.state.c__Phone);
			component.set("v.ctiInteractionPhonePrefix", myPageRef.state.c__PhonePrefix);
        }


        component.set('v.spinnerControl', true);
        let recordId = component.get("v.recordId");
        let recordTypeId = component.get('v.recordTypeToReturn');
        console.log('recordId->' + recordId);
        console.log('recordTypeId->' + recordTypeId);

        let action = component.get("c.retrieveData");
        let accountRecord = component.get("v.accountRecord");
        console.log('accountRecord->' + accountRecord);
        action.setParams({
            'recordId': recordId,
            'recordTypeId': recordTypeId
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = JSON.parse(a.getReturnValue());
                console.log('****result****', result);
                component.set("v.techConfiguration", result);
                component.set('v.accountRecord', result.existingRecord);
                component.set('v.recordTypeName', result.recordTypeName);
                component.set('v.userCountry', result.userCountry);
                component.set("v.accountRecord.XC_Country__c", result.userCountry);
                let defaultPrefix = result.defaultPhonePrefix;
                console.log("********DEFAULT PHONE " + defaultPrefix)
                component.set("v.newSection.PhonePrefix", defaultPrefix);
                component.set("v.newSection.MobilePrefix", defaultPrefix);
                component.set("v.newSection.Nationality", result.defaultNationality);
                component.set("v.newSection.PreferredLanguage", result.defaultPrefLanguage);

                if(!result.recordTypeName.includes('SFM')){
                    //dpalamides
                    $A.createComponent(
                        "c:XC_LCP163_CreateConsents", {
                        "aura:id": "inpId",
                        "recordId": component.get("v.recordId"),
                        "objectType": "Account",
                        "sObjectData": component.get("v.accountRecord"),
                        "recordTypeId": component.get("v.recordTypeToReturn")
                    },
                        function (newInp, status, errorMessage) {
                            if (status === "SUCCESS") {
                                var body = component.get("v.bodyConsents");
                                body.push(newInp);
                                component.set("v.bodyConsents", body);
                            } else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                            } else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                            }
                        }
                    );
                }
                if (result.recordTypeName == 'XC_Account_Partner') {
                    component.set('v.isPartner', true);
                    component.set("v.isSmallBusiness", false);
                    component.set("v.isCondominium", false);
                    component.set("v.isGlobalB2B", false);
                    component.set("v.isGlobalB2G", false);
                } else if (result.recordTypeName == 'XC_GLO_Account_Condominium') {
                    component.set('v.isPartner', false);
                    component.set("v.isCondominium", true);
                    component.set("v.isSmallBusiness", false);
                    component.set("v.isGlobalB2B", false);
                    component.set("v.isGlobalB2G", false);
                } else if (result.recordTypeName == 'XC_GLO_Account_Soho') {
                    component.set('v.isPartner', false);
                    component.set("v.isCondominium", false);
                    component.set("v.isSmallBusiness", true);
                    component.set("v.isGlobalB2B", false);
                    component.set("v.isGlobalB2G", false);
                } else if(result.recordTypeName == 'XC_GLO_B2B'){
                    component.set('v.isPartner', false);
                    component.set("v.isCondominium", false);
                    component.set("v.isSmallBusiness", false);
                    component.set("v.isGlobalB2B", true);
                    component.set("v.isGlobalB2G", false);
                    if(component.get('v.userCountry') != 'Chile' && component.get('v.userCountry') != 'Colombia' && component.get('v.userCountry') != 'Spain'){
                        component.set("v.showAddress", true );
                        component.set("v.showCheckBoxAddress", false);
                    }
                }else if(result.recordTypeName == 'XC_GLO_B2G'){
                    component.set('v.isPartner', false);
                    component.set("v.isCondominium", false);
                    component.set("v.isSmallBusiness", false);
                    component.set("v.isGlobalB2B", false);
                    component.set("v.isGlobalB2G", true);
                    if(component.get('v.userCountry') != 'Chile' && component.get('v.userCountry') != 'Colombia' && component.get('v.userCountry') != 'Spain'){
                        component.set("v.showAddress", true );
                        component.set("v.showCheckBoxAddress", false);
                    }
                }
                else if(result.recordTypeName.includes('SFM')){
                    component.set("v.isSFMAccount", true);
                }
                window.setTimeout(
                    $A.getCallback(function () {
                        component.set('v.spinnerControl', false);
                    }), 1000
                );
                component.set('v.initFinished', true);
                let fieldLabelMap = {};

                component.set('v.requiredFields', JSON.parse(result.listMandatory));

                // popolamento picklist brand
                var opts = [];
                result.brands.forEach(function (entry) {
                    opts.push({
                        value: entry,
                        label: entry
                    });
                })
                component.set('v.options', opts);



                this.populateFieldsFromFieldSet(component, event, result.fsPersonalData, 'v.body1', fieldLabelMap);
                this.populateFieldsFromFieldSet(component, event, result.fsType, 'v.body5', fieldLabelMap);
                this.populateFieldsFromFieldSet(component, event, result.fsDocumentData, 'v.body2', fieldLabelMap);
                this.populateFieldsFromFieldSet(component, event, result.fsOpportunity, 'v.body3', fieldLabelMap);

                component.set('v.fieldLabelMap', fieldLabelMap);


                helper.evaluateShowContact(component);
                //[ BEGIN, arjun.raoh@accenture.com, 24/11/2021, Enel X - NR2041 - Energy Communities, FT3-2021 ]
                helper.evaluateShowSectionEnergyCommunity(component);
                helper.evaluateShowSectionEnergyCommunityMember(component);
                //[ END, arjun.raoh@accenture.com, 24/11/2021, Enel X - NR2041 - Energy Communities, FT3-2021 ]
            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), "error");
                component.set('v.spinnerControl', true);
            }
            if(component.find("XC_DocumentCountry__c")){
                component.find("XC_DocumentCountry__c").set("v.value", component.get('v.userCountry'));
            }
         /*   if(component.get('v.userCountry') != 'Chile' && component.get('v.userCountry') != 'Colombia'){
                component.set("v.newSection.DocumentCountry", component.get('v.userCountry'));
            }*/
            //console.log("*******HERE " + defaultPrefix);


           /* if (component.get("v.userCountry") == 'Spain') {

                if (component.find("XC_AccountNationality__c")) {
                    //   component.find("XC_AccountNationality__c").set("v.value", 'Spanish');
                }
                component.set("v.newSection.Nationality", 'Spanish');
                component.find("XC_AccountPhonePrefix__c").set("v.value", '+34');
                component.find("XC_MainPhonePrefix__c").set("v.value", '+34');
                component.set("v.newSection.PhonePrefix", '+34');
                component.set("v.newSection.MobilePrefix", '+34');
                // component.set("v.setDependent",true);
            }else if(component.get("v.userCountry") == 'Colombia'){
                component.find("XC_AccountPhonePrefix__c").set("v.value", '+57');
                component.find("XC_MainPhonePrefix__c").set("v.value", '+57');
                component.set("v.newSection.PhonePrefix", '+57');
                component.set("v.newSection.MobilePrefix", '+57');
            }else if(component.get("v.userCountry") == 'Chile'){
                component.find("XC_AccountPhonePrefix__c").set("v.value", '+56');
                component.find("XC_MainPhonePrefix__c").set("v.value", '+56');
                component.set("v.newSection.PhonePrefix", '+56');
                component.set("v.newSection.MobilePrefix", '+56');
            }
         
                //  component.set("v.newSection.Nationality", 'Spanish');

                component.find("XC_AccountPhonePrefix__c").set("v.value", defaultPrefix);
                component.find("XC_MainPhonePrefix__c").set("v.value", defaultPrefix);

                // component.set("v.setDependent",true);
            } */

            console.log("DEFAULT VALUE ON ACCOUNT")
           


            //  component.find("XC_AccountPhonePrefix__c").set("v.value", defaultPrefix);
            //  component.find("XC_MainPhonePrefix__c").set("v.value", defaultPrefix);


        });
        $A.enqueueAction(action);


    },
        isSpain : function(component){
            console.log("jjp TESTT");
        let action = component.get("c.isSpain");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            console.log('is Spain return value: ', retValue);
            if (state === "SUCCESS")  {
                component.set("v.isSpain",retValue);
            }
        }); 
        $A.enqueueAction(action);
    },
    
    evaluateShowContact: function (component) {

        if (component.get('v.isPartner') || component.get('v.isSmallBusiness') || component.get('v.isCondominium') || component.get('v.isGlobalB2B') || component.get('v.isGlobalB2G') || component.get('v.isSFMAccount')) {
            component.set('v.showContact', true);
        }
    },

    populateFieldsFromFieldSet: function (component, event, fieldSet, bodyName, fieldLabelMap) {
        let cmp = component;
        let accountRecord = {};
        if (JSON.stringify(component.get('v.accountRecord'))) {
            accountRecord = JSON.parse(JSON.stringify(component.get('v.accountRecord')));
        }

        let requiredFields = component.get('v.requiredFields');
        for (let i = 0; i < fieldSet.length; i++) {
            let labelMap = {};
            labelMap[fieldSet[i].fieldPath] = fieldSet[i].label;
            fieldLabelMap[fieldSet[i].fieldPath] = fieldSet[i].label;
            let a = fieldSet[i];
            let className = '';


            if (requiredFields.indexOf(a.fieldPath) > -1) {
                className = 'customRequired';
            }

            let fieldObject = {};

            if (accountRecord && accountRecord.hasOwnProperty(a.fieldPath) && accountRecord[a.fieldPath]) {
                console.log("HERE I AM 1" + a.fieldPath);
                fieldObject = {
                    "aura:id": a.fieldPath,
                    "fieldName": a.fieldPath,
                    "class": className, //"customRequired" 
                    "value": accountRecord[a.fieldPath]
                }
            } else {
                if (a.fieldPath == 'IdentityType__c') {
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class": className, //"customRequired" 
                        "value": accountRecord[a.fieldPath],
                        "onchange": component.getReference("c.checkIfNIE")


                    }


                } else if (component.get('v.recordTypeName') == 'XC_Account_Partner' && (a.fieldPath == 'XC_PartnerType__c' || a.fieldPath == 'XC_CommercialCode__c')) {
                    console.log('@@@@entrato');
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class": className, //"customRequired" 
                        "required": true
                    }
                } else if (a.fieldPath == 'XC_AccountPhone__c' && component.get('v.ctiInteractionPhone')) {

                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class": className, //"customRequired" 
                        "value": component.get('v.ctiInteractionPhone')
                    }


                } else if (component.get('v.recordTypeName') == 'XC_GLO_Account_Soho' && a.fieldPath == 'XC_TradingPartner__c') {

                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class": className,
                        "disabled": true
                    }

                } else if (component.get('v.recordTypeName') == 'XC_GLO_Account_Soho' && a.fieldPath == 'XC_SohoType__c') {

                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class": className,
                        "onchange": component.getReference("c.handleSohoTypeChange")
                    }

                } else if (component.get('v.recordTypeName') == 'XC_GLO_Account_Residential' && a.fieldPath == 'XC_Preference_Language__c') {
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class": className, //"customRequired"
                        "value": component.get("v.techConfiguration").defaultPrefLanguage
                    }
                } else if (a.fieldPath === 'XC_AccountPhonePrefix__c' || a.fieldPath === 'XC_MainPhonePrefix__c' || a.fieldPath === 'XC_AccountNationality__c' ) { 
                    let resultTec = component.get("v.techConfiguration");
                    let valuedefault = (a.fieldPath === 'XC_AccountPhonePrefix__c' || a.fieldPath === 'XC_MainPhonePrefix__c') ? resultTec.defaultPhonePrefix : resultTec.defaultNationality;
                    if(component.get("v.ctiInteractionPhonePrefix") && a.fieldPath != 'XC_AccountNationality__c'){
                        valuedefault = component.get("v.ctiInteractionPhonePrefix");
                    }
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class": className, //"customRequired" 
                        "value": valuedefault
                    }
                } else {
                    //console.log("HERE I AM 2" + a.fieldPath);
                    fieldObject = {
                        "aura:id": a.fieldPath,
                        "fieldName": a.fieldPath,
                        "class": className //"customRequired" 
                    }

                }

            }


            $A.createComponents([
                ["lightning:layoutItem", {
                    "flexibility": "auto",
                    "size": "12",
                    "smallDeviceSize": "5",
                    "mediumDeviceSize": "5",
                    "largeDeviceSize": "6",
                    "padding": "horizontal-small"
                }],
                ["lightning:inputField", fieldObject]
            ],
                function (components, status, errorMessage) {
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

    showToast: function (component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },

    

    onSubmitHelper: function (component, event, helper) {
        let mandatory = component.get("v.addressMandatoryFields");
        let address = component.get("v.addressFromEvent");
        let fieldsMissing = [];
        let check;

        if(  component.get('v.recordTypeName') != 'XC_GLO_Account_Residential' && 
            !component.get('v.recordTypeName').includes('SFM') &&
            component.get('v.recordTypeName') != 'XC_GLO_B2B' &&
            component.get('v.recordTypeName') != 'XC_GLO_B2G' &&
           	(component.get('v.sohoType') == null || component.get("v.sohoType") == '' || component.get('v.sohoType') == 'Soho') &&
            ((component.get("v.newSection.DocumentCountry") == '' || component.get("v.newSection.DocumentCountry") == null) ||
            (component.get("v.newSection.DocumentType") == '' || component.get("v.newSection.DocumentType") == null) ||
            (component.get("v.newSection.DocumentID") == '' || component.get("v.newSection.DocumentID") == null))
        )
        {
            let toastEventError = $A.get("e.force:showToast");
            toastEventError.setParams({
                title: $A.get("$Label.c.XC_CL_Warning"),
                message: $A.get("$Label.c.XC_CL_MissingContactDocument"),
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '15000'
            });
            toastEventError.fire();
            event.preventDefault(); 
            return;
        }

        if (address) {
            for (var j in mandatory) {
                check = false;
                for (var i in address) {
                    if (i == mandatory[j] && address[i]) {
                        check = true;
                    }
                }

                if (!check) {
                    fieldsMissing.push(mandatory[j]);
                }
            }
        }
        if (fieldsMissing.length > 0) {
            let toastEventError = $A.get("e.force:showToast");
            toastEventError.setParams({
                title: $A.get("$Label.c.XC_CL_Warning"),
                message: "Missing the following fields in address section: " + fieldsMissing,
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '15000'
            });
            toastEventError.fire();
            return;
        }


        let consWrap = component.get("v.saveConsentsWrapper");
        let confirmationByTheCustomer = component.get("v.confirmationByTheCustomer");

        /*
                if((consWrap==null && confirmationByTheCustomerVar==true) || (consWrap!=null && confirmationByTheCustomerVar==true && (consWrap[0].thirdPartyValue == undefined || consWrap[0].thirdPartyValue == null || consWrap[0].thirdPartyValue == $A.get("$Label.c.XC_CL_None")))){
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                                         title : $A.get("$Label.c.XC_CL_Error"),
                                         message: 'Give data to third party is a mandatory field',
                                         key: 'info_alt',
                                         type: 'error'
                                         });
                    toastEvent.fire();
        
                } */
        helper.removeRedBox(component, event);
        event.preventDefault();
        let fieldToControl = JSON.parse(JSON.stringify(event.getParam("fields")));
        console.log('@@@ fieldValue @@@ :', JSON.parse(JSON.stringify(fieldToControl)));

        component.set('v.fieldMap', JSON.stringify(event.getParam("fields")));
        let streetType = (JSON.parse(component.get('v.fieldMap')))["XC_StreetType__c"];
        let streetNumber = (JSON.parse(component.get('v.fieldMap')))["XC_StreetNumber__c"];
        let city = (JSON.parse(component.get('v.fieldMap')))["XC_City__c"];
        let province = (JSON.parse(component.get('v.fieldMap')))["XC_AddressProvince__c"];
        address = (JSON.parse(component.get('v.fieldMap')))["XC_Address__c"];
        let zipCode = (JSON.parse(component.get('v.fieldMap')))["XC_PostalCode__c"];
        let country = (JSON.parse(component.get('v.fieldMap')))["XC_AddressCountry__c"];
        let door = (JSON.parse(component.get('v.fieldMap')))["XC_Door__c"];
        let category = (JSON.parse(component.get('v.fieldMap')))["XC_Category__c"];
        let stair = (JSON.parse(component.get('v.fieldMap')))["XC_Stair__c"];
        let floor = (JSON.parse(component.get('v.fieldMap')))["XC_Floor__c"];

        let addressFields = component.get("v.addressFromEvent");
        let newSection = component.get('v.newSection');
        helper.fieldFilledControl(component, helper, fieldToControl, newSection);
        let canInsert = component.get('v.canInsert');

        check = true;
        console.log('controllo address' + streetType + 'category' + category);
        console.log('controllo addresssssssssssssssssss' + component.get("v.addressFromEvent"));

        //dpalamides manage confirmation by the customer

        if (!component.get('v.recordTypeName').includes('SFM') && !confirmationByTheCustomer && (fieldToControl.IdentityNumber__c == null || fieldToControl.IdentityNumber__c == undefined)
                && (fieldToControl.XC_SohoType__c != 'B2B' && fieldToControl.XC_SohoType__c != 'Public Administration')) {
            let toastEvent = $A.get("e.force:showToast");
            //let cmpTarget = component.find('confirmationByCutomerCheck');
            //$A.util.addClass(cmpTarget, 'slds-has-error ');

            toastEvent.setParams({
                title: $A.get("$Label.c.XC_CL_Warning"),
                message: "If no document is provided it is mandatory to confirm that consents were asked to the customer",
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '6000'
            });
            toastEvent.fire();
            component.set('v.spinnerControl', false);
            return;
        }
        if (!component.get('v.recordTypeName').includes('SFM') && component.find("XC_DocumentCountry__c").get("v.value")!='Spain' && !confirmationByTheCustomer) {

        //if (!confirmationByTheCustomer && (fieldToControl.XC_SohoType__c == 'B2B' || fieldToControl.XC_SohoType__c == 'Public Administration')) {
            let toastEvent = $A.get("e.force:showToast");
            //let cmpTarget = component.find('confirmationByCutomerCheck');
            //$A.util.addClass(cmpTarget, 'slds-has-error ');

            toastEvent.setParams({
                title: $A.get("$Label.c.XC_CL_Warning"),
                message: $A.get("$Label.c.XC_CL_MandatoryConsConfirmation"),
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '6000'
            });
            toastEvent.fire();
            component.set('v.spinnerControl', false);
            return;
        }
        if (component.get("v.saveConsentsWrapper") != null && component.get("v.saveConsentsWrapper") != undefined) {
            component.get("v.saveConsentsWrapper").forEach(function (element) {
                element.confirmationByTheCustomer = confirmationByTheCustomer;
            });
        }
        /******************************************/

        if (((component.get("v.showAddress") && component.get("v.addressFromEvent") === null) ||
            (component.get("v.showAddress") && component.get("v.addressFromEvent") !== null && !component.get("v.addressFromEvent").validate)) &&
            !component.get("v.withoutValidate") && !component.get('v.isSFMAccount')) {

            check = false;
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: $A.get("$Label.c.XC_CL_Warning"),
                message: $A.get("$Label.c.XC_CL_Address_MissingValidation"),
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '6000'
            });
            toastEvent.fire();
            component.set('v.spinnerControl', false);
        }

        let hasDuplicatedLE = helper.hasDuplicatedLegalEntity(component, event, helper);

        if (hasDuplicatedLE) {
            let toastEventDuplicatedLE = $A.get("e.force:showToast");
            toastEventDuplicatedLE.setParams({
                title: $A.get("$Label.c.XC_CL_Warning"),
                message: $A.get("$Label.c.XC_CL_LegalEntityDuplicated"),
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                duration: '6000'
            });
            toastEventDuplicatedLE.fire();
            component.set('v.spinnerControl', false);
        }

        if (canInsert && check && !hasDuplicatedLE) {
            this.compeleteSubmit(component, fieldToControl, helper, newSection, addressFields);
        }

    },

    compeleteSubmit: function (component, eventFields, helper, newSection, addressFields) {

        component.set('v.spinnerControl', true);
        let action = component.get("c.createRecord");
        let accId = null;

        if (component.get('v.accountRecord')) {
            accId = JSON.parse(JSON.stringify(component.get('v.accountRecord'))).Id;
        }

        console.log('@@@@@ addressFields = ' + JSON.stringify(addressFields));

        // Fix Salvatore Agrillo 24/04/2019
        let mapAccount = {
            'fieldMapStringAccount': JSON.stringify(eventFields),
            'assignRecord': component.get('v.assignLeadCheckBox'),
            'recordTypeId': component.get("v.recordTypeToReturn"),
            'existingAccountId': accId,
            'contactFields': JSON.stringify(newSection),
            'addressFields': JSON.stringify(addressFields),
            'isCommunity': component.get('v.isCommunity'),
            'releaseDate': component.get('v.releaseDate'),
            'robinsonCustomer': component.get('v.robinsonCustomer'),
            'thirdPartiesCheck': component.get("v.thirdPartiesCheck"),
            'thirdPartiesVersion': component.get("v.thirdPartiesVersion"),
            'consentsLE': JSON.stringify(component.get("v.consentsLE")),
            'brandString': component.get("v.brandString"),
            'withoutValidate': component.get('v.withoutValidate'),
            'consentsWrapper': JSON.stringify(component.get('v.saveConsentsWrapper')), //dpalamides
            'confirmationByTheCustomer': component.get('v.confirmationByTheCustomer') //dpalamides
        }
        console.log('@@@ mapAccount ---> ', mapAccount);
        let mapAccountString = JSON.stringify(mapAccount);

        action.setParams({
            'mapAccountString': mapAccountString
        });
        console.log('accountFields->' + eventFields);
        console.log('contactFields->' + JSON.stringify(newSection));
        action.setCallback(this, function (a) {
            let errorMessage;
            let accountCreated = $A.get("$Label.c.XC_CL_AccountCreated");
            if (component.get('v.recordId')) {
                errorMessage = $A.get("$Label.c.XC_CL_AccountUpdated");
            } else {
                errorMessage = accountCreated;
            }
            console.log('errorMessage->' + errorMessage);

            let result = a.getReturnValue();
            if (result && result.success) {
                console.log('ok');
                console.log("result", result);
                if (result.errorMessage.length != 0) {
                    errorMessage = result.errorMessage;
                }
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: errorMessage,
                    message: ' ',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                helper.closeCurrentTab(component, event, helper, result.recordId);

            } else {
                if (result && result.errorMessage && !result.existingAccId) {

                    errorMessage = result.errorMessage;
                    let toastEventResError = $A.get("e.force:showToast");
                    toastEventResError.setParams({
                        title: $A.get("$Label.c.XC_CL_Warning"),
                        message: errorMessage,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEventResError.fire();
                    this.showErrorOnField(component, result.fieldName);
                } else if (result && result.existingAccId) {
                    component.set('v.existingAccId', result.existingAccId);
                    component.set('v.errorMessage', result.errorMessage);
                    component.set('v.showAccountModal', true);
                }
            }
            component.set('v.spinnerControl', false);
        });

        $A.enqueueAction(action);

    },

    hasDuplicatedLegalEntity: function (component, event, helper) {
        let hasDuplicatedLE = false;
        let consentsLE = component.get("v.consentsLE");
        if (consentsLE.length > 0) {
            let unicLE = [];
            for (let le of consentsLE) {
                for (let unicItem of unicLE) {
                    if (le.XC_LegalEntity__c === unicItem.XC_LegalEntity__c &&
                        le.XC_LeCountry__c === unicItem.XC_LeCountry__c) {
                        hasDuplicatedLE = true;
                        break;
                    }
                };
                if (hasDuplicatedLE) {
                    break;
                } else {
                    unicLE.push(le);
                }
            };
        }

        return hasDuplicatedLE;
    },

    closeCurrentTab: function (component, event, helper, toRedirect) {

        component.set('v.tabLabel', 'Account');
        let targetPageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": toRedirect,
                "actionName": "view"
            },
            state: {
                "c__recordId": toRedirect,
                "c__closeSource": true
            }
        };
        component.set("v.targetPageReference", targetPageReference);
        helper.executeAptNavigation(component, event, helper);
    },

    openTab: function (component, event, recordId) {
        let workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: recordId,
            focus: true
        }).then(function (response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function (tabInfo) {
                console.log("The url for this tab is: " + tabInfo.url);
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    },

    showErrorOnField: function (component, fieldName) {
        let cmpTarget = component.find(fieldName);
        console.log('result.fieldName->' + fieldName);
        $A.util.addClass(cmpTarget, 'slds-has-error ');
    },

    removeRedBox: function (component, event) {

        let mapField = component.get('v.fieldLabelMap');
        for (let i in mapField) {
            let cmpTarget = component.find(i);
            $A.util.removeClass(cmpTarget, 'slds-has-error ');
        }

    },
    fieldFilledControl: function (component, helper, objectField, newSection) {
        let fieldLabel = JSON.parse(JSON.stringify(component.get('v.fieldLabelMap')));
        let fieldSet = component.get('v.requiredFields');
        console.log("Requred" + JSON.stringify(fieldSet));
        
        let jsonfieldSet = JSON.parse(JSON.stringify(fieldSet));
        console.log("Requred" + jsonfieldSet);
        let canInsertControl = true;
        let checkIDorPhone = helper.checkIdentityOrEmailPhone(component, helper, component.get('v.fieldMap'));

        let identityOrEmailPhone = '';
        let checkMail = helper.checkValidityEmail(component, helper, component.get('v.fieldMap'));
        let checkId = true;
        let checkOnlyLetters = true;
        let checkName = true;
        let checkMailOrId = false;
        let checkSecondMail = true;
        let contactPhone = true;
        let contactSecondPhoneConsents = true;
        let contactMobilePhone = true;
        let checkContactEmailOrPhone = false;
        let onlylettersForCondominium = true;
        let messageForCondominiumName = '';

        if (component.get('v.isPartner') || component.get('v.isSmallBusiness') || component.get('v.isCondominium')) {
            //checkMailOrId = helper.checkContactEmailOrDocumentID(component, event, newSection);
            checkId = true;//helper.checkValidDocumentID(component, event, newSection);
            checkSecondMail = helper.checkValidityContactEmail(component, event, newSection);
            checkContactEmailOrPhone = helper.checkContactEmailOrIdentityAndPhone(component, event, newSection);
            contactPhone = helper.checkValidityPhoneForContact(component, helper, newSection);
            contactSecondPhoneConsents = helper.checkContactSecondaryPhoneConsents(component, helper, newSection);
            contactMobilePhone = helper.checkValidityMobilePhoneForContact(component, helper, newSection);
        }

        let messageForContactPhone = '';
        let messageForContactMobilePhone = '';
        let validEmail = '';
        let secondPhoneConsents = helper.checkSecondaryPhoneConsents(component, helper, component.get('v.fieldMap'));
        let checkMobilePhone = helper.checkValidityMobilePhone(component, helper, component.get('v.fieldMap'));
        let validContactMailOrId = '';
        let validMobilePhone = '';
        let validID = '';
        let checkPhone = helper.checkValidityPhone(component, helper, component.get('v.fieldMap'));
        let validPhone = '';

        let validletters = '';
        let leFilled = this.checkLegalEntity(component, event);
        let leErrorMsg = '';



        if (!checkName && !component.get('v.isSFMAccount')) {
            validletters = $A.get("$Label.c.XC_CL_ErrorNameOnlyLetters");
            canInsertControl = false;
        }
        if (!contactPhone && !component.get('v.isSFMAccount')) {
            messageForContactPhone = $A.get("$Label.c.XC_CL_Contact_ErrorOnPhone");
            canInsertControl = false;
        }
        if (!contactSecondPhoneConsents && !component.get('v.isSFMAccount')) {
            canInsertControl = false;
        }
        if (!onlylettersForCondominium && !component.get('v.isSFMAccount')) {
            messageForCondominiumName = $A.get("$Label.c.XC_CL_Account_CondominiumOnlyLetters");
            canInsertControl = false;
        }
        if (!contactMobilePhone && !component.get('v.isSFMAccount')) {
            messageForContactMobilePhone = $A.get("$Label.c.XC_CL_Contact_ErrorOnMobilePhone");
            canInsertControl = false;
        }
        /*if (checkMailOrId) {
            validContactMailOrId = $A.get("$Label.c.XC_CL_Contact_ErrorMailOrId");
            canInsertControl = false;
        }*/
        if (!checkOnlyLetters && !component.get('v.isSFMAccount')) {
            validletters = $A.get("$Label.c.XC_CL_Contact_ErrorNameOnlyLetters");
            canInsertControl = false;
        }


        if (!checkPhone && !component.get('v.isSFMAccount')) {
            validPhone = $A.get("$Label.c.XC_CL_Account_PhoneFormat");
            canInsertControl = false;
        }
        if (!checkId && !component.get('v.isSFMAccount')) {
            validID = $A.get("$Label.c.XC_CL_Contact_InvalidDocumentIdFormat");
            canInsertControl = false;
        }

        if (checkIDorPhone && !component.get('v.isSFMAccount')) {
            identityOrEmailPhone = $A.get("$Label.c.XC_CL_Account_InsertPhoneMail");
            canInsertControl = false;
        }
        if (checkContactEmailOrPhone && !component.get('v.isSFMAccount')) {
            identityOrEmailPhone = $A.get("$Label.c.XC_CL_Contact_InsertPhoneMail");
            canInsertControl = false;
        }


        if ((!checkMail || !checkSecondMail) && !component.get('v.isSFMAccount')) {
            validEmail = $A.get("$Label.c.XC_CL_Account_ValidMail");
            canInsertControl = false;
        }
        if (!secondPhoneConsents && !component.get('v.isSFMAccount')) {
            canInsertControl = false;
        }
        if (!checkMobilePhone && !component.get('v.isSFMAccount')) {
            validMobilePhone = $A.get("$Label.c.XC_CL_Account_ValidMobilePhone");
            canInsertControl = false;
        }
        if (!leFilled && !component.get('v.isSFMAccount')) {
            leErrorMsg = $A.get("$Label.c.XC_CL_ConsentsToFill");
            canInsertControl = false;
        }
        let errorMessageTotal = [];
        for (let i = 0; i < fieldSet.length; i++) {
            if (!objectField[fieldSet[i]]  && !component.get('v.isSFMAccount')) {
                errorMessageTotal.push(fieldLabel[jsonfieldSet[i]]);
                canInsertControl = false;
                helper.showErrorOnField(component, fieldSet[i]);
                component.set('v.canInsert', false);
            }
        }
        if (canInsertControl) {
            component.set('v.canInsert', true);
        } else {

            let errorMessageFinal = errorMessageTotal.join(', ');
            if (errorMessageTotal.length > 1) {
                errorMessageFinal = errorMessageFinal + ' ' + $A.get("$Label.c.XC_CL_MandatoryPlural");
            }
            if (errorMessageTotal.length == 1) {
                errorMessageFinal = errorMessageFinal + ' ' + $A.get("$Label.c.XC_CL_Mandatory");
            }

            component.set("v.showToastMessage", true);
            component.set("v.type", "error");

            let errorMessageList = null;
            let errMessListDelt1 = [identityOrEmailPhone, validMobilePhone, validPhone, validEmail, messageForCondominiumName, messageForContactPhone];
            let errMessListDelt2 = [messageForContactMobilePhone, validID, errorMessageFinal, validletters, validContactMailOrId, leErrorMsg];
            errorMessageList = errMessListDelt1.concat(errMessListDelt2);

            console.log('First Error List: ' + errorMessageList);
            let errorMessageListFinal = [];
            for (let j = 0; j < errorMessageList.length; j++) {
                if (errorMessageList[j] !== null && errorMessageList[j] != "") {
                    errorMessageListFinal.push(errorMessageList[j]);
                }
            }

            let lengthFinalErr = errorMessageListFinal.length;

            if (lengthFinalErr > 0) {
                component.set('v.canInsert', false);
            }
            console.log('Error List: ' + errorMessageListFinal);
            if (lengthFinalErr > 1) {
                if (errorMessageListFinal[lengthFinalErr - 1] == errorMessageFinal &&
                    !errorMessageListFinal[lengthFinalErr - 1].includes($A.get("$Label.c.XC_CL_GiveDataToEndesa") + ' ' + $A.get("$Label.c.XC_CL_Mandatory"))) {
                    errorMessageListFinal[lengthFinalErr - 1] = $A.get("$Label.c.XC_CL_Lead_Also") + ' ' + errorMessageListFinal[lengthFinalErr - 1];
                } else if (errorMessageListFinal[lengthFinalErr - 1].includes($A.get("$Label.c.XC_CL_GiveDataToEndesa") + ' ' + $A.get("$Label.c.XC_CL_Mandatory"))) {
                    errorMessageListFinal[lengthFinalErr - 1] = $A.get("$Label.c.XC_CL_Lead_Also") + ' ' + $A.get("$Label.c.XC_CL_GiveDataToEndesaIsMandatory");
                } else {
                    errorMessageListFinal[lengthFinalErr - 1] = $A.get("$Label.c.XC_CL_Lead_Also") + ' ';
                    errorMessageListFinal[lengthFinalErr - 1] = errorMessageListFinal[lengthFinalErr - 1] + errorMessageListFinal[lengthFinalErr - 1].charAt(0).toLowerCase();
                    errorMessageListFinal[lengthFinalErr - 1] = errorMessageListFinal[lengthFinalErr - 1] + errorMessageListFinal[lengthFinalErr - 1].slice(1);
                }
            }
            let errorMessage = errorMessageListFinal.join('. ');

            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: $A.get("$Label.c.XC_CL_Warning"),
                message: errorMessage,
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }

    },

    validationField: function (component, helper, newSection, errorMessageFinal) {

        let checkIDorPhone = helper.checkIdentityOrEmailPhone(component, helper, component.get('v.fieldMap'));
        let identityOrEmailPhone = '';
        let checkMail = helper.checkValidityEmail(component, helper, component.get('v.fieldMap'));
        let checkId = true;
        let checkOnlyLetters = true;
        let checkName = true;
        let checkMailOrId = false;
        let checkSecondMail = true;
        let contactPhone = true;
        let contactSecondPhoneConsents = true;
        let contactMobilePhone = true;
        let checkContactEmailOrPhone = false;
        let onlylettersForCondominium = true;
        let messageForCondominiumName = '';

        if (component.get('v.isPartner') || component.get('v.isSmallBusiness') || component.get('v.isCondominium')) {
            checkMailOrId = helper.checkContactEmailOrDocumentID(component, event, newSection);
            checkId = true;//helper.checkValidDocumentID(component, event, newSection);
            checkSecondMail = helper.checkValidityContactEmail(component, event, newSection);
            checkContactEmailOrPhone = helper.checkContactEmailOrIdentityAndPhone(component, event, newSection);
            contactPhone = helper.checkValidityPhoneForContact(component, helper, newSection);
            contactSecondPhoneConsents = helper.checkContactSecondaryPhoneConsents(component, helper, newSection);
            contactMobilePhone = helper.checkValidityMobilePhoneForContact(component, helper, newSection);
        }

        let messageForContactPhone = '';
        let messageForContactMobilePhone = '';
        let messageSecondPhone = '';
        let validEmail = '';
        let secondPhoneConsents = helper.checkSecondaryPhoneConsents(component, helper, component.get('v.fieldMap'));
        let checkMobilePhone = helper.checkValidityMobilePhone(component, helper, component.get('v.fieldMap'));
        let validContactMailOrId = '';
        let validMobilePhone = '';
        let validID = '';
        let checkPhone = helper.checkValidityPhone(component, helper, component.get('v.fieldMap'));
        let validPhone = '';

        let validletters = '';
        let leFilled = this.checkLegalEntity(component, event);
        let leErrorMsg = '';

        validletters = helper.checkFlagValidatecheckName(checkName).msg;
        messageForContactPhone = helper.checkFlagValidatecheckPhone(contactPhone).msg;
        messageSecondPhone = helper.checkFlagValidatecheckPhone(contactSecondPhoneConsents).msg;
        messageForCondominiumName = helper.checkFlagValidateCondominum(onlylettersForCondominium).msg;
        messageForContactMobilePhone = helper.checkFlagValidateContactMobile(contactMobilePhone).msg;
        validContactMailOrId = helper.checkFlagValidateContactEmail(checkMailOrId).msg;
        validletters = helper.checkFlagValidatecheckName(checkOnlyLetters).msg;
        validPhone = helper.checkFlagValidatePhone(checkPhone).msg;
        validID = helper.checkFlagValidateId(checkId).msg;
        identityOrEmailPhone = helper.checkFlagIdentityIdOrPhone(checkIDorPhone).msg;
        identityOrEmailPhone = helper.checkFlagIdentityIdOrPhone(checkContactEmailOrPhone).msg;
        validEmail = helper.checkFlagValidateEmail(checkMail).msg;
        validEmail = helper.checkFlagValidateEmail(checkSecondMail).msg;
        validMobilePhone = helper.checkFlagValidateMobilePhone(checkMobilePhone).msg;
        leErrorMsg = helper.checkFlagValidateLe(leFilled).msg;

        if (!secondPhoneConsents) {
            canInsertControl = false;
        }

        let errorMessageList = null;
        let errMessListDelt1 = [identityOrEmailPhone, validMobilePhone, validPhone, validEmail, messageForCondominiumName, messageForContactPhone];
        let errMessListDelt2 = [messageForContactMobilePhone, validID, errorMessageFinal, validletters, validContactMailOrId, leErrorMsg];
        errorMessageList = errMessListDelt1.concat(errMessListDelt2);


        console.log('First Error List: ' + errorMessageList);
        let errorMessageListFinal = [];
        for (let j = 0; j < errorMessageList.length; j++) {
            if (errorMessageList[j] !== null && errorMessageList[j] != "") {
                errorMessageListFinal.push(errorMessageList[j]);
            }
        }

        return errorMessageListFinal;
    },

    checkFlagValidatecheckName: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_ErrorNameOnlyLetters")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },

    checkFlagValidatecheckPhone: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Contact_ErrorOnPhone")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },


    checkFlagValidateCondominum: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Account_CondominiumOnlyLetters")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },


    checkFlagValidateContactMobile: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Contact_ErrorOnMobilePhone")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },

    checkFlagValidateContactEmail: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Contact_ErrorMailOrId")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },

    checkFlagValidatePhone: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Account_PhoneFormat")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },

    checkFlagValidateId: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Contact_InvalidDocumentIdFormat")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },

    checkFlagIdentityIdOrPhone: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Account_InsertPhoneMail")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },

    checkFlagValidateEmail: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Account_ValidMail")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },

    checkFlagValidateMobilePhone: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_Account_ValidMobilePhone")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },
    checkFlagValidateLe: function (flag) {
        return !flag ? {
            "canInsertControl": false,
            "msg": $A.get("$Label.c.XC_CL_ConsentsToFill")
        } : {
                "canInsertControl": true,
                msg: ""
            };
    },

    checkLegalEntity: function (component, event) {
        let consentsLE = component.get("v.consentsLE");
        if (consentsLE.length === 0) {
            return true; //dpalamides
        }
        return true;
    },

    checkIdentityOrEmailPhone: function (component, event, mapField) {

        let identity = (JSON.parse(mapField))["IdentityNumber__c"];
        let email = (JSON.parse(mapField))["PrimaryEmail__c"];
        let phone = (JSON.parse(mapField))["XC_AccountPhone__c"];
        let mobilePhone = (JSON.parse(mapField))["XC_AccountMainPhone__c"];
        let phonePrefix = (JSON.parse(mapField))["XC_AccountPhonePrefix__c"];
        let mobilePhonePrefix = (JSON.parse(mapField))["XC_MainPhonePrefix__c"];
        let company = (JSON.parse(mapField))["Company"];
        let conmdominuim = (JSON.parse(mapField))["XC_CondominiumName__c"];

        let recType = component.get("v.recordTypeName");
        console.log("recType" + recType);

        if (recType != 'XC_GLO_Account_Soho' && recType != 'XC_GLO_Account_Condominium' && identity && (!email && (!phone && !phonePrefix) && (!mobilePhone && !mobilePhonePrefix))) {
            return true;
        }

        return false;

    },


    checkContactEmailOrIdentityAndPhone: function (component, event, newSection) {
        let email = newSection.Email;
        let contactDocumentId = newSection.DocumentID;

        if (email) {
            return false;
        } else if (!contactDocumentId || !newSection.PhonePrefix || !newSection.ContactPhone) {
            return true;
        }

        return false;


    },

    checkContactEmailOrDocumentID: function (component, event, newSection) {
        let email = newSection.Email;
        let contactDocumentId = newSection.DocumentID;

        if (email) {
            return false;
        } else if (!contactDocumentId || !newSection.PhonePrefix || !newSection.ContactPhone) {
            return true;
        }

        return false;

    },

    checkValidDocumentID: function (component, event, newSection) {
        let documentType = newSection.DocumentType;
        let documentID = newSection.DocumentID;
        let regExpEmailformat;

        if (documentType == "NIE") {
            regExpEmailformat = /^[XYZ]{1}[0-9]{7}[TRWAGMYFPDXBNJZSQVHLCKETtrwagmyfpdxbnjzsqvhlcket]{1}$/i;
        }
        if (documentType == "NIF") {
            regExpEmailformat = /^[0-9]{8}[TRWAGMYFPDXBNJZSQVHLCKETtrwagmyfpdxbnjzsqvhlcket]{1}$/i;
        }

        if (documentType == "Passport") {
            return true;
        }
        if (documentID.match(regExpEmailformat)) {
            return true;
        } else {

            return false;
        }

    },

    redirectToExistingAccHelper: function (component, event, helper) {

        let accId = component.get('v.existingAccId');
        this.openTab(component, event, accId);
        this.closeCurrentTab(component, event, helper);
    },
    gotoList: function (component, event) {
        let action = component.get("c.getListViews");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let listviews = response.getReturnValue();
                let navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": 'Recently Viewed Accounts',
                    "scope": "Account"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    goBack: function (component, event) {
        let isMobile = component.get("v.isMobile");
        if (isMobile || component.get("v.isCommunity")) {
            this.gotoList(component, event);
        } else {
            let workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                let focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
        }
    },

    checkValidityEmail: function (component, helper, mapField) {
        let emailFieldValue = (JSON.parse(mapField))["PrimaryEmail__c"];
        let isValidEmail;
        let regExpEmailformat = new RegExp('^(([^<>()\\[\\]\\\\.,;:\\s@"]+(\\.[^<>()\\[\\]\\\\.,;:\\s@"]+)*)' +
            '|(".+"))@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}])' +
            '|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$');
        if ($A.util.isEmpty(emailFieldValue)) {
            isValidEmail = true;
        } else {
            if (emailFieldValue.match(regExpEmailformat)) {
                /*let suffix = emailFieldValue.substr(emailFieldValue.length - 3, emailFieldValue.length - 1);
                if(suffix != ".es" && suffix != ".it" && suffix != "com")
                    isValidEmail = false
                    else*/
                isValidEmail = true;
            } else {
                isValidEmail = false;
            }
        }
        return isValidEmail;

    },
    checkValidityContactEmail: function (component, event, newSection) {
        let emailFieldValue = newSection.Email;
        let isValidEmail;
        let regExpEmailformat = new RegExp('^(([^<>()\\[\\]\\\\.,;:\\s@"]+(\\.[^<>()\\[\\]\\\\.,;:\\s@"]+)*)' +
            '|(".+"))@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}])' +
            '|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$');
        if ($A.util.isEmpty(emailFieldValue)) {
            isValidEmail = true;
        } else {
            if (emailFieldValue.match(regExpEmailformat)) {
                // let suffix = emailFieldValue.substr(emailFieldValue.length - 3, emailFieldValue.length - 1);
                /*if(suffix != ".es" && suffix != ".it" && suffix != "com")
                    isValidEmail = false
                    else*/
                isValidEmail = true;
            } else {
                isValidEmail = false;
            }
        }
        return isValidEmail;
    },

    checkUniqueValidityPhone: function (component, helper, phoneFieldValue, prefixValue) {

        let isValidMobilePhone;
        let regExpPhoneFormat = /^[6|7|8|9][\s|\-|\.]?([0-9][\s|\-|\.]?){8}$/;
        if ($A.util.isEmpty(phoneFieldValue)) {
            isValidMobilePhone = true;
        } else {
            if (phoneFieldValue.match(regExpPhoneFormat) || (prefixValue != '+34' && prefixValue != '0034' && prefixValue != '34')) {
                isValidMobilePhone = true;
            } else {
                isValidMobilePhone = false;
            }
        }
        return isValidMobilePhone;

    },

    checkValidityPhone: function (component, helper, mapField) {
        let mobilePhoneFieldValue = (JSON.parse(mapField))["Phone"];
        let isValidMobilePhone;
        let regExpMobilePhoneFormat = /^(\+34|0034|34)?[\s|\-|\.]?[6|7|8|9][\s|\-|\.]?([0-9][\s|\-|\.]?){8}$/; //OLD> [9] anzichè 6|7|8|9
        if(component.get('v.isGlobalB2B') || component.get('v.isGlobalB2G')){
            return true;
        }
        if ($A.util.isEmpty(mobilePhoneFieldValue)) {
            isValidMobilePhone = true;
        } else {
            if (mobilePhoneFieldValue.match(regExpMobilePhoneFormat)) {
                isValidMobilePhone = true;
            } else {
                isValidMobilePhone = false;
            }
        }
        return isValidMobilePhone;

    },

    checkValidityMobilePhone: function (component, helper, mapField) {
        let mobilePhoneFieldValue = (JSON.parse(mapField))["MainPhone__c"];
        let isValidMobilePhone;
        let regExpMobilePhoneFormat = /^(\+34|0034|34)?[\s|\-|\.]?[6|7|8|9][\s|\-|\.]?([0-9][\s|\-|\.]?){8}$/;
        if(component.get('v.isGlobalB2B') || component.get('v.isGlobalB2G')){
            return true;
        }
        if ($A.util.isEmpty(mobilePhoneFieldValue)) {
            isValidMobilePhone = true;
        } else {
            if (mobilePhoneFieldValue.match(regExpMobilePhoneFormat)) {
                isValidMobilePhone = true;
            } else {
                isValidMobilePhone = false;
            }
        }
        return isValidMobilePhone;

    },

    checkSecondaryPhoneConsents: function (component, helper, mapField) {
        let secondPhoneFieldValue = (JSON.parse(mapField))["MainPhone__c"];
        if (secondPhoneFieldValue === '') {
            return true;
        }
        let phoneFieldValue = (JSON.parse(mapField))["Phone"];
        return helper.secondaryPhoneConsentsControl(component, helper, phoneFieldValue, secondPhoneFieldValue);
    },

    checkContactSecondaryPhoneConsents: function (component, helper, newSection) {
        let seconPrefixValue = newSection.MobilePrefix;
        let seconPhoneFieldValue = newSection.ContactMobile;
        if (seconPrefixValue === '' && seconPhoneFieldValue === '') {
            return true;
        }
        let phoneFieldValue = newSection.ContactPhone;
        let prefixValue = newSection.PhonePrefix;
        return helper.secondaryPhoneConsentsControl(component, helper, prefixValue + phoneFieldValue, seconPrefixValue + seconPhoneFieldValue);
    },

    secondaryPhoneConsentsControl: function (component, helper, phoneValue, seconPhoneValue) {
        let checkOk = true;
        if (phoneValue === '' && seconPhoneValue !== '') {
            checkOk = false;
        }
        return checkOk;
    },

    checkValidityPhoneForContact: function (component, helper, newSection) {
        let phoneFieldValue = newSection.ContactPhone;
        let prefixValue = newSection.PhonePrefix;
        let checkResult = helper.checkUniqueValidityPhone(component, helper, phoneFieldValue, prefixValue);
        return checkResult;

    },

    checkValidityMobilePhoneForContact: function (component, helper, newSection) {
        let mobilePhoneFieldValue = newSection.ContactMobile;
        let prefixValue = newSection.MobilePrefix;
        let checkResult = helper.checkUniqueValidityPhone(component, helper, mobilePhoneFieldValue, prefixValue);
        return checkResult;

    },

    handleSohoType: function (component, event, helper) {

        let sohoType = event.getSource().get("v.value");
        component.set("v.sohoType", sohoType);
        let tradingPartnersField = component.find("XC_TradingPartner__c");
        if (sohoType == "Associated Companies") {
            tradingPartnersField.set("v.disabled", false);
            tradingPartnersField.set("v.required", true);

        } else {
            tradingPartnersField.set("v.disabled", true);
            tradingPartnersField.set("v.required", false);

        }
    },

    //[ BEGIN, arjun.raoh@accenture.com, 24/11/2021, Enel X - NR2041 - Energy Communities, FT3-2021 ]
    evaluateShowSectionEnergyCommunity: function (component) {
        //14-12-2021 ALC Deloitte This section also applies to Spain
        if ((component.get('v.userCountry') === 'Italy' || component.get('v.userCountry') === 'Spain') && component.get('v.recordTypeName') === 'XC_GLO_B2B') {
            component.set('v.isEnergyCommunity', true);
        }
    },

    evaluateShowSectionEnergyCommunityMember: function (component) {
        var recordTypeNames = ['XC_GLO_Account_Residential', 'XC_GLO_Account_Condominium', 'XC_GLO_B2G', 'XC_GLO_B2C', 'XC_GLO_B2B'];
        //14-12-2021 ALC Deloitte This section also applies to Spain
        var recordTypeNamesSpain = ['XC_GLO_B2G', 'XC_GLO_B2B'];
        if ((component.get('v.userCountry') === 'Italy'  && recordTypeNames.includes(component.get('v.recordTypeName'))) || (component.get('v.userCountry') === 'Spain' && recordTypeNamesSpain.includes(component.get('v.recordTypeName')))) {
            component.set('v.isEnergyCommunityMember', true);
        }
    },
     //[ END, arjun.raoh@accenture.com, 24/11/2021, Enel X - NR2041 - Energy Communities, FT3-2021 ]
})