/**
 * Created by FMARCHEGIA00 on 19/04/2021.
 */
({

    navigate : function(cmp, evt, helper) {

        console.log('hai cliccato');
        var action = cmp.get("c.getAnonymousIdFromCustomSetting");
        console.log('hai cliccato2');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId:  response.getReturnValue(),
                        objectApiName: 'Account',
                        actionName: 'view'
                    }
                };
                var navService = cmp.find("navService");
                navService.navigate(pageReference);
            } else {
                console.log('***error*** ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    }

})