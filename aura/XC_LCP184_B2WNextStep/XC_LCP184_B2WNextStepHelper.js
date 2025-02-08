({
    processNextStep : function(component,event,helper) {
        
        component.set("v.disableNextButton",true);
        component.set("v.showCapexError",false);
        let action = component.get("c.b2wOrderToOrder");
        let params = {recordId : component.get("v.recordId"), rtName : component.get("v.rtSelected")};
        let workspaceAPI = component.find("workspace");
        component.set("v.showSpinner",true);

        action.setParams({paramsMap : params });
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result.success){
                    //check if we are in console navigation
                    if(workspaceAPI){ 
                        workspaceAPI.isConsoleNavigation().then(function(response){
                            if(response){
                                console.log('IS CONSOLE NAVIGATION NEXT STEP:: ' + response);
                                helper.openNewSubtab(component,event,helper,result.resultRecordId);
                            }else{
                                helper.navigateToSobject(component,event,helper,result.resultRecordId);
                            }
                        }).catch(function(error){
                            console.log("ERROR ON WORKSPACE API ON NEXT STEP " + error);
                        });
                    }else{
                        helper.navigateToSobject(component,event,helper,result.resultRecordId);
                    }

                }else{
                    console.log('ERROR ON ORDER TO ORDER NEXT STEP::');
                    // button.set('v.disabled',false);
                    component.set("v.showCapexError",true);
                    component.set("v.showCapexErrorMsg",result.errorMsg);
                }
                component.set("v.showSpinner",false);
            }else{
                let msg = response.getError()[0].message;
                console.log('ERROR ON ORDER TO ORDER NEXT STEP:: ' + msg);
                button.set('v.disabled',false);
            }
        });
        $A.enqueueAction(action);
    },

    openNewSubtab : function(component,event,helper,resultId){
        let workspaceAPI = component.find("workspace");

        workspaceAPI.openTab({
            recordId: resultId,
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                  tabId: response
            }).then(function(tabInfo) {
            console.log("The url for this tab is: " + tabInfo.url);
            });
        })
        .catch(function(error) {
               console.log(error);
        });

    },

    navigateToSobject : function(component,event,helper,resultId){
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({"recordId" : resultId ,"slideDevName" : "details"});
        navEvt.fire();
    },


    doInit : function(component,event,helper){

        let recordId = component.get("v.recordId");
        let action = component.get("c.checkLEBusinessProcess");
        action.setParams({"recordId" : recordId});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                let availableRts = result.availableRTs;
                let autoConvert = result.autoConvert;

                component.set('v.showQuote',availableRts.includes('Quote'));
                component.set("v.autoConvert",autoConvert);

                if(autoConvert){
                    component.set("v.orderSelected",true);
                    component.set("v.rtSelected","Order");
                    helper.processNextStep(component,event,helper);
                }

            }else{
                console.log('ERROR ON INIT LCP184 ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);

    }



})