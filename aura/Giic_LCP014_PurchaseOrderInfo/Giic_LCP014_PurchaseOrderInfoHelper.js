({
    
    
    
    manageForm : function(component, event, helper){     
        
          if(component.get("v.record")!=null && component.get("v.record")!=undefined ){    
			if(component.get("v.record").giic_WarehouseLimitExceeded__c){
				//helper.showToast(component,event,helper,'Attention, warehouse limit exceeded!', 'error');
				component.set("v.isOpenWarehouse" , true);
			}
              
			if(component.get("v.record").giic_BudgetLimitExceeded__c){
				//helper.showToast(component,event,helper,'Attention, budget limit exceeded!', 'error');
				component.set("v.isOpenBudget" , true);
			}
              
              
              if(component.get("v.record").giic_MultipleSuppliersForProduct__c){
				//helper.showToast(component,event,helper,'Attention, budget limit exceeded!', 'error');
				component.set("v.isOpenMultiple" , true);
			}
              var Q1 = component.get("v.isOpenWrongQuantity");
              console.log("isOpenWrongQuantity " + Q1)
              console.log("giic_ProductsWithWrongQuantity__c " + component.get("v.record").giic_ProductsWithWrongQuantity__c)

			  console.log("v.record " , JSON.parse(JSON.stringify(component.get("v.record"))))
              if(component.get("v.record").giic_ProductsWithWrongQuantity__c   && component.get("v.record").giic_ProductsWithWrongQuantity__c != undefined){
				//helper.showToast(component,event,helper,'Attention, budget limit exceeded!', 'error');
				component.set("v.isOpenWrongQuantity" , true);
                Q1 = component.get("v.isOpenWrongQuantity");
                console.log("isOpenWrongQuantity " + Q1)

			}
            
        }
        
        
    },
    
    
    
	  showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
    
    
})