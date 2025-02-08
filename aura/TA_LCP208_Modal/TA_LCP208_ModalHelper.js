({
    initialize : function(component) {
        console.log('TA_LCC208_Modal >> Helper >> initialize >> Start');
        let params = component.get('v.params');
        let action = component.get("c.initialize");
        component.set('v.title', $A.getReference('$Label.c.' + params.title))
        component.set('v.description', $A.getReference('$Label.c.' + params.description));

        action.setParams({'phaseName' : params.phaseName,
                            'actionsName' : params.actionsName,
                            'workTypeCategory' : params.workTypeCategory,
                            'country' : params.country
                        });

        action.setCallback(this, function(response) {
            console.log('TA_LCC208_Modal >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.matrixWrappers', response.getReturnValue());
                component.set('v.isSpinnerVisible', false);
                component.set('v.isInitialized', true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                component.set('v.isSpinnerVisible', false);
            }
            console.log('TA_LCC208_Modal >> Helper >> initializeCallback >> End');
        });
        $A.enqueueAction(action);
        console.log('TA_LCC208_Modal >> Helper >> initialize >> End');
    },

    invokeActionButton : function(component, event) {
        console.log('TA_LCC208_Modal >> Helper >> invokeActionButton >> Start');
        let matrixWrappers = component.get('v.matrixWrappers');
        let configs = {};
        let showSpinner = false;

        matrixWrappers.forEach(function(matrixWrp) {
            if(matrixWrp.actionWrp.developerName == event.getSource().get('v.name')) {
                configs = {
                    'actionDeveloperName' : matrixWrp.actionWrp.developerName,
                    'methods' : matrixWrp.methods,
                    'nextPhase' : matrixWrp.nextPhase,
                    'updateNextPhase' : matrixWrp.updateNextPhase,
                    'updateFields' : matrixWrp.updateFields
                }

                if(matrixWrp.actionWrp.type == 'Primary' || matrixWrp.actionWrp.type == 'Secondary') {
                    showSpinner = true;
                }
            }
        });

        if(showSpinner) {
            component.set("v.isSpinnerVisible", true);
        }

        let workOrderEvt = component.getEvent('modalEvt');
        workOrderEvt.setParams({'configs' : configs});
        workOrderEvt.fire();
        console.log('TA_LCC208_Modal >> Helper >> invokeActionButton >> End');
    }
})