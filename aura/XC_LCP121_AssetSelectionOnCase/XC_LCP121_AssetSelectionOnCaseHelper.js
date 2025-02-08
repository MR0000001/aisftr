({
	init : function(component, event, helper) {
        component.set("v.showSpinner", true);
        let action = component.get("c.getAssetsByAddress");
		this.getColumn(component, event);
        action.setParams({
            'caseId'      : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS"){
                let res = response.getReturnValue();
                if(res.success) {
                    let selectedRows = res.relatedAssetIds;
                    component.set("v.data", res.assets);
                    component.set("v.selectedRows", selectedRows);
                    component.set("v.countRowSelected", selectedRows.length);
                    component.set("v.showSpinner", false);
                }else{
                    helper.showMessage(component, event, helper, "error", "Warning", res.resultMessage );
                }
            }
        });
        $A.enqueueAction(action); 
	},
    
    getColumn: function (component, event) {
        let column = 
        [{ label: $A.get('$Label.c.XC_CL_Name'), fieldName: 'Name', type: 'text' },
         { label: $A.get('$Label.c.XC_CL_ProductType'), fieldName: 'XC_Product_Type__c', type: 'text' },
         { label: $A.get('$Label.c.XC_CL_ProductSubtype'), fieldName: 'XC_Product_Subtype__c', type: 'text' },
         { label: $A.get('$Label.c.XC_CL_Status'), fieldName: 'Status', type: 'text' }];
        
        component.set("v.columns", column);
    },

	updateSelectedRows : function(component, event, helper) {
		let selectedRows = event.getParam('selectedRows');
		component.set("v.selected", selectedRows);
		component.set("v.countRowSelected", selectedRows.length);
    },
    
    attachSelectedAssets : function(component, event, helper) {
        component.set("v.showSpinner", true);
        let action = component.get("c.attachAssets");
        action.setParams({
            'caseId'        : component.get("v.recordId"),
            'assetToAttach' : component.get("v.selected")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS"){
                let res = response.getReturnValue();
                if(res.success) {
                    helper.showMessage(component, event, helper, "success", "Success", res.resultMessage );
                    component.set("v.showSpinner", false);
                }else{
                    helper.showMessage(component, event, helper, "error", "Error", res.resultMessage );
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    goBack: function (component, event, helper) {
        if(component.get("v.isCommunity")){
            var windowRedirect = window.location.href;
            window.location.href = windowRedirect; 
        }else{
            //lancio evento per il close della finestra
            var ev = $A.get("e.c:XC_LCE015_ModalClosed");
            if(ev){
                ev.setParams({"modalName": $A.get("$Label.c.XC_CL_AssetsAttachClosedEvent")});
                ev.fire();
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    },

    showMessage : function(component, event, helper, variante, title, message){
        component.find('notifLib').showToast({
            "variant": variante,
            "header": title,
            "message": message
        });
        helper.goBack(component, event, helper);
    }

	/*showMessage: function(component, event, helper, message, type){
        component.set("v.showSpinner" , false);
        if(type === 'success'){
            type = 'info';
        }
        component.find('notifLib').showNotice({
            "header": message,
            "message": '',
            "variant": type
        }); 
    	
        var fromOrder = component.get("v.fromOrderComponent");
        if(!fromOrder){
			setTimeout(function(){
				$A.get("e.force:closeQuickAction").fire();
			}, 3000); 
			
			setTimeout(function(){
				$A.get("e.force:closeQuickAction").fire();
			}, 2000); 
        }
    }*/
})