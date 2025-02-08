({
     init : function(component, event, helper) {
        component.set("v.showSpinner" , true);
        var spinner = component.find("theSpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
        console.log('Record ID:::'+component.get("v.recordId"));
        var action = component.get("c.fetchTOAndToLineData");
        action.setParams({ idTO : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                var spinner = component.find("theSpinner");
                $A.util.removeClass(spinner, "slds-show");
                $A.util.addClass(spinner, "slds-hide");
                var returnResult = response.getReturnValue();
                if(returnResult.WrapperData.lstOrderLine.length>0){
                    component.set("v.mainGIWrapper",returnResult.WrapperData);
                    var utc = new Date().toJSON().slice(0,10).split('/').join('-');
                    console.log('setto '+utc);
        
                    component.set("v.mainGIWrapper.registrationDate" , utc)
                    if(!$A.util.isEmpty(returnResult.WrapperData.lstOrderLine)){
                        component.set("v.filter", " gii__Warehouse__c = '"+returnResult.WrapperData.lstOrderLine[0].transferFromWarehouseId+"'");
                    }
                    component.set("v.mapPSData",returnResult.PSData);
                }else{
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showWarningToast(component, event, helper,'Shipments completed for all transfer order lines or TO Line is not available for this record.');
                }
                 component.set("v.showSpinner" , false);
            }else if (state === "INCOMPLETE") {
                console.log('INCOMPLETE State');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
	SaveToDB : function(component, event,helper) {
		var action = component.get("c.createTOReservnQship");
        var wrapperInit = component.get("v.mainGIWrapper");
        wrapperInit.maplotNameToQuantity = component.get("v.lotToQuantity");
        var params = JSON.stringify(wrapperInit);
        console.log('PARAM = '+params);
		action.setParams({ strMainGIWrapper : params });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var returnResult = response.getReturnValue();
				var spinner = component.find("theSpinner");
				$A.util.removeClass(spinner, "slds-show");
				$A.util.addClass(spinner, "slds-hide");
				$A.get("e.force:closeQuickAction").fire();
				console.log('returnResult:::'+JSON.stringify(returnResult));

				console.log('returnResult size:::'+returnResult.length);
				if(returnResult.Exceptions.length>0){
					console.log('returnResult:::'+JSON.stringify(returnResult.Exceptions));
					helper.showErrorToast(component,event,helper,JSON.stringify(returnResult.Exceptions));
				}else if(returnResult.listInvReserve.length>0){
					console.log('in else:::'+returnResult);
					helper.showSuccessToast(component,event,helper,'The Reservation and Quick ship has completed successfully.');//$A.get("$Label.c.giic_TOAlreadyReceived")
					$A.get('e.force:refreshView').fire();
				}else if(returnResult.Exceptions.length==0 && returnResult.listInvReserve.length==0){
					helper.showWarningToast(component,event,helper,'Product is not available in Warehouse or product serial is not selected.');
					$A.get('e.force:refreshView').fire();
				}
			}else if (state === "INCOMPLETE") {
				console.log('INCOMPLETE State');
			}else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + 
									errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
		
	},
	showSuccessToast : function(component, event, helper,message) {
		console.log('showSuccessToast');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: message,
            //messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
	},
	
	showErrorToast : function(component, event, helper,errMsg) {
		console.log('showErrorToast');
        var toastEvent = $A.get("e.force:showToast");  
        toastEvent.setParams({
            title : 'Error: ',
            message:errMsg,
            //messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
	},
    
  

	showWarningToast : function(component, event, helper,warningMsg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: warningMsg,
            duration:'5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    
    
   
    
    setNewSize : function(component, event, helper) {
        var idTO = event.target.id;
        var openQuantity = event.target.value;
        
		console.log('Id = '+idTO)
        console.log('open quantity = '+openQuantity);
        var action = component.get("c.fakeUpdateQuantityAndSerialNumOnTol");
        action.setParams({ 'idTOLine' : idTO,
                           'newOpenQuantity' : openQuantity,
                           'wrapperSerialized' : JSON.stringify(component.get("v.mainGIWrapper"))
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS" ) {
                 if(res.WrapperData.lstOrderLine.length>0){
                    component.set("v.mainGIWrapper", res.WrapperData);
                 }
              //  helper.init(component, event, helper);
            }else{
                helper.showErrorToast(component, event, helper,res.resultMessage);
            }
            
             component.set("v.showSpinner" , false);
          
        });
        $A.enqueueAction(action);
    },
    
    
    lotSelected : function(component, event, helper, lotName, quantity) {  
        var selectedPS = lotName;
     
        var maplotToQuantity = component.get("v.lotToQuantity");
      
        
        
        console.log('selectedPS:::'+selectedPS);
        console.log(component.get("v.psPosition"));
        var psPosition = component.get("v.psPosition");
        var positionPOline = psPosition.split('-')[0];
        var positionPS = psPosition.split('-')[1];
        console.log('positionPOline:::'+positionPOline);
        console.log('positionPS:::'+positionPS);
        var lstorderLine = component.get("v.mainGIWrapper.lstOrderLine");
            
        if(quantity<=lstorderLine[positionPOline].orderQuantity){
        lstorderLine[positionPOline].lstAssignedSerial[positionPS].serialNumber = selectedPS;
        maplotToQuantity[lotName]  = quantity;
  	    component.set("v.lotToQuantity" , maplotToQuantity);
        
        
        lstorderLine[positionPOline].lstAssignedLot[positionPS].lotNumber = lotName; 
        lstorderLine[positionPOline].lstAssignedLot[positionPS].lotQty = quantity;
            
        component.set("v.mainGIWrapper.lstOrderLine",lstorderLine);
        component.set("v.isOpen", false);
        var serialAlreadySelected = component.get("v.serialAlreadySelected");
        serialAlreadySelected.push(selectedPS);
        console.log('metto in lista already selected questo '+selectedPS);
        component.set("v.serialAlreadySelected", serialAlreadySelected);
        
        component.set("v.listShowPS",[]);
            
        }else{
            
            helper.showErrorToast(component, event, helper, 'You can insert max '+lstorderLine[positionPOline].orderQuantity+' quantities for this TO line!');
        }
      
    }
    
})