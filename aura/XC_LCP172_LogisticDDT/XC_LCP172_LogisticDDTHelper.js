({
	doInit : function(component, event, helper) {
        var action = component.get("c.populateFieldDDT");
        var goodIssueId = component.get("v.recordId");
        console.log('@@@@ doInit HELPER:' + goodIssueId);
        action.setParams({
            'goodIssueId':goodIssueId
		})
     		var resultsToast = $A.get("e.force:showToast");	
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@ getListConfCommercial - state:' + state);
            console.log('@@@ a.getReturnValue():' + response.getReturnValue());
           
            if (state === "SUCCESS") { 
          		if(response.getReturnValue()!='' && response.getReturnValue()!='KO') {
                	
                    	resultsToast.setParams({
                    		"title":'Generate DDT',
                    		"message": 'Generate document Success!!',
                        	"duration": "4000",
                        	"type": 'Success'
                		});
                       resultsToast.fire();
                      
                }    
            }else{
            	   
                	resultsToast.setParams({
                    		"title":'Generate DDT',
                    		"message": 'Generate document failed!!!',
                        	"duration": "4000",
                        	"type": 'Error'
                		});
                     resultsToast.fire();
            }
            $A.get("e.force:closeQuickAction").fire();
	        $A.get("e.force:refreshView").fire();
        });
       
        $A.enqueueAction(action);
        
   }  
})