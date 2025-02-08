({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.resendSAP(component, event, helper);
		
	},
    
    setCheckboxVal : function(component, event, helper) {                        
        
        var checkBox1 = document.getElementById("visual-picker-76");
        var checkBox2 = document.getElementById("visual-picker-77");
		
        if(checkBox1.checked == true){
            component.set("v.sapSelected", true);
        }else{
            component.set("v.sapSelected", false);
        }
        if(checkBox2.checked == true){
            component.set("v.logisticSelected", true);
        }else{
            component.set("v.logisticSelected", false);
        }
	},
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    
    manageData : function(component, event, helper) {
        if(component.get("v.sobjecttype")=='gii__PurchaseOrder__c' &&  component.get("v.purchaseOrder")!=null && component.get("v.purchaseOrder")!=undefined ){ 
        	console.log('Sobject  = '+JSON.stringify(component.get("v.purchaseOrder")));
            if(component.get("v.purchaseOrder").giic_Status__c == 'Cancelled' ){
               component.set("v.operationType" , 'Cancellation')
            }
        }else if(component.get("v.sobjecttype") == 'gii__PurchaseOrderReceiptStaging__c'){
             component.set("v.operationType" , 'Cancellation')
        }
        
    }
})