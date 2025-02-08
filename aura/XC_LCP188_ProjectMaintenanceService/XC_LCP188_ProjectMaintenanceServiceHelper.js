({
	 toastError : function(component,message){
            console.log('success');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning!',
                message: message,
                messageTemplate: message,
                duration: '100',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();

        },
     ToastSuccess : function(component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: message,
            messageTemplate: message,
            duration: '100',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    }
})