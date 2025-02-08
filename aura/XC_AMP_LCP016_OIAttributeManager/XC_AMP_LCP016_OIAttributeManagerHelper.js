({
    fireAMPEvent : function(component,eventData) {
        let ev = component.getEvent("XC_AMP_LCE001_AMPCommunicationEvent");
        ev.setParam("data",eventData);
        ev.fire();
    }
})