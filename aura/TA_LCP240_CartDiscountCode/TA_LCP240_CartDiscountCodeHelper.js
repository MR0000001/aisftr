({
    initialize : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> initialize >> Start');
        //this.getSubsidies(component);
        component.set('v.totalCartAmount', component.get('v.cartContext').configuration.NE__One_Time_Fee_Total__c);
        component.set('v.b2winResponse', component.get('v.cartContext'));

        let b2winResponse = component.get('v.b2winResponse');
        let appliedVouchers = [];

        if(b2winResponse.cart != null && b2winResponse.cart.length > 0) {
            b2winResponse.cart.forEach(function(cartItem) {
                if(cartItem.fields.LicProductName == 'Cupon') {
                    cartItem.listOfAttributes.forEach(function(attr) {
                        if(attr.fields.LicName == 'Coupon code') {
                            cartItem.XC_VoucherCode__c = attr.fields.value;
                        } else if(attr.fields.LicName == 'Discount Value') {
                            cartItem.XC_Amount__c = attr.fields.value;
                        } else if(attr.fields.LicName == 'Coupon type') {
                            cartItem.XC_Type_of_Discount__c = attr.fields.value;
                        }
                    });
                    appliedVouchers.push(cartItem);
                }
            })
        }
        component.set('v.appliedVouchers', appliedVouchers);
        component.set('v.isInitialized', true);

        this.manageCartStepEvt('TA_LCP226_CartContainer', 'refreshCartSummary', null, null);
        this.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP240_CartDiscountCode >> Helper >> initialize >> End');
    },

    manageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageB2WResponse >> Start');
        let params = event.getParams();
        helper[params.actionName](component, event, helper, params.actionParams);
        component.set('v.workOrder', params.actionParams.workOrder);
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageB2WResponse >> End');
    },

    /*getSubsidies : function(component) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> getSubsidies >> Start');
        let _helper = this;
        let getSubsidies = component.get("c.getSubsidies");
        getSubsidies.setParams({
            'workOrderId' : component.get('v.workOrderId'),
        });

        getSubsidies.setCallback(this, function(response) {
            console.log('TA_LCP240_CartDiscountCode >> Helper >> getSubsidies >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
                    component.set('v.subsidies', response.getReturnValue());
                } else {
                    component.set('v.subsidies', []);
                }
                component.set('v.totalCartAmount', component.get('v.cartContext').configuration.NE__One_Time_Fee_Total__c);
                component.set('v.b2winResponse', component.get('v.cartContext'));

                let b2winResponse = component.get('v.b2winResponse');
                let appliedVouchers = [];

                if(b2winResponse.cart != null && b2winResponse.cart.length > 0) {
                    b2winResponse.cart.forEach(function(cartItem) {
                        if(cartItem.fields.LicProductName == 'Cupon') {
                            cartItem.listOfAttributes.forEach(function(attr) {
                                if(attr.fields.LicName == 'Coupon code') {
                                    cartItem.XC_VoucherCode__c = attr.fields.value;
                                } else if(attr.fields.LicName == 'Discount Value') {
                                    cartItem.XC_Amount__c = attr.fields.value;
                                }
                            });
                            appliedVouchers.push(cartItem);
                        }
                    })
                }
                component.set('v.appliedVouchers', appliedVouchers);
                component.set('v.isInitialized', true);

                _helper.manageCartStepEvt('TA_LCP226_CartContainer', 'refreshCartSummary', null, null);
                _helper.fireToggleSpinnerEvent(component, false);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP240_CartDiscountCode >> Helper >> getSubsidies >> End');
        });
        
        _helper.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(getSubsidies);
        console.log('TA_LCP240_CartDiscountCode >> Helper >> getSubsidy >> End');
    },*/

    getVoucherCode : function(component) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> getVoucherCode >> Start');

        let _helper = this;
        let getVoucherCode = component.get("c.getVoucherCode");
        getVoucherCode.setParams({
            'voucherCode' : component.get('v.voucherCode'),
            'catalogId' : component.get('v.b2winResponse').configuration.NE__CatalogId__c
        });

        getVoucherCode.setCallback(this, function(response) {
            console.log('TA_LCP240_CartDiscountCode >> Helper >> getVoucherCode >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
                    component.set('v.selectedVoucher', JSON.parse(response.getReturnValue()));
                    component.set('v.isVoucherCodeFound', true);
                    component.set('v.showVoucherCodeModal', true);
                } else {
                    component.set('v.isVoucherCodeFound', false);
                    component.set('v.showVoucherCodeModal', true);
                }
                _helper.fireToggleSpinnerEvent(component, false);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP240_CartDiscountCode >> Helper >> getVoucherCode >> End');
        });
        
        _helper.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(getVoucherCode);
        console.log('TA_LCP240_CartDiscountCode >> Helper >> getVoucherCode >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP240_CartDiscountCode",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP240_CartDiscountCode >> Helper >> fireToggleSpinnerEvent >> End');
    },

    manageAddCoupon : function(component) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageAddCoupon >> Start');
        
        let cartContext = component.get('v.b2winResponse');
        let _helper = this;
        let categorySelected = null;
        cartContext.listOfCategories.forEach(function(category) {
            if(category.categoryFields.LicName == 'Coupon') categorySelected = category;
        });

        if(categorySelected != null) {
          _helper.fireToggleSpinnerEvent(component, true);  
          _helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageAddCoupon', categorySelected, true);
        } else {
            component.set('v.showVoucherCodeModal', false);
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", $A.get('$Label.c.TA_NoCategoryCouponFound'));
        }

        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageAddCoupon >> End');
    },

    manageAddCouponResponse : function(component, event, helper, parameters) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageAddCouponResponse >> Start');

        component.set('v.b2winResponse', parameters.b2winResponse);
        let b2winResponse = component.get('v.b2winResponse');
        let selectedProduct;
        
        b2winResponse.listOfItems.forEach(function(item) {
            if(item.fields.LicProductName == 'Cupon') selectedProduct = item;
        });

        if(selectedProduct != null) {
            component.set('v.selectedProduct', selectedProduct);
            component.set('v.currentAction', 'add');
            this.fireToggleSpinnerEvent(component, true);  
            this.manageCartStepEvt('TA_LCP226_CartContainer', 'manageAddToCart', selectedProduct, true);
        }

        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageAddCouponResponse >> End');
    },

    addRemoveFromCartResponse : function(component, event, helper, parameters) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> addRemoveFromCartResponse >> Start');

        let b2winResponse = parameters.b2winResponse;
        component.set('v.totalCartAmount', b2winResponse.configuration.NE__One_Time_Fee_Total__c);
        component.set('v.b2winResponse', b2winResponse);

        if(component.get('v.currentAction') == 'add') {
            
            let newAttributes = [];
            let appliedVouchers = component.get('v.appliedVouchers');
            let selectedProduct = component.get('v.selectedProduct');
            let itemToUpdate = null;
            
            b2winResponse.cart.forEach(function(cartItem) {
                if(cartItem.fields.id == selectedProduct.fields.id) {
                    cartItem.listOfAttributes.forEach(function(attr) {
                        if(attr.fields.LicName == 'Coupon code' && attr.fields.value == '') itemToUpdate = cartItem;
                    });
                }
            });

            if(itemToUpdate != null) {
                itemToUpdate.listOfAttributes.forEach(function(attribute) {
                    let newAttribute = {fields : {}};
                    if(attribute.fields.LicName == 'Coupon code') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_VoucherCode__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Codigo cupon';
        
                    } else if(attribute.fields.LicName == 'Coupon selected') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_VoucherCode__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Cupon seleccionado';
                        
                    } else if(attribute.fields.LicName == 'Coupon type') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_Type_of_Discount__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Tipo Cupon';
        
                    } else if(attribute.fields.LicName == 'Objective') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').Name;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Objetivo';
        
                    } else if(attribute.fields.LicName == 'Discount Value') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_Amount__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Valor descuento';
        
                    } else if(attribute.fields.LicName == 'Discount Type') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_Voucher_To_Be_Created__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Tipo descuento';
        
                    } else if(attribute.fields.LicName == 'Coupon Category') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_ProductCategory__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Coupon Category';
        
                    } else if(attribute.fields.LicName == 'Coupon Payment Model') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_Billing_Model__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Coupon Payment Model';
        
                    } else if(attribute.fields.LicName == 'Coupon Catalog Item') {
                        newAttribute.fields.value = ''
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Coupon Catalog Item';
        
                    } else if(attribute.fields.LicName == 'Coupon Start Date') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_StartDate__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Coupon Start Date';
        
                    } else if(attribute.fields.LicName == 'Coupon End Date') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_EndDate__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Coupon End Date';
        
                    } else if(attribute.fields.LicName == 'Territory') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_Territories__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Territory';
        
                    } else if(attribute.fields.LicName == 'Number of quotas') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_NumberOfQuotas__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Number of quotas';

                    } else if(attribute.fields.LicName == 'Amount Count') {
                        newAttribute.fields.value = component.get('v.selectedVoucher').XC_Amount__c;
                        newAttribute.fields.pfpId = attribute.fields.pfpId;
                        newAttribute.fields.attributeCode = 'Detalles cupon:Amount Count';
                    }
        
                    if(newAttribute.fields.pfpId != null) newAttributes.push(newAttribute);
                });
            }
            
            if(newAttributes.length > 0) {
                itemToUpdate.listOfAttributes = newAttributes;
                
                this.fireToggleSpinnerEvent(component, true);  
                this.manageCartStepEvt('TA_LCP226_CartContainer', 'manageUpsertItems', itemToUpdate, true);
    
                selectedProduct.XC_VoucherCode__c = component.get('v.selectedVoucher').XC_VoucherCode__c;
                selectedProduct.XC_Amount__c = component.get('v.selectedVoucher').XC_Amount__c;
                selectedProduct.Name = component.get('v.selectedVoucher').Name;
                selectedProduct.XC_Type_of_Discount__c = component.get('v.selectedVoucher').XC_Type_of_Discount__c;
                appliedVouchers.push(selectedProduct);
                component.set('v.appliedVouchers', appliedVouchers);
            } else {
                this.fireToggleSpinnerEvent(component, false); 
            }
        } else {
            this.fireToggleSpinnerEvent(component, false);  
        }

        console.log('TA_LCP240_CartDiscountCode >> Helper >> addRemoveFromCartResponse >> End');
    },

    manageUpsertItemsResponse : function(component, event, helper, parameters) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageUpsertItemsResponse >> Start');
        let b2winResponse = parameters.b2winResponse;
        b2winResponse.configuration.cartLocked = false;
        component.set('v.b2winResponse', b2winResponse);
        this.manageCartStepEvt('TA_LCP226_CartContainer', 'manageSaveConfiguration', b2winResponse, true);
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageUpsertItemsResponse >> End');
    },

    manageSaveConfigurationResponse : function(component, event, helper, parameters) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageSaveConfigurationResponse >> Start');
        component.set('v.b2winResponse', parameters.b2winResponse);
        component.set('v.totalCartAmount', parameters.b2winResponse.configuration.NE__One_Time_Fee_Total__c);
        component.set('v.showVoucherCodeModal', false);
        component.set('v.voucherCode', null);
        this.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageSaveConfigurationResponse >> End');
    },

    manageCartStepEvt : function(handlerCmpName, actionName, actionParams, showButton) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageCartStepEvt >> Start');
        let appEvent = $A.get("e.c:TA_LCE226_CartStep");
        appEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'actionName' : actionName,
            'actionParams' : actionParams,
            'showButton' : showButton
        });
        appEvent.fire();
        console.log('TA_LCP240_CartDiscountCode >> Helper >> manageCartStepEvt >> End');
    },

    removeVoucherCode : function(component, selectedVoucherId) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> removeVoucherCode >> Start');
        
        let b2winResponse = component.get('v.b2winResponse');
        let appliedVouchers = component.get('v.appliedVouchers');
        let _helper = this;
        let productToRemove = null;

        b2winResponse.cart.forEach(function(cartElement) {
            if(cartElement.fields.id == selectedVoucherId) {
                productToRemove = cartElement;
            }
        })

        for(let i = 0; i < appliedVouchers.length; i++) {
            if(appliedVouchers[i].fields.id == selectedVoucherId) {
                appliedVouchers.splice(i, 1);
            }
        }
        component.set('v.appliedVouchers', appliedVouchers);
        component.set('v.totalCartAmount', b2winResponse.configuration.NE__One_Time_Fee_Total__c);

        if(productToRemove != null) {
            _helper.fireToggleSpinnerEvent(component, true);
            component.set('v.currentAction', 'remove');
            _helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageRemoveFromCart', productToRemove);
        }
        console.log('TA_LCP240_CartDiscountCode >> Helper >> managremoveVoucherCodeeCartStepEvt >> End');
    },

    /*applySubsidy : function(component) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> applySubsidy >> Start');
        console.log('TA_LCP240_CartDiscountCode >> Helper >> applySubsidy >> End');
    },

    removeSubsidy : function(component) {
        console.log('TA_LCP240_CartDiscountCode >> Helper >> removeSubsidy >> Start');
        console.log('TA_LCP240_CartDiscountCode >> Helper >> removeSubsidy >> End');
    }*/
})