({
    doInit : function(component, event, helper) {
     	helper.init(component, event, helper);
    },
    
    checkRequired : function(component, event, helper) {
        var wr = component.get("v.mainGIWrapper");
        console.log('Registration Date = '+wr.registrationDate);
        if(wr.reference!=undefined && wr.reference!=''  && wr.registrationDate!=undefined){     
            component.set("v.savePermitted" , false);
        }else{
            component.set("v.savePermitted" , true);
        }
        
        
    },

    handleCancel : function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
    },
    handleSave : function(component, event, helper) {
        var checkPSInput = false;
        var lstOrderLine = component.get("v.mainGIWrapper.lstOrderLine");//.lstAssignedSerial
        if(lstOrderLine.length>0){
            for(var count=0;count<lstOrderLine.length;count++){		
                if(lstOrderLine[count].lstAssignedSerial.length>0){
                    console.log('Serial product');
                    for(var countO=0;countO<lstOrderLine[count].lstAssignedSerial.length;countO++){
                        if(lstOrderLine[count].lstAssignedSerial[countO].serialNumber != ''){
                            console.log('In IF:::');
                            checkPSInput = true;
                            break;
                        }
                    }
                }else{
                    checkPSInput = true;
                    console.log('Have Non serial product');
                }
            }
        }
		    
		//component.set("v.mainGIWrapper.lstOrderLine",lstOrderLine);
		if(checkPSInput){
            component.set("v.extraMsg","");
            component.set("v.blErrorMsg",false);
            var spinner = component.find("theSpinner");
            $A.util.removeClass(spinner, "slds-hide");
            $A.util.addClass(spinner, "slds-show");
            console.log(JSON.stringify(component.get("v.mainGIWrapper")));
            helper.SaveToDB(component, event,helper);
        }else{
            component.set("v.blErrorMsg", true);
        }
    },
    
    
    openModal : function(component, event, helper) {
        console.log('Open Modal');
        var productName = event.currentTarget.dataset.id;
        var eliminatedList = component.get("v.eliminatedList");
        console.log("productName::"+productName);
        var position = event.currentTarget.dataset.name;
        var action = event.currentTarget.dataset.action;
        component.set("v.action",action);  
        if(action=='Product Serial'){
            console.log(" Product Serial Position::"+position);
            component.set("v.psPosition",position);
            var mapPSData = component.get("v.mapPSData");
            var lstPS = mapPSData[productName];
            if($A.util.isEmpty(lstPS)){
                  component.set("v.noProductSerial" , true);
            }else{
                  component.set("v.noProductSerial" , false);
            }
            
            var serialAlreadySelected = component.get("v.serialAlreadySelected");
            for(var i=0; i<lstPS.length;  i++){
 				for(var j=0; j<serialAlreadySelected.length; j++){
                   
 	    			if(lstPS[i].gii__ProductSerial__r.Name == serialAlreadySelected[j]){
                        eliminatedList.push(lstPS[i]);
    					lstPS.splice(i, 1);
    				}
    			}
			}
            
            component.set("v.eliminatedList",eliminatedList);
            console.log('new size '+lstPS.length);
            component.set("v.listShowPS", lstPS); 
        }
        
        component.set("v.isOpen", true);
    },
    
    
    
    openModalForLot : function(component, event, helper) {
        console.log('Open Modal');
        var productName = event.currentTarget.dataset.id;
        var eliminatedList = component.get("v.eliminatedList");
        console.log("productName::"+productName);
        var position = event.currentTarget.dataset.name;
        var action = event.currentTarget.dataset.action;
        component.set("v.action",action);  
        if(action=='Product Lot'){
            console.log(" Product Serial Position::"+position);
            component.set("v.psPosition",position);
            var mapPSData = component.get("v.mapPSData");
            var lstPS = mapPSData[productName];
            if($A.util.isEmpty(lstPS)){
                  component.set("v.noProductSerial" , true);
            }else{
                  component.set("v.noProductSerial" , false);
            }
            
            var serialAlreadySelected = component.get("v.serialAlreadySelected");
            for(var i=0; i<lstPS.length;  i++){
 				for(var j=0; j<serialAlreadySelected.length; j++){
                   
 	    			if(lstPS[i].gii__ProductLot__r.Name == serialAlreadySelected[j]){
                        eliminatedList.push(lstPS[i]);
    					lstPS.splice(i, 1);
    				}
    			}
			}
            
            component.set("v.eliminatedList",eliminatedList);
            console.log('new size '+lstPS.length);
            component.set("v.listShowPS", lstPS); 
        }
        
        component.set("v.isOpen", true);
    },
    
    
    closeModel : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    

    psSelected : function(component, event, helper) {  
        var selectedPS = event.currentTarget.dataset.name;
     //   var selectedPSid = event.currentTarget.dataset.id;
        console.log('selectedPS:::'+selectedPS);
        console.log(component.get("v.psPosition"));
        var psPosition = component.get("v.psPosition");
        var positionPOline = psPosition.split('-')[0];
        var positionPS = psPosition.split('-')[1];
        console.log('positionPOline:::'+positionPOline);
        console.log('positionPS:::'+positionPS);
        var lstorderLine = component.get("v.mainGIWrapper.lstOrderLine");
        lstorderLine[positionPOline].lstAssignedSerial[positionPS].serialNumber = selectedPS;
        //lstorderLine[positionPOline].lstAssignedSerial[positionPS].productserialId = selectedPSid;
        component.set("v.mainGIWrapper.lstOrderLine",lstorderLine);
        component.set("v.isOpen", false);
        var serialAlreadySelected = component.get("v.serialAlreadySelected");
        serialAlreadySelected.push(selectedPS);
        console.log('metto in lista already selected questo '+selectedPS);
        component.set("v.serialAlreadySelected", serialAlreadySelected);
        
        component.set("v.listShowPS",[]);
    },
    
    
    
    setLotQuantityMap : function(component, event, helper) {
       
        var lotName = event.target.id;
        var quantity = event.target.value;
        console.log('lotName = '+lotName);
        console.log('quantity = '+quantity);
       
        helper.lotSelected(component, event, helper, lotName, quantity) ;
                
        
    },
    
    
    clearSelection : function(component, event, helper) {
        var position = event.currentTarget.dataset.name;
        let foundOneToRemit = false;
        var eliminatedList = component.get("v.eliminatedList");
        var positionPOline = position.split('-')[0];
        var positionPS = position.split('-')[1];
        var action = event.currentTarget.dataset.action;//component.get("v.action");  
        var lstorderLine = component.get("v.mainGIWrapper.lstOrderLine");
        
        var listaSerialAlreadySelected = component.get("v.serialAlreadySelected");
        
        var mapPSData = component.get("v.mapPSData");
        var current = lstorderLine[positionPOline];
        
        var lstPS = mapPSData[current.productName];
        
        if(action=='Product Serial'){
            console.log('rimetto questo in lista');
            var j = 0;
            while (j < listaSerialAlreadySelected.length){
                    if(listaSerialAlreadySelected[j] == lstorderLine[positionPOline].lstAssignedSerial[positionPS].serialNumber){
                         listaSerialAlreadySelected.splice(j, 1);
                    }else{
                         j++;
                    }
            }
            
           for(var i=0; i<eliminatedList.length;  i++){
 	    			if(eliminatedList[i].gii__ProductSerial__r.Name == lstorderLine[positionPOline].lstAssignedSerial[positionPS].serialNumber){
                          var elementAlreadyPresent = false;
                          for(var j=0; j<lstPS.length;  j++){
                              console.log('j ='+j);
                              if(eliminatedList[i].gii__ProductSerial__r.Name == lstPS[j].gii__ProductSerial__r.Name){
                                  
                                  elementAlreadyPresent = true;
                              }
                          }
                        if(!elementAlreadyPresent){
                            lstPS.push(eliminatedList[i]);
                        }
                        
                        foundOneToRemit = true;
                       
    				}
                         
    	    }
            
            if(foundOneToRemit){
            	component.set("v.listShowPS", lstPS); 
            }
            
            
			lstorderLine[positionPOline].lstAssignedSerial[positionPS].serialNumber = '';
            component.set("v.serialAlreadySelected", listaSerialAlreadySelected);
           
        }else if(action=='Product Lot'){
            //lstorderLine[position].assignedLot = '';
            console.log('rimetto sto lotto in lista');
            var j = 0;
            while (j < listaSerialAlreadySelected.length){
                    if(listaSerialAlreadySelected[j] == lstorderLine[positionPOline].lstAssignedSerial[positionPS].serialNumber){
                         listaSerialAlreadySelected.splice(j, 1);
                    }else{
                         j++;
                    }
            }
            
           for(var i=0; i<eliminatedList.length;  i++){
 	    			if(eliminatedList[i].gii__ProductLot__r.Name == lstorderLine[positionPOline].lstAssignedSerial[positionPS].serialNumber){
                          var elementAlreadyPresent = false;
                          for(var j=0; j<lstPS.length;  j++){
                              console.log('j ='+j);
                              if(eliminatedList[i].gii__ProductLot__r.Name == lstPS[j].gii__ProductLot__r.Name){
                                  
                                  elementAlreadyPresent = true;
                              }
                          }
                        if(!elementAlreadyPresent){
                            lstPS.push(eliminatedList[i]);
                        }
                        
                        foundOneToRemit = true;
                       
    				}
                         
    	    }
            
            if(foundOneToRemit){
            	component.set("v.listShowPS", lstPS); 
            }
            
            
			lstorderLine[positionPOline].lstAssignedSerial[positionPS].serialNumber = '';
            component.set("v.serialAlreadySelected", listaSerialAlreadySelected);
           
            
            
        }else if(action=='Location'){
            lstorderLine[position].locationName = '';
            lstorderLine[position].locationId = '';
            component.set("v.listShowLocation",[]); 
        }

        component.set("v.mainGIWrapper.lstOrderLine",lstorderLine);
        component.set("v.showCustomLocationSearch" , true);
        
    },
    
    
    setNewSize :  function(component, event, helper) {
        component.set("v.showSpinner" , true);
        helper.setNewSize(component, event, helper);
      
      
    }

})