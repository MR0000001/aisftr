({
	  
     init : function(component, event, helper) {
            component.set("v.showSpinner", true);
            let action = component.get("c.getPIinfoAndAllpiqd"); 
            action.setParams({
                'productInventoryId' : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS"){
                    let result = response.getReturnValue();
                    if(result.success){
                        component.set("v.productId",   result.productId); 
                        component.set("v.productName", result.productName); 
                        component.set("v.warehouseId", result.wareHouseId); 
                        component.set("v.warehouseName",result.wareHouseName); 
                        component.set("v.productCode", result.productCode); 
                        component.set("v.SKUCode",     result.SKUCode); 
                 
                        component.set("v.allPiqDetails",  result.piqdList); 
                        component.set("v.filter1", "gii__Warehouse__c = '"+result.wareHouseId+"'");
                        component.set("v.filter2", "gii__Warehouse__c = '"+result.wareHouseId+"' AND gii__Product__c='"+result.productId+"'" );
                        component.set("v.filter3", "gii__Product__c = '"+result.productId+"'" );
                        
                        component.set("v.isReady1" , true);
                        component.set("v.isReady2" , true);
                         
                        component.set("v.showDataTable", true);
                        component.set("v.showSpinner", false); 

                    }
                }
              
            });
            $A.enqueueAction(action);
         

        
    },
    
    
    requeryData : function(component, event, helper) {
            component.set("v.showSpinner", true);
            let action = component.get("c.getPiqdFiltered"); 
            var locationValue = component.get("v.locationSearchSelectedValue");
            var productSerialValue = component.get("v.productSerialSearchSelectedValue");
            var lotValue = component.get("v.productLOTSearchSelectedValue");
            if(locationValue==''){
            	locationValue = null;
        	}
            if(productSerialValue==''){
            	productSerialValue = null;
        	}
            if(lotValue==''){
            	lotValue = null;
        	}
        
            action.setParams({
                'productInventoryId' : component.get("v.recordId"),
                'locationValue' : locationValue,
                'productSerialValue' : productSerialValue,
                'lotValue' : lotValue,
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS"){
                    let result = response.getReturnValue();
                    component.set("v.allPiqDetails",  result); 
                }else{
                    
                }
                 component.set("v.showSpinner", false);
 			   });
            $A.enqueueAction(action);
    }

         
         
     
    
})