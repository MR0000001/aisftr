({
	
	doInit : function(component, event, helper) {
		/*component.set('v.spinnerControl',true);
		let action = component.get("c.callCommodityInvoice");
		action.setParams({
            'recordId': component.get('v.recordId'),
            'sobjectType': component.get('v.sobjecttype')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var responseResult = response.getReturnValue();*/
        
        let country = component.get('v.accountDocCountry');
        component.set('v.showPDFSection', (country === 'Spain'));
        
        let commodityGlobalMessage = component.get("v.commodityGlobalMessage");
        if(commodityGlobalMessage){
            helper.showToast(component, commodityGlobalMessage, 'error');
            return;
        }

        var responseResult = component.get('v.invoiceCommodityObj');
        console.log('@@@ v.invoiceCommodityObj' + JSON.stringify(responseResult))
        if(responseResult && responseResult.success && responseResult.sections){
            /*let sections = responseResult.sections;
            if(sections !== null){*/
                //Sezione Invoice
            let invSection = responseResult.sections['Invoice'];
            if(invSection && invSection.objectsRecordFields){
                for(let index in invSection.objectsRecordFields){
                    helper.createSectionFields(invSection.objectsRecordFields[index], component);
                }
                helper.createSectionComponentWithObj(component, helper, $A.get("$Label.c.XC_CL_Invoice"), invSection.dataObjects);
            } else {
                helper.showToast(component, responseResult.resultMessage, 'error');
            }
            //}
        }/* else {
            helper.showToast(component, $A.get("$Label.c.XC_CL_NoInvoiceForDoc"), 'error');
        } */
            /*}
            setTimeout(function(){ component.set('v.spinnerControl',false); }, 2000);
        });
        $A.enqueueAction(action);*/
    },
    
    handleCallReadInvoicePDF : function(component, event, helper) {
		component.set('v.spinnerControl',true);
		let dataObj = event.getParam("invoiceStringWrapper");
		let action = component.get("c.callReadInvoicePDF");
		let country = component.get("v.accountDocCountry");
		action.setParams({
            'invoiceDataObj': dataObj,
            'country'       : country
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var responseResult = response.getReturnValue();
                console.log('@@@ CallReadInvoicePDF resp=' + responseResult);
                if(responseResult.success){
                    component.set('v.PDFData', responseResult.objectResult);
                    component.set('v.BaseURL', responseResult.resultMessage);
                    component.set('v.loadPdf', true);

                    helper.navigateToPDF(component, event, helper);
                    //helper.loadPDF(component, event, helper);
                }else{
                    helper.showToast(component, $A.get("$Label.c.XC_CL_RetrievingPdfErrorMess"), 'error'); // responseResult.resultMessage
                }
            }
            component.set('v.spinnerControl',false);
        });
        $A.enqueueAction(action);
    },

    /*loadPDF: function (component, event, helper) {
    
        if(isCommunity){
            component.set('v.urlPDFGenerator', sitePrefix+'/apex/NE__NextStepPage?Id=' + recordId);
        }
        else{
            component.set('v.urlPDFGenerator', '/apex/NE__NextStepPage?Id=' + recordId);  
        }
        component.set('v.loadPdf',true);
    },*/
    
    navigateToPDF: function (component, event, helper) {
        let url = 'data:application/octet-stream;base64,' + component.get("v.PDFData");
        //var url = 'data:application/pdf;base64,' + component.get("v.PDFData");
        /*let urlEvent = $A.get('e.force:navigateToURL');

        console.log('url');
        console.log(url);
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();*/

        /*let navService = component.find("navService");
        let pageReference =
        {
            "type": "standard__webPage",
            "attributes": {
                "url": url,
                "download": 'Invoice.PDF'
            }
        }
        navService.navigate(pageReference);*/


        let a = document.createElement("a");
        a.href = url;
        a.download = "InvoiceDocument.PDF";
        a.click();

        /*
        let navService = component.find("navService");
        let workspaceAPI = component.find("workspace");
        let oldTabId;
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            oldTabId = response.tabId;
        });
        let pageReference =
        {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__XC_LCP176_PDFGenerator"
            },
            "state": {
                "c__PDFdata": component.get("v.PDFData")
            }
        }
        navService.navigate(pageReference);*/
    }
})