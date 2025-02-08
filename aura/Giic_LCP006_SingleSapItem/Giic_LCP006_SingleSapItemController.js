({
	doInit : function(component, event, helper) {
		var divisionToDefinition = component.get("v.divisionToDefinition");
        var purchaseOrganizationToDefinition = component.get("v.purchaseOrganizationToDefinition");
        var divisionMap =  component.get("v.divisionMap");
        var purchaseOrganizationMap = component.get("v.purchaseOrganizationMap");
        var applicantUnitMap = component.get("v.applicantUnitMap");
        var applicantUnitNameToDef = component.get("v.applicantUnitNameToDef");
        var applicantUnitDefault = component.get("v.applicantUnitDefault");
        var applicantUnitOnPBE = component.get("v.applicantUnitOnPBE");
        var plantOnPBE = component.get("v.plantOnPBE");
         console.log('divisionMap ='+JSON.stringify(divisionMap));
         console.log('Division = '+component.get("v.division"));
          console.log('divisionOptions = '+component.get("v.divisionOptions"));
        console.log('Requesting unit = '+applicantUnitDefault);
        console.log('applicantUnitNameToDef = '+JSON.stringify(applicantUnitNameToDef));
         var opts = [];
                /*
                divisionMap.forEach(function(entry) {
                    opts.push({
      				value: entry['key'],
      				label: entry['value']
    				});
                })  */
        
        for(var i=0;i<divisionMap.length;i++){
            var dDefinition = divisionToDefinition[i].value;
             if(dDefinition == undefined || dDefinition == 'undefined'){
                 dDefinition = '';
             }else{
                 dDefinition = ' - '+dDefinition;
             }
                    opts.push({
      				value: divisionMap[i].key,
      				label: divisionMap[i].value+dDefinition
    				});
            
        }
                
                
        		component.set('v.divisionOptions', opts);
         var opts2 = [];
        /*
                purchaseOrganizationMap.forEach(function(entry) {
                    opts2.push({
      				value: entry['key'],
      				label: entry['value']
    				});
                })
                
                */
         for(var i=0;i<purchaseOrganizationMap.length;i++){
             var definition = purchaseOrganizationToDefinition[i].value;
             if(definition == undefined){
                 definition = '';
             }else{
                 definition = ' - '+definition;
             }
                    opts2.push({
      				value: purchaseOrganizationMap[i].key,
      				label: purchaseOrganizationMap[i].value+definition
    				});
            
        }
        		component.set('v.purchaseOptions', opts2);
        
        
        
         var opts3 = [];
                applicantUnitMap.forEach(function(entry) {
                    var alabel = '';
                    if(applicantUnitNameToDef.hasOwnProperty(entry['key'])){
                        alabel = entry['value'] +' - '+applicantUnitNameToDef[entry['key']];
                    }else{
                        alabel = entry['value'];
                    }
                    opts3.push({
      				value: entry['key'],
      				label: alabel
    				});
                })
                if(applicantUnitDefault!=null && applicantUnitDefault!=undefined && applicantUnitDefault!=''){
                    opts3.push({
      				value: applicantUnitDefault,
      				label: applicantUnitDefault
    				});
                    
                }
        		component.set('v.appUnitOptions', opts3);
        
        var d = component.get("v.division");
        var isForSpain = component.get("v.isForSpain");
        var isForClosedContract = component.get("v.isForClosedContract");
        console.log('isForSpain = '+isForSpain);
        if((d!=null && d!=undefined && d!='' && !isForSpain && plantOnPBE) || (isForClosedContract && d!=null && d!=undefined && d!='') ){
           console.log('d = '+d);
           component.set("v.plantDisabled", true);
        }
        
        if((applicantUnitDefault!=null && applicantUnitDefault!=undefined && applicantUnitDefault!='' && !isForSpain && applicantUnitOnPBE) || (isForClosedContract && applicantUnitDefault!=null && applicantUnitDefault!=undefined && applicantUnitDefault!='')){
           console.log('applicantUnitDefault = '+applicantUnitDefault);
           component.set("v.unitDisabled", true);
        }
        
	},
    
    
    setDDefinition : function(component, event, helper) {
         var divisionToDefinition = component.get("v.divisionToDefinition");
         var selectedOptionValue = event.getParam("value");
         for(var key in divisionToDefinition){
            if(divisionToDefinition[key].key == selectedOptionValue){
                 var definition = divisionToDefinition[key].value;
         		 component.set("v.definitionOfDivision", definition);
            }
         }
        
        
    },
    
    setOrgDefinition : function(component, event, helper) {
         var purchaseOrganizationToDefinition = component.get("v.purchaseOrganizationToDefinition");
         var selectedOptionValue = event.getParam("value");
         for(var key in purchaseOrganizationToDefinition){
            if(purchaseOrganizationToDefinition[key].key == selectedOptionValue){
                 var definition = purchaseOrganizationToDefinition[key].value;
         		 component.set("v.definitionOfPurchaseOrganization", definition);
            }
         }
    
	},
    
    closeLine :  function(component, event, helper) {
    	component.destroy();   
    },
    
    saveLineValues  :  function(component, event, helper) {
        helper.saveLineValues(component, event, helper);
    }
})