({
	doInit : function(component, event, helper) {
		var checkBox = [];
        let actionContactList = component.get("c.getContactListFromAccount");
        
        actionContactList.setParams({
            accountId : component.get("v.recordId")
        });
        
        actionContactList.setCallback(this, function(response) {
            component.set("v.contacts", response.getReturnValue());
            var res = response.getReturnValue();
            var singlePrimaryFound = false;
            for (let i = 0; i < res.length; i++){
                if(res[i].XC_PrimaryContact__c){
                    checkBox.push(true);
                    singlePrimaryFound = true;
                }else{
                	checkBox.push(false);
                }
            } 
            component.set("v.flags", checkBox);
            
            console.log('FLAG ='+checkBox);
            let availableCheckboxes = component.find('rowSelection');
            
            if (Array.isArray(availableCheckboxes)) {
            //If more than one checkbox available then individually resets each checkbox
         
                let i = 0;
                for( i ; i<component.get("v.flags").length ; i++){
                    var checkbox =availableCheckboxes[i];
                    if(component.get("v.flags")[i]){
                        checkbox.set('v.value', true);
                    }else{
                         checkbox.set('v.value', false);
                    }
                          }
                     
        		}else{
                 var checkbox = availableCheckboxes;
                 if(singlePrimaryFound){
               		 checkbox.set('v.value', true);
                 }else{
                     checkbox.set('v.value', false);
                 }
                
            }
               
            
          
            
                
            console.log('CONTATTI:'+JSON.stringify(component.get("v.contacts")));
            

        });
        $A.enqueueAction(actionContactList);
	},
    
    cancel : function(component, event,helper) {
        $A.get('e.force:closeQuickAction').fire();
    },
    
    savePrimary :  function(component, event,helper) {
        component.set("v.showSpinner",true);
        helper.savePrimary(component, event, helper);
    },
  
    
    onCheckContactSelection :  function (component, event, helper) {
        
        let id = event.getSource().get("v.text");
        let flags = component.get("v.flags");
        let contacts = component.get("v.contacts");
        let actualSelection = event.getSource().get("v.value");
        
        //Gets the checkbox group based on the checkbox id
		let availableCheckboxes = component.find('rowSelection');
        let resetCheckboxValue  = false;
        if (Array.isArray(availableCheckboxes)) {
            //If more than one checkbox available then individually resets each checkbox
            availableCheckboxes.forEach(function(checkbox) {
            checkbox.set('v.value', resetCheckboxValue);
            }); 
        } else {
            //if only one checkbox available then it will be unchecked
            availableCheckboxes.set('v.value', resetCheckboxValue);
        }
        
        for(let i = 0;i< flags.length ; i++){
            flags[i] = false;
        }
		console.log('CONTACT SELECTED = '+JSON.stringify(contacts[id]));
        if(actualSelection){
    		flags[id] = actualSelection;
            component.set("v.contactId", contacts[id].Id);
            
		}else{ 
            component.set("v.contactId","");
            flags[id] = false;
 		}
        
 		component.set("v.flags",flags);
        
        event.getSource().set("v.value",actualSelection);
	
     }
})