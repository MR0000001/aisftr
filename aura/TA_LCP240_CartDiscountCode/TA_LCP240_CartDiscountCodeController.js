({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleInitialize >> Finish');
    },

    handleManageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleManageB2WResponse >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP240_CartDiscountCode') {
            helper.manageB2WResponse(component, event, helper);
        }
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleManageB2WResponse >> End');
    },

    handleGetVoucherCode : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleGetVoucherCode >> Start');
        helper.getVoucherCode(component);
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleGetVoucherCode >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleCloseModal >> Start');
        component.set('v.showVoucherCodeModal', false);
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleCloseModal >> End');
    },

    handleApplyVoucher : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleApplyVoucherButton >> Start');
        helper.manageAddCoupon(component);
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleApplyVoucherButton >> End');
    },

    handleRemoveVoucherCode : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleRemoveVoucherCode >> Start');
        helper.removeVoucherCode(component, event.currentTarget.id);
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleRemoveVoucherCode >> End');
    },

    /*handleApplySubsidy : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleApplySubsidy >> Start');
        helper.applySubsidy(component);
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleApplySubsidy >> End');
    },

    handleRemoveSubsidy : function(component, event, helper) {
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleRemoveSubsidy >> Start');
        helper.removeSubsidy(component);
        console.log('TA_LCP240_CartDiscountStep >> Controller >> handleRemoveSubsidy >> End');
    }*/

})