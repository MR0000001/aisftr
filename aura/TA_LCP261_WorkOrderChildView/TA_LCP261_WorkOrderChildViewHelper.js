({
	initialize : function(component) {
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> initialize >> Start');

        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        console.log("@@@custom",component.get("v.custom"));
        var getObjWrapper = component.get('c.getObjWrapper');
        getObjWrapper.setParams({
            'workOrderId' : component.get('v.workOrderId'),
            'customFieldSet' : JSON.stringify(component.get('v.custom'))
        });

        getObjWrapper.setCallback(this, function(response) {
            console.log('TA_LCP261_WorkOrderChildView >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {

                this.fireSendInitStateEvt(component, true);

                console.log( JSON.stringify(component.get('v.general')));
                var objWrapper =  response.getReturnValue();

                let allWorkOrderChildCompleted = true;
                //let allWorkOrderChild = objWrapper.woChildQueryList;                

                if(objWrapper.errorMessage){
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", objWrapper.errorMessage);
                } else {

                    if(!objWrapper.readOnly && objWrapper.workOrderChilds){
                        //console.log('allWorkOrderChild: ' + allWorkOrderChild.length);                
                        objWrapper.workOrderChilds.forEach(function(workOrderChild) {
                            console.log('workOrderChild.status: ' + workOrderChild.status);
                            if(workOrderChild.status != 'Completed') {
                                allWorkOrderChildCompleted = false;
                            }
                            if(workOrderChild.workOrderSecondary.length > 0){
                                workOrderChild.workOrderSecondary.forEach(function(workOrderChildSec) {
                                    if(workOrderChildSec.status != 'Completed') {
                                        allWorkOrderChildCompleted = false;
                                    }                                                                 
                                });
                            }                    
                        });
                        console.log('allWorkOrderChildCompleted: ' + allWorkOrderChildCompleted);
                        if(allWorkOrderChildCompleted) this.fireValidationEvt(component, [], 'TA_LCP261_WorkOrderChildView');
                        else this.fireValidationEvt(component,[$A.get('$Label.c.TA_WorkOrderChildError')],'TA_LCP261_WorkOrderChildView');
                    }                    

                    component.set('v.objWrapper', objWrapper);

                    if(component.get('v.general').titleType == 'default') {
                        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
                    }

                    if(objWrapper.whereCondition) {
                        component.set('v.whereCondition', objWrapper.whereCondition);
                    }

                    if(component.get('v.general').description != null && component.get('v.general').description != '') {
                        component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
                    }

                    component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
                    component.set('v.checkIcon', $A.get('$Resource.TA_Icons') + '/xc-icons/check-white-bgp.svg');
                }
                component.set('v.isInitialized', true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP261_WorkOrderChildView >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(getObjWrapper);
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> initialize >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP261_WorkOrderChildView",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> fireSendInitStateEvt >> End');
    },

    redirectToObject : function(component, event, helper) {
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> redirectToObject >> Start');
        this.fireSendInitStateEvt(component, false);
        let urlPath = '/community/s/workorder/'+event.currentTarget.id;
        let redirectUrl = window.location.protocol + '//' + window.location.hostname + urlPath;
        window.location.href = redirectUrl;
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> redirectToObject >> End');
    },

    fireValidationEvt : function(component, errors, cmpName) {
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> fireValidationEvt >> Start');
        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : cmpName,
            "errors" : errors,
            "validate" : errors.length > 0 ? false : true
        }); 
        validationEvt.fire();
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> fireValidationEvt >> End');
    },

    manageAccordion : function(component,event) {
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> manageAccordion >> Start');
        let name = event.currentTarget.name;
        let woList = component.get("v.objWrapper.workOrderChilds");
        woList.forEach(function(wo) {
            if(wo.workOrderNumber == name) {
                wo.showSecondary = !wo.showSecondary;
            }
        });
        component.set("v.objWrapper.workOrderChilds", woList);
        console.log('TA_LCP261_WorkOrderChildView >> Helper >> manageAccordion >> End');
    }
})