({
	showModal : function(component, event) {
        console.log('showModal');
       
	    let toastEvent = $A.get("e.force:showToast");
        if (toastEvent){
        toastEvent.setParams({
            title : 'Success',
            message: 'Address correctly validate',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration: '100',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
        } else {    //toast implementation for a standalone app 
		component.set("v.isOpen", true);
       

    }

    },
    
    closeModel : function(component, event) {
         let windowRedirect = window.location.href;
       	 window.location.href = windowRedirect;
    
    }
		
	
})