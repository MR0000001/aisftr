({
	init : function(component, event, helper) {
		
        console.log('@@@@ helper');
        helper.controlRMAWh(component, event, helper);
        console.log('@@@@ Magazzino Centrale:' + component.get("v.CentralWarehouseRMA"));
        helper.controlRMARelated(component, event, helper);
	},
    
    controlRMARelated : function(component, event, helper) {    
        console.log('@@@@ Check exitst RMA Line/receipt/disposition');
        let action = component.get("c.checkOnRmaEntity");
     	action.setParams({ "rmaId": component.get("v.recordId")
                         });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            console.log('@@@@ result check: ' + state + ' - retValue.Success:' + retValue.success);
            if (state === "SUCCESS" && retValue.success) {
                	helper.getColumn(component, event, helper);
          			var rows =  JSON.parse(retValue.objectInfo);
                    component.set("v.linesFromServer", rows);
                	console.log('@@@@ rows.lenght:' + rows.lenght);
                    for (var i = 0; i < rows.length; i++) {
                        var row = rows[i];
                        row.DispositionName = row.Name;
                        row.Warehouse = row.gii__Warehouse__r.Name;
                        row.ProductName = row.gii__Product__r.Name;
                        row.ProductCode = row.gii__Product__r.gii__ProductCode__c;
                        row.SKUCode = row.gii__Product__r.giic_SKUCode__c;
                        if(row.gii__ProductSerial__c !='' && row.gii__ProductSerial__c !=undefined){
                        	row.SerialControlled = row.gii__ProductSerial__r.Name;
                        }else{
                            row.SerialControlled = '';
                        }
                        console.log('@@@@ before');
                        row.DispositionQuantity = row.RMA_Disposition_Lines__r.records[0].giic_DispositionQuantity__c ;
                        //console.log('@@@@ row.DispositionQuantity:' + row.RMA_Disposition_Lines__r.records[0].giic_DispositionQuantity__c);
                       	//row.DispositionQuantity = row.gii__DispositionQuantity__c;
                        row.OrderQuantity =row.gii__RTSQuantity__c;
                        row.DispositionLocation = row.gii__DispositionLocation__r.giic_LocationType__c;
                         
                 }      
                 component.set("v.data", rows);

                 component.set('v.showSpinner', false);
                 component.set("v.mapDispLine",  retValue.fieldName5);
                 component.set('v.reasonsList',  JSON.parse(retValue.fieldName4));
                console.log('@@@@ loaded mapDispLine:' + component.get("v.mapDispLine"));   
            
            }else{
                  helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                  component.set("v.showSpinner" , false);
                  $A.get("e.force:closeQuickAction").fire();
            }
            
        });       
        $A.enqueueAction(action);   
       
        
    },
    
    controlRMAWh : function(component, event, helper) {    
        console.log('@@@@ Check WH on Starting RMA');
     
        let action = component.get("c.checkWHRMa");
        action.setParams({ "rmaId": component.get("v.recordId")
                         });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            console.log('@@@@ retValue.state:' + state);
            if (state === "SUCCESS" && retValue.success && retValue!=null) {
                    component.set("v.ShipFromPoTo",retValue.fieldName);
                    component.set("v.warehouseRMA", retValue.objectInfo);
                    component.set("v.warehouseParent", retValue.fieldName2);
                    component.set("v.wareHouseAccount", retValue.fieldName3);
                	console.log('@@@@ WH ON RMA:' + retValue.fieldName);
                	if(retValue.fieldName =="Central"){
                        component.set("v.CentralWarehouseRMA", true);
                        component.set("v.warehouseFrom", component.get("v.warehouseParent"));
                        component.set("v.POonCentralWarehouse",'false');
                    }else{
                        component.set("v.CentralWarehouseRMA", false);
                        component.set("v.RTSOnWarehouse",'Local');
                        component.set("v.POonWarehouse",'None');
                        component.set("v.warehouseFrom", component.get("v.warehouseRMA"))
                	}
                     console.log('@@@ first control RTSonWarehouse:' + component.get("v.RTSOnWarehouse"));
            }else{
                  helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                  component.set("v.showSpinner" , false);
                  $A.get("e.force:closeQuickAction").fire();
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
    
    getColumn : function (component, event, helper) {
        var column = [{ label: 'DISPOSITION', fieldName: 'DispositionName', type: 'text' },
                      { label: 'WAREHOUSE', fieldName: 'Warehouse', type: 'text' },
                      { label: 'PRODUCT', fieldName: 'ProductName', type: 'text' },
                      { label: 'CODE', fieldName: 'ProductCode', type: 'text' },
                      { label: 'SKU CODE', fieldName: 'SKUCode', type: 'text' },
                      { label: 'QUANTITY', fieldName: 'DispositionQuantity', type: 'number' },
                      { label: 'QUANTITY TO RETURN', fieldName: 'OrderQuantity', type: 'number',editable:true,
                       cellAttributes:{ iconName: 'utility:edit' , iconPosition: 'right'} },
                      { label: 'SERIAL', fieldName: 'SerialControlled', type: 'text' },
                      {label:'LOCATION', fieldName:'DispositionLocation', type:'text'}
                      ];
        component.set("v.columns", column);
    },
    
     SelectionRowDisposition : function(component, event, helper){
       		
        	var selectedRows = event.getParam('selectedRows'); 
        	var setRows = [];
        	component.set("v.currentDispSelected", selectedRows[0]);
        	for (var i = 0; i < selectedRows.length; i++) {
            	setRows.push(selectedRows[i].Id);
            	
        	}
         console.log('@@@@ size line selected:' + selectedRows.length);
         component.set("v.countSelectedRow", selectedRows.length);
         component.set("v.DispositionLineList", setRows);
         console.log("@@@@ List disposition Line check:" + component.get("v.DispositionLineList"));
        },
           
      startProcessRTS : function (component, event, helper){
        var objectList = component.get("v.DispositionLineList");
		var RTSFinalWH;
        var POFinalWH;
        var TOFinalWH;
        var ShipFrom;
		var typeMessageToast ;
        var messageToast;
        console.log('@@@@ start RTS');
       
        var mapDisQty = component.get("v.mapDispIdToQuantity");
        
        if($A.util.isEmpty(mapDisQty)){
           helper.showToast(component, event, helper, 'Warning: select at least one line and put quantity return ' , 'error'); 
           return;
        }
        console.log('@@@ start RTS dispLine List:' + JSON.stringify(component.get("v.mapDispLine")));
       if(component.get("v.reason")==="" || (component.get("v.RTSOnWarehouse") ==="" && component.get("v.CentralWarehouseRMA")===false)) {    
        	 helper.showToast(component, event, helper, 'RTS Configuration missing!!', 'error');
             component.set("v.showSpinner" , false);
             $A.get("e.force:closeQuickAction").fire();
        }else{ 
            console.log('@@@@ From Central WH RMA creation PO on Central:' + component.get("v.POonCentralWarehouse"));
            if(component.get("v.POonCentralWarehouse") === "true"){ 
                POFinalWH =component.get("v.warehouseRMA");
                                
            } else { 
               console.log('@@@@ From Local/central WH RMA creation PO on central:' + component.get("v.POonCentralWarehouse"));
               console.log('@@@@ From Local/central WH RMA creation PO on WHS choiced:' + component.get("v.POonWarehouse")); 
            	if(component.get("v.POonWarehouse")!= "None"){
                    helper.logicToCreatePO(component, event,helper);
                    POFinalWH = component.get("v.FinalPORmaWH");
                    TOFinalWH = component.get("v.FinalTORmaWH");
            	} 
               
            }    
            console.log('@@@@ from Local WH create RST on:' +component.get("v.RTSOnWarehouse"));
            if(component.get("v.RTSOnWarehouse") ==="Central"){
                 RTSFinalWH = component.get("v.warehouseParent");
            }else{
                 RTSFinalWH = component.get("v.warehouseRMA");
            }
            console.log('@@@@ Warehouse Id on RTS:' + RTSFinalWH);
			var typeMessageToast ;
            var messageToast;
            if($A.util.isEmpty(objectList)){ 
                messageToast ='No disposition Line selected!';
                typeMessageToast='error';
                helper.showToast(component, event, helper, messageToast, typeMessageToast);
                component.set("v.showSpinner" , false);
                $A.get("e.force:closeQuickAction").fire();
            
            }else{
                console.log('@@@@ Disposition selected:' + JSON.stringify(objectList));
                component.set("v.showSpinner" , true);
                console.log('@@@ befor call method dispLine List:' + JSON.stringify(component.get("v.mapDispLine")));
           		let action = component.get("c.createRTS");
              	let mapToSend = JSON.parse(component.get("v.mapDispLine"));
                var listParam = {
                            rmaId : component.get("v.recordId"),
                            rows:JSON.stringify(objectList), 	
                            Reason: component.get("v.reason"),
                            POFinalWH: POFinalWH,
                            RTSFinalWH : RTSFinalWH,
                            TOFinalWH: TOFinalWH,
                            ShipFrom:component.get("v.ShipFromPoTo"),
                            warehouseFrom: component.get("v.warehouseFrom"),
                            warehouseAccount: component.get("v.wareHouseAccount")
                            
                  };
                 console.log('@@@ call action');
                console.log('@@@ ListParameter:' + JSON.stringify(listParam));
                 var prova = 'prova';
                
                   action.setParams({ 
                            "listParam": JSON.stringify(listParam),
                            "mapDispIdToQuantity" : component.get("v.mapDispIdToQuantity"),
                       		'mapDispLine1' :mapToSend
                       		
                        });
                        action.setCallback(this, function (response) {
                            let state = response.getState();
                            let retValue = response.getReturnValue();
                           
                            console.log('@@@@ START RTS Creation result:' + state + ' - retvalue.success:' + retValue.success);
                            if (state ==="SUCCESS" && retValue.success){
								typeMessageToast = 'success';
                            }else{
                                typeMessageToast = 'error';
                            }
                            messageToast= retValue.resultMessage;
                            helper.showToast(component, event, helper, retValue.resultMessage , typeMessageToast);
                            component.set("v.showSpinner" , false);
                            $A.get("e.force:closeQuickAction").fire();    
                                                      
                        });       
                        $A.enqueueAction(action);   
                }
    

                 
            }
                  
    },
    
      logicToCreatePO : function (component, event, helper){
          console.log('@@@@ logics to create PO e TO:')
          if( component.get("v.RTSOnWarehouse")==="Local" && component.get("v.POonWarehouse") ==="LW"){ //RTSOnWarehouse
             component.set("v.FinalPORmaWH", component.get("v.warehouseRMA"));
              
              console.log('@@@@ logics 1');
            
          }
          if(component.get("v.RTSOnWarehouse")==="Local" && component.get("v.POonWarehouse") ==="CW"){
             component.set("v.FinalPORmaWH", component.get("v.warehouseParent"));
             component.set("v.FinalTORmaWH", component.get("v.warehouseParent"));
              console.log('@@@@ logics 2'); 
             
          }
          if( component.get("v.RTSOnWarehouse")==="Central" && component.get("v.POonWarehouse") ==="LW"){
             component.set("v.FinalPORmaWH", component.get("v.warehouseRMA"));
             component.set("v.FinalTORmaWH", component.get("v.warehouseParent"));
               console.log('@@@@ logics 3');
              
          }
          if( component.get("v.RTSOnWarehouse")==="Central" && component.get("v.POonWarehouse") ==="CW"){
              component.set("v.FinalPORmaWH", component.get("v.warehouseParent"));
              component.set("v.FinalTORmaWH", component.get("v.warehouseParent")); 
               console.log('@@@@ logics 4');
          }
          if( component.get("v.RTSOnWarehouse")==="Central" && component.get("v.POonWarehouse") ==="None"){
              component.set("v.FinalTORmaWH", component.get("v.warehouseParent")); 
               console.log('@@@@ logics 5');
          } 
          
        }, 
    
        handleSaveEdition: function (component, event, helper, draftValues) {
        var map = {};
        var rq = 0;
        var linesFromServer = component.get("v.linesFromServer");
        var lineSelected = parseInt(component.get("v.countSelectedRow"));
        var draftSize = draftValues.length;
        console.log('@@@@ Save Line - lineFronServer size:'+  linesFromServer.length);
        console.log('@@@@ Save Line - draftValues size:'+  draftSize);
        console.log('@@@@ Save Line - lineselected size:'+  lineSelected);
      
        if(lineSelected != draftSize){
             helper.showToast(component, event, helper, 'Warning: No match QUANTITY RETURN and line selected!!', 'error'); 
             return;          
        }
            
        for (var i = 0; i < draftValues.length; i++) {
            for(var j = 0; j < linesFromServer.length; j++){

                var currentPol = linesFromServer[j];
                console.log('@@@@ currentPol:'+  currentPol.Id);
                console.log('@@@@ currentqty:'+  currentPol.RMA_Disposition_Lines__r.records[0].giic_DispositionQuantity__c);
                console.log('@@@@ Id row:'+   draftValues[i].Id);
                if(currentPol.Id == draftValues[i].Id){
                    if(currentPol.RMA_Disposition_Lines__r.records[0].giic_DispositionQuantity__c >= draftValues[i].OrderQuantity && draftValues[i].OrderQuantity !=0){
                         rq = draftValues[i].OrderQuantity;
            	    	 map[draftValues[i].Id] = rq;  
                    }
                    else{
                        helper.showToast(component, event, helper, 'Warning: QUANTITY:'+ currentPol.RMA_Disposition_Lines__r.records[0].giic_DispositionQuantity__c + ' is the maximum value permitted to QUANTITY TO RETURN on '+currentPol.Name+'!' , 'error'); 
                       return;
                    }
                    
                }
            }
        }
        
        component.set("v.mapDispIdToQuantity", map);
        console.log('MAP mapDispIdToQuantity '+JSON.stringify(component.get("v.mapDispIdToQuantity")));
        helper.showToast(component, event, helper, 'Disposition quantities saved!', 'success');
        $A.get('e.force:refreshView').fire();
    },
})