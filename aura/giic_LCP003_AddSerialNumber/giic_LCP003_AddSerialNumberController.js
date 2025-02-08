({
	doInit : function(component, event, helper) {
    	helper.init(component, event, helper);
        console.log('numberOfSerialToShow = '+component.get("v.numberOfSerialToShow"));
	},
    
    sendReceipt :  function(component, event, helper) {
        console.log('ciao '+JSON.stringify(component.get("v.serialNumberList")));
        var serialList;
        var serialMap = component.get("v.serialNumberList");
        var serialList = [];
         for ( var i = 0; i < serialMap.length; i++ ) {
             if(serialMap[i].value!=''){
             	serialList.push(serialMap[i].value);
             }
          }
        var currentPOLineId = component.get("v.purchaseOrderLineId");
        var cmpEvent = $A.get("e.c:XC_LCE005_SendSerialNumber");
        cmpEvent.setParams({
            "purchaseOrderLineId" : currentPOLineId,
            "serialList" : serialList
        }); 
        var mapIdToQuantity = {};
        mapIdToQuantity = component.get("v.mapPolIdToQuantity");
        console.log('mapIdToQuantity = '+JSON.stringify(mapIdToQuantity));
        if(mapIdToQuantity.hasOwnProperty(currentPOLineId) && serialList.length == mapIdToQuantity[currentPOLineId] ){
        	cmpEvent.fire();
    	}else{
            helper.showToast(component, event, helper, 'Warning: The number of serial numbers must be equal to the received quantity entered above!', 'error');
		}
        
	},
    
    closeModal :  function(component, event, helper) {
        component.destroy();
    },
    
    setMapFromCsv :  function(component, event, helper) {
     
      var map = new Map();
      var stringJson = event.getParam("mapPolToSerialList");
      map = JSON.parse(stringJson);
      console.log('ricevuto '+JSON.stringify(map));
      component.set("v.allData", map);
     
      helper.init(component, event, helper);
      component.set("v.showDragAndDropBox", false);
    },
    
    
    
    
    clearSerials :  function(component, event, helper) {
         var serialList = component.get('v.serialNumberList');
         for (var i = 0; i < serialList.length; i++) {
             if(serialList[i].value!=''){
             	serialList[i].value='';
             }
          }
         component.set("v.serialNumberList", serialList);
        
    }
    
    
        
   
        
    
})