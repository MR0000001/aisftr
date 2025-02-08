({
	doInit : function(component, event, helper) {
        //let action = component.get("c.retrieveLegalEntities");
        let action = component.get("c.retrieveLegalEntityData");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS"){
                let legalEntityData = response.getReturnValue();
                component.set("v.userCountry", legalEntityData.userCountry);
                component.set("v.userLE", legalEntityData.userLE);
                component.set("v.country", legalEntityData.country);
                component.set("v.consentsOptions", legalEntityData.consentsOptions);
                component.set("v.legalEntityConsents", legalEntityData.legalEntityConsents);
                /*let legalEntities = response.getReturnValue();
                if(legalEntities!==null){
                    component.set("v.maxNumRows",legalEntities.length-1);
                }*/
                helper.addRow(component, event, helper);
            }else{
                console.debug('@@@@@ LegalEntityDynamicItem - Error on calling retrieveLegalEntityData...');
            }
            //helper.addRow(component, event, helper);
        });
        $A.enqueueAction(action);
	},

	createObjectData: function(component, event, helper) {
        let rowItemList = component.get("v.consentsInstance");
        rowItemList.push({
            'sobjectType': 'XC_LegalEntityConsent__c',
            'XC_LegalEntity__c': component.get("v.userLE"),
            'XC_GiveDataTo__c': 'Yes',
            'XC_CompanyConsentVersion__c': '',
            'XC_KeepMeUpdateOnProducts__c': '',
            'XC_MarketingConsentVersion__c': '',
            'XC_GiveConsentToDataProcessing__c': '',
            'XC_ProfilingConsentVersion__c': '',
            'XC_LeCountry__c': component.get("v.userCountry"),
            'legalEntityConsents': component.get("v.legalEntityConsents")
        });
        
        component.set("v.consentsInstance", rowItemList);
        if(component.get("v.userLE")!=null && component.get("v.userLE")!=undefined && component.get("v.userLE")!='' ){
            helper.setLegalEntityConsents(component, event, helper);
        }
    },

	addRow: function(component, event, helper) {
        helper.createObjectData(component, event, helper);
        /*let allRowsList = component.get("v.consentsInstance");
        let maxNumRows = component.get("v.maxNumRows");
        
        if(allRowsList.length <  maxNumRows){
            helper.createObjectData(component, event, helper);
        } else {
            helper.showToast(component, 'Maximum number of legal entities reached', 'warning');
        }*/
    },
 
    removeDeletedRow: function(component, event, helper) {
        let index = event.getParam("indexVar") | 0;
        let allRowsList = component.get("v.consentsInstance");
        allRowsList.splice(index, 1);
        component.set("v.consentsInstance", allRowsList);
        //update the parent list
        helper.setLegalEntityConsents(component, event, helper);

        if(allRowsList.length===0){
            helper.createObjectData(component, event, helper);
        }
    },
	
	setLegalEntityConsents: function(component, event, helper) {
		let rows =  component.get("v.consentsInstance");
		let legalEntities = [];
		//remove empty row
		rows.forEach(function(row) {
			if(!(row.XC_LegalEntity__c === '')){
				legalEntities.push(row);
			}
		});

		let eventLE = $A.get("e.c:XC_LCE_SetLEConsentsObject");
		eventLE.setParams({
			"consentsLE"          : legalEntities,
            "robinsonCustomer"    : component.get("v.robinsonCustomer"),
            "thirdPartiesCheck"   : component.get("v.thirdPartiesCheck"),
            "thirdPartiesVersion" : component.get("v.thirdPartiesVersion"),
            "relatedObject"       : component.get("v.relatedObject")
		}); 
		eventLE.fire();
	},
	
	setLegalEntityConsentsNEW: function(component, event, helper) {
		let rows =  component.get("v.consentsInstance");
		let legalEntities = [];
		//remove empty row
		rows.forEach(function(row) {
			if(!(row.XC_LegalEntity__c === '')){
				legalEntities.push(row);
			}
		});
        
        let eventLE = component.getEvent("XC_LCE110_SetLegalEntityConsents");
		eventLE.setParams({
			"consentsLE"          : legalEntities,
            "robinsonCustomer"    : component.get("v.robinsonCustomer"),
            "thirdPartiesCheck"   : component.get("v.thirdPartiesCheck"),
            "thirdPartiesVersion" : component.get("v.thirdPartiesVersion"),
            "relatedObject"       : component.get("v.relatedObject")
		}); 
		eventLE.fire();
	},

	showToast : function(component, message, type) {
		let typeValue = type | 'warning';
		console.log('@#@#@#@#@#@ LegalEntityDynamicTable message: '+message);
		component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": typeValue
        });
    }
})