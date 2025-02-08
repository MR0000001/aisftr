({
    initialize : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Helper >> initialize >> Start');
        let _helper = this;
        let calledFromExternalCmp = component.get("v.calledFromExternalCmp");
          
        let action = component.get("c.initialize");

        action.setCallback(this, function(response) {
            console.log('TA_LCP250_SelectAccount >> Helper >> initialize >> Start');
            if(response.getState() == "SUCCESS") {

                component.set('v.productCategoryValues', response.getReturnValue().productCategoryValuesList);
                console.log('@@>> productCategoryValues >>> ' + component.get('v.productCategoryValues'));
                component.set('v.recordTypesMap', response.getReturnValue().recordTypesMap);
                console.log('@@>> recordTypesMap >>> ' + JSON.stringify(component.get('v.recordTypesMap')));
                //component.set("v.isInitialized", true);
                component.set("v.showSelectAccountModal", true);
                
                _helper.fireToggleSpinnerEvent(component, false);
                if(calledFromExternalCmp){
                    _helper.searchAccount(component, event, helper);
                }
                
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                _helper.fireToggleSpinnerEvent(component, false);

            }
            console.log('TA_LCP250_SelectAccount >> Helper >> initialize >> End');
        });
        $A.enqueueAction(action);
        _helper.fireToggleSpinnerEvent(component, true);
        
        console.log('TA_LCP250_SelectAccount >> Helper >> initialize >> End');
    },

    searchAccount : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Helper >> searchAccount >> Start');
        let _helper = this;
        let searchParam = component.get("v.searchParam");

        component.set("v.disableConfirmAccount", true);
        component.set("v.productCategoryDisabled", true);
        component.set("v.selectedAccountId", "");
        component.set("v.selectedAddressId", "");
        component.set("v.showProductCategory", false);
        component.set("v.selectedAccount", null);
          
        let action = component.get("c.searchAccount");
        action.setParams({ 'searchParam' : searchParam });

        action.setCallback(this, function(response) {
            console.log('TA_LCP250_SelectAccount >> Helper >> searchAccount >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.searchResultList', response.getReturnValue());
                console.log('v.searchResultList >>> ', JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue().length == 0){
                    component.set("v.noAccountFound", true);
                } else {
                    component.set("v.noAccountFound", false);
                }
                _helper.fireToggleSpinnerEvent(component, false);
                
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                _helper.fireToggleSpinnerEvent(component, false);

            }
            console.log('TA_LCP250_SelectAccount >> Helper >> searchAccount >> End');
        });
        $A.enqueueAction(action);
        _helper.fireToggleSpinnerEvent(component, true);
        
        console.log('TA_LCP250_SelectAccount >> Helper >> searchAccount >> End');
    },

    checkSearchParam : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Helper >> checkSearchParam >> Start');
        let searchParam = component.get("v.searchParam");
        if(searchParam.length >= 3){
            component.set("v.disableSearch", false);
        } else {
            component.set("v.disableSearch", true);
        }
        console.log('TA_LCP250_SelectAccount >> Helper >> checkSearchParam >> End');
    },

    selectAccount : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Helper >> selectAccount >> Start');
        let _helper = this;
        let selectedAccountId = event.currentTarget.id;
        let searchResultList = component.get("v.searchResultList");

        _helper.fireToggleSpinnerEvent(component, true);
        component.set("v.selectedAddressId", "");

        searchResultList.forEach(function(account) {
            if(account.accountId == selectedAccountId) {
                console.log('@@>> List of address >>> ' + JSON.stringify(account.addressList));
                if(account.selected){
                    account.selected = false;
                    component.set("v.selectedAccountId", "");
                    component.set("v.disableConfirmAccount", true);
                    component.set("v.productCategoryDisabled", true);
                    _helper.fireToggleSpinnerEvent(component, false);
                    component.set("v.showProductCategory", false);
                    component.set("v.selectedAccount", null);
                    
                } else {
                    account.selected = true;
                    component.set("v.selectedAccountId", account.accountId);
                    component.set('v.accountSelected', account);
                    component.set("v.selectedAccountRecordTypeDeveloperName", account.recordTypeDeveloperName);
                    //component.set("v.disableConfirmAccount", false);
                    component.set("v.disableConfirmAccount", false);
                    component.set("v.productCategoryDisabled", false);

                    let recordTypesMap = component.get("v.recordTypesMap")[0];
                    if(account.recordTypeDeveloperName.includes("Account")){
                        let replacedRecordTypeDeveloperName = account.recordTypeDeveloperName.replace("Account", "Lead");
                        let recordTypeId = recordTypesMap[replacedRecordTypeDeveloperName];
                        console.log('recordTypeId >>> ' + recordTypeId);
                        component.set("v.recordTypeId", recordTypeId);
                    } else {
                        let recordTypeId = recordTypesMap[account.recordTypeDeveloperName];
                        component.set("v.recordTypeId", recordTypeId);
                    }
                    component.set("v.selectedAccount", account);
                    _helper.populateProductTypePicklist(component, event, helper);
                }
                
            } else {
                component.set("v.selectedAccount", null);
                account.selected = false;
            }
        });

        component.set("v.searchResultList", searchResultList);
        console.log('TA_LCP250_SelectAccount >> Helper >> selectAccount >> End');
    },

    selectAddress : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Helper >> selectAddress >> Start');
        
        let _helper = this;
        let selectedAddressId = event.currentTarget.id;
        //let selectedAccountId = component.get("v.selectedAccountId");
        //let searchResultList = component.get("v.searchResultList");

        _helper.fireToggleSpinnerEvent(component, true);
        //component.set("v.addressMap", null);

        /*searchResultList.forEach(function(account) {
            if(account.accountId == selectedAccountId){
                let currentAddressList = account.addressList; */
                let currentAddressList = component.get('v.accountSelected').addressList;
                currentAddressList.forEach(function(address) {
                    if(address.addressId == selectedAddressId) {
                        if(address.selected){
                            address.selected = false;
                            component.set("v.selectedAddressId", "");
                            //component.set("v.disableConfirmAccount", true);
                            component.set("v.disableConfirmAddress", true);
                            _helper.fireToggleSpinnerEvent(component, false);
                        } else {
                            address.selected = true;
                            component.set("v.selectedAddressId", address.addressId);
                            //component.set("v.disableConfirmAccount", false);
                            component.set("v.disableConfirmAddress", false);
                        }
                        
                    } else {
                        address.selected = false;
                    }
                });
            /*}
        }); */

        let accountSelected = component.get('v.accountSelected');
        accountSelected.addressList = currentAddressList;
        component.set("v.accountSelected", accountSelected);
        //component.set("v.searchResultList", searchResultList);
        _helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP250_SelectAccount >> Helper >> selectAddress >> End');
    },

    confirmAccount : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Helper >> confirmAccount >> Start');

        let _helper = this;
        let selectedAccountId = component.get("v.selectedAccountId");
        let selectedProductCategory = component.get("v.selectedProductCategory");
        let selectedAddressId = component.get("v.selectedAddressId");
        let addressMap = component.get("v.addressMap");

        let action = component.get("c.createWorkOrder");
        action.setParams({ 'selectedAccountId' : selectedAccountId,
                            'selectedProductCategory' : selectedProductCategory,
                            'selectedAddressId' : selectedAddressId,
                            'addressMap' : addressMap });

        action.setCallback(this, function(response) {
            console.log('TA_LCP250_SelectAccount >> Helper >> changeSearchParam >> Start');
            if(response.getState() == "SUCCESS") {
                let createWorkOrderResponse = response.getReturnValue();
                if(createWorkOrderResponse.success){
                    _helper.redirect(component, createWorkOrderResponse.workOrderId);
                } else {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(createWorkOrderResponse.errorMessage));
                    _helper.fireToggleSpinnerEvent(component, false);
                }
                
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                _helper.fireToggleSpinnerEvent(component, false);
            }
            console.log('TA_LCC208_Modal >> Helper >> initializeCallback >> End');
        });
        $A.enqueueAction(action);
        _helper.fireToggleSpinnerEvent(component, true);

        component.set("v.searchResultList", searchResultList);
        console.log('TA_LCP250_SelectAccount >> Helper >> confirmAccount >> End');
    },

    populateProductTypePicklist : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Helper >> confirmAccount >> Start');

        let _helper = this;
        let recordTypeId = component.get("v.recordTypeId");
        let action = component.get("c.populateProductTypePicklist");

        action.setParams({ 'recordTypeId' : recordTypeId });

        action.setCallback(this, function(response) {
            console.log('TA_LCP250_SelectAccount >> Helper >> changeSearchParam >> Start');
            if(response.getState() == "SUCCESS") {
                let picklistValues = response.getReturnValue();
                console.log(picklistValues);
                let productCategoryValues = component.get("v.productCategoryValues");
                let newList = [];
                
                picklistValues.forEach(function(singleValue) {
                    if(productCategoryValues.includes(singleValue)){
                        newList.push(singleValue);
                    }
                });

                component.set("v.filteredProductCategoryValues", newList);
                component.set("v.showProductCategory", true);
                
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            _helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCC208_Modal >> Helper >> initializeCallback >> End');
        });
        $A.enqueueAction(action);
        _helper.fireToggleSpinnerEvent(component, true);

        //component.set("v.searchResultList", searchResultList);
        console.log('TA_LCP250_SelectAccount >> Helper >> confirmAccount >> End');
    },

    closeModal : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleConfirmAccount >> Start');
        helper.fireCloseModalEvent(component);
        component.set("v.searchParam", "");
        component.set("v.searchResultList", "");
        component.set("v.selectedAccountId", "");
        component.set("v.selectedAddressId", "");
        console.log('TA_LCP250_SelectAccount >> Controller >> handleConfirmAccount >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP250_SelectAccount >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP250_SelectAccount",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP250_SelectAccount >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireCloseModalEvent : function(component) {
        console.log('TA_LCP250_SelectAccount >> Helper >> fireCloseModalEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("closeModal");
        toggleSpinnerEvent.setParams({
            "action" : "closeModal",
            "params" : {}
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP250_SelectAccount >> Helper >> fireCloseModalEvent >> End');
    },

    redirect : function(component, redirectParam) {
        console.log('TA_LCP209_BaseWizard >> Helper >> redirectToPage >> Start');
        let redirectUrl = component.get('v.communityBaseUrl') +'/' + redirectParam;
        window.location.href = redirectUrl;
        console.log('TA_LCP209_BaseWizard >> Helper >> redirectToPage >> End');
    },

    addressEvent : function(component, event, helper) {
        console.log('TA_LCP209_BaseWizard >> Helper >> addressEvent >> Start');
        let map = event.getParam("address");
        component.set("v.addressMap", map);

        if(map.validate){
            component.set("v.disableConfirmAccount", false);
            component.set("v.selectedAddressId", "");

            let accountSelected = component.get('v.accountSelected');
            accountSelected.addressList.push({ 
                'streetType' : map.streetTypeText,
                'streetName' : map.address,
                'streetNumber' : map.streetNumber,
                'city' : map.city,
                'postalCode' : map.postalCode,
                'addressId' : 'custom-address'
            });
            component.set('v.accountSelected', accountSelected);
            component.set('v.showAddressSection', false);
            component.set("v.createAddressLabel", $A.get("$Label.c.TA_CreateNewAddress"));
        } else {
            component.set("v.disableConfirmAccount", true);
        }
        console.log('TA_LCP209_BaseWizard >> Helper >> addressEvent >> Start');
    },

    toggleAddressSection : function(component, event, helper) {
        console.log('TA_LCP209_BaseWizard >> Helper >> toggleAddressSection >> Start');
        let addressSectionDisplayed = component.get("v.showAddressSection");
        if(!addressSectionDisplayed) {
            component.set("v.createAddressLabel", $A.get("$Label.c.TA_HideAddressSection"));
            let accountSelected = component.get('v.accountSelected');
            let currentAddressList = accountSelected.addressList;
            for(let i = 0; i < currentAddressList.length; i++) {
                if(currentAddressList[i].addressId == 'custom-address') currentAddressList.splice(i, 1);
            }
            component.set('v.accountSelected', accountSelected);
        } else {
            component.set("v.createAddressLabel", $A.get("$Label.c.TA_CreateNewAddress"));
        }

        component.set("v.showAddressSection", !addressSectionDisplayed);
        console.log('TA_LCP209_BaseWizard >> Helper >> toggleAddressSection >> Start');
    }
})