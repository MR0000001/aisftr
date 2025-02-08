({
	doInit : function(component, event, helper) {
		let action = component.get("c.fetchUser");
        
        action.setParams({
            'recordId' : component.get("v.recordId")
        });        
        action.setCallback(this, function(response) {
            let state = response.getState();
			console.log('@state@'+state);
			
            if (state === "SUCCESS") {
                let storeResponse = response.getReturnValue();
                let userInformation = JSON.parse(storeResponse.objectInfo);
                let objectParentId;  //GLOVIA DDT
                if(storeResponse.success){
                    component.set("v.username",userInformation.userName);
                    component.set("v.objectType",userInformation.objectType);
                    objectParentId = userInformation.parentId; //GLOVIA DDT
				}
                console.log('@userInformation.objectType@:'+userInformation.objectType);
                console.log('@objectParentId@:'+objectParentId);
                //Set current user information on userInfo attribute 
                component.set("v.userInfo", storeResponse);
                component.set("v.userInfo.Company", storeResponse.Company__c); 
				let ObjectParent;
                let recordId = component.get("v.recordId");
               	let typeOfObject = component.get("v.objectType") + "_Id";
				              
				let username = component.get("v.username");
				if(typeOfObject == 'NE__Order__c_Id'){
					typeOfObject = 'Configuration_Id';
					 
				}else if(typeOfObject == 'NE__OrderItem__c_Id'){
                    typeOfObject = 'Configuration_item_Id';
                  
					
				}else if(typeOfObject == 'WorkOrder_Id'){
                    typeOfObject = 'Workorder_Id';
                  

				}else if(typeOfObject == 'WorkOrderLineItem_Id'){
					typeOfObject = 'Workorder_lineitem_Id';
                  
				
				}else if(typeOfObject == 'NE__Billing_Profile__c_Id'){
					typeOfObject = 'Billing_profile_Id';
                    
				}else if(typeOfObject == 'gii__PurchaseOrder__c_Id'){
					typeOfObject = 'Purchase_order_Id';
                    
				}else if(typeOfObject == 'gii__PurchaseOrderReceipt__c_Id'){
					typeOfObject = 'PurchaseOrder_receipt_Id';
                    ObjectParent = 'Purchase_order_Id';
                                      
				}else if(typeOfObject == 'gii__TransferOrder__c_Id'){
					typeOfObject = 'Transfer_order_Id';
                   
				}else if(typeOfObject == 'gii__ReturntoSupplier__c_Id'){
					typeOfObject = 'Return_to_vendor_Id';
                    ObjectParent = 'PurchaseOrder_receipt_Id';
                 
				}else if(typeOfObject == 'gii__Shipment__c_Id'){
					typeOfObject = 'Shipment_Id';
                    ObjectParent = 'Transfer_order_Id';
				}    
      
              //comments   
                let jsonString = '{ "User":"'+username+'",'+
                                    '"Country":"'+userInformation.country+'",'+
                                    '"Company":"'+userInformation.company+'",'+
                                    '"'+typeOfObject+'":"'+recordId+'"';
                console.log('@@ first json:' + jsonString);
				// DDT Glovia add parent to Json to retrieve document Parent
                if(objectParentId!='' && objectParentId!=null) {
                    jsonString = jsonString + ',"'+ObjectParent+'":"'+objectParentId+'"}';
                }else {
                	jsonString = jsonString +  '}';
                }

                component.set("v.json", jsonString);
                component.set("v.jsonFull", true);
                console.log('@jsonString@'+jsonString);
                
            } // Success state
        }); //Action
        
        console.log('@ACTION@:doxeeHelper:'+action);
        $A.enqueueAction(action);
	}
})