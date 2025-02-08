({  doInit : function(component, event, helper) { 
    component.set("v.spinnerControl", true);
    var action = component.get("c.checkRootTerritoryInEdit");
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
                //helper.populateProvinceValuesFromRoot(component, event, helper); 
                helper.setInitValues(component, event, helper); 
                
            }
        } 
    });
    $A.enqueueAction(action); 
},
  
  checkTerritoryForProfile : function(component, event, helper){
      console.log("@@inside checkTerritoryForProfile");
      var action = component.get("c.checkRootTerritoryForProfilesInEdit");
      action.setParams({"recordId" : component.get("v.recordId")});
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS"){
              var retValue = response.getReturnValue();
              if(retValue === true){ 
                  console.log('entrato in cannotInsert');
                  $A.get("e.force:closeQuickAction").fire();
                  helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_CannotInsertZipCodeSkill"), "error");
              }
              else{
                  helper.setInitValues(component, event, helper);
                  helper.populatePickValues(component, event, helper);
                  helper.populateSkillValues(component, event, helper);
              }  
          }
          component.set("v.spinnerControl", false);    
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
          var listProvinces = JSONMapCountryProvinces[country]['listProvinces'];
          console.log(listProvinces);
          if(listProvinces && listProvinces.length>0){  
              component.set('v.provinceOptions', helper.populatePicklist(component, event, helper, listProvinces)); 
          }  
          helper.setInitValues(component, event, helper); 
      }));                
      req.send(null); 
  },
  
  setInitValues  : function(component, event, helper){ 
      var isRoot =  component.get("v.isRoot");
      var action = component.get("c.setZipCodeValues");
      action.setParams({
          'recordId' : component.get("v.recordId")
      });
      action.setCallback(this, function(a) {
          var state = a.getState();
          if (state === "SUCCESS"){
              var result = a.getReturnValue();
              if(result && isRoot){
                  var names = result.XC_ListOfSkills__c.split(';');
                  component.set("v.selectedProvince", result.XC_Province__c); 
                  component.set("v.selectedSkill", result.XC_ListOfSkillNames__c);
                  component.set("v.existingZipCode", result.XC_ZipCode__c);

                  console.log('@@@@setInitValues' +  component.get("v.selectedSkill")); 
                  helper.getProvinceCode(component, event, helper, result.XC_Province__c, true); 
                  component.set("v.seeSkills",true);
              }
              else if(result && !isRoot){
                  component.set("v.selectedProvinceRoot", result.XC_Province__c); 
                  component.set("v.selectedZipCodeRoot", result.XC_ZipCode__c);
                  component.set("v.selectedRootSkill", result.XC_ListOfSkillNames__c);
                  console.log('@@@@selectedProvinceRoot' +  component.get("v.selectedProvinceRoot")); 
                  console.log('@@@@selectedZipCodeRoot' +  component.get("v.selectedZipCodeRoot")); 
                  console.log('@@@@setInitValues' +  component.get("v.selectedRootSkill")); 
                  helper.populateProvinceValuesFromRoot(component, event, helper);
                  helper.getZipCodeFromRoot(component, event, helper, result.XC_Province__c);
                  helper.getSkillFromRoot(component, event, helper, result.XC_Province__c, result.XC_ZipCode__c);
                  
              }
          }             
      });
      $A.enqueueAction(action); 
  },  
  
  populateSkillValues : function(component, event, helper){ 
      var action = component.get("c.getSkillForTerritoryInEdit");
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
  
  
  populateProvinceValuesFromRoot : function(component, event, helper, country){
      var action = component.get("c.getRootProvinceInEdit");
      action.setParams({
          'recordId' : component.get("v.recordId")
      });
      action.setCallback(this, function(a) {
          var state = a.getState();
          if (state === "SUCCESS"){
              var listProvinces = a.getReturnValue();
              component.set('v.provinceOptions', helper.populatePicklist(component, event, helper, listProvinces));             
          }
      }); 
      $A.enqueueAction(action);
  },

   getZipCodeFromRoot : function(component, event, helper, province){
        var action = component.get("c.getZipCodeFromRootInEdit");
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'province' : province
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var listZipCode = a.getReturnValue();
                    component.set('v.zipOptions', helper.populatePicklist(component, event, helper, listZipCode));             
                    console.log('ZipOptions-->' + component.get('v.zipOptions')); 
            }
        }); 
        $A.enqueueAction(action);
    },

    getSkillFromRoot : function(component, event, helper, province, zipCode){
        var action = component.get("c.getSkillForTerritoryFromRootInEdit");
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
                component.set("v.seeSkills",true); 
            }
        }); 
        $A.enqueueAction(action);
    },
  
  getProvinceCode : function(component, event, helper, province, isInit){ 
      var path = $A.get("$Resource.XC_STR002_MapCountryProvinces");
      var req = new XMLHttpRequest();
      req.open("GET", path);
      req.addEventListener("load", $A.getCallback(function() {
          var country = component.get('v.country');
          var JSONListZipCodes = JSON.parse(req.response);
          var provinceCode = JSONListZipCodes[country]['mapNameCode'][province];
          console.log(provinceCode);
          if(provinceCode && provinceCode != null){ 
              helper.getZipCodes(component, event, helper, provinceCode, isInit); 

          }
      }));                
      req.send(null);
  },
  
  getZipCodes : function(component, event, helper, provinceCode, isInit){ 
      var path = $A.get("$Resource.XC_STR003_SpainMapProvinceZipCodes");
      var req = new XMLHttpRequest();
      req.open("GET", path);
      req.addEventListener("load", $A.getCallback(function() {
          var JSONListZipCodes = JSON.parse(req.response);
          var listZipCodes = JSONListZipCodes[provinceCode];
          if(listZipCodes && listZipCodes.length>0){ 
              component.set('v.zipOptions', helper.populatePicklist(component, event, helper, listZipCodes)); 
              if(isInit){         
                  component.set('v.selectedZipCode', component.get('v.existingZipCode')); 

              }
          }
      }));                
      req.send(null);
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

      updateZipCodeSkillTerritory : function(component, event, helper, province , zipCode, skillList){
        var action = component.get("c.updateSkillTerritory"); 
        // Modifica Salvatore Agrillo (07/05/2019)
        var mapZipCodeSkillTerritory = {
            'recordId' : component.get("v.recordId"),
            'zipCode' : zipCode,
            'province' : province,
            'skillList' : skillList
        }
        var mapZipCodeSkillTerritoryString = JSON.stringify(mapZipCodeSkillTerritory);
        action.setParams({
            'mapZipCodeSkillTerritoryString': mapZipCodeSkillTerritoryString
        });

        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                if(result.success){
                    helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_SkillTerritoryUpdated") , "success"); 
                    this.closeCurrentTab(component, event, helper, result.recordId);
                    $A.get("e.force:closeQuickAction").fire();
                    setTimeout(function(){
                      $A.get('e.force:refreshView').fire();
                      }, 500);
   
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
  },
  
    closeCurrentTab : function(component, event, helper, toRedirect) {
       var workspaceAPI = component.find("workspace");
       var navigateEvent = $A.get("e.force:navigateToSObject");
       navigateEvent.setParams({ "recordId": toRedirect, "slideDevName": "detail", "isredirect": true });    
       navigateEvent.fire();
    }
 })