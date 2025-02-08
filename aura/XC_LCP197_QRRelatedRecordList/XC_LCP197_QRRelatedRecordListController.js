({
    doInit : function(component, event, helper) {

        let action = component.get("c.getQRRelatedRecords");
        action.setParams({recordId : component.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                component.set("v.showCmp",result.showComponent);
                component.set("v.records",result.records);
            }else{
                console.log('ERROR ON LCP 197 ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);

    }
})