({
    handleCloseToast : function(component, event, helper) {
        console.log('TA_LCP236_ToastMessage >> Controller >> handleCloseToast >> Start');
        component.set('v.showToastMessage', false);
        console.log('showToastMessage = ' + component.get('v.showToastMessage'));
        console.log('TA_LCP236_ToastMessage >> Controller >> handleCloseToast >> End');
    }
})