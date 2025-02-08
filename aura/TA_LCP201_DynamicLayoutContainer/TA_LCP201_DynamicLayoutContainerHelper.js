({
    initialize : function(component) {
        console.log('TA_LCP201_DynamicLayoutContainer >> Helper >> initialize >> Start');
        let componentsInitStateList = component.get("v.componentsInitStateList");
        let getConfigurations = component.get('c.getConfigurations');
        getConfigurations.setParams({ 'workOrderId' : component.get('v.recordId')});

        getConfigurations.setCallback(this, function(response) {
            console.log('TA_LCP201_DynamicLayoutContainer >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let configs = response.getReturnValue().sectionWrappers;
                let components = [];

                if(configs != null && configs.length > 0) {
                    configs.forEach(function(config) {
                        let params = {};

                        config.params.forEach(function(param) {
                            params[param.key] = param.value;
                        });

                        components.push(['c:' + config.cmpName, params]);
                        let componentInitState = {
                            "componentName" : config.cmpName,
                            "initState" : false
                        };
                        componentsInitStateList.push(componentInitState);
                    });
                    console.log('TA_LCP201_DynamicLayoutContainer >> Helper >> initializeCallback >> Components: ' + JSON.stringify(componentsInitStateList));

                    component.set("v.componentsInitStateList", componentsInitStateList);
                    $A.createComponents(components, function(newCmp, status, errMsg) {
                        if(status == "SUCCESS") {
                            let body = component.find('dynamicCmp').get('v.body');
                            newCmp.forEach(function(item) {
                                body.push(item);
                            });
                            component.find('dynamicCmp').set('v.body', body);
                        } else if(status == "ERROR") {
                            let errorMsg = '';
                            errMsg.forEach(function(cmpMsg) {
                                if(cmpMsg.status == "ERROR") {
                                    if(errorMsg != '') {
                                        errorMsg += '<br>';
                                    }
                                    errorMsg += cmpMsg.message;
                                }
                            });
                            component.set("v.showToastMessage", true);
                            component.set("v.isError", true);
                            component.set("v.toastMessage", errorMsg);
                        }
                    });
                }

                let generalInfoToButtonSection = $A.get("e.c:TA_LCE201_GeneralInfoToButtonSection");
                generalInfoToButtonSection.setParams({"generalInfoMap": response.getReturnValue().generalInfoMap});
                generalInfoToButtonSection.fire();
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP201_DynamicLayoutContainer >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(getConfigurations);
        console.log('TA_LCP201_DynamicLayoutContainer >> Helper >> initialize >> End');
    },

    catchReceiveInitStateEvt : function(component, event) {
        console.log('TA_LCP201_DynamicLayoutContainer >> Helper >> catchReceiveInitStateEvt >> Start');
        const eventFromComponent = event.getParams();
        let componentsInitStateList = component.get("v.componentsInitStateList");
        let isSpinnerVisible = false;

        for(let i = 0; i < componentsInitStateList.length; i++) {
            if(componentsInitStateList[i].componentName == eventFromComponent.componentName && componentsInitStateList[i].initState != eventFromComponent.initState) {
                componentsInitStateList[i].initState = eventFromComponent.initState;
            }

            if(!componentsInitStateList[i].initState) {
                isSpinnerVisible = true;
            }
        }

        console.log('TA_LCP201_DynamicLayoutContainer >> Helper >> initializeCallback >> Components: ' + JSON.stringify(componentsInitStateList));
        component.set("v.componentsInitStateList", componentsInitStateList);
        setTimeout(function() {
            component.set("v.isSpinnerVisible", isSpinnerVisible);
        }, 500);
        console.log('TA_LCP201_DynamicLayoutContainer >> Helper >> catchReceiveInitStateEvt >> End');
    }
})