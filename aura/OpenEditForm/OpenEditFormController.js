/**
 * Created by RGAROFALO00 on 28/05/2020.
 */
({
    invoke: function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.recordId") 
        });
       /* var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();*/
        editRecordEvent.fire();

    }
})