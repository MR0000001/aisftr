({
    initialize : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> initialize >> Start');
        helper.manageCartStepEvt('TA_LCP199_ButtonSection', null, {}, false);
        console.log('TA_LCP227_CartConfiguration >> Helper >> initialize >> End');
    },

    initializeResponse : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> initializeResponse >> Start');
        
        let b2winResponse = event.getParam('actionParams').b2winResponse;
        let bundles = [];
        let bundleNames = [];
        b2winResponse.listOfBundles.forEach(function(bundle) {
            if(!bundleNames.includes(bundle.fields.bundlename)) {
                bundleNames.push(bundle.fields.bundlename);
                bundles.push(bundle);
            }
        });
        b2winResponse.listOfBundles = bundles;
        component.set('v.workOrder', event.getParam('actionParams').workOrder);
        component.set('v.b2winResponse', b2winResponse);

        helper.organizeCategory(component, event, helper);
        component.set('v.isInitialized', true);
        helper.fireSendInitStateEvt(component, true);
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP227_CartConfiguration >> Helper >> initializeResponse >> End');
    },

    manageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> manageB2WResponse >> Start');
        let params = event.getParams();
        component.set('v.actionType', params.actionParams.actionType);
        helper[params.actionName](component, event, helper, params.actionParams);
        console.log('TA_LCP227_CartConfiguration >> Helper >> manageB2WResponse >> End');
    },

    organizeCategory : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> organizeCategory >> Start');
        let b2winResponse = component.get('v.b2winResponse');
        let lastOfChainList = [];
        b2winResponse.listOfCategories.forEach(function(category) {
            // if(category.categoryFields.hidden != 'true' && category.categoryFields.LicName != 'Technical Catalog') {
            if(category.categoryFields.hidden != 'true') {
                let founded = false;
                b2winResponse.listOfCategories.forEach(function(categoryNested) {
                    if(category.id == categoryNested.categoryFields.parentcategory) {
                        founded = true;
                    }
                });
                if(!founded) {
                    lastOfChainList.push(category);
                }
            }
        });

        let categoryResult = {};
        let categoryListToShow = [];
        lastOfChainList.forEach(function(lastOfChain) {
            categoryResult = helper.searchParentCategory(b2winResponse, lastOfChain.categoryFields.parentcategory, helper);
            categoryResult.categoryToSave += categoryResult.categoryToSave ? ' - ' + lastOfChain.categoryFields.name : lastOfChain.categoryFields.name;
            lastOfChain.categoryName = categoryResult.categoryToSave;
            if(!categoryResult.remove) {
                categoryListToShow.push(lastOfChain);
            }
        });
        component.set("v.categoryListToShow", categoryListToShow);
        console.log('TA_LCP227_CartConfiguration >> Helper >> organizeCategory >> End');
    },

    searchParentCategory : function (b2winResponse, parentcategory, helper) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> searchParentCategory >> Start');
        let result = {
                        'categoryToSave' : '',
                        'remove' : false
                    };

        b2winResponse.listOfCategories.forEach(function(category) {
            if(parentcategory == category.id && category.categoryFields.hidden != 'true') {
                if(category.categoryFields.parentcategory) {
                    result = helper.searchParentCategory(b2winResponse, category.categoryFields.parentcategory, helper);
                    result.categoryToSave += ' - ' + category.categoryFields.name;
                } else {
                    result.categoryToSave = category.categoryFields.name;
                }
            } else if(parentcategory == category.id && category.categoryFields.hidden == 'true') {
                result.remove = true;
            }
        });
        console.log('TA_LCP227_CartConfiguration >> Helper >> searchParentCategory >> End');
        return result;
    },

    managePressButton : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> managePressButton >> Start');
        let categoryListToShow = component.get("v.categoryListToShow");
        let listOfBundles = component.get("v.b2winResponse.listOfBundles");
        let eventId = event.target.id;
        let actionParams = {'id' : eventId};

        categoryListToShow.forEach(function(categoryToShow) {
            if(categoryToShow.id == eventId) {
                categoryToShow.holdButton = true;
                helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageSelectCategory', actionParams, true);
            } else {
                categoryToShow.holdButton = false;
            }
        });

        if(component.get('v.actionType') == 'edit') {
            let cartItems = component.get('v.b2winResponse.cart');
            cartItems.forEach(function(cartItem) {
                if(cartItem.fields.bundleId == eventId && cartItem.fields.LicCategoryName == 'bundleItem') {
                    listOfBundles.forEach(function(singleBundle) {
                        if(singleBundle.id == eventId) {
                            singleBundle.holdButton = true;
                        } else {
                            singleBundle.holdButton = false;
                        }
                    });
                    helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageAddBundle', cartItem, true);
                }
            });
        } else {
            listOfBundles.forEach(function(singleBundle) {
                if(singleBundle.id == eventId) {
                    singleBundle.holdButton = true;
                    helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageAddBundle', singleBundle, true);
                } else {
                    singleBundle.holdButton = false;
                }
            });
        }

        component.set("v.categoryListToShow", categoryListToShow);
        component.set("v.b2winResponse.listOfBundles", listOfBundles);
        console.log('TA_LCP227_CartConfiguration >> Helper >> managePressButton >> End');
    },

    manageCartStepEvt : function(handlerCmpName, actionName, actionParams, showButton) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> manageCartStepEvt >> Start');
        let appEvent = $A.get("e.c:TA_LCE226_CartStep");
        appEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'actionName' : actionName,
            'actionParams' : actionParams,
            'showButton' : showButton
        });
        appEvent.fire();
        console.log('TA_LCP227_CartConfiguration >> Helper >> manageCartStepEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP229_CartMainProduct",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP227_CartConfiguration >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP227_CartConfiguration >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP226_CartContainer",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP227_CartConfiguration >> Helper >> fireSendInitStateEvt >> End');
    }
})