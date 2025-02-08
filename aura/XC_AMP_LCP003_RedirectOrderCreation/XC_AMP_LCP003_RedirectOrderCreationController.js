({
	init : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},

	onTypeSelect : function(component,event,helper){
		helper.initializeView(component,event,helper);
		let modaltargetext = component.find('ExtModal');
        let backdroptargetext = component.find('Modalbackdrop');
        $A.util.removeClass(modaltargetext, 'slds-fade-in-open');
        $A.util.removeClass(backdroptargetext, 'slds-backdrop--open');
	},

	closeModal : function(component,event,helper){
		let modaltargetext = component.find('ExtModal');
        let backdroptargetext = component.find('Modalbackdrop');
        $A.util.removeClass(modaltargetext, 'slds-fade-in-open');
		$A.util.removeClass(backdroptargetext, 'slds-backdrop--open');
		let currentURL = window.location.href;
		let baseURL = currentURL.substring(0, currentURL.indexOf("/s"));
		window.location.replace(baseURL+"/s");
	}

})