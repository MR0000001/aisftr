({
       fetchData : function(component, event, helper) {    
           console.log('@@@@ Load Addresses:' + component.get('v.recordId'));
        	let action = component.get("c.searchAddressSupplier");
     		action.setParams({ "poId": component.get("v.recordId")
                         });
        	console.log('@@@@ call method');   
            console.log('@@@@ result check');

        	action.setCallback(this, function (response) {
              
            	let state = response.getState();
            	var retValue = response.getReturnValue();
            	console.log('@@@@ result check: ' + state + ' - retValue.Success:' + retValue.success);
            	if (state === "SUCCESS" && retValue.success) {
                    console.log('@@@@ result check: ' + state + ' - retValue.Success:' + retValue.success);
                    component.set("v.supplierName", retValue.fieldName);
                    console.log('@@@ suppliername:' + component.get("v.supplierName"));
                   	var rows =  JSON.parse(retValue.objectInfo);
                    console.log('@@@@ rowses:' + JSON.stringify(rows));
                    console.log('@@@@ rows.lenght:' + rows.lenght);
                    for (var i = 0; i < rows.length; i++) {
                     
                    	var row = rows[i];
                        console.log('@@@@ dentro for');
                       
                        row.FullAddress = row.XC_FullAddress__c;
                        	console.log('@@@@ dentro for2');

                        row.PostalCode = row.XC_PostalCode__c;
                        	console.log('@@@@ dentro for3');
                        
                        row.City = row.XC_City__c;
                        	console.log('@@@@ dentro for3');

                        row.Province = row.XC_AddressProvince__c;
                        	console.log('@@@@ dentro for4');

                        row.Country = row.XC_AddressCountry__c;
                        console.log('@@@@ dentro for5:' + row.Country);

                        
                                             
                 }     
                 component.set("v.data", rows);
           
            }else{
                  helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                  $A.get("e.force:closeQuickAction").fire();
            }
            
        });       
       $A.enqueueAction(action);   
       
        
    },
    
    getColumn : function (component, event, helper) {
        console.log('@@@ load colum');
        var column = [{ label: 'FULL ADDRESS', fieldName: 'FullAddress', type: 'text' },
                      { label: 'POSTAL CODE', fieldName: 'PostalCode', type: 'text' },
                      { label: 'CITY', fieldName: 'City', type: 'text' },
                      { label: 'PROVINCE', fieldName: 'Province', type: 'text' },
                      { label: 'COUNTRY', fieldName: 'Country', type: 'text' }
                     ];
        component.set("v.columns", column);
    },
    

    showToast : function(component, event, helper, message, type) {
        
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },
    
    SelectionRowAddress : function(component, event, helper){
       		
        	var selectedRows = event.getParam('selectedRows'); 
        	var setRows = [];
        	component.set("v.currentAddrSelected", selectedRows[0]);
        	for (var i = 0; i < selectedRows.length; i++) {
            	setRows.push(selectedRows[i].Id);
            	component.set('v.addressId',selectedRows[i].Id );
                console.log('@@@@ selected row.:' + component.get('v.addressId'));
        	}
         console.log('@@@@ size line selected:' + selectedRows.length);
         component.set("v.countSelectedRow", selectedRows.length);
         component.set("v.AddressLineList", setRows);
         console.log("@@@@ List Address Line check:" + component.get("v.AddressLineList"));
    },
    
    upgradeAddressOnPO : function (component, event, helper){
        console.log('@@@ upgradeAddressOnPO');
        component.set("v.showSpinner" , true);
        //component.set('v.addressId',JSON.Parse(component.get("v.AddressLineList")));
        console.log('@@@ addressId in attribute:' + component.get('v.addressId'));
         var typeMessageToast ;
         var messageToast;
          if($A.util.isEmpty(component.get('v.addressId'))){ 
                messageToast ='No Address Line selected!';
                typeMessageToast='error';
                helper.showToast(component, event, helper, messageToast, typeMessageToast);
                component.set("v.showSpinner" , false);
                $A.get("e.force:closeQuickAction").fire();
            
           }else{
                console.log('@@@@ Address selected:' + component.get('v.addressId'));
                component.set("v.showSpinner", true);
                
                let action = component.get("c.saveAddressOnPo");
                action.setParams({ 
                            "poId": component.get("v.recordId"),
                            "addressId" : component.get("v.addressId"),
                                          		
                });
                console.log('@@@@ after parameter');
                action.setCallback(this, function (response) {
              	    let state = response.getState();
            		var retValue = response.getReturnValue();
            		console.log('@@@@ result check: ' + state + ' - retValue.Success:' + retValue.success);
            		if (state === "SUCCESS" && retValue.success) {
                         $A.get('e.force:refreshView').fire();
                        helper.showToast(component, event, helper, retValue.resultMessage , 'success');
                  		$A.get("e.force:closeQuickAction").fire();    
                    }else {
                             
                    }
                }); 
                $A.enqueueAction(action);   
           } 
           //$A.get('e.force:refreshView').fire();
               
    }                           
	 

});