({
    init : function(component, event, helper) {
        helper.doInit(component, event, helper); 
    },
    
    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    confirm :  function(component, event, helper) {
         console.log("v.selectedZipCodeRoot");
         console.log("v.selectedProvinceRoot");
        if(component.get("v.selectedProvince") != null && component.get("v.selectedZipCode") != null){
            helper.saveSkillTerritory(component, event, helper, component.get("v.selectedProvince"), component.get("v.selectedZipCode")  );
        }else if(component.get("v.selectedProvinceRoot") != null && component.get("v.selectedZipCodeRoot") != null ){
            helper.saveSkillTerritory(component, event, helper, component.get("v.selectedProvinceRoot"), component.get("v.selectedZipCodeRoot")  );
        }
       
    },
    
    populateZipCodePicklist : function(component, event, helper) {
        var province = component.get("v.selectedProvince");
        console.log(province);
        helper.getProvinceCode(component, event, helper, province);
    } ,
    populateZipCodeFromRoot : function(component, event, helper) {
        var province = component.get("v.selectedProvinceRoot");
        console.log(province);
        helper.getZipCodeFromRoot(component, event, helper, province);
    }  ,
    populateSkillFromRoot : function(component, event, helper) {
        var province = component.get("v.selectedProvinceRoot");
        var zipCode = component.get("v.selectedZipCodeRoot");
        console.log(province);
        helper.getSkillFromRoot(component, event, helper,province, zipCode); 
    } 
})