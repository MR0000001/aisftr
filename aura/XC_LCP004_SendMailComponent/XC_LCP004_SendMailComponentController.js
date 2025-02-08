({
    init : function(component, event, helper) {
		helper.doInit(component, event);
	},
    
    
	sendMailMethod : function(component, event, helper) {
		helper.sendMailHelper(component, event);
	},
    
    handleUploadFinished: function (cmp, event) {
        console.log('@@@ uploaded @@@',event.getParam("files"));
        
    }
})