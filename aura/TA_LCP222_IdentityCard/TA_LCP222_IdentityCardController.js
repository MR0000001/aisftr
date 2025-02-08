({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP222_IdentityCard >> Helper >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP222_IdentityCard >> Helper >> handleInitialize >> End');
    },

    handleDeletePhoto : function(component, event, helper) {
        console.log('TA_LCP222_IdentityCard >> Helper >> handleDeletePhoto >> Start');
        helper.deletePhoto(component, event.currentTarget.id);
        console.log('TA_LCP222_IdentityCard >> Helper >> handleDeletePhoto >> End');
    },

    handleUploadFile : function(component, event, helper) {
        console.log('TA_LCP222_IdentityCard >> Helper >> handleUploadFile >> Start');
        helper.callDoxee(component, event);
        console.log('TA_LCP222_IdentityCard >> Helper >> handleUploadFile >> End');
    }
})