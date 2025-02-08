({
    initialize : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
        component.set('v.lastAction', 'initialize');

        if(component.get('v.workOrder').TA_Parameters__c && JSON.parse(component.get("v.workOrder").TA_Parameters__c).newOppty) {
            component.set('v.opportunityId', JSON.parse(component.get("v.workOrder").TA_Parameters__c).newOppty);
        } else if(component.get('v.workOrder').TA_Parameters__c && JSON.parse(component.get("v.workOrder").TA_Parameters__c).quoteToModify) {
            component.set('v.orderId', JSON.parse(component.get("v.workOrder").TA_Parameters__c).quoteToModify);
        } else if(component.get('v.workOrder').XC_Configuration__c) {
            component.set('v.orderId', component.get('v.workOrder').XC_Configuration__c);
        } else {
            component.set('v.opportunityId', component.get('v.workOrder').XC_Opportunity__c);
        }

        if(component.get('v.workOrder').TA_Parameters__c && JSON.parse(component.get("v.workOrder").TA_Parameters__c).actionModify) {
            component.set('v.actionParam', JSON.parse(component.get("v.workOrder").TA_Parameters__c).actionModify);
        }

        helper.loadB2WinComponent(component, event, helper);

        let action = component.get('c.initialize_TA_LCP226_CartContainer');
        action.setParam('customConfigSerialized', JSON.stringify(component.get("v.custom")));

        action.setCallback(this, function(response) {
            console.log('TA_LCP226_CartContainer >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let returnValue = JSON.parse(response.getReturnValue())
                component.set('v.catalogCategoryId', returnValue.catalogCategoryId);
                component.set('v.mappingStep', returnValue.mapComponentStep);
                component.set("v.isInitialized", true);
			} else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
			console.log('TA_LCP226_CartContainer >> Helper >> initializeCallback >> End');
		});
        $A.enqueueAction(action);
        console.log('TA_LCP226_CartContainer >> Helper >> initialize >> End');
    },

    loadB2WinComponent : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Helper >> loadB2WinComponent >> Start');
        let b2winParameters = {
                                "parameters" : "lightningFromVF=true;sourcePlatform=APP",
                                "ShowCartAlways" : "false",
                                "enableDestroy" : "false",
                                "disableRedirect" : true,
                            };

        if(component.get('v.opportunityId')) {
            b2winParameters.oppId = component.get('v.opportunityId');
        //START FIX [#20210303AL] - fix edit quote not loading data
        //} else if(component.get('v.quoteId')) {
        } else if(component.get('v.orderId')) {
        //END FIX [#20210303AL] - fix edit quote not loading data
            b2winParameters.orderId = component.get('v.orderId');
        }
        $A.createComponent('NE:B2WGin_Core_Engine', b2winParameters, function(cmp, status, errorMessage) {
            if(status == "SUCCESS") {
                component.find('b2wComponent').set('v.body', cmp);
            } else if(status == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", errorMessage);
            }
        });
        console.log('TA_LCP226_CartContainer >> Helper >> loadB2WinComponent >> End');
    },

    loadNextStepComponent : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Helper >> loadNextStepComponent >> Start');
        let nextStepCmpName = 'c:' + component.get('v.nextStepCmpName');
        $A.createComponent(nextStepCmpName, null, function(cmp, status, errorMessage) {
            if(status == "SUCCESS") {
                component.find('stepCmp').set('v.body', cmp);
                helper.manageCartStepEvt(component.get('v.nextStepCmpName'), 'initializeResponse', component.get('v.nextStepCmpParams'));
                helper.refreshCartEvt(component.get('v.nextStepCmpParams').b2winResponse);
            } else if(status == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", errorMessage);
            }
        });
        console.log('TA_LCP226_CartContainer >> Helper >> loadNextStepComponent >> End');
    },

    refreshCartEvt : function(responseCart) {
        console.log('TA_LCP226_CartContainer >> Helper >> refreshCartEvt >> Start');
        let fireRefreshEvt = $A.get("e.c:TA_LCE224_Refresh");
        fireRefreshEvt.setParams({
            'action' : 'refresh-cart',
            'params' : responseCart
        });
        fireRefreshEvt.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> refreshCartEvt >> End');
    },

    manageUpdateContext : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageUpdateContext >> Start');
        console.log('TA_LCP226_CartContainer >> Helper >> manageUpdateContext >> lastAction: ',component.get('v.lastAction'));

        let cartContext = event.getParam('CartService_Output');
        component.set('v.cartContext', cartContext);
        console.log('cartContext >> ' + JSON.stringify(cartContext));
        console.log('cartContext.respondingTo >> ' +cartContext.respondingTo);
        console.log('cartContext.respondingTo >> ' +component.get('v.lastAction'));
        console.log('context.sessionParameters.currentcatalogid >>' +cartContext.sessionParameters.currentcatalogid);

        if(component.get('v.catalogCategoryId') && cartContext.sessionParameters.currentcatalogid != component.get('catalogCategoryId')) {
            return helper.manageSelectCatalog(component, event, helper, component.get('catalogId'), false);
        }
        
        if(cartContext) {
            let nextStepCmpParams = {
                'b2winResponse' : cartContext,
                'isBundle' : component.get('v.isBundle'),
                'workOrder' : component.get('v.workOrder')
            };
            component.set('v.nextStepCmpParams', nextStepCmpParams);

            if(component.get('v.lastAction') == 'initialize') {
                component.set('v.nextStepCmpName', 'TA_LCP227_CartConfiguration');
                if(component.get('v.orderId')) {
                    if(component.get('v.actionParam') == 'edit') { 
                        let newListOfBundles = [];
                        let newListOfCategories = [];
                        cartContext.cart.forEach(function(cartItem) {
                            if(cartItem.fields.LicCategoryName == 'bundleItem') {
                                cartContext.listOfBundles.forEach(function(bundle) {
                                    if(bundle.fields.LicName == cartItem.fields.LicProductName) {
                                        newListOfBundles.push(bundle);
                                    }
                                });
                            } else if(cartItem.fields.bundleId == null) {
                                cartContext.listOfCategories.forEach(function(category) {
                                    if(category.id == cartItem.fields.categoryid) {
                                        newListOfCategories.push(category);
                                    }
                                });
                            }
                        });
                        cartContext.listOfBundles = newListOfBundles;
                        cartContext.listOfCategories = newListOfCategories;
                        nextStepCmpParams.actionType = component.get('v.actionParam');
                        component.set('v.nextStepCmpParams', nextStepCmpParams);
                    } else if(component.get('v.actionParam') == 'addMore') {
                        //TODO - Check logic
                    }
                // } else {
                //     component.set('v.lastAction', 'initializeAfterClearCart');
                //     let restartEvent = $A.get("e.NE:Bit2win_Event_CartEvent");
                //     restartEvent.setParams({
                //         'process':'ResetSession',
                //         'processOptions':{clearCart:'true'}
                //     }); 
                //     restartEvent.fire();
                }
                helper.loadNextStepComponent(component, event, helper);

            } else if(component.get('v.lastAction') == 'initializeAfterClearCart' || component.get('v.lastAction') == 'manageSelectCatalog') {
                helper.loadNextStepComponent(component, event, helper);

            } else if(component.get('v.lastAction') == 'manageAddBundle') {
                cartContext.listOfBundles.forEach(function(bundle) {
                    if(bundle.id == component.get('v.bundleId')) {
                        component.set('v.bundleElementList', bundle.bundleElements);
                    }
                });
                if(component.get('v.bundleElementList').length) {
                    let bundleElement = component.get('v.bundleElementList')[component.get('v.bundleElementCurrentIndex')];
                    let mappingStep = component.get('v.mappingStep');
                    for(let prop in mappingStep) {
                        if(mappingStep[prop].includes(bundleElement.fields.macroCategory) && prop != 'TA_LCP228_CatalogConfiguration') {
                            helper.manageRetrieveItemsFromBundleElement(component, event, helper, bundleElement);
                        }
                    }
                }

            } else if(component.get('v.lastAction') == 'manageSelectCategory') {
                component.set('v.nextStepCmpName', 'TA_LCP229_CartMainProduct');
                helper.loadNextStepComponent(component, event, helper);

            } else if(component.get('v.lastAction') == 'manageRetrieveItemsFromBundleElement') {
                let bundleElement = component.get('v.bundleElementList')[component.get('v.bundleElementCurrentIndex')];
                let mappingStep = component.get('v.mappingStep');
                for(let prop in mappingStep) {
                    if(mappingStep[prop].includes(bundleElement.fields.macroCategory)) {
                        nextStepCmpParams.b2winCurrentBundleElement = bundleElement;
                        component.set('v.nextStepCmpName', prop);
                        component.set('v.nextStepCmpParams', nextStepCmpParams);
                        helper.loadNextStepComponent(component, event, helper);
                    }
                }

            } else if(component.get('v.lastAction') == 'manageUpsertItems') {
                let actionName = component.get('v.lastAction') + 'Response';
                helper.manageCartStepEvt(component.get('v.isVoucherStep') ? 'TA_LCP240_CartDiscountCode' : component.get('v.isEventFromCartSummary') ? 'TA_LCP232_CartSummary' : component.get('v.nextStepCmpName'), actionName, component.get('v.nextStepCmpParams'));

            } else if(component.get('v.lastAction') == 'manageSaveConfiguration') {
                let actionName = component.get('v.lastAction') + 'Response';
                helper.refreshCartEvt(cartContext);
                helper.manageCartStepEvt(component.get('v.isVoucherStep') ? 'TA_LCP240_CartDiscountCode' : component.get('v.isEventFromCartSummary') ? 'TA_LCP232_CartSummary' : component.get('v.nextStepCmpName'), actionName, component.get('v.nextStepCmpParams'));

            } else if(component.get('v.lastAction') == 'addRemoveFromCart') {
                let actionName = component.get('v.lastAction') + 'Response';
                let nextStepCmpParams = component.get('v.nextStepCmpParams');
                nextStepCmpParams.currentProductId = component.get('v.currentProductId');
                helper.refreshCartEvt(cartContext);
                helper.manageCartStepEvt(component.get('v.isVoucherStep') ? 'TA_LCP240_CartDiscountCode' : component.get('v.isEventFromCartSummary') ? 'TA_LCP232_CartSummary' : component.get('v.nextStepCmpName'), actionName, nextStepCmpParams);

            } else if(component.get('v.lastAction') == 'manageSaveBundle') {
                //helper.manageCheckPenalty(component, event, helper, {"action" : "checkout"});
                if(component.get('v.isVoucherStep')) {
                    helper.manageCheckPenalty(component, event, helper, {"action" : "checkout"});
                } else {
                    helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageSaveBundle', null, true);
                    component.set('v.showDiscountStep', true);
                    component.set('v.isVoucherStep', true);
                    //helper.refreshCartEvt(component.get('v.cartContext'));
                    helper.fireToggleSpinnerEvent(component, false);
                }
                
            } else if(component.get('v.lastAction') == 'manageAddCoupon') {
                helper.manageCartStepEvt('TA_LCP240_CartDiscountCode', 'manageAddCouponResponse', nextStepCmpParams);
            }
        }
        console.log('TA_LCP226_CartContainer >> Helper >> manageUpdateContext >> End');
    },

    prepareNextAction : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Helper >> prepareNextAction >> Start');
        let params = event.getParams();
        let isEventFromCartSummary = false;
        if(params.isCartSummary) isEventFromCartSummary = true;
        component.set('v.isEventFromCartSummary', isEventFromCartSummary);

        component.set('v.currentProductId', params.currentProductId);
        if(params.actionName == 'manageRetrieveItemsFromBundleElement') {
            component.set('v.bundleElementCurrentIndex', component.get('v.bundleElementCurrentIndex') + 1);
            if(component.get('v.bundleElementList').length <= component.get('v.bundleElementCurrentIndex') || component.get('v.isBundle') == false) {
                params.actionName = 'manageSaveBundle';
            } else {
                params.actionParams = component.get('v.bundleElementList')[component.get('v.bundleElementCurrentIndex')];
            }
        }
        helper[params.actionName](component, event, helper, params.actionParams);
        console.log('TA_LCP226_CartContainer >> Helper >> prepareNextAction >> End');
    },

    manageAddBundle : function(component, event, helper, bundleItem) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageAddBundle >> Start');
        console.log('@@@ bit2winAction - manageAddBundle - bundleItem: ' + JSON.stringify(bundleItem));

        component.set('v.lastAction', 'manageAddBundle');
        component.set('v.isBundle', true);

        if(component.get('v.actionParam') == 'edit') component.set('v.bundleId', bundleItem.fields.bundleId);
        else component.set('v.bundleId', bundleItem.id);

        component.set('v.bundleElementCurrentIndex', 0);

        let configureBundle = $A.get("e.NE:Bit2win_Event_ConfigureBundle");
        configureBundle.setParams({
            'bundleItem' : bundleItem
        });
        configureBundle.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageAddBundle >> End');
    },

    manageSelectCategory : function(component, event, helper, category) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageSelectCategory >> Start');
        console.log('@@@ bit2winAction - manageSelectCategory - categoryId: ' + JSON.stringify(category.id) + ' isCatalog : false');

        component.set('v.lastAction', 'manageSelectCategory');
        component.set('v.isBundle', false);

        let changeCatalogAppEvent = $A.get("e.NE:Bit2win_Event_CategoryChanged");
        changeCatalogAppEvent.setParams({
            'categoryId' : category.id,
            'isCatalog' : false
        });
        changeCatalogAppEvent.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageSelectCategory >> End');
    },

    manageSelectCatalog : function(component, event, helper, catalogId) {
            console.log('TA_LCP226_CartContainer >> Helper >> manageSelectCatalog >> Start');
            console.log('@@@ bit2winAction - manageSelectCatalog - categoryId: ' + catalogId + ' isCatalog : true');
            component.set('v.lastAction', 'initialize');

            let changeCatalogAppEvent = $A.get("e.NE:Bit2win_Event_CategoryChanged");
            changeCatalogAppEvent.setParams({
                'catalogId' : catalogId,
                'isCatalog' : true
            });
            changeCatalogAppEvent.fire();
            console.log('TA_LCP226_CartContainer >> Helper >> manageSelectCatalog >> End');
        },

    manageRetrieveItemsFromBundleElement : function(component, event, helper, bundleElement) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageRetrieveItemsFromBundleElement >> Start');
        console.log('@@@ bit2winAction - manageRetrieveItemsFromBundleElement - BundleElement: ' + JSON.stringify(bundleElement));

        component.set('v.lastAction', 'manageRetrieveItemsFromBundleElement');

        let appEvent = $A.get("e.NE:Bit2win_Event_BundleElements");
        appEvent.setParams({
            'BundleElement' : bundleElement
        });
        appEvent.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageRetrieveItemsFromBundleElement >> End');
    },

    manageUpsertItems : function(component, event, helper, itemWithOnlyModifiedAttributes) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageUpsertItems >> Start');
        console.log('@@@ bit2winAction - manageUpsertItems - itemChanged: ' + JSON.stringify(itemWithOnlyModifiedAttributes));
        component.set('v.lastAction', 'manageUpsertItems');

        let changeAttributeEvent = $A.get("e.NE:Bit2win_Event_AttributeChanged");
        changeAttributeEvent.setParams({
            'itemChanged' : itemWithOnlyModifiedAttributes
        });
        changeAttributeEvent.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageUpsertItems >> End');
    },

    manageSaveConfiguration : function(component, event, helper, cartContext) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageSaveConfiguration >> Start');
        console.log('@@@ bit2winAction - manageSaveConfiguration - type: save - CartService_Output: ' + JSON.stringify(cartContext));
        component.set('v.lastAction', 'manageSaveConfiguration');

        let resetConfiguration = $A.get("e.NE:Bit2Win_Event_ResetSaveConfiguration");
        resetConfiguration.setParams({
            'type' : 'save',
            'CartService_Output' : cartContext
        });
        resetConfiguration.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageSaveConfiguration >> End');
    },

    manageAddToCart : function(component, event, helper, item) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageAddToCart >> Start');
        helper.addRemoveFromCart(component, event, helper, item, 'add');
        console.log('TA_LCP226_CartContainer >> Helper >> manageAddToCart >> End');
    },

    manageRemoveFromCart : function(component, event, helper, item) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageRemoveFromCart >> Start');
        helper.addRemoveFromCart(component, event, helper, item, 'remove');
        console.log('TA_LCP226_CartContainer >> Helper >> manageRemoveFromCart >> End');
    },

    addRemoveFromCart : function(component, event, helper, item, action) {
        console.log('TA_LCP226_CartContainer >> Helper >> addRemoveFromCart >> Start');
        console.log('@@@ bit2winAction - addRemoveFromCart - item: ' + JSON.stringify(item) + ' - action: ' + JSON.stringify(action));
        component.set('v.lastAction', 'addRemoveFromCart');
        
        let mapOfItems = {};
        mapOfItems[item.fields.itemCode] = item.fields.qty == 0 ? 1 : item.fields.qty;

        let configureAppEvent = $A.get("e.NE:Bit2win_Event_AddRemoveFromCart");
        configureAppEvent.setParams({
            'item' : item,
            'action' : action,
            'typeOfAdd' : 'multiAdd',
            'mapOfItems' : mapOfItems,
            'catalogId' : item.fields.catalogid,
            'categoryId' : item.fields.categoryid
        });
        configureAppEvent.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> addRemoveFromCart >> End');
    },

    manageSaveBundle : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageSaveBundle >> Start');
        console.log('@@@ bit2winAction - manageSaveBundle - type: saveBundle');
        component.set('v.lastAction', 'manageSaveBundle');

        let resetConfiguration = $A.get("e.NE:Bit2Win_Event_ResetSaveConfiguration");
        resetConfiguration.setParams({
            'type' : 'saveBundle'
        });
        resetConfiguration.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageSaveBundle >> End');
    },
    /*
    manageSelectCatalog : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageSelectCatalog >> Start');
        let idCatalog;
        console.log('@@@ bit2winAction - manageSelectCatalog - catalogId: ' + JSON.stringify(idCatalog) + ' - isCatalog: true');

        let changeCatalogAppEvent = $A.get("e.NE:Bit2win_Event_CategoryChanged");
        changeCatalogAppEvent.setParams({
            'catalogId' : idCatalog,
            'isCatalog' : true
        });
        changeCatalogAppEvent.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageSelectCatalog >> End');
    },*/

    manageCartStepEvt : function(handlerCmpName, actionName, actionParams, showButton) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageCartStepEvt >> Start');
        let appEvent = $A.get("e.c:TA_LCE226_CartStep");
        appEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'actionName' : actionName,
            'actionParams' : actionParams,
            'showButton' : showButton
        });
        appEvent.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageCartStepEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP226_CartContainer >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP226_CartContainer",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> fireToggleSpinnerEvent >> End');
    },

    manageCheckPenalty : function(component, event, helper, parameters) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageCheckPenalty >> Start');
        console.log('@@@ bit2winAction - manageSelectCatalog - action: ' + parameters.action);

        let checkPenaltyEvt = $A.get("e.NE:Bit2win_Event_ApplyPenalty");
        checkPenaltyEvt.setParams({
            "action" : parameters.action
        });
        checkPenaltyEvt.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageCheckPenalty >> End');
    },

    manageBitwinMap : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageBitwinMap >> Start');
        let configurationId = event.getParam("bitwinMap")["checkOutResponse"].configuration.Id;

        /*if(component.get('v.isVoucherStep')) {
            helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'goToQuoteSummary', {'configurationId' : configurationId});
        } else {
            helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageSaveBundle', null, true);
            component.set('v.showDiscountStep', true);
            component.set('v.isVoucherStep', true);
            helper.refreshCartEvt(component.get('v.cartContext').cart);
            helper.fireToggleSpinnerEvent(component, false);
        }*/

        let evtParams = {
            "workOrder" : component.get("v.workOrder"),
            "evtParam" : {
                'selectedQuote' : configurationId
            }
        };
        //START FIX [ADC25-06-2021] ENXCRM-161
        //helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'goToQuoteSummary', evtParams);        
        if(!component.get("v.isManageBitwinMapWasCalled")){
            helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'goToQuoteSummary', evtParams);
            component.set("v.isManageBitwinMapWasCalled",true);
        }
        //END FIX [ADC25-06-2021] ENXCRM-161
        console.log('TA_LCP226_CartContainer >> Helper >> manageBitwinMap >> End');
    },

    manageAddCoupon : function(component, event, helper, category) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageAddCoupon >> Start');
        console.log('@@@ bit2winAction - manageSelectCategory - categoryId: ' + JSON.stringify(category.id) + ' isCatalog : false');

        component.set('v.lastAction', 'manageAddCoupon');
        //component.set('v.isVoucherStep', true);
        //component.set('v.isBundle', false);

        let changeCatalogAppEvent = $A.get("e.NE:Bit2win_Event_CategoryChanged");
        changeCatalogAppEvent.setParams({
            'categoryId' : category.id,
            'isCatalog' : false
        });
        changeCatalogAppEvent.fire();
        console.log('TA_LCP226_CartContainer >> Helper >> manageAddCoupon >> End');
    },

    manageModifyFromCart : function(component, event, helper, item) {
        console.log('TA_LCP226_CartContainer >> Helper >> manageModifyFromCart >> Start');
        helper.addRemoveFromCart(component, event, helper, item, 'modify');
        console.log('TA_LCP226_CartContainer >> Helper >> manageModifyFromCart >> End');
    }
})