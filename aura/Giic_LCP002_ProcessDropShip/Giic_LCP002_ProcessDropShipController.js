({
	doInit : function(component, event, helper) {
		helper.init(component, event, helper);
        
	},
    
    closeModal : function(component, event, helper) {
      
            $A.get("e.force:closeQuickAction").fire();
    },
    
    updateSelectedRow : function(component, event, helper){
        helper.doLogicForSelectedRow(component, event, helper);
       
    },
    
    
    
    checkReq : function(component, event, helper){
         helper.checkRequest(component, event, helper);
    },
    
    startReceipt : function (component, event, helper) {
        component.set("v.showSpinner" , true);
        helper.createReceipt(component, event, helper) ;
        
    },
    
    handleSaveLine : function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log('draftValues ='+JSON.stringify(draftValues));
    	helper.handleSaveEdition(component, event, helper, draftValues);
    },
    
    setSerialMap  : function (component, event, helper) {
        var purchaseOrderLineId = event.getParam("purchaseOrderLineId");
        var serialList = event.getParam("serialList");
        var lotNameToQuantityMap = event.getParam("lotMap");
        var map  = new Map();
        var map2 = new Map();
        map = component.get("v.mapPolToSerialList");
        map2 = component.get("v.totalLotMap");
        map[purchaseOrderLineId] = serialList;
        map2[purchaseOrderLineId] = lotNameToQuantityMap;
        component.set("v.mapPolToSerialList", map);
        component.set("v.totalLotMap", map2);
        console.log('Mappa : '+JSON.stringify(component.get("v.mapPolToSerialList")));
        component.set("v.body", '');
        helper.showToast(component, event, helper, 'Serial numbers saved!', 'success');
    },
    
     manageData  : function (component, event, helper) {

        var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); 
		var yyyy = today.getFullYear();   
		today = yyyy + '-' + mm + '-' + dd;
        console.log('isActiveNR2626 ='+component.get("v.isActiveNR2626"));
     	if(component.get("v.purchaseOrder")!=null && component.get("v.purchaseOrder")!=undefined ){    
			if(component.get("v.purchaseOrder").gii__DropShip__c){
				component.set("v.isDropShip" , true);
                component.set("v.isRequired" , false);
                component.set('v.receiptDate', today);
                component.set("v.cmpTitle" , 'Process DropShip');
                component.set('v.deliveryDate', today);
                /*if(component.get("v.isActiveNR2626")){
                    component.set('v.deliveryDate', null);
                    component.set('v.receiptDate', today);
            		component.set('v.ReadOnly2246', true);
                    component.set('v.qualityControl', true);
                }else{
                    component.set('v.deliveryDate', today);
                    component.set('v.receiptDate',  today);
            		component.set('v.ReadOnly2246', false);
                }*/
            }else{
                component.set("v.isDropShip" , false);
                component.set("v.isRequired" , true);
                component.set('v.receiptDate', today);
                component.set("v.cmpTitle" , 'Receive');
                component.set('v.deliveryDate', today);
                /*if(component.get("v.isActiveNR2626")){
                    component.set('v.deliveryDate', null);
                    component.set('v.receiptDate', today);
            		component.set('v.ReadOnly2246', true);
            		component.set('v.qualityControl', true);
                }else{
                    component.set('v.deliveryDate', today);
                    component.set('v.receiptDate',  today);
            		component.set('v.ReadOnly2246', false);
                }*/
                
            }
              
		}

     },
    
    
     checkNoteRequired : function(component, event, helper){

        if(component.get("v.qualityFail") == true){
            
            component.set("v.QualityNote2246", true);
            helper.checkRequest(component,event,helper);

        }else{
            component.set("v.QualityNote2246", false);
        }
        
     }
    
    
})