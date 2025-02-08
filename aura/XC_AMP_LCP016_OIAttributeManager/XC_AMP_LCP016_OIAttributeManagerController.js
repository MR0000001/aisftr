({
    onChangeAttribute : function(component, event, helper) {

        let changedPfpId = event.getSource().get('v.name');
        let actualValue = event.getParam("value");
        console.log('SELECTED PFP_ID: ' + changedPfpId);
        console.log('ACTUAL ATTRIBUTE CONFIGURATION ' + JSON.stringify(component.get("v.attributes")));

        let evtData = {
            type : "CHANGED_ATTRIBUTE",
            attrData : {
                pfpId : changedPfpId,
                value : actualValue,
                itemCode : component.get("v.itemCode")
            }
        };

        helper.fireAMPEvent(component,evtData);

    }
})