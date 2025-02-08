({
	checkPaymentPlatform : function( component, event ) {
		component.set("v.mostrarSpinner", true);
		var action = component.get("c.checkIfIsPaymentPlatform");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function( response ) {
            if ( response.getState() === 'SUCCESS' ) {
                console.log('success: ' + JSON.stringify(response.getReturnValue()));
                component.set("v.result", response.getReturnValue());
            } else {
                console.log('else success: ' + response.getReturnValue());
            }
			component.set("v.mostrarSpinner", false);
        });
		$A.enqueueAction( action );
	}
})