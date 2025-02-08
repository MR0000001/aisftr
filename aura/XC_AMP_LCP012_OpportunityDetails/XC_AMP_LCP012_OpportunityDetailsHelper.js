({
    init : function(component,event,helper) {
        let optyFieldsValue = component.get("v.optyRecord");
        console.log('OPTY FIELDS RETRIEVED ' + JSON.stringify(optyFieldsValue));
        component.set("v.spinnerControl",false);
    }
})