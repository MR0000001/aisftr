({

    //object structure
    /*
        {
            "sObjectName" : "sobjectName",
            "sectionName" : "sectionName",
            "isSectionValid" : "boolean"
            "fields" : {
                "api_name" : "value"
            }
        }

    */

    fireAMPEvent : function(component,eventData) {
        let ev = component.getEvent("XC_AMP_LCE001_AMPCommunicationEvent");
        ev.setParam("data",eventData);
        ev.fire();
    }
})