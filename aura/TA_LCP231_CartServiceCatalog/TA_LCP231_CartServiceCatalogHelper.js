({
    initialize : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> initialize >> Start');
        helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageRetrieveItemsFromBundleElement', {}, true);
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> initialize >> End');
    },

    initializeResponse : function(component, event, helper, parameters) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> initializeResponse >> Start');
        component.set('v.b2winResponse', parameters.b2winResponse);
        component.set('v.b2winCurrentBundleElement', parameters.b2winCurrentBundleElement);
        component.set('v.workOrder', parameters.workOrder);

        let totalQuantity = 0;
        let showButton = true;

        parameters.b2winResponse.listOfItems.forEach(function(item) {
            if(item.fields.qty != 0) {
                totalQuantity += Number(item.fields.qty);
            } else {
                parameters.b2winResponse.cart.forEach(function(cartItem) {
                    if(item.fields.id == cartItem.id && cartItem.fields.qty != 0) totalQuantity += Number(cartItem.fields.qty);
                });
            }
        });

        component.set('v.totalQuantity', totalQuantity);

        if(totalQuantity < component.get('v.b2winCurrentBundleElement').fields.minqty) showButton = false;

        this.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageRetrieveItemsFromBundleElement', {}, showButton);
        this.createWrapperServices(component, event, helper, component.get('v.b2winResponse'));
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> initializeResponse >> End');
    },

    manageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageB2WResponse >> Start');
        let params = event.getParams();
        helper[params.actionName](component, event, helper, params.actionParams);
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageB2WResponse >> End');
    },

    createWrapperServices : function(component, event, helper, b2winResponse) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> createWrapperServices >> Start');
        let services = [];
        if(b2winResponse != null && b2winResponse.listOfItems != null && b2winResponse.cart != null) {
            b2winResponse.listOfItems.forEach(function(item) {
                /*if(item.fields.visible == 'Y') {
                    services.push(item);                
                } else if(item.fields.eligible == 'N') {
                    b2winResponse.cart.forEach(function(cartItem) {
                        if(item.fields.id == cartItem.fields.id) {
                            item.fields.isCart = true;
                            services.push(item);
                        }
                    });
                    
                }*/
                if(item.fields.visible == 'true') {
                    b2winResponse.cart.forEach(function(cartItem) {
                        if(item.fields.id == cartItem.id) {
                            if(item.fields.qty == 1 && item.fields.maxqty == 1 && item.fields.minqty == 1) {
                                item.fields.isCart = true;
                            } else {
                                item.fields.isAdded = true;
                            } 
                        } 
                    });
                    
                    if(item.fields.ReferenceOneTimeFee != null && item.fields.ReferenceOneTimeFee > item.fields.baseonetimefee) {
                        item.fields.priceToDiscount = item.fields.ReferenceOneTimeFee;
                    } else if(item.fields.Orig_OneTimeFee__c != null && item.fields.Orig_OneTimeFee__c > item.fields.baseonetimefee) {
                        item.fields.priceToDiscount = item.fields.Orig_OneTimeFee__c;
                    } else {
                        item.fields.priceToDiscount = null;
                    }
                    
                    services.push(item);
                }
            });
            component.set('v.services', services);

            if(services.length == 0) {
                helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageRetrieveItemsFromBundleElement', {});
            } else {
                this.fireToggleSpinnerEvent(component, false);
                component.set('v.isInitialized', true);
            }
        }
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> createWrapperServices >> End');
    },

    prepareModal : function(component, serviceId) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> prepareModal >> Start');
        let services = component.get('v.services');
        if(services != null) {
            services.forEach(function(service) {
                if(service.fields.id == serviceId) {
                    component.set('v.serviceSelected', service);
                    component.set('v.showAddCartModal', !component.get('v.showAddCartModal'));
                }
            });
        }
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> prepareModal >> End');
    },

    addToCart : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> addToCart >> Start');
        let totalQuantity = component.get('v.totalQuantity');

        if(totalQuantity >= component.get('v.b2winCurrentBundleElement').fields.maxqty) {
            component.set('v.toastMessage', $A.get("$Label.c.TA_MaxQtyReached"));
            component.set('v.isError', true);
            component.set('v.showToastMessage', true);
            return;
        }

        component.set('v.currentAction', 'add');
        let services = component.get('v.services');
        let showButton = true;

        services.forEach(function(service) {
            if(service.fields.id == component.get('v.serviceSelected').fields.id) {
                service.fields.isAdded = true;
                totalQuantity = totalQuantity + (service.fields.maxqty == 1 ? 1 : service.fields.qty);
            }
        });

        component.set('v.totalQuantity', totalQuantity);
        component.set('v.services', services);

        if(component.get('v.totalQuantity') < component.get('v.b2winCurrentBundleElement').fields.minqty) showButton = false;
        this.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageRetrieveItemsFromBundleElement', {}, showButton);
        this.manageCartStepEvt('TA_LCP226_CartContainer', 'manageAddToCart', component.get('v.serviceSelected'));

        console.log('TA_LCP231_CartServiceCatalog >> Helper >> addToCart >> End');
    },

    removeFromCart : function(component, event) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> removeFromCart >> Start');

        let services = component.get('v.services');
        let b2winResponse = component.get('v.b2winResponse');
        let itemToRemove = null;
        let showButton = true;
        let totalQuantity = component.get('v.totalQuantity');

        services.forEach(function(service) {
            if(service.fields.id == event.currentTarget.id) {
                service.fields.isAdded = false;
                totalQuantity = totalQuantity - (service.fields.maxqty == 1 ? 1 : service.fields.qty);
                service.fields.qty = 0;
                component.set('v.serviceSelected', service);
            }
        });
        component.set('v.totalQuantity', totalQuantity);
        component.set('v.services', services);
        component.set('v.currentAction', 'remove');
        
        b2winResponse.cart.forEach(function(cartItem) {
            if(cartItem.id == event.currentTarget.id) {
                itemToRemove = cartItem;
            }
        });

        if(component.get('v.totalQuantity') < component.get('v.b2winCurrentBundleElement').fields.minqty) showButton = false;

        this.manageCartStepEvt('TA_LCP226_CartContainer', 'manageRemoveFromCart', itemToRemove);    
        this.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageRetrieveItemsFromBundleElement', {}, showButton);

        console.log('TA_LCP231_CartServiceCatalog >> Helper >> removeFromCart >> End');
    },

    addRemoveFromCartResponse : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> addRemoveFromCartResponse >> Start');
        if(component.get('v.services') && component.get('v.services').length && component.get('v.currentAction') == 'add') {
            // let responseCart = event.getParam('actionParams').b2winResponse.cart;
            // component.set('v.b2winResponse', responseCart);
            // responseCart.forEach(function(itemCart) {
            //     if(itemCart.fields.id == component.get('v.serviceSelected').fields.id) {
            //         component.set('v.serviceSelected', itemCart);
            //     }
            // });
            // helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageUpsertItems', component.get('v.serviceSelected'));
            let responseCart = event.getParam('actionParams').b2winResponse.cart;
            responseCart.forEach(function(itemCart) {
                if(itemCart.fields.id == component.get('v.serviceSelected').fields.id) {
                    itemCart.listOfAttributes = component.get("v.serviceSelected").listOfAttributes;
                    helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageUpsertItems', itemCart);
                }
            });
        } else {
            this.fireToggleSpinnerEvent(component, false);
        }
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> addRemoveFromCartResponse >> End');
    },

    manageSaveConfigurationResponse : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageSaveConfigurationResponse >> Start');
        /*if(component.get('v.serviceSelected')) {
            helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageUpsertItems', component.get('v.serviceSelected'));
        } else {
            helper.fireToggleSpinnerEvent(component, false);
            component.set('v.isInitialized', true);
            component.set('v.showAddCartModal', false);
        }*/

        helper.fireToggleSpinnerEvent(component, false);
        component.set('v.isInitialized', true);
        component.set('v.showAddCartModal', false);

        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageSaveConfigurationResponse >> End');
    },

    manageUpsertItemsResponse : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageUpsertItemsResponse >> Start');
        if(component.get('v.serviceSelected')) {
            component.set('v.b2winResponse', event.getParam('actionParams').b2winResponse);
            helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageSaveConfiguration', event.getParam('actionParams').b2winResponse);
        } else {
            helper.fireToggleSpinnerEvent(component, false);
            component.set('v.isInitialized', true);
            component.set('v.showAddCartModal', false);
        }
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageUpsertItemsResponse >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP231_CartServiceCatalog",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> fireToggleSpinnerEvent >> End');
    },

    manageCartStepEvt : function(handlerCmpName, actionName, actionParams, showButton) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageCartStepEvt >> Start');
        let appEvent = $A.get("e.c:TA_LCE226_CartStep");
        appEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'actionName' : actionName,
            'actionParams' : actionParams,
            'showButton' : showButton
        });
        appEvent.fire();
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageCartStepEvt >> End');
    },

    manageQuantity : function(component, action, serviceId) {
        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageQuantity >> Start');
        
        let services = component.get('v.services');
        services.forEach(function(service) {
            if(service.fields.id == serviceId) {
                if(action == 'add') {              
                    service.fields.qty = service.fields.qty + 1;
                } else {
                    if(service.fields.qty > 0) {
                        service.fields.qty = service.fields.qty - 1;
                    }
                }
                if(service.fields.maxqty == service.fields.qty) {
                    service.maxQtyReached = true;
                } else {
                    service.maxQtyReached = false;
                }
            }
        });
        component.set('v.services', services);

        console.log('TA_LCP231_CartServiceCatalog >> Helper >> manageQuantity >> End');
    }
})