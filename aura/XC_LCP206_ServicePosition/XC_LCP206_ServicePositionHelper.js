({
	init: function(component, event, helper)  {
        
        var action = component.get("c.retrivePoLInformation");
        action.setParams({
            'recordId': component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue) {
                if(retValue.length>0 && retValue[0].resultMessage==''){  
                	component.set("v.POLList", retValue);
                    component.set("v.lineOk", true);
                   
                }else{
                    component.set("v.errorMessage", 'No Lines Found');
                    if(retValue.length>0){
                        component.set("v.errorMessage2", retValue[0].resultMessage);
                    } 
                }
               
            }
            else{
                
                 console.log('errore');
            }
        }); 
        $A.enqueueAction(action); 
        
    },
       
		
	
})