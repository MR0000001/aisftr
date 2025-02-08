({
	initSiteUrl : function(component, event,helper) {
        let url = 'https://enelsud--enelx--c.cs106.visual.force.com/apex/TestZuoraPage?accountId='+ component.get('v.recordId') + 
            '&paymentMethodType=CreditCard&entityName=Enel+Spain+B2C';
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": url });
        urlEvent.fire();
	}
})