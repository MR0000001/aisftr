({
    initialize : function(component) {
        console.log('TA_LCP232_CartSummary >> Helper >> initialize >> Start');
        console.log('TA_LCP232_CartSummary >> Helper >> initialize >> Finish');
    },

    refreshCart : function(component, responseCart) {
        console.log('TA_LCP232_CartSummary >> Helper >> refreshCart >> Start');

        let cartItems = [];
        let counter = 0;

        if(responseCart != null) {
            responseCart.cart.forEach(function(cartItem) {
                //if(cartItem.fields.LicCategoryName != 'bundleItem') {
                    if(cartItem.fields.LicCategoryName == 'bundleItem') cartItem.hidden = true;
                    if(cartItem.fields.totalonetimefeeov != cartItem.fields.totalbaseonetimefee) cartItem.isDiscounted = true;
                    
                    cartItem.listOfDiscounts.forEach(function(discount) {
                        if(discount.fields.reason == 'Cupon') cartItem.discountApplied = true;
                    });
                    cartItems.push(cartItem);
                    counter += cartItem.fields.qty;
                //}   
            });
        }
        
        component.set('v.cartItems', cartItems);
        component.set('v.counter', counter);
        component.set('v.totalAmount', responseCart.configuration.NE__One_Time_Fee_Total__c != null ? responseCart.configuration.NE__One_Time_Fee_Total__c : 0);

        console.log('TA_LCP232_CartSummary >> Helper >> refreshCart >> Finish');
    },

    saveAttribute : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Helper >> saveAttribute >> Start');
        let selectedCartItem = component.get("v.selectedCartItem");

        let product;
        let productCode;
        let price;
        let productSubType;
        selectedCartItem.listOfAttributes.forEach(function(attribute) {
            if(attribute.fields.type == 'Dynamic Lookup' && attribute.fields.hidden == 'false') {
                attribute.listOfDomains.forEach(function(domain) {
                    if(domain.Name == attribute.fields.value) {
                        product = domain.XC_ProductCategory__c;
                        productCode = domain.ProductCode;
                        price = domain.XC_Price__c;
                        productSubType = domain.XC_ProductSubType__c;
                    }
                });
            }
        });

        selectedCartItem.listOfAttributes.forEach(function(attribute) {
            if(attribute.fields.LicName == 'Producto') {
                attribute.fields.value = product;
            } else if(attribute.fields.LicName == 'Referencia') {
                attribute.fields.value = productCode;
            } else if(attribute.fields.LicName == 'Precio Endesa') {
                attribute.fields.value = price;
            } else if(attribute.fields.LicName == 'Product Subtype') {
                attribute.fields.value = productSubType;
            }
        });

        if(selectedCartItem) {
            helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageUpsertItems', selectedCartItem, false, true);
        }
        console.log('TA_LCP232_CartSummary >> Helper >> saveAttribute >> End');
    },

    manageCartStepEvt : function(handlerCmpName, actionName, actionParams, showButton, isCartSummary) {
        console.log('TA_LCP232_CartSummary >> Helper >> manageCartStepEvt >> Start');
        let appEvent = $A.get("e.c:TA_LCE226_CartStep");
        appEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'actionName' : actionName,
            'actionParams' : actionParams,
            'showButton' : showButton,
            'isCartSummary' : isCartSummary
        });
        appEvent.fire();
        console.log('TA_LCP232_CartSummary >> Helper >> manageCartStepEvt >> End');
    },

    manageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Helper >> manageB2WResponse >> Start');
        let params = event.getParams();
        helper[params.actionName](component, event, helper, params.actionParams);
        console.log('TA_LCP232_CartSummary >> Helper >> manageB2WResponse >> End');
    },

    manageUpsertItemsResponse : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Helper >> manageUpsertItemsResponse >> Start');
        helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageSaveConfiguration', event.getParam('actionParams').b2winResponse, false, true);
        console.log('TA_LCP232_CartSummary >> Helper >> manageUpsertItemsResponse >> End');
    },

    manageSaveConfigurationResponse : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Helper >> manageSaveConfigurationResponse >> Start');
        component.set('v.isEditAttributeModal', false);
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP232_CartSummary >> Helper >> manageSaveConfigurationResponse >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP232_CartSummary >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP232_CartSummary",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP232_CartSummary >> Helper >> fireToggleSpinnerEvent >> End');
    },

    getDynamicLookupValue : function(component, event, helper, listAttributeDynamicLookup, productName) {
        console.log('TA_LCP232_CartSummary >> Helper >> getDynamicLookupValue >> Start');
        let action = component.get('c.getDynamicLookupValue');
        let cart = component.get('v.cartItems');
        let rType;
        let sType;

        let bundleSubType;
        cart.forEach(function(cartElement) {
            if(cartElement.fields.XC_Product_Type__c == 'Bundle') {
                bundleSubType = cartElement.fields.XC_Product_Subtype__c;
            }
        });

        cart.forEach(function(cartElement) {
            if(cartElement.fields.XC_Product_Type__c != 'Bundle' && cartElement.fields.XC_Product_Subtype__c == bundleSubType) {
                cartElement.listOfAttributes.forEach(function(elementAttribute) {
                    if(elementAttribute.fields.LicName == 'Tipologia PV') {
                        rType = elementAttribute.fields.value;
                    }
                });
            }

            cartElement.listOfFamilies.forEach(function(elementFamily) {
                if(elementFamily.fields.LicName == 'Photovoltaic Structure') {
                    cartElement.listOfAttributes.forEach(function(elementAttribute) {
                        if(elementAttribute.fields.LicName == 'Tipologia tetto') {
                            sType = elementAttribute.fields.value;
                        }
                    });
                }
            });
        });

        //TO DO - Da gestire sType e rType per Photovoltaic
        action.setParams({
            'listAttributeDynamicLookupSerialized' : JSON.stringify(listAttributeDynamicLookup),
            'legalEntity' : component.get("v.workOrder").XC_LegalEntity__c,
            'kType' : productName,
            'rType' : rType,
            'sType' : sType,
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP232_CartSummary >> Helper >> getDynamicLookupValueCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let listOfAttributesDynamicLookup = JSON.parse(response.getReturnValue());
                let mainProductSelected = component.get("v.selectedCartItem");
                listOfAttributesDynamicLookup.forEach(function(attributesDynamicLookup) {
                    mainProductSelected.listOfAttributes.forEach(function(attribute) {
                        if(attributesDynamicLookup.id == attribute.id) {
                            attribute.listOfDomains = attributesDynamicLookup.listOfDomains;
                        }
                    });
                });
                component.set("v.selectedCartItem", mainProductSelected);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP232_CartSummary >> Helper >> getDynamicLookupValueCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP232_CartSummary >> Helper >> getDynamicLookupValue >> End');
    },
})