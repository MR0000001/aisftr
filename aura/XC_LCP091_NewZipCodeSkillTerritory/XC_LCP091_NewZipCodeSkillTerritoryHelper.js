({
    doInit : function(component, event, helper) { 
         component.set("v.spinnerControl", true);
        console.log("@@inside do init");
        //this.populatePickValues(component, event, helper);
        var action = component.get("c.checkRootTerritory");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var retValue = response.getReturnValue();
                    if(retValue === true){ 
                        console.log('entrato in root'); 
                        component.set("v.isRoot", retValue); 
                        helper.checkTerritoryForProfile(component, event, helper);

                    }else{
                        component.set("v.spinnerControl", false);    
                        helper.populateProvinceValuesFromRoot(component, event, helper); 

                    }
            } 
            });
        $A.enqueueAction(action); 

 },
 
  checkTerritoryForProfile : function(component, event, helper){
       
        console.log("@@inside checkTerritoryForProfile");
        //this.populatePickValues(component, event, helper);
        var action = component.get("c.checkRootTerritoryForProfiles");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var retValue = response.getReturnValue();
                    if(retValue === true){ 
                        console.log('entrato in cannotInsert');
                        helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_CannotInsertZipCodeSkill"), "error");
                    }
                    else{
                        helper.populatePickValues(component, event, helper);
                        helper.populateSkillValues(component, event, helper);
                    }  
                }
                component.set("v.spinnerControl", false);    
                });
        $A.enqueueAction(action); 
   },


  populateSkillValues : function(component, event, helper){ 
        var action = component.get("c.getSkillForTerritory");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var skillList = a.getReturnValue();
            console.log('@@@@' + skillList);
            if (state === "SUCCESS"){

                component.set('v.skillOptions', helper.populatePicklist(component, event, helper, skillList)); 
            }
        }); 
        $A.enqueueAction(action);
    },

    populatePickValues : function(component, event, helper){ 
        var action = component.get("c.getCountry");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var country = a.getReturnValue();
                if(country && country != null){
                    component.set('v.country', country);
                    this.getProvinces(component, event, helper, country);
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    
    getProvinces : function(component, event, helper, country){
        var pathProvinces = $A.get("$Resource.XC_STR002_MapCountryProvinces");
        var req = new XMLHttpRequest();
        req.open("GET", pathProvinces);
        req.addEventListener("load", $A.getCallback(function() {
            var JSONMapCountryProvinces = JSON.parse(req.response);
            var listProvinces = JSONMapCountryProvinces[country.toUpperCase()]['listProvinces'];
            console.log(listProvinces);
            if(listProvinces && listProvinces.length>0){  
                component.set('v.provinceOptions', helper.populatePicklist(component, event, helper, listProvinces)); 
            }  
        }));                
        req.send(null); 
    },
    
    populateProvinceValuesFromRoot : function(component, event, helper, country){
        var action = component.get("c.getRootProvince");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var listProvinces = a.getReturnValue();
                if(listProvinces.length >0){
                    component.set('v.provinceOptions', helper.populatePicklist(component, event, helper, listProvinces));             
                }  
                else{
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_ProvinceFromRoot"), "error"); 
                }  
            }
        });  
        $A.enqueueAction(action);
    },

     getZipCodeFromRoot : function(component, event, helper, province){
        var action = component.get("c.getZipCodeFromRoot");
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'province' : province
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var listZipCode = a.getReturnValue();
                    component.set('v.zipOptions', helper.populatePicklist(component, event, helper, listZipCode));             
                   
            }
        }); 
        $A.enqueueAction(action);
    },

    getSkillFromRoot : function(component, event, helper, province, zipCode){
        var action = component.get("c.getSkillForTerritoryFromRoot");
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'province' : province,
            'zipCode' : zipCode
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var skillList = a.getReturnValue();
            console.log('@@@@' + skillList);
            if (state === "SUCCESS"){

                component.set('v.skillOptions', helper.populatePicklist(component, event, helper, skillList)); 
            }
        }); 
        $A.enqueueAction(action);
    },



    populatePicklist : function(component, event, helper, listOptions){
        var opts = [];
        for (var i = 0; i < listOptions.length; i++) {
            opts.push({
                value: listOptions[i],
                label: listOptions[i]
            });
        } 
        return opts;
    },
    
    getZipCodes : function(component, event, helper, provinceCode){ 
        var path = $A.get("$Resource.XC_STR003_SpainMapProvinceZipCodes");
        var req = new XMLHttpRequest();
        req.open("GET", path);
        req.addEventListener("load", $A.getCallback(function() {
            var JSONListZipCodes = JSON.parse(req.response);
            var listZipCodes = JSONListZipCodes[provinceCode];
            console.log(listZipCodes);
            if(listZipCodes && listZipCodes.length>0){ 
                component.set('v.zipOptions', helper.populatePicklist(component, event, helper, listZipCodes)); 
            }
        }));                
        req.send(null);
    },
    
    getProvinceCode : function(component, event, helper, province){ 
        var path = $A.get("$Resource.XC_STR002_MapCountryProvinces");
        var req = new XMLHttpRequest();
        req.open("GET", path);
        req.addEventListener("load", $A.getCallback(function() {
            var country = component.get('v.country');
            var JSONListZipCodes = JSON.parse(req.response);
            var provinceCode = JSONListZipCodes[country.toUpperCase()]['mapNameCode'][province];
            console.log(provinceCode);
            if(provinceCode && provinceCode != null){ 
                helper.getZipCodes(component, event, helper, provinceCode); 
            }
        }));                
        req.send(null);
        component.set("v.disabledProvince", true);
    },
    
    saveSkillTerritory : function(component, event, helper, province , zipCode){
        console.log(province);
        console.log(zipCode);
        var action = component.get("c.saveSkillTerritory"); 
        // Modifica Salvatore Agrillo (06/05/2019)
        var mapSkillTerritory = {
            'recordId' : component.get("v.recordId"),
            'zipCode' : zipCode,
            'province' : province,
            'skillList' : component.get("v.selectedSkill")
        }
        var mapSkillTerritoryString = JSON.stringify(mapSkillTerritory);
        action.setParams({
            'mapSkillTerritoryString': mapSkillTerritoryString
        });

        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var result = a.getReturnValue();
                if(result.success){
                    helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_SkillTerritoryCreated") , "success"); 
                     $A.get("e.force:closeQuickAction").fire();
                     $A.get("e.force:refreshView").fire();
                   // helper.navigateToServiceResourceSkill(component, event, helper, result.recordId);
                }
                else{
                    helper.showToast(component, event, helper, result.resultMessage, "error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper, message, type) {
        component.set("v.spinnerControl",false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get("e.force:closeQuickAction").fire();
    },
    
    navigateToServiceResourceSkill : function(component, event, helper, newRecordId) {
        var navService = component.find("navService");
        var targetPageReference = { 
            type: 'standard__recordPage',
            attributes: {
                "recordId": newRecordId,
                "actionName": "view"
            }
        };
        navService.navigate(targetPageReference);
    }
})