({
	doInit : function(component, event, helper) {
		var checkBox = [];
        var actionContactList = component.get("c.getContactListFromAccount");
        
        actionContactList.setParams({
            accountId : component.get("v.accountId")
        });
        
        actionContactList.setCallback(this, function(response) {
            component.set("v.contacts", response.getReturnValue());
            console.log(response.getReturnValue);
            for (var i = 0; i < response.getReturnValue().length; i++){
                checkBox.push(false);
            } 
            component.set("v.flags", checkBox);

        });
        $A.enqueueAction(actionContactList);
	},
  
    
    onCheckContactSelection :  function (component, event, helper) {
        
        var id = event.getSource().get("v.text");
        var flags = component.get("v.flags");
        var contacts = component.get("v.contacts");
        var actualSelection = event.getSource().get("v.value");
        
        //Gets the checkbox group based on the checkbox id
		var availableCheckboxes = component.find('rowSelection');
        var resetCheckboxValue  = false;
        if (Array.isArray(availableCheckboxes)) {
            //If more than one checkbox available then individually resets each checkbox
            availableCheckboxes.forEach(function(checkbox) {
            checkbox.set('v.value', resetCheckboxValue);
            }); 
        } else {
            //if only one checkbox available then it will be unchecked
            availableCheckboxes.set('v.value', resetCheckboxValue);
        }
        
        for(var i = 0;i< flags.length ; i++){
            flags[i] = false;
        }
		console.log(contacts[id]);
        if(actualSelection){
    		flags[id] = actualSelection;
            component.set("v.contactId", contacts[id].Id);
            
		}else{ 
            component.set("v.contactId","");
            flags[id] = false;
 		}
        
 		component.set("v.flags",flags);
        console.log(component.get("v.contactId"));
        console.log(component.get("v.accountId"));
        event.getSource().set("v.value",actualSelection);
	
     }
})