({
	doInit : function(component, event, helper) {
    	helper.init(component, event, helper);
        console.log('numberOfSerialToShow = '+component.get("v.numberOfSerialToShow"));
	},
    
    sendReceipt :  function(component, event, helper) {
        console.log('ciao '+JSON.stringify(component.get("v.serialNumberList")));
        var lotMap = {};
        var serialList;
        var totalQuantityPerLine = 0;
        var serialMap = component.get("v.serialNumberList");
        var serialList = [];
        for ( var i = 0; i < serialMap.length; i++ ) {
             if(serialMap[i].value!=''){
             	
                if(serialMap[i].quantity!=null && serialMap[i].quantity!=0){
                    serialList.push(serialMap[i].value);
                	lotMap[serialMap[i].value] = serialMap[i].quantity;
                    totalQuantityPerLine = (totalQuantityPerLine + parseInt(serialMap[i].quantity) );
                }
                
             }
        }
        console.log('totalQuantityPerLine = '+totalQuantityPerLine);
        var currentPOLineId = component.get("v.purchaseOrderLineId");
        var cmpEvent = $A.get("e.c:XC_LCE005_SendSerialNumber");
        cmpEvent.setParams({
            "purchaseOrderLineId" : currentPOLineId,
            "serialList" : serialList,
            "lotMap" : lotMap
        }); 
        var mapIdToQuantity = {};
        mapIdToQuantity = component.get("v.mapPolIdToQuantity");
        console.log('mapIdToQuantity = '+JSON.stringify(mapIdToQuantity));
        console.log('Sto per sparare la mappa lottoNumber-quantita'+JSON.stringify(lotMap) );
        if(mapIdToQuantity.hasOwnProperty(currentPOLineId) && totalQuantityPerLine == mapIdToQuantity[currentPOLineId] ){
        	cmpEvent.fire();
    	}else{
            helper.showToast(component, event, helper, 'Warning: The number of Lot Quantity must be equal to the received quantity entered above!', 'error');
		}
        
	},
    
    closeModal :  function(component, event, helper) {
        component.destroy();
    },
    
    
    
    setMapFromCsv :  function(component, event, helper) {
      var currentPurchaseOrderLineId = component.get("v.purchaseOrderLineId");
      var map = new Map();
      var stringJson = event.getParam("mapPolToSerialList");
      var lotNumberToQuantityMap = event.getParam("lotNumberToQuantityMap"); 
      var totalLotMap = component.get("v.totalLotMap");
      totalLotMap[currentPurchaseOrderLineId] = map;
      component.set("v.totalLotMap", totalLotMap);
      totalLotMap[currentPurchaseOrderLineId] = lotNumberToQuantityMap;
      map = JSON.parse(stringJson);
      console.log('ricevuto '+JSON.stringify(map));
      component.set("v.allData", map);
      component.set("v.totalLotMap", totalLotMap);
      helper.init(component, event, helper);
      component.set("v.showDragAndDropBox", false);
    },
    
    
    
    
    clearSerials :  function(component, event, helper) {
         var serialList = component.get('v.serialNumberList');
         for (var i = 0; i < serialList.length; i++) {
             if(serialList[i].value!=''){
             	serialList[i].value='';
                serialList[i].quantity=0;
             }
          }
         component.set("v.serialNumberList", serialList);
        
    }
    
    
        
   
        
    
})