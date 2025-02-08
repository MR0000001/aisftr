({
	init : function(component, event, helper) {
         console.log('Step00 -> ');
         component.set('v.showSpinner', true);
         console.log('Step0 -> ');
         helper.controlForSupplier(component, event, helper);
         console.log('Step2 -> ');
    },
    
    
    controlForSupplier : function(component, event, helper) {    
        
        let purchaseOrder = component.get("v.purchaseOrder");
        let action = component.get("c.checkIfCanPress");
        action.setParams({ "purchaseOrderId": component.get("v.recordId")
                         });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
          
            if (state === "SUCCESS" && retValue.success) {
                    var isActiveNR2626 = JSON.parse(retValue.NR2626);
                    component.set("v.isActiveNR2626", isActiveNR2626);
                	 console.log('isActiveNR2626Bis ='+component.get("v.isActiveNR2626"));
        			helper.getColumn(component, event, helper);
          			helper.getTableData(component, event, helper);
            }else{
                  helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                  component.set("v.showSpinner" , false);
                  $A.get("e.force:closeQuickAction").fire();
            }
            
        });       
        $A.enqueueAction(action);
       
        
    },
    
    
    checkRequest : function(component, event, helper) {      
        if(component.get("v.isActiveNR2626")){

            if(component.get("v.isDropShip")==false && component.get("v.receiptDate")!=undefined && component.get("v.deliveryDate")!=undefined && component.get("v.deliveryDoc")!=undefined && component.get("v.deliveryDoc")!='' &&  component.get("v.lineSelected") && component.get("v.arrivalMaterial") != undefined && component.get("v.qualityNoteRequire") != false){
                if(component.get("v.qualityFail") != false){
                    if(component.get("v.qualityNote") != '' && component.get("v.qualityNote") != undefined){
                        console.log('QualityNote vuoto --> ' + component.get('v.qualityNote'));
                        component.set("v.sblokSubmit", false);
                    }else{
                        component.set("v.sblokSubmit", true);
                        console.log('QualityNote non vuoto --> ' + component.get("v.qualityNote"));
                    }
                }else{
                    component.set("v.sblokSubmit", false);
                }    
            }else if(component.get("v.isDropShip") && component.get("v.receiptDate")!=undefined &&  component.get("v.lineSelected") && component.get("v.arrivalMaterial") != undefined && component.get("v.qualityNoteRequire") != false){
                if(component.get("v.qualityFail") != false){
                    if(component.get("v.qualityNote") != '' && component.get("v.qualityNote") != undefined){
                        component.set("v.sblokSubmit", false);
                    }else{
                        component.set("v.sblokSubmit", true);
                    }
                }else{
                    component.set("v.sblokSubmit", false);
                }    
            }else{
                component.set("v.sblokSubmit", true);
            }
        } else {
        if(component.get("v.isDropShip")==false && component.get("v.receiptDate")!=undefined && component.get("v.deliveryDate")!=undefined && component.get("v.deliveryDoc")!=undefined && component.get("v.deliveryDoc")!='' &&  component.get("v.lineSelected")){
                component.set("v.sblokSubmit", false);
            }else if(component.get("v.isDropShip") && component.get("v.receiptDate")!=undefined &&  component.get("v.lineSelected")){
                component.set("v.sblokSubmit", false);
            }else{
                component.set("v.sblokSubmit", true);
            }
        }	        
    },
    
    getTableData : function (component, event, helper) {
        let purchaseOrder = component.get("v.purchaseOrder");
        let action = component.get("c.getPurchaseOrderLine");
        action.setParams({ "purchaseOrderId": component.get("v.recordId")
                         });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
          	console.log('Step2 -> ');
            if (state === "SUCCESS" && retValue.success) {
                	console.log('Step3 -> ' + state);
                    var rows =  JSON.parse(retValue.objectInfo);
                	console.log('Step4 -> ' + rows);
                    component.set("v.linesFromServer", rows);
                    for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    // checking if any account related data in row
                    if (row.gii__SalesOrderLine__c) {
                        row.SalesOrderName = row.gii__SalesOrderLine__r.Name;
                    }
                    if (row.gii__Product__c) {
                        row.ProductName = row.gii__Product__r.Name;
                        row.SerialControlled = row.gii__Product__r.gii__SerialControlled__c;
                        row.LotControlled = row.gii__Product__r.gii__LotControlled__c;
                        row.ProductCode = row. gii__Product__r.gii__ProductCode__c;
                        row.SKUCode = row.gii__Product__r.giic_SKUCode__c;
                    }
                    if (row.gii__ShipTo__c) {
                        row.WarehouseName = row.gii__ShipTo__r.Name;
                    }
                        
                    if (row.gii__ReceivedQuantity__c) {
                        row.gii__ReceivedQuantity__c = 0;
                    }
                        
                 
                  console.log('Step5 -> ' + rows);
            }
                console.log('Step6 -> ' + rows);
                component.set("v.data", rows);
                component.set('v.showSpinner', false);
            }else{
                 helper.showToast(component, event, helper, 'Warning: No lines available', 'error');
                 $A.get("e.force:closeQuickAction").fire();
            }
      
             });       
        $A.enqueueAction(action);   
       
    },
        
         
    getColumn : function (component, event, helper) {
        var column = [{ label: 'PURCHASE ORDER LINE', fieldName: 'Name', type: 'text' },
                        { label: 'PRODUCT', fieldName: 'ProductName', type: 'text' },
                      { label: 'CODE', fieldName: 'ProductCode', type: 'text' },
                    
                      { label: 'SHIP TO', fieldName: 'WarehouseName', type: 'text' },
                   //   { label: 'LOCATION', fieldName: 'Name', type: 'input' },
                      { label: 'ORDER QUANTITY', fieldName: 'gii__OrderQuantity__c', type: 'number' },
                      { label: 'OPEN QUANTITY', fieldName: 'gii__OpenQuantity__c', type: 'number' },
                      { label: 'RECEIVED QUANTITY', fieldName: 'gii__ReceivedQuantity__c', type: 'number', editable:true,
                      cellAttributes:{ iconName: 'utility:edit' , iconPosition: 'right'} },
                      { label: 'SERIAL CONTROLLED', fieldName: 'SerialControlled', type: 'boolean' },
                      { label: 'LOT CONTROLLED', fieldName: 'LotControlled', type: 'boolean' },
                      { label: 'SKU CODE', fieldName: 'SKUCode', type: 'text' }
                   
                      ];
        component.set("v.columns", column);
    },
    
    createReceipt : function (component, event, helper) {
        
       var docOptions = {
           receiptDate: component.get("v.receiptDate"),
           deliveryDoc: component.get("v.deliveryDoc"),
           deliveryDate: component.get("v.deliveryDate"),
           qualityNoteRequire: component.get("v.qualityNoteRequire"),
           arrivalMaterial: component.get("v.arrivalMaterial"),
           qualityNote: component.get("v.qualityNote"),
           qualityCheckFail: component.get("v.qualityFail")
        };
        var options = JSON.stringify(docOptions);

        console.log('VEDIAMO UN PO -> ' + options);

        let action = component.get("c.createPOReceiptandLine");
        action.setParams({ "purchaseOrderId"      : component.get("v.recordId"),
                           "purchaseOrderLineIds" : component.get("v.POrderLineList"),
                           "options" : options,
                           "mapPolIdToQuantity" : component.get("v.mapPolIdToQuantity"),
                           "mapPolToSerialList" : component.get("v.mapPolToSerialList"),
                           "idPOLToLotMap" :      component.get("v.totalLotMap")
                          
                         });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
          
            if (state === "SUCCESS" && retValue.success) {
                 helper.showToast(component, event, helper, retValue.resultMessage, 'success');
                 if(component.get("v.isActiveNR2626")){
                    helper.showToast(component, event, helper, 'Allegare il Documento di Trasporto', 'warning');
                 }
                 
                 $A.get('e.force:refreshView').fire();
                 $A.get("e.force:closeQuickAction").fire();
            }
            else{
                if(retValue!=null){
                	helper.showToast(component, event, helper, 'Error: '+retValue.resultMessage, 'error');
                	component.set("v.showSpinner" , false);
                }else{
                    helper.showToast(component, event, helper, 'Warning: error in a callback' , 'error');
                	component.set("v.showSpinner" , false);
                    
                }
            }
             
                
      
             });       
        $A.enqueueAction(action);   
       
        
    },
    
    showSerialNumber : function(component, event, helper, purchaseOrderLine) {
        var mappaConData = component.get("v.mapPolToSerialList");
        console.log('purchaseOrderLine '+JSON.stringify(purchaseOrderLine));
        if(purchaseOrderLine.SerialControlled){
        	$A.createComponent(
       
                            "c:giic_LCP003_AddSerialNumber",     
                            {    
                                "purchaseOrderLineId"   : purchaseOrderLine.Id,
                                "numberOfSerialToShow"  : purchaseOrderLine.gii__OpenQuantity__c,
                                "mapPolIdToQuantity" : component.get("v.mapPolIdToQuantity"),
                                "allData"  :  mappaConData
                               
                            },
                            function(newcomponent, status, errorMessage){
                                if (status === "SUCCESS") {
                                    console.log('creo il body');
                                    let body = newcomponent.get("v.body");
                                    //var div1 = component.get("v.body");
                                    body.push(newcomponent);
                                    //div1.push(newcomponent);
                                   
                                  
                                    component.set("v.body", body);
                                }
                                else if (status === "INCOMPLETE") {
                                        console.log("No response from server or client is offline.")
                                }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                }
                            });
        }else if(purchaseOrderLine.LotControlled){
        	$A.createComponent(
       
                            "c:Giic_LCP024_AddLotNumber",     
                            {    
                                "purchaseOrderLineId"   : purchaseOrderLine.Id,
                                "numberOfSerialToShow"  : purchaseOrderLine.gii__OpenQuantity__c,
                                "mapPolIdToQuantity" : component.get("v.mapPolIdToQuantity"),
                                "allData"  :  mappaConData,
                                "totalLotMap" : component.get("v.totalLotMap")
                               
                            },
                            function(newcomponent, status, errorMessage){
                                if (status === "SUCCESS") {
                                    console.log('creo il body');
                                    let body = newcomponent.get("v.body");
                                    //var div1 = component.get("v.body");
                                    body.push(newcomponent);
                                    //div1.push(newcomponent);
                                   
                                  
                                    component.set("v.body", body);
                                }
                                else if (status === "INCOMPLETE") {
                                        console.log("No response from server or client is offline.")
                                }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                }
                            });
        }
        else{
             component.set("v.body", '');
        }
        
    },
    
    showToast : function(component, event, helper, message, type) {
        
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type,
            "mode": ''
        });
    },
    
    handleSaveEdition: function (component, event, helper, draftValues) {
        var map = {};
        var rq = 0;
        var linesFromServer = component.get("v.linesFromServer");
        
        for (var i = 0; i < draftValues.length; i++) {
            for(var j = 0; j < linesFromServer.length; j++){
                var currentPol = linesFromServer[j];
                if(currentPol.Id == draftValues[i].Id){
                    if(draftValues[i].gii__ReceivedQuantity__c<=currentPol.gii__OpenQuantity__c){
                         rq = draftValues[i].gii__ReceivedQuantity__c;
            	    	 map[draftValues[i].Id] = rq;  
                    }
                    else{
                       helper.showToast(component, event, helper, 'Warning: '+currentPol.gii__OpenQuantity__c+' is the maximum amount you can receive on line '+currentPol.Name+'!' , 'error'); 
                       return;
                    }
                    
                }
            }
        }
       
        component.set("v.mapPolIdToQuantity", map);
        console.log('MAP mapPolIdToQuantity '+JSON.stringify(component.get("v.mapPolIdToQuantity")));
        helper.showToast(component, event, helper, 'Received quantities saved!', 'success');
        if(component.get("v.currentPolSelected")!=undefined){
             helper.showSerialNumber(component, event, helper,component.get("v.currentPolSelected"));
        }
        $A.get('e.force:refreshView').fire();
        //component.set('v.errors', []);
        //component.set('v.draftValues', []);
        //component.find("supertableId").set("v.draftValues", null);               
            
        
        
    },
    
    handleShowNotice : function(component, event, helper, message) {
        component.find('notifLib').showNotice({
            "variant": "error",
            "header": message,
            "message": ""
            
        });
    },
    
    doLogicForSelectedRow : function(component, event, helper){
        component.set("v.lineSelected", true);
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        	component.set("v.currentPolSelected", selectedRows[0]);
        	for (var i = 0; i < selectedRows.length; i++) {
            	setRows.push(selectedRows[i].Id);
            	helper.showSerialNumber(component, event, helper, selectedRows[i]);
        	}
       
        if(selectedRows.length==0){
             component.set("v.body", '');
             
        }
      
        component.set("v.POrderLineList", setRows);
        helper.checkRequest(component, event, helper);
        
        
        
    }
       
})