({
    doInit : function(component,event,helper) {
        let action = component.get("c.getLogoUrl");
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result){
                    component.set("v.logoUrl",result);
                    component.set("v.showLogo",true);
                }
            }else{
                console.log('ERROR ON INIT LOGO ' + JSON.stringify(response.getError()[0]));
            }
        });
        $A.enqueueAction(action);

    }
})