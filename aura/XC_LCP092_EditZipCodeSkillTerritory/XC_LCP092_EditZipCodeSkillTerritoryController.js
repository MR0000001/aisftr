({
    init : function(component, event, helper) { 
       helper.doInit(component, event, helper);
    },
    
    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    confirm :  function(component, event, helper) {
        if(component.get("v.selectedProvince") != null && component.get("v.selectedZipCode") != null && component.get("v.selectedSkill") != null){
            var selectedSkill = component.get("v.selectedSkill");
            console.log(component.get("v.selectedSkill"));
            helper.updateZipCodeSkillTerritory(component, event, helper, component.get("v.selectedProvince"), component.get("v.selectedZipCode"), component.get("v.selectedSkill"));
        }else if(component.get("v.selectedProvinceRoot") != null && component.get("v.selectedZipCodeRoot") != null && component.get("v.selectedRootSkill") != null){
            helper.updateZipCodeSkillTerritory(component, event, helper, component.get("v.selectedProvinceRoot"), component.get("v.selectedZipCodeRoot"),component.get("v.selectedRootSkill"));
        }
    }  ,
   /* populateZipCodeFromRoot : function(component, event, helper) {
        var province = component.get("v.selectedProvinceRoot");
        console.log('province in controller' + province);
        helper.getZipCodeFromRoot(component, event, helper, province);
    }  ,
    populateSkillFromRoot : function(component, event, helper) {
        var province = component.get("v.selectedProvinceRoot");
        var zipCode = component.get("v.selectedZipCodeRoot");
        console.log(province);
        helper.getSkillFromRoot(component, event, helper,province, zipCode); 
    } ,*/
    
    populateZipCodePicklist : function(component, event, helper) {
        var province = component.get("v.selectedProvince");
        console.log(province);
        helper.getProvinceCode(component, event, helper, province, false);
    } 
})