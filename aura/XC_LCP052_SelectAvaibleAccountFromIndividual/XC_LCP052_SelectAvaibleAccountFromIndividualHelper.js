({
    doInit: function (component, event, helper) {

        if(component.get("v.sourceObjType") && component.get("v.sourceObjType") === 'Account'){
            //Start CR758
            console.log("@@@ INIT : "+component.get("v.sourceObjType"));
            helper.showedSedeLegaleCheck(component, event, helper);
            //End CR758
            if (component.get("v.forOpportunity")) {
                helper.setRelatedContact(component, event, helper);
                return;
            }
        }

        let action = component.get("c.getType");

        action.setParams({
            'recordId': component.get("v.recordId"),
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            var res = response.getReturnValue();

            if (state === "SUCCESS") {
                console.log('@@@ res -> ', res);

                if (!res.documentExists && !component.get("v.isSFMObject")) {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: $A.get("$Label.c.XC_CL_NoDocForAccountMess"),
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {

                    if (res.typeObject === 'Opportunity') {

                        component.set("v.forOpportunity", true)
                        component.set("v.forAsset", false);
                        component.set("v.manageAddress", true);
                        component.set("v.titleOpp", "Manage Address");
                        
                        helper.checkWoAndConf(component, event, helper);
                        helper.checkLegalEntity(component, event, helper);

                    } else if (res.typeObject === 'Contact') {

                        let myPageRef = component.get("v.pageReference");
                        if (myPageRef) {
                            component.set("v.recordId", myPageRef.state.c__recordId);
                            component.set("v.recordTypeId", myPageRef.state.c__recordTypeId);
                            component.set("v.stageName", myPageRef.state.c__stageName);
                            component.set("v.closeDate", myPageRef.state.c__closeDate);
                        }

                        if (component.get("v.forOpportunity")) {
                            helper.checkLegalEntity(component, event, helper);
                            component.set("v.forAsset", false);
                            helper.setAccount(component, event, helper);
                            
                            let actionResidentialAddress = component.get("c.showResidentialAddress");

                            actionResidentialAddress.setParams({
                                'recordTypeId': component.get("v.recordTypeId"),
                            });
                            actionResidentialAddress.setCallback(this, function (response) {
                                let state = response.getState();
                                var res = response.getReturnValue();
                    
                                if (state === "SUCCESS") {
                                    if(res){
                                        component.set("v.showAddressResidential", true);
                                    }else {
                                        component.set("v.showAddressResidential", false);
                                    }
                                }
                            });
                            $A.enqueueAction(actionResidentialAddress);
                        } else {
                            component.set("v.forAsset", true);
                            helper.selectAvaibleAccount(component, event, helper);
                            helper.getProductTypeOptions(component, event, helper);
                            helper.getProductSubTypeDependency(component, event, helper);

                        }
                    }

                }
            }

        });

        $A.enqueueAction(action);
    },

    selectAvaibleAccount: function (component, event, helper) {
        component.set("v.title", $A.get("$Label.c.XC_CL_Contact_AssetSettings"));

        let action = component.get("c.selectAvaibleAccount");

        action.setParams({
            'recordId': component.get("v.recordId"),
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();

            if (state === "SUCCESS" && retValue) {
                console.log('mappa= ' + retValue);
                console.log('mappa=' + JSON.stringify(retValue));
                let opts = [];

                retValue.forEach(function (entry) {
                    opts.push({
                        value: entry['key'],
                        label: entry['value']
                    });
                })

                component.set('v.categoryOptions', opts);
            }
        });
        $A.enqueueAction(action);
    },

    setAccount: function (component, event, helper) {
        let action = component.get("c.selectAvaibleAccount");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();

            if (state === "SUCCESS" && retValue) {
                console.log('mappa= ' + retValue);
                console.log('mappa=' + JSON.stringify(retValue));
                let opts = [];

                retValue.forEach(function (entry) {
                    opts.push({
                        value: entry['key'],
                        label: entry['value']
                    });
                })

                component.set('v.categoryOptions', opts);
                component.set("v.categoryValue", opts[0].value);
                component.set("v.accountid", opts[0].value);
                component.set("v.disabledSubmit", false);

                helper.setAddress(component, event, helper);

            }
        });
        $A.enqueueAction(action);

    },

    setRelatedContact: function (component, event, helper) {
        let action = component.get("c.selectAvaibleContact");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let result = response.getReturnValue();
            let objInfo = [];
            let contactData = [];
            let addressData = [];
            if (state === "SUCCESS" && result) {
                objInfo = JSON.parse(result.objectInfo);
                //Account List (1 value readonly)
                contactData = objInfo['contactData'];
                let optsAcc = [];
                optsAcc.push({
                    value: component.get("v.recordId"),
                    label: objInfo['accountName']
                });
                component.set('v.categoryOptions', optsAcc);
                component.set("v.categoryValue", optsAcc[0].value);
                component.set("v.accountid", optsAcc[0].value);

                //Contact List
                contactData = objInfo['contactData'];
                let optsContact = [];
                contactData.forEach(function (entry) {
                    optsContact.push({
                        value: entry['key'],
                        label: entry['value']
                    });
                });
                component.set('v.contactOptions', optsContact);

                //Address List
                addressData = objInfo['addressData'];
                let optsAddress = [];
                addressData.forEach(function (entry) {
                    optsAddress.push({
                        value: entry['key'],
                        label: entry['value']
                    });
                });
                component.set('v.addressOptions', optsAddress);

                if(component.get("v.addressCreated") && optsAddress.length>0){
                        component.find('ChooseAddress').set("v.value", optsAddress[0].value);                    
                }
            }
            
            component.set('v.showContactOpt', true);
        });
        $A.enqueueAction(action);
    },

    checkWoAndConf: function (component, event, helper) {
        let action = component.get("c.checkChangeAddress");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue) {
                if (!retValue.success) {
                    helper.showToast(component, retValue.resultMessage, 'error');


                } else {
                    helper.manageAddress(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },


    checkLegalEntity: function (component, event, helper) {
        let action = component.get("c.checkAvaibleLE");
        action.setParams({
            'recordTypeId': component.get("v.recordTypeId"),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue) {
                try {
                    component.set('v.listOfLegalEntities', retValue.listOfAvaibleLE);
                    component.set('v.legalEntityValue',retValue.defaultLE);
                    component.set('v.showLE',retValue.showSelectLE);
                } catch(e) {
                    console.log('@@@ Errore: ', e);
                }
            }
        });
        $A.enqueueAction(action);
    },

    manageAddress: function (component, event, helper) {
        let action = component.get("c.getAccountFromOpportunity");      
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue) {
                component.set("v.categoryValue", retValue.accountId);
                component.set("v.accountid", retValue.accountId);
                component.set("v.disabledSubmit", false);

                helper.setAddress(component, event, helper);

                component.find('ChooseAddress').set("v.value", retValue.addressId);
            }
        });
        $A.enqueueAction(action);
    },

    setAddress: function (component, event, helper) {

        //Start CR758
        let action;
        console.log("@@@@@@ setAddress");
		if(component.get("v.searchForSedeLegale")){
            action = component.get("c.getAddressesForOppCat");
            
            console.log("@@@@@@ if setAddress");
            action.setParams({
            'recordId': component.get("v.categoryValue"),
            'category': component.get("v.searchForSedeLegale")
        	});
        }else{
            action = component.get("c.getAddressesForOpp");
            
            console.log("@@@@@@ else setAddress");
            action.setParams({
                'recordId': component.get("v.categoryValue")
            });
        }
        //End CR758

        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            
            if (state === "SUCCESS" && retValue) {
                let opts = [];
                retValue.forEach(function (entry) {
                    opts.push({
                        value: entry['key'],
                        label: entry['value']
                    });
                })

                component.set('v.addressOptions', opts);
                
                if(component.get("v.addressCreated") && opts.length>0){
                    if(component.get("v.isResidentialAddress")){
                        component.set("v.addressValueResidential", opts[0].value);
                        component.set("v.isResidentialAddress", false);
                    }else{
                        component.find('ChooseAddress').set("v.value", opts[0].value);
                    }
                }

            }
        });
        $A.enqueueAction(action);
    },

    change: function (component, event, helper) {
        let catalog = component.get("v.catalogValue");
        let catalogCategory = component.get("v.catalogCategoryValue");
        if (!component.get("v.forAsset") && component.get("v.categoryValue") !== null) {// && catalogCategory!=null && catalogCategory!=""){
            component.set("v.disabledSubmit", false);
        } else if (component.get("v.forAsset") && component.get("v.categoryValue") !== null) {
            if (catalog != undefined && catalog != "") {
                component.set("v.disabledCatalogueCategory", false);
                if (catalogCategory != undefined && catalogCategory != "") {
                    component.set("v.disabledSubmit", false);
                } else {
                    component.set("v.catalogFilter", "NE__CatalogId__c='" + catalog + "'");
                    component.set("v.disabledSubmit", true);
                }
            } else {
                component.set("v.catalogCategoryValue", "");
                component.set("v.disabledCatalogueCategory", true);
                component.set("v.disabledSubmit", true);
            }
        } else {
            if (catalog == "") {
                component.set("v.catalogCategoryValue", "");
                component.set("v.disabledCatalogueCategory", true);
            }
            component.set("v.disabledSubmit", true);
        }
    },

    changeOpportunityData: function (component, event, helper) {
        if(component.get("v.forOpportunity") && !component.get("v.forAsset")){
            if(component.get("v.productCategory") === '' || !component.get("v.addressValue") ||
               (component.get("v.showContactOpt") && !component.get("v.contactValue"))){
                component.set("v.disableOpportunity", true);
            }
            else{
                component.set("v.disableOpportunity", false);
            }
        }
    },

    selectAvaibleAddress: function (component, event, helper) {
        let action = component.get("c.getListAddress");        
        action.setParams({
            'recordId': component.get("v.categoryValue"),
            'applyIstallCondition': false
        });
        action.setCallback(this, function (response) {
            let state = response.getState();


            let retValue = response.getReturnValue();

            if (state === "SUCCESS" && retValue) {
                console.log('address = ' + retValue);

                let opts = [];
                for (var i = 0; i < retValue.length; i++) {
                    opts.push({

                        value: retValue[i].Id,
                        label: retValue[i].XC_FullAddress__c
                    });
                }

                component.set('v.addressOptions', opts);

            }
        });
        $A.enqueueAction(action);

    },

    createOpp: function (component, event, helper) {
        let recordType = component.get("v.recordTypeId");
        console.log('recordType' + recordType);
        console.log('contactId' + component.get("v.recordId"));
        console.log('accountId' + component.get("v.categoryValue"));
        console.log('workOrderId' + component.get("v.workOrderId"));
        console.log('caseId' + component.get("v.caseId"));
        console.log('closeDate' + component.get("v.closeDate"));
        console.log('serviceId' + component.get("v.serviceId"));//cr 763
        let contactId = component.get("v.recordId");
        if(component.get("v.sourceObjType") === 'Account'){
            contactId = component.get("v.contactValue");
        }
        $A.createComponent(
            "c:XC_LCP053_RedirectOpportunity",
            {
                "recordTypeId": recordType,
                "fromContact": true,
                "contactId": contactId,
                "accountId": component.get("v.categoryValue"),
                "workOrderId": component.get("v.workOrderId"),
                "caseId": component.get("v.caseId"),
                "addressId": component.get('v.addressValue'),
                "addressIdResidential": component.get('v.addressValueResidential'),
                "productCategory": component.get('v.productCategory'),
                "stageName": "Draft",
                "closeDate": component.get("v.closeDate"),
                "legalEntityValue": component.get("v.legalEntityValue"),
                "serviceId":component.get("v.serviceId") //CR763
            },
            function (newButton, status, errorMessage) {
                console.log('status' + status);
                console.log('errorMessage' + errorMessage);
                if (status === 'SUCCESS') {
                    $A.get("e.force:closeQuickAction").fire();


                    let ev = $A.get("e.c:XC_LCE015_ModalClosed");
                    if (ev) {
                        ev.setParams({ "modalName": $A.get("$Label.c.XC_CL_CreateOpportunityClosedEvent") });
                        ev.fire();
                    }
                    component.set("v.spinner", false);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")

                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }

            }
        );

        //lancio evento per il close della finestra
        /*var ev = $A.get("e.c:XC_LCE015_ModalClosed");
        if(ev){
            ev.setParams({"modalName": $A.get("$Label.c.XC_CL_CreateOpportunityClosedEvent")});
            ev.fire();
        }
        component.set("v.spinner", false);*/
    },

    createAsset: function (component, event, helper) {
        //let recordType = component.get("v.recordTypeId");

        let contactId = component.get("v.recordId");
        let accountId = component.get("v.categoryValue");
        let catalog = component.get("v.catalogValue");
        let catalogCategory = component.get("v.catalogCategoryValue");
        let description = component.get("v.description");
        let modelValue = component.get("v.modelValue");
        let addressId = component.get("v.addressValue");
        let assetName = component.get("v.assetName");
        let productTypeValue = component.get("v.productTypeValue");
        let productSubTypeValue = component.get("v.productSubTypeValue");
        var options = {
            contactId: contactId,
            accountId: accountId,
            catalog: catalog,
            catalogCategory: catalogCategory,
            description: description,
            modelValue: modelValue,
            addressId: addressId,
            assetName: assetName,
            productType: productTypeValue,
            productSubType: productSubTypeValue
        };

        var assetValues = JSON.stringify(options);

        let action = component.get("c.createAssetApex");
        action.setParams({
            'assetValues': assetValues,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue.success) {
                helper.showToast(component, $A.get("$Label.c.XC_CL_AssetCreated"), 'success')
                //$A.get("e.force:closeQuickAction").fire();
                var navService = component.find("navService");
                // Use this pageReference to navigate to recordPage 
                var pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": retValue.recordId,
                        "objectApiName": "Asset",
                        "actionName": "view"
                    }
                };

                navService.navigate(pageReference);

            } else {
                helper.showToast(component, retValue.resultMessage, 'error');
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
        /*
        $A.createComponent(
            "c:XC_LCP101_SelectAddress",
            {		
                    "title" : "Choose an Address",
                    "recordTypeId" : recordType,
                    "fromContact" : true,
                    "recordId" : component.get("v.categoryValue"),
                    "contactId" : component.get("v.recordId"),
                    "accountId" : component.get("v.categoryValue"),
                    "catalog" : component.get("v.catalogValue"),
                    "catalogCategory" : component.get("v.catalogCategoryValue"),
                    "isAssetCreation": true,
                    "description" : component.get("v.description"),
                    "modelValue" : component.get("v.modelValue")
            },
            function(newcomponent, status, errorMessage){
                if(status === 'SUCCESS'){
                    component.set("v.showSpinner", false);
                    let body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body); 
                    component.set("v.title", '');
                    component.set("v.showFooter", false);
                  
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        component.set("v.spinner", false);
        */
    },

    updateOpp: function (component, event, helper) {

        let recordid = component.get("v.recordId");
        let addressId = component.find("ChooseAddress").get("v.value");

        var m = {
            "opportunityId": recordid,
            "addressId": addressId
        };

        let inputFields = JSON.stringify(m);

        let action = component.get("c.updateOpportunityAddress");
        action.setParams({
            'inputFields': inputFields,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {
                if (retValue.success) {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Opportunity updated',
                        message: ' ',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    component.set('v.showSpinner', false);
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    let errorMessageResult = retValue.errorMessage;
                    let toastEventError = $A.get("e.force:showToast");
                    toastEventError.setParams({
                        title: $A.get("$Label.c.XC_CL_Warning"),
                        message: errorMessageResult,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible',
                        duration: '15000'
                    });
                    toastEventError.fire();
                    component.set('v.showSpinner', false);
                }
            } else {
                let toastEventWarn = $A.get("e.force:showToast");
                toastEventWarn.setParams({
                    title: $A.get("$Label.c.XC_CL_Warning"),
                    message: $A.get("$Label.c.XC_CL_ErrorsOccurred"),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible',
                    duration: '15000'
                });
                toastEventWarn.fire();
                component.set('v.spinnerControl', false);
            }

        });
        $A.enqueueAction(action);

    },

    createAddress: function (component, event, helper) {
        console.log('creating address');
        component.set("v.showNewAddress", true);
        component.set("v.showFooter", false);
    },

    createResidentialAddress: function (component, event, helper) {
        console.log('creating address');
        component.set("v.isResidentialAddress", true);
        component.set("v.showNewAddress", true);
        component.set("v.showFooter", false);
    },


    getProductTypeOptions: function (component, event, helper) {

        let action = component.get("c.getProductTypeValues");
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {

                let result = response.getReturnValue();
                let opts = [];
                for (let i = 0; i < result.length; i++) {
                    opts.push({ 'label': result[i], 'value': result[i] });
                }
                component.set("v.productTypeOpts", opts);
                //component.set("v.productTypeValue",opts[0].value);
                console.log("PRODUCT TYPE OPTS: ", component.get("v.productTypeOpts"));


            } else {

                let toastEventWarn = $A.get("e.force:showToast");
                toastEventWarn.setParams({
                    title: $A.get("$Label.c.XC_CL_Warning"),
                    message: $A.get("$Label.c.XC_CL_ErrorsOccurred"),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible',
                    duration: '15000'
                });
                toastEventWarn.fire();
                component.set('v.spinnerControl', false);
            }
        });

        $A.enqueueAction(action);


    },

    getProductSubTypeDependency: function (component, event, helper) {

        let action = component.get("c.getProductSubTypeValues");

        action.setCallback(this, function (response) {

            if (response.getState() == "SUCCESS") {
                console.log("RETURN VALUE::: ", response.getReturnValue());
                component.set("v.productSubTypeDependency", response.getReturnValue());
                console.log("SUBTYPE DEPENDENCY ", component.get("v.productSubTypeDependency"));



            } else {

                let toastEventWarn = $A.get("e.force:showToast");
                toastEventWarn.setParams({
                    title: $A.get("$Label.c.XC_CL_Warning"),
                    message: $A.get("$Label.c.XC_CL_ErrorsOccurred"),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible',
                    duration: '15000'
                });
                toastEventWarn.fire();
                component.set('v.spinnerControl', false);

            }
        });

        $A.enqueueAction(action);

    },

    handleCloseNewAddress: function (component, event, helper) {
        console.log('to 52');
        component.set("v.showNewAddress", false);
        component.set("v.showFooter", true);
        component.set("v.addressCreated", true);
        helper.setAddress(component, event, helper);
    },

    handleSubmit: function (component, event, helper) {
        if (component.get("v.manageAddress")) {
            helper.updateOpp(component, event, helper);
        } else {
            helper.createOpp(component, event, helper);
        }
    },

    closeModel: function (component, event, helper) {
        let navigateEvent = $A.get("e.force:navigateToSObject");
        let navigateRecordId = component.get("v.recordId");
        if (!(component.get("v.workOrderId") === "")) {
            navigateRecordId = component.get("v.workOrderId");
        }
        navigateEvent.setParams({ "recordId": navigateRecordId, "slideDevName": "detail", "isredirect": true });
        navigateEvent.fire();
    },

    showToast: function (component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get("e.force:closeQuickAction").fire();
    },

    closeFunctinality: function (component, event, helper, message, typeMessage) {
        component.set("v.spinner", false);
        helper.showToast(component, message, typeMessage);
        $A.get("e.force:closeQuickAction").fire();

        //lancio evento per il close della finestra
        let ev = $A.get("e.c:XC_LCE015_ModalClosed");
        if (ev) {
            ev.setParams({ "modalName": $A.get("$Label.c.XC_CL_CreateOpportunityClosedEvent") });
            ev.fire();
        }
    },

    prodTypeChange: function (component, event, helper) {
        let productTypeSelection = event.getParam("value");
        let subTypeValues = component.get("v.productSubTypeDependency")[productTypeSelection];

        let opts = [];
        for (let i = 0; i < subTypeValues.length; i++) {
            opts.push({ 'label': subTypeValues[i], 'value': subTypeValues[i] });
        }
        component.set("v.productSubTypeValue", opts[0].value);
        component.set("v.productSubTypeOpts", opts);
        component.set("v.subTypeDisabled", false);

    },
    
    //Start CR758
    showedSedeLegaleCheck: function (component, event, helper){
        let action = component.get("c.showSedeLegale");
        console.log("@@@@ Start showedSedeLegaleCheck");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.showSedeLegale", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
    //End CR758

})