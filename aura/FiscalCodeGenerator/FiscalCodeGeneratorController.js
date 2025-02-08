({
    /* doInit : function(component, event, helper) {
        setTimeout(
            $A.getCallback(() => component.find('fcLwc').generateFiscalCode(component.get("v.recordId")))
        );
        $A.get("e.force:closeQuickAction").fire();
    }*/

    handleCloseQuickAction: function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    }
})