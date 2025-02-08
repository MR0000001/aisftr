({
	getWarehouseListHelper : function (component, event, name){
    	var action = component.get("c.getWarehouseList");
        var recordId = component.get("v.parentRecordId");
        
        var filterList = [component.find("warehouseNameFilter").get("v.value"),component.find("warehouseCodeFilter").get("v.value"),component.find("warehouseCoverageFilter").get("v.value")];
        var map2 = {};
        map2["warehouseNameFilter"] = component.find("warehouseNameFilter").get("v.value");  
        map2["warehouseCodeFilter"] = component.find("warehouseCodeFilter").get("v.value"); 
        map2["warehouseCoverageFilter"] = component.find("warehouseCoverageFilter").get("v.value");
        map2["warehouseLegalEntityFilter"] = component.get("v.warehouseLegalEntityFilter");

        
        component.set("v.spinner", true);
        console.log('@@@@ recordId:' + recordId);
        let filterJson = JSON.stringify(map2);
        action.setParams({
            'recordId':recordId,
            'filterMap':filterJson
		})
     	
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
            var prods = response.getReturnValue();
          		if(response.getReturnValue()!='' && response.getReturnValue()!=null && response.getReturnValue().length > 0) {
                   	component.set("v.spinner", false);
                    component.set("v.warehouseList", JSON.parse(response.getReturnValue()));
                }else{   
                    var resultsToast = $A.get("e.force:showToast");
                			resultsToast.setParams({
                    		"title":$A.get('$Label.c.XC_CL_Error'),
                    		"message": $A.get('$Label.c.XC_CL_NoWarehouseFound'),
                        	"duration": "4000",
                        	"type": 'Error'
                		});
                       resultsToast.fire();
                       $A.get("e.force:closeQuickAction").fire();                     
                }    
            }    
        });
        $A.enqueueAction(action);
	},
    
    setWarehouseHelper : function (component, event, name){
        
        let selRec = event.currentTarget.dataset.record;
        let selId = event.currentTarget.dataset.recordId;
      
                
    	var action = component.get("c.setWarehouse");
        var recordId = component.get("v.parentRecordId");
        //var selectedWar = event.getSource().get("v.value");
        
        var selectedWar = component.get("v.warehouseList")[selRec];
        
        component.set("v.spinner", true);
        console.log('@@@@ recordId:' + recordId);
        action.setParams({
            'recordId':recordId,
            'warehouse': JSON.stringify(selectedWar)
		})
     	
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
            var prods = response.getReturnValue();
          		var resultsToast = $A.get("e.force:showToast");
                			resultsToast.setParams({
                    		"title":$A.get('$Label.c.XC_CL_Success'),
                    		"message": $A.get('$Label.c.XC_CL_Success'),
                        	"duration": "2000",
                        	"type": 'Success'
                		});
                       resultsToast.fire();
                        setTimeout(function () {
                            $A.get('e.force:refreshView').fire()
                        }, 10);
                       $A.get("e.force:closeQuickAction").fire();
            }    else{   
                    var resultsToast = $A.get("e.force:showToast");
                			resultsToast.setParams({
                    		"title":$A.get('$Label.c.XC_CL_Error'),
                    		"message": $A.get('$Label.c.XC_CL_Error'),
                        	"duration": "4000",
                        	"type": 'Error'
                		});
                       resultsToast.fire();
                       $A.get("e.force:closeQuickAction").fire();                     
                    
            }    
        });
        $A.enqueueAction(action);
	},
    doSearchHelper : function(component, event, helper) {
     	//var value = helper.getParameterByName(component , event, 'inContextOfRef');
        //var context = JSON.parse(window.atob(value));
		
        var pageRef = component.get("v.pageReference");
        if(pageRef!=null && pageRef!=undefined){
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        component.set("v.parentRecordId", addressableContext.attributes.recordId);
        }else{
            component.set("v.parentRecordId", component.get("v.recordId"));
        }
        //component.set("v.parentRecordId", context.attributes.recordId);
        console.log('@@@@ id:' + component.get("v.parentRecordId"));
		helper.getWarehouseListHelper(component, event, helper);

       
	}
})