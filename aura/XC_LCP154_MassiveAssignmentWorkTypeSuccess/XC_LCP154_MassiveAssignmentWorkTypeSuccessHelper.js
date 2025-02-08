/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 16/09/2019
* @description XC_LCP154_MassiveAssignmentWorkTypeSuccess – Component for Massive WorkType/ZipCode Assignment
*/

({
	doInit : function(component, event, helper) {
		console.log('@@@ In init LCP154');
		component.set('v.spinnerControl', true);

		let typeOperation = component.get('v.preferredOperation');
		let displayZipCode = component.get('v.displayRowRemTransf');
		if(typeOperation == 'Add') {
			let listSelectedWorkType = component.get('v.selectedRowsWorktype');
			let listSelectedZipCode = component.get('v.selectedRowsZipCodeAdd');
			let newListZipCodeWorkType = [];
			listSelectedWorkType.forEach(workType => {
				listSelectedZipCode.forEach(zipCode => {
					newListZipCodeWorkType.push({
						XC_ZipCode__c : zipCode,
						XC_WorkTypeName__c : workType.Name
					});
				});
			});
			component.set('v.titleInitialTable', $A.get("$Label.c.XC_CL_MassiveWorkType_TitleAdd"));
			component.set('v.dataInitialTable', newListZipCodeWorkType);
		} 
		else if(typeOperation == 'Remove') {
			component.set('v.titleInitialTable', $A.get("$Label.c.XC_CL_MassiveWorkType_TitleRemove"));
			component.set('v.dataInitialTable', displayZipCode);
		} 
		else {
			component.set('v.titleInitialTable', $A.get("$Label.c.XC_CL_MassiveWorkType_TitleTransfer"));
			component.set('v.dataInitialTable', displayZipCode);
		}

		component.set('v.columnsInitialTable', [
			{label: $A.get("$Label.c.XC_CL_MassAssSkillPostalCode"), fieldName: 'XC_ZipCode__c', type: 'text'},
			{label: $A.get("$Label.c.XC_CL_MassAssSkillListName"),  fieldName: 'XC_WorkTypeName__c', type: 'text'}
		]);

		component.set('v.spinnerControl', false);
	},

	operation : function(component, event, helper) { 
		component.set("v.spinnerControl", true);
		let typeOperation = component.get('v.preferredOperation');
		let idOriginPartner = component.get('v.originPartner');
		let listSelectedWorkType = component.get('v.selectedRowsWorktype');
		let listSelectedZipCode = component.get('v.selectedRowsZipCodeAdd');
		let listExistingPartnerCoverage = component.get('v.dataZipcode');
		let action;

		if(typeOperation == 'Add') {
			action = component.get("c.addOperation");
			action.setParams({ 
				idOriginPartner : idOriginPartner,
				listSelectedWorkType : listSelectedWorkType,
				listSelectedZipCode : listSelectedZipCode,
				listExistingZipCodeWorkType : listExistingPartnerCoverage
			});
		} else if(typeOperation == 'Remove') {
			action = component.get("c.removeOperation");
			action.setParams({ 
				listPartnerCoverageIds : component.get('v.displayZipCode')
			});
		} else {
			action = component.get("c.transferOperation");
			let listIdsPartnerCoverage = component.get('v.displayZipCode');
			let listPartnerCoverage = listExistingPartnerCoverage;
			let listSelectedPartnerCoverage = helper.getObjById(component, listIdsPartnerCoverage, helper, listPartnerCoverage);
			action.setParams({ 
				listPartnerCoverage : listSelectedPartnerCoverage,
				idDestinationPartner : component.get('v.destinationPartner')
			});
		}

		action.setCallback(this, function(a) { 
			var state = a.getState();
			console.log('@@@ State operation ---> ' + state);
			if(state === "SUCCESS") {
				component.set("v.spinnerControl", false);
				var result = a.getReturnValue();
				console.log('@@@ result -> ', result);
				if(result.success) {
					/*var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: $A.get("$Label.c.XC_CL_MassAssSkillRequestSent"),
						key: 'info_alt',
						type: 'success',
						mode: 'pester'
					});
					toastEvent.fire();

					helper.cleanAttributes(component, event, helper);
					$A.get('e.force:refreshView').fire();*/
					component.set('v.showInitialTable', false);
					component.set('v.operationCompleted', true);
					if(typeOperation == 'Add') {
						component.set('v.titleFinalTable', $A.get("$Label.c.XC_CL_MassiveWorkType_Add"));
					} 
					else if(typeOperation == 'Remove') {
						component.set('v.titleFinalTable', $A.get("$Label.c.XC_CL_MassiveWorkType_Remove"));
					} 
					else {
						component.set('v.titleFinalTable', $A.get("$Label.c.XC_CL_MassiveWorkType_Transfer"));
					}
				}
				else {
					component.set("v.spinnerControl",false);
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: $A.get("$Label.c.XC_CL_MassAssSkillErrorAddTitle"),
						message: result.resultMessage,
						key: 'info_alt',
						type: 'error',
						mode: 'dismissible',
						mode: 'pester'
					});
					toastEvent.fire();
				}
			} else {
				component.set("v.spinnerControl",false);
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: $A.get("$Label.c.XC_CL_MassAssSkillErrorAddTitle"),
					message: $A.get("$Label.c.XC_CL_MassAssSkillErrorAddMessage"),
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				toastEvent.fire();
			}            
		});
		$A.enqueueAction(action); 
		$A.get('e.force:refreshView').fire();
	},

	getObjById : function(component, listIdObj, helper, listOriginal) {
		var result = [];
		var newListId = helper.cleanListId(component, listIdObj);
		for(var i=0; i<newListId.length; i++) {
			for(var j=0; j<listOriginal.length; j++) {
				if(newListId[i] == listOriginal[j].Id) {
					result.push(listOriginal[j]);
					break;
				}
			}
		}
		return result;
	},

	cleanListId : function(component, listId) {
		var newListId = [];
		listId.forEach(function(row) {
			if(!newListId.includes(row)) {
				newListId.push(row);
			}
		});
		return newListId;
	}

})