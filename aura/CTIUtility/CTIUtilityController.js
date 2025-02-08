({
    init : function(component, event, helper) {
        var action = component.get("c.getMysterySettings");
        action.setCallback(this, function(response){
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                component.set("v.mysteryActive", response.getReturnValue());
                helper.logToBrowserConsole(component, 'Custom setting mystery Active: ', component.get("v.mysteryActive"));
            }
        });
        $A.enqueueAction(action);

        var postMessageManager = $A.getCallback(function(event) {
            //helper.logToBrowserConsole(component, 'event received: ', event);
            //helper.logToBrowserConsole(component, 'An event has been received with data: ', event.data);

            if (!event) {
                return;
            }
            else {
                if (event.data.messageType === 'navigation') {
                    if (event.data.operation === 'openTab') {
                        if (event.data.objectType === 'component') {

                            var tabIdToClose = event.data.enclosingTab;

                            var PhoneCTI= event.data.PhoneCTI;
                            var finalComp = "c__"+event.data.objectName;
                            var mystery= event.data.mystery;

                            helper.logToBrowserConsole(component, 'event data received: ', event.data);
                            helper.logToBrowserConsole(component, 'of type: ', event.data.messageType, 'having operation: ', event.data.operation, ', object type: ', event.data.objectType, ' and object name: ', event.data.objectName, '. The PhoneCTI value is: ',event.data.PhoneCTI);
                            helper.logToBrowserConsole(component, 'navigation component name: ', finalComp);

                            var pageReference = {
                                type: 'standard__component',
                                attributes: {
                                    componentName: finalComp,
                                },
                                state: {
                                    "c__PhoneCTI": PhoneCTI,
                                    "c__finalComponent": finalComp,
                                    "c__tabToClose" : tabIdToClose,
                                    "c__mystery": mystery,
                                }
                            };
                            component.set("v.pageReference", pageReference);
                            var navService = component.find("navService");
                            var pageReference = component.get("v.pageReference");
                            event.preventDefault();
                            navService.navigate(pageReference);

                        }
                    }
                } 

                else {
                    var mysteryActive = component.get("v.mysteryActive");
                    if (mysteryActive){
                        helper.logToBrowserConsole(component, 'mystery is active, processing the event');
                        var dataToCheck = event.data;
                        console.log('dataToCheck: ', dataToCheck)
                        if (typeof dataToCheck === 'string') {
                            if (dataToCheck.includes('integrationApi')){
                                console.log('mystery is active');
                                helper.logToBrowserConsole(component, 'messageType is integrationApi, analyzing it: ');
                                var callType = helper.getParameterByName(component,event, dataToCheck,'direction');
                                var callLabel = helper.getParameterByName(component,event, dataToCheck,'remoteName');
                                var xdomain_originFrame = helper.getParameterByName(component,event, dataToCheck,'xdomain_originFrame');
                                var xdomain_name = helper.getParameterByName(component,event, dataToCheck,'xdomain_name');
                                var xdomain_targetFrame = helper.getParameterByName(component,event, dataToCheck,'xdomain_targetFrame');
                                var isFirstCall = !(dataToCheck.includes('new'));
                                //helper.logToBrowserConsole(component, 'xdomain_name: ', xdomain_name,' -  xdomain_originFrame: ', xdomain_originFrame, ' - xdomain_targetFrame: ', xdomain_targetFrame, ' - callType: ', callType, ' - callLabel: ', callLabel);
                                console.log('callType: ', callType);
                                console.log('callLabel: ', callLabel);
                                console.log('xdomain_originFrame: ', xdomain_originFrame);
                                console.log('xdomain_name: ', xdomain_name);
                                console.log('xdomain_targetFrame: ', xdomain_targetFrame);
                                if ((xdomain_name === 's:fireEvent')
                                    && (callType === 'Inbound')
                                    && (xdomain_originFrame === 's:sfdcSoftphone')
                                    && (xdomain_targetFrame === 's:sfdc-console')
                                    && (callLabel === 'Anonymous')
                                    && (isFirstCall)
                                ) {
                                    console.log('mystery found');
                                    helper.logToBrowserConsole(component, 'Mystery found');
                                    var pageReference = {
                                        type: 'standard__component',
                                        attributes: {
                                            componentName: "c__SoftphoneNoContact",
                                        },
                                        state: {
                                            "c__mystery": true,
                                        }
                                    };
                                    component.set("v.pageReference", pageReference);
                                    //console.log();
                                    var navService = component.find("navService");
                                    //console.log('navService -> ', navService);
                                    var pageReference = component.get("v.pageReference");
                                    //console.log('pageReference -> ', pageReference);
                                    //console.log('pre navService');
                                    event.preventDefault();
                                    navService.navigate(pageReference);
                                    //console.log('post navService');
                                } else {
                                    console.log('mystery not');
                                    helper.logToBrowserConsole(component, 'Not Mystery');
                                }
                            }
                        }
                    } else {
                        console.log('mystery is not active');
                        helper.logToBrowserConsole(component, 'mystery is not active, ignoring the event');
                    }

                }

            }


        });
        window.addEventListener("message", postMessageManager);
    },
})