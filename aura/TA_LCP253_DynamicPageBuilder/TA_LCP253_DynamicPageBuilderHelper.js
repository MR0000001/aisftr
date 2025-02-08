({
	initialize : function(component) {
		console.log('TA_LCP253_DynamicLPageBuilder >> Helper >> handleInitialize >> Start');
		let pageName = window.document.title;
		console.log(">_> pageName : " + pageName);
		let componentsInitStateList = component.get("v.componentsInitStateList");
		let getPageConfigurations = component.get('c.getPageConfigurations');
        getPageConfigurations.setParams({
			 "pageName" : pageName
		});
		getPageConfigurations.setCallback(this, function(response) {
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
					console.log('TA_LCP253_DynamicLPageBuilder >> Helper >> initializeCallback >> Components: ' + JSON.stringify(componentsInitStateList));
					component.set("v.componentsInitStateList", componentsInitStateList);
					$A.createComponents(components, function(newCmp, status, errMsg) {
                        if(status == "SUCCESS") {
                            let body = component.find('dynamicCmp').get('v.body');
                            newCmp.forEach(function(item) {
                                body.push(item);
                            });
                            component.find('dynamicCmp').set('v.body', body);
                        } else if(status == "ERROR") {
                            component.set("v.showToastMessage", true);
                            component.set("v.isError", true);
                            component.set("v.toastMessage", JSON.stringify(errMsg));
                        }
                    });
				}
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
			// component.set('v.isSpinnerVisible', false);
		});

        $A.enqueueAction(getPageConfigurations);
        console.log('TA_LCP253_DynamicLPageBuilder >> Helper >> handleInitialize >> End');
	}
})