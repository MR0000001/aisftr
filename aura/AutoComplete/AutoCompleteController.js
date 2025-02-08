({
    searchHandler : function (component, event, helper) {
        
        const searchString = event.target.value;
        var searchStringValue = searchString;
        if (searchString.length >= 3) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchFunction")) {
                clearTimeout(component.get("v.inputSearchFunction"));
            }

            var inputTimer = setTimeout($A.getCallback(function () {
                helper.searchRecords(component, searchString);
            }), 1000);
            component.set("v.inputSearchFunction", inputTimer);
        } else{
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
    },

    optionClickHandler : function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
        var structureId = component.get("v.selectedOption");
       console.log("id selezionato in autocompletecontroller ",component.get("v.selectedOption"));
       var appEvent = $A.get("e.c:ResultEvent");
       appEvent.setParams({"PassStructure" : structureId });
       appEvent.fire();
    },

    clearOption : function (component, event, helper) {
        console.log("sei in clear option");
        component.set("v.results", []); 
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
        var appEvent = $A.get("e.c:DeleteStructureEvent");
        appEvent.setParams({"DeleteStructure" : "v.selectedOption" });
        appEvent.fire();
    },

    fireEventComponent : function(component,event,helper){

        var appEvent = $A.get("e.c:ResultEvent");
        appEvent.setParams({"PassStructure" : "v.selectedOption" });
        appEvent.fire();
    },

})