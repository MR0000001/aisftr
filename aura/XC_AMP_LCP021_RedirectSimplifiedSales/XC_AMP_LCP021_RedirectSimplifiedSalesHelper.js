({
	doInit : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let oppId = component.get('v.recordId');
        if(!oppId || oppId==null || oppId==='') {
            helper.showToast(component,$A.get("$Label.c.XC_CL_Opportunity_NoFound"),'Error',true);
            return;
        }
        let action = component.get("c.evaluateRedirect");
        action.setParams({
            'oppId': oppId
        });
        action.setCallback(this, function (resp) {
            let state = resp.getState();
            if(state === "SUCCESS") {
                let result = resp.getReturnValue();
                if(result.success) {
                    let objData = JSON.parse(result.objectInfo);
					if(!objData.orderId || objData.orderId == null){
                        let opts = {};
                        opts['mode']='edit_simple_flow';
                        $A.createComponent(
                            "c:XC_AMP_LCP002_OrderMainViewBuilder", {
                                "createdAccountId": objData.accountId,
                                "parentOpportunityId": objData.opportunityId,
                                "options": opts
                            },
                            function (newcomponent, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    let body = component.get("v.body");
                                    body.push(newcomponent);
                                    component.set("v.body", body);
                                } else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                } else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                }
                            });
					}else{
						$A.createComponent(
                            "c:XC_AMP_LCP020_SimplifiedSales", {
                                "recordId": objData.opportunityId
                            },
                            function (newcomponent, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    let body = component.get("v.body");
                                    body.push(newcomponent);
                                    component.set("v.body", body);
                                } else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                } else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                }
                            });
					}
				}else{
					helper.showToast(component,result.resultMessage,'Error',true);
					return;
				}
			}
            component.set('v.spinnerControl', false);
		});
        $A.enqueueAction(action);
	},

    showToast : function(component,message,type,destroyCmp){
        component.find('notifLib').showToast({
            "title": message,
            "mode": "pester",
            "variant": type
        });
		if(destroyCmp){
			component.destroy();
		}
        component.set('v.spinnerControl', false);
    }
})