({
    init: function (component, event, helper) {
        console.log('init');
        //component.set("v.showSpinner", true);
        helper.init(component, event, helper);
    }
})