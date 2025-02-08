({
    invoke :  function (component, event, helper) {
        if(component.get("v.Templatechoice") === "Refresh"){
            $A.get('e.force:refreshView').fire();
        }
        else{
        helper.RetrieveTemplateId(component, event, helper);   
        helper.Populatefields(component, event, helper);
        }
        }
    })