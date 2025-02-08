({
    init: function (component, event, helper) {
        console.log("DOINIT ContactSectionController")
        helper.doInit(component, event, helper);
    },
    /*
        changeDocumentType : function(component, event) {
            let documentType=component.get("v.newSection.DocumentType");
            component.set("v.newSection.DocumentID","");
            if('NIE' != documentType){
                component.set("v.newSection.Expiration",null);
                component.set("v.newSection.Expedition",null);
            }
        }
        */
    sblockDoc: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        if (selectedOptionValue != 'undefined' && selectedOptionValue != '') {
            component.set("v.docCountryOK", false);
        } else {
            component.set("v.docCountryOK", true);
        }
        helper.retrieveDefaultDocumentTypeHelper(component, event, helper);
    },


    checkIfNIE: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        if (selectedOptionValue != 'undefined' && selectedOptionValue === 'NIE') {
            component.set("v.showDate", true);
        } else {
            component.set("v.showDate", false);
        }
        
    },

    onloadContactSec: function(component,event,helper) {
        console.log("ON LOAD");
        //console.log("DOC TYPE : " + component.get('v.newSection.DocumentType'));
        helper.retrieveDefaultDocumentTypeHelper(component,event,helper);
    }

    
})