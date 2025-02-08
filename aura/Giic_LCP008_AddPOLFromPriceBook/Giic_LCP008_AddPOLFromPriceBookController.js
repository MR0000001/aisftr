({
	createURL : function(component, event, helper) {
        var url = window.location.href;
        var finalUrl = url.substr(0, url.indexOf('.')); 
        
        component.set("v.completeURL", finalUrl+"--gii.visualforce.com/apex/AddPurchaseOrderLines?scontrolCaching=1&id="+component.get("v.recordId"));
	
		//component.set("v.completeURL", "https://enelx-ci--exdev1--gii.visualforce.com/apex/AddPurchaseOrderLines?scontrolCaching=1&id="+component.get("v.recordId"));
	}
})