({  
    init : function(component, event,helper){
     try{
            
            component.set('v.showSpinner',true);
            console.log('Record ID:::'+component.get("v.recordId"));
            var action = component.get("c.fetchSOAndSoLineData");
            action.setParams({ idSO : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.showSpinner',false);
                    var returnResult = response.getReturnValue();
                   
                    console.log('INIT CON '+returnResult.IsSuccess );
                    console.log('INIT CON '+returnResult.ErrorMessage);
                    if(returnResult.IsSuccess == 'false'){
                             helper.showErrorToast(component, event, helper, returnResult.ErrorMessage);
                             $A.get("e.force:closeQuickAction").fire();
                    }
                    if(returnResult.WrapperData.salesOrderLineList.length>0){
                        component.set("v.mainGIWrapper", returnResult.WrapperData);
                        console.log('JSON = '+JSON.stringify(returnResult.WrapperData));
                        component.set("v.mapPSData", returnResult.PSData);
                       
                        
                    }else{
                        $A.get("e.force:closeQuickAction").fire();
                        helper.showWarningToast(component, event, helper, 'Shipments completed for all transfer order lines or TO Line is not available for this record.');
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
        }catch(ex){
            console.log(ex);
        }
},
    
    
    saveToDB : function(component, event,helper) {
		try{
            var checkPSInput = false;
            var pdtSerialError = false;
            var mainWrapper = component.get("v.mainGIWrapper");//.lstAssignedSerial
            mainWrapper.lastGoodIssue = component.get("v.isLastGoodIssue");
            console.log('LastGoodIssue = '+mainWrapper.lastGoodIssue);
            console.log('mainWrapper---------------');
            console.log(JSON.stringify(mainWrapper));
            if($A.util.isUndefinedOrNull(mainWrapper.fslWorkOrder)){
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": "WorkOrder not defined on Sales Order !!",
                    "variant": "error"
                });
            }else{
                mainWrapper.salesOrderLineList.forEach(function(element){
                    if(element.productRequiredID == null){
                        checkPSInput = true;
                    }
                    if(element.isSerialControlled == true && element.consumedQuantity!=0){
                        element.assignedSerials.forEach(function(element1){
                            if($A.util.isUndefinedOrNull(element1.serialNumber) || element1.serialNumber ==''){
                                pdtSerialError = true;
                            }
                        });
                    }
                });
                if(checkPSInput == true){
                    component.find('notifLib').showToast({
                        "title": "Error!",
                        "message": "ProductRequiredId not defined on Sales Order Line!!",
                        "variant": "error"
                    });
                }else if(pdtSerialError == true){
                    component.find('notifLib').showToast({
                        "title": "Error!",
                        "message": "Product Serial not selected",
                        "variant": "error"
                    });
                }else{
                  	component.set('v.showSpinner',true);
                    var action = component.get("c.callGoodIssueSOApi");
                    
                    var newSalesOrderLineList = [];
                    mainWrapper.salesOrderLineList.forEach(function(element){
                        if(element.consumedQuantity==0){
                            
                        }else{
                            newSalesOrderLineList.push(element);
                        }
                         
                    });
                    mainWrapper.salesOrderLineList = newSalesOrderLineList;
                    console.log('INVIO AL BE '+ mainWrapper.salesOrderLineList.length +' LINEE');
                    console.log('INVIO AL BE '+ JSON.stringify(mainWrapper.salesOrderLineList));
                    
                    action.setParams({ inputApiString : JSON.stringify(mainWrapper),
                                       salesOrderId : component.get("v.recordId")
                                     });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set('v.showSpinner',false);
                            var returnWrapper = response.getReturnValue();
                            var returnResult = returnWrapper.success;
                            console.log('returnResult:::'+JSON.stringify(returnResult));
                            if(returnResult == null || returnResult == false){
                                component.find('notifLib').showToast({
                                    "title": "Error!",
                                    "message": "Error: "+returnWrapper.resultMessage,
                                    "variant": "error"
                                });
                            }else{
                                component.find('notifLib').showToast({
                                    "title": "Success!",
                                    "message": "Goods Issue Succesfull !",
                                    "variant": "success"
                                });
                                
                                $A.get('e.force:refreshView').fire();
                                $A.get('e.force:closeQuickAction').fire();
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
                                component.find('notifLib').showToast({
                                    "title": "Error!",
                                    "message": "Error occurred in Goods Issue!!",
                                    "variant": "error"
                                });
                            }
                        }
                    });
                    $A.enqueueAction(action);    
                }  
            }   
        }catch(ex){
            console.log(ex);
        }	
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
            title : 'Warning:',
            message:errMsg,
            //messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
	},

	showWarningToast : function(component, event, helper, warningMsg) {
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
    
    
    lotSelected : function(component, event, helper, lotName, quantity){
        
            var selectedPS = lotName;
            console.log('selectedPS:::'+selectedPS);
            console.log(component.get("v.psPosition"));
            var psPosition = component.get("v.psPosition");
            var positionPOline = psPosition.split('-')[0];
            var positionPS = psPosition.split('-')[1];
            console.log('positionPOline:::'+positionPOline);
            console.log('positionPS:::'+positionPS);
            var lstorderLine = component.get("v.mainGIWrapper.salesOrderLineList");
           
            lstorderLine[positionPOline].lstAssignedLot[positionPS].lotNumber = lotName; 
            lstorderLine[positionPOline].lstAssignedLot[positionPS].lotQty = quantity;
            
            component.set("v.mainGIWrapper.salesOrderLineList",lstorderLine);
            component.set("v.isOpen", false); 
            component.set("v.listShowPS",[]);   
       
    },
    
})