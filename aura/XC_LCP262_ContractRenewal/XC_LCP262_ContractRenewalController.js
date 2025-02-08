({
    contractRenewalClick:function(component, event, helper){
        //Set the parent parameter to show next component and hide the current one
        component.set("v.showNext", true);
        component.set("v.showMyself", false);

    }
})