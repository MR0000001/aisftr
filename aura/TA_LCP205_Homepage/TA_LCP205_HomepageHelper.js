({
    initialize : function(component) {
        console.log('TA_LCP205_Homepage >> Helper >> initialize >> Start');
        let _helper = this;
        _helper.setAccountListView(component);
        setTimeout(function() {component.set('v.isSpinnerVisible', false); }, 2000);
        console.log('TA_LCP205_Homepage >> Helper >> initialize >> End');
    },

    closeModal : function(component, event, helper) {
        console.log('TA_LCP205_Homepage >> Helper >> closeModal >> Start');

        let action = event.getParam("action");
        if(action == 'closeModal'){
            component.set("v.showSelectAccountModal", false);
        }

        console.log('TA_LCP205_Homepage >> Helper >> closeModal >> End');
    },

    setAccountListView : function(component){
        console.log('TA_LCP205_HomePage >> Helper >> getAccountListView >> Start');
        let action = component.get('c.getListView');
        action.setParams({
            "objName" : "Account",
            "listViewName" : "All"
        });
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
                    let result = response.getReturnValue();
                    //component.set("v.redirectParamAccount", "account/Account/" +  result);
                    component.set("v.redirectParamAccount", "createnewaccount");
                }
            } else if(response.getState() == "INCOMPLETE" || response.getState() == "ERROR") {
                console.log(JSON.stringify(response.getError()));
            }
        });

        $A.enqueueAction(action);
        console.log('TA_LCP205_HomePage >> Helper >> getAccountListView >> End');
    }
})