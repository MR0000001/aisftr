({
	init : function(component, event, helper) {
	    console.log("stringSubDataValues-->"+component.get("v.stringSubDataValues"));
	    console.log("stringDataValues-->"+component.get("v.stringDataValues"));
		//var stringDataValues = component.get("v.stringDataValues");

        //console.log('@#@#@#@ stringDataValues='+stringDataValues);
	},

	saveCommodityObject : function(component, event, helper) {
		let dataValues = component.get("v.stringDataValues");
		let subdataValues = component.get("v.stringSubDataValues");
		let mainTitle = component.get("v.mainTitle");
		let ev = $A.get("e.c:XC_LCE014_SaveSectionValue");
		ev.setParams({"objectType": mainTitle,  "values" : dataValues, "subvalues" : subdataValues });
        ev.fire();
	},

	loadPDF : function(component, event, helper) {
		let dataObj = component.get("v.dataObj");
		console.log("-->> dataObj -->> "+dataObj);
		var cmpEvent = component.getEvent("XC_LCE018_CallReadInvoicePDF");
        cmpEvent.setParams({
            "invoiceStringWrapper" : dataObj });
        cmpEvent.fire();
	}
})