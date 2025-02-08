({
	init : function(component, event, helper) {
        var action = component.get("c.retrivePoInfo");
        action.setParams({
            'recordId': component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue.success) {
                component.set("v.companyCode", retValue.resultMessage);
                if(retValue.typeMessage!=null && retValue.typeMessage!=''){
                     component.set("v.purchasesGroup", retValue.typeMessage);
                }
                var opts = [];
                var opts2 = [];
                var opts3 = [];
                var opts4 = [];
                var purchaseGroup = JSON.parse(retValue.fieldName);
                var purchaseOrganization = JSON.parse(retValue.fieldName5);
                console.log('purchaseOrganization = '+purchaseOrganization);
                var defOfpurchaseGroup = JSON.parse(retValue.fieldName2);
                var defOfpurchaseOrganization = JSON.parse(retValue.fieldName4);
                var purchaseGroupToDefinition = JSON.parse(retValue.objectInfo);
                var purchaseOrgToOrgDefinition = JSON.parse(retValue.fieldName3);
                var prepopolatePurchaseOrganization = retValue.parentObjectGlovia;
                console.log('prepopolatePurchaseOrganization = '+prepopolatePurchaseOrganization);
                var legalEntity = retValue.legalEntity;
                if(legalEntity=='EndesaX'){
                    component.set("v.isForSpain", true);
                    
                }
                if(prepopolatePurchaseOrganization!=null && prepopolatePurchaseOrganization!=''){
                     component.set('v.purchasingOrganization', prepopolatePurchaseOrganization);
                     // helper.savePurchaseOrG(component,event,helper);
                }
                component.set('v.purchaseGroupToDefinition', purchaseGroupToDefinition);
                component.set('v.purchaseOrgToOrgDefinition', purchaseOrgToOrgDefinition);
                
                for (var i = 0; i < purchaseGroup.length; i++) {
                    var def = defOfpurchaseGroup[i];
                    if(def==null){
                        def = '';
                    }
    				opts.push({
      				value: purchaseGroup[i],
      				label: purchaseGroup[i]+' - '+def
    				});
                }
                for (var i = 0; i < purchaseOrganization.length; i++) {
                   
                    		var def = defOfpurchaseOrganization[i];
                    		if(def==null){
                        		def = '';
                    		}
                    if(purchaseOrganization[i]!=null){
    						opts3.push({
      						value: purchaseOrganization[i],
      						label: purchaseOrganization[i]+' - '+def
    						});
                    }
                 
                }
                for (var i = 0; i < defOfpurchaseGroup.length; i++) {
    				opts2.push({
      				value: defOfpurchaseGroup[i],
      				label: defOfpurchaseGroup[i]
    				});
                }
                 for (var i = 0; i < defOfpurchaseOrganization.length; i++) {
    				opts4.push({
      				value: defOfpurchaseOrganization[i],
      				label: defOfpurchaseOrganization[i]
    				});
                }
        		component.set('v.purchasesGroupOptions', opts);
                component.set('v.definitionOfPurchasesGroupOptions', opts2);
                component.set('v.purchasesOrganizationOptions', opts3);
                component.set('v.definitionOfPurchasesOrganizationOptions', opts4);
            }else{
                
                  helper.showToast(component, event, helper, retValue.resultMessage, 'error') ;
            }
             component.set("v.showSpinner", false);
             if(component.get("v.purchasesGroup")!=undefined && component.get("v.purchasingOrganization")!=undefined && component.get("v.purchasingOrganization")!=''){
             	component.set("v.organizationDataOK", false);
        	 }
             }); 
        $A.enqueueAction(action); 
    },
    
     showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },
    
    
    savePG : function(component, event, helper){
          component.set("v.showSpinner", true);
        var action = component.get("c.savePurchaseGroup");
        action.setParams({"poId": component.get("v.recordId"),
                          "purchasesGroup"  : component.get("v.purchasesGroup")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res =   response.getReturnValue();
            if (state === "SUCCESS" && res.success) {
            	 helper.showToast(component, event, helper, 'Group correctly saved!', 'success');
            }else{
                 helper.showToast(component, event, helper, res.resultMessage, 'error');
            }
              component.set("v.showSpinner", false);
        });    
        $A.enqueueAction(action);    
                
	},
    
    savePurchaseOrG : function(component, event, helper){
        component.set("v.showSpinner", true);
        var action = component.get("c.savePurchaseOrganization");
        action.setParams({"poId": component.get("v.recordId"),
                          "purchasingOrganization"  : component.get("v.purchasingOrganization")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res =   response.getReturnValue();
            if (state === "SUCCESS" && res.success) {
            	 helper.showToast(component, event, helper, 'Organization correctly saved!', 'success');
            }else{
                 helper.showToast(component, event, helper, res.resultMessage, 'error');
            }
              component.set("v.showSpinner", false);
        });    
        $A.enqueueAction(action);    
                
	},
    
    
    
   
    
		
	
})