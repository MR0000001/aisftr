({
    handleInitialize: function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleInitialize >> End');
    },

    handleUploadFile : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleUploadFile >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.uploadFile(component, event, helper);
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleUploadFile >> End');
    },

    handleDeleteFile : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleDeleteFile >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.deleteFile(component, event, helper);
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleDeleteFile >> End');
    },

    handleManageListPhoto : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleManageListPhoto >> Start');
        if(component.get("v.custom").fileCategory == 'SF_TRANSPORT_DOCUMENT' || component.get("v.custom").fileCategory == 'SF_WASTE_IDENTIFICATION_FORM') {
            helper.updateWasteDisposal(component, event, helper);
            /*if(component.get("v.workOrder").XC_WasteDisposal__c == true && component.get("v.listPhotosUrl").length == 0) {
                helper.updateWasteDisposal(component, event, helper, false);
            } else if(component.get("v.workOrder").XC_WasteDisposal__c == false && component.get("v.listPhotosUrl").length > 0) {
                helper.updateWasteDisposal(component, event, helper, true);
            }*/
        }
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleManageListPhoto >> End');
    },

    handleHideComponent : function(component, event, helper){
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleHideComponent >> Start');
        if(component.get("v.custom").fileCategory == 'SF_EXTRA_COST_INVOICE'){           
            if(event.getParam("action") == 'show') {
                component.set("v.isInitialized", true);
                component.set("v.extraCostInvoiceToSend",true);
            }
            if(event.getParam("action") == 'hide'){
             component.set("v.isInitialized", false);
             component.set("v.extraCostInvoiceToSend",false);
            }
            helper.checkExtraCostInvoiceValidation(component, event, helper);

        } 
        //START [20220517AL] - NR2551
        else if(component.get("v.custom").fileCategory == 'SF_PERMITTING_FORM' && 
                event.getParam('params') && 
                event.getParam('params').field == 'XC_PermittingForm__c') {
                    
            if(event.getParam("action") == 'show') {
                component.set("v.isInitialized", true);
                component.set("v.permittingFormRequired", true);
            }

            if(event.getParam("action") == 'hide') {
             component.set("v.isInitialized", false);
             component.set("v.permittingFormRequired", false);
            }

            helper.checkPermittingForm(component);
        }
        //END [20220517AL] - NR2551
        console.log('TA_LCP204_ComponentTakePhoto >> Controller >> handleHideComponent >> End');
    }    
})