/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 13/09/2019
* @description XC_LCP114_MassiveAssignmentWorkTypeZipCode – Component for Massive WorkType/ZipCode Assignment
*/

({
	init : function(component, event, helper) {
		component.set("v.spinnerControl", true);
		if(component.get('v.originPartner') != '') {
			var idOriginPartner = component.get('v.originPartner');
			console.log('@@@ Origin Partner ---> ' + idOriginPartner);
			var action = component.get("c.getResultWrapperByPartner");
			action.setParams({ 
				'idAssignedPartner' : idOriginPartner
			});
			action.setCallback(this, function(a) { 
				var state = a.getState();
				console.log('@@@ State init ---> ' + state);
				if(state === "SUCCESS") {
					component.set("v.spinnerControl", false);
					var result = a.getReturnValue();
					console.log('@@@ Result init -> ', result);
					component.set('v.columnsWorktype', [
						{label: $A.get("$Label.c.XC_CL_MassAssSkillName"), fieldName: 'Name', type: 'text'}
					]);
					component.set('v.columnsZipcode', [
						{label: $A.get("$Label.c.XC_CL_MassAssSkillPostalCode"), fieldName: 'XC_ZipCode__c', type: 'text'},
						{label: $A.get("$Label.c.XC_CL_MassAssSkillListName"), fieldName: 'XC_WorkTypeName__c', type: 'text'}
					]);
					component.set('v.country', result.country);
					component.set('v.tempDataZipcode', result.listZipCodeWorkType);
					console.log('@@@ result.listWorktype ---> ', result.listWorkType);
					console.log('@@@ result.listZipCodeWorktype ---> ', result.listZipCodeWorkType);
					component.set('v.partnerChoosed', true);
					component.set('v.filterStrikeLookupDestination', "RecordType.Name = 'Partner' AND Id != '" + idOriginPartner + "' AND Name != 'No Candidate Found'");
					component.set('v.dataWorktype', result.listWorkType);
					component.set('v.dataZipcode', result.listZipCodeWorkType);
					component.set('v.originalDataWorktype', result.listWorkType);
					component.set('v.originalDataZipcode', result.listZipCodeWorkType);
				} else {
					helper.cleanAttributes(component, event, helper);
				}            
			});
			$A.enqueueAction(action); 
		}
		else {
			helper.cleanAttributes(component, event, helper);
		}
		component.set("v.disabledPickList", false);
	},

	// ---------------------------------------------------------------------------------- Util methods:
	cleanAttributes : function(component, event, helper) {
		component.set('v.partnerChoosed', "false"); 
		component.set('v.isFiltered', "false"); 
		component.set('v.isSelectedProvince', "false"); 
		component.set('v.isOptionSelected', "false"); 
		component.set('v.isOperation', "false"); 
		component.set('v.tempDataZipcode', new Array());
		component.set('v.isOperation', "false"); 
		component.set('v.isDestinationPartner', "false"); 
		component.set('v.disableAdd', "true");
		component.set('v.country', "");
		component.set('v.disableRemove', "true");
		component.set('v.isChangeFilterWorktype', "false");
		component.set('v.disableTransfer', "false");
		component.set("v.spinnerControl", false);
		component.set("v.preferredOperation", "");
		component.set("v.isWorktypeSelectedForAdd", "false");
		component.set('v.destinationPartner', "");
		component.set('v.filterWorktype', "");
		component.set('v.listIdSelectedPrecWorktype', "");
		component.set('v.filterZipCode', "");
		component.set('v.filterZipCodeAdd', "");
		component.set('v.filterProvince', "");
		component.set('v.selectedRowsCountWorktype', "0");
		component.set('v.dataWorktype', new Array());
		component.set('v.columnsWorktype', new Array());
		component.set('v.columnsZipCodeAdd', new Array());
		component.set('v.selectedRowsCountZipcode', "0");
		component.set('v.selectedRowsCountZipcodeForAdd', "0");
		component.set('v.selectedRowsCountProvince', "0");
		component.set('v.columnsZipcode', new Array());
		component.set('v.columnsProvince', new Array());
		component.set('v.dataZipcode', new Array());
		component.set('v.dataAddZipcode', new Array());
		component.set('v.dataProvinces', new Array());
		component.set('v.originalDataProvince', new Array());
		component.set('v.originalZippCodeAdd', new Array());
		component.set('v.originalDataWorktype', new Array());
		component.set('v.originalDataZipcode', new Array());
		component.set('v.selectedRowsWorktype', new Array());
		component.set('v.selectedRowsProvince', new Array());
		component.set('v.selectedRowsZipCodeAdd', new Array());
		component.set('v.selectedRowsZipcode', new Array());
		component.set('v.optionSelected', "");
		component.set('v.titleZipcodeTable', "");
		component.set('v.readyButton', false);
		component.set('v.textButton', '');
	},

	onSelectedDestinationPartner: function(component, event, helper) { 
		if(component.get('v.destinationPartner') != null && component.get('v.destinationPartner') != '') {
			component.set('v.disableButton', false);
		}
	},

	enableButton : function(component, event, helper) { 
        if(component.get('v.destinationPartner') != '') {
			var selectedValue = component.get('v.preferredOperation');
			console.log('@@@ Operation ---> ', selectedValue);
			if(selectedValue == 'Transfer') {
				component.set('v.disableTransfer', "false");
			}
		} else {
			component.set('v.disableTransfer', "true");
		}
	},

	cleanListId : function(component, listId) {
		var newListId = [];
		listId.forEach(function(row) {
			if(!newListId.includes(row)) {
				newListId.push(row);
			}
		});
		return newListId;
	},

	getIds : function(component, listObject) {
		var result = [];
		listObject.forEach(function(row) {
			result.push(row.Id);
		});
		return result;
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
	
	assignWorktypeZipCode : function(component, event, helper) { 
        component.set("v.spinnerControl",true);
		if(component.get('v.destinationPartner') == "" || component.get('v.originPartner') == "") {
			component.set('v.disableAdd', "true");
			component.set('v.disableRemove', "true");
			component.set('v.disableTransfer', "true");
			component.set("v.spinnerControl",false);
		}
		component.set("v.spinnerControl", false);
	},

	// --------------------------------------------------------------------------------- For Operations:
	operation : function(component, event, helper) {
		console.log('@@@ In operation'); 
		component.set("v.spinnerControl", true);

		let typeOperation = component.get('v.preferredOperation');
		let displayRowAdd = component.get('v.selectedRowsZipCodeAdd');
		let displayRowRemTransf = helper.getObjById(component, component.get('v.displayZipCode'), helper, component.get('v.originalDataZipcode'));
		console.log('@@@ displayRowAdd -> ', displayRowAdd);
		console.log('@@@ displayRowRemTransf -> ', displayRowRemTransf);

		if((typeOperation == 'Add' && (displayRowAdd.length == 0 || displayRowAdd == null)) ||
			((typeOperation == 'Remove' || typeOperation == 'Transfer') && (displayRowRemTransf.length == 0 || displayRowRemTransf == null))) {
				console.log('@@@ Error: select a row in the table.');
				component.set("v.spinnerControl", false);
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Error",
					message: $A.get("$Label.c.XC_CL_MassiveWorkType_SelectRow"),
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				toastEvent.fire();
		}
		else {
			console.log('@@@ You have selected rows in the table');
			let modalBody;
			$A.createComponents([
				[
					"c:XC_LCP154_MassiveAssignmentWorkTypeSuccess",
					{
						'originPartner' : component.get('v.originPartner'),
						'destinationPartner' : component.get('v.destinationPartner'),
						'preferredOperation' : typeOperation,
						'selectedRowsWorktype' : component.get('v.selectedRowsWorktype'),
						'selectedRowsZipCodeAdd' : component.get('v.selectedRowsZipCodeAdd'),
						'displayZipcodeAdd' : component.get('v.displayZipcodeAdd'),
						'displayZipCode' : component.get('v.displayZipCode'),
						'dataZipcode' : component.get('v.dataZipcode'),
						'displayRowAdd' : displayRowAdd,
						'displayRowRemTransf' : displayRowRemTransf,
						'selectedRowsWorktype' : component.get('v.selectedRowsWorktype'),
						'selectedRowsZipCodeAdd' : component.get('v.selectedRowsZipCodeAdd')
					}
				]],
				function(components, status, errorMessage) {
					component.set("v.spinnerControl", false);
					if (status === "SUCCESS") {
						console.log('[CALL COMPONENT] ----> ', status);
						modalBody = components[0];
						component.find('overlayLib').showCustomModal({
							header: $A.get("$Label.c.XC_CL_MassiveWorkType_Summary"),
							body: modalBody,
							showCloseButton: true,
							//closeCallback: function () {
							//	document.location.reload(true);
							//}
						})
						console.log('[FINISH COMPONENT]');
					}
					else {
						console.log('[WARNING COMPONENT] ----> ', status);
						console.log('[ERROR MESSAGE] ----> ', errorMessage);
					}
				}
			);
		}
		/*let typeOperation = component.get('v.preferredOperation');
		let idOriginPartner = component.get('v.originPartner');
		let listSelectedWorkType = component.get('v.selectedRowsWorktype');
		let listSelectedZipCode = component.get('v.selectedRowsZipCodeAdd');
		let listExistingPartnerCoverage = component.get('v.dataZipcode');
		component.set("v.spinnerControl", true);
		let action;

		if(typeOperation == 'Add') {
			action = component.get("c.addOperation");
			action.setParams({ 
				idOriginPartner : idOriginPartner,
				listSelectedWorkType : listSelectedWorkType,
				listSelectedZipCode : listSelectedZipCode,
				listExistingZipCodeWorkType : listExistingPartnerCoverage
			});
			console.log('@@@ listExistingPartnerCoverage -> ', listExistingPartnerCoverage);
			console.log('@@@ idOriginPartner -> ', idOriginPartner);
			console.log('@@@ listSelectedWorkType -> ', listSelectedWorkType);
			console.log('@@@ listSelectedZipCode -> ', listSelectedZipCode);
		} else if(typeOperation == 'Remove') {
			action = component.get("c.removeOperation");
			action.setParams({ 
				listPartnerCoverageIds : component.get('v.displayZipCode')
			});
			console.log('@@@ listPartnerCoverage -> ', component.get('v.displayZipCode'));
		} else {
			action = component.get("c.transferOperation");
			let listIdsPartnerCoverage = component.get('v.displayZipCode');
			let listPartnerCoverage = listExistingPartnerCoverage;
			let listSelectedPartnerCoverage = helper.getObjById(component, listIdsPartnerCoverage, helper, listPartnerCoverage);
			action.setParams({ 
				listPartnerCoverage : listSelectedPartnerCoverage,
				idDestinationPartner : component.get('v.destinationPartner')
			});
			console.log('@@@ listPartnerCoverage -> ', component.get('v.displayZipCode'));
			console.log('@@@ idDestinationPartner -> ', component.get('v.destinationPartner'));
			console.log('@@@ listSelectedPartnerCoverage -> ', listSelectedPartnerCoverage);
		}

		action.setCallback(this, function(a) { 
			var state = a.getState();
			console.log('@@@ State operation ---> ' + state);
			if(state === "SUCCESS") {
				component.set("v.spinnerControl", false);
				var result = a.getReturnValue();
				console.log('@@@ result -> ', result);
				if(result.success) {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: $A.get("$Label.c.XC_CL_MassAssSkillRequestSent"),
						key: 'info_alt',
						type: 'success',
						mode: 'pester'
					});
					toastEvent.fire();

					helper.cleanAttributes(component, event, helper);
					$A.get('e.force:refreshView').fire();
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
		$A.enqueueAction(action); */
	}, 

	onChangePicklist : function(component, event, helper) {
		component.set("v.spinnerControl", true);
		let selectedValue = component.get('v.preferredOperation');
		component.set('v.disabledPickList', true);
		console.log('@@@ Operation ---> ', selectedValue);

		if(selectedValue == 'Transfer') {
			component.set('v.disableButton', true);
			component.set('v.isOperation', "false"); 
			component.set('v.titleZipcodeTable', $A.get("$Label.c.XC_CL_MassAssSkillTransferAddMessage"));
			component.set('v.isDestinationPartner', "false"); 
			component.set('v.isOptionSelected', "true"); 
			component.set('v.textButton', $A.get("$Label.c.XC_CL_MassAssSkillOpTransfer"));
			helper.populateWorkTypesForRemoveTransfer(component);
		} else if(selectedValue == 'Add') {
			//helper.populateTablesForAdd(component, event, helper);
			component.set('v.disableButton', false);
			component.set('v.isOperation', true); 
			component.set('v.isOptionSelected', "false"); 
			component.set('v.textButton', $A.get("$Label.c.XC_CL_MassAssSkillOpAdd"));
			var country = component.get('v.country');
			helper.getProvinces(component, event, helper, country);
		} else if(selectedValue == 'Remove') {
			component.set('v.disableButton', false);
			component.set('v.isOperation', "false"); 
			component.set('v.isOptionSelected', "true"); 
			component.set('v.titleZipcodeTable', $A.get("$Label.c.XC_CL_MassAssSkillTransferAddMessage"));
			component.set('v.textButton', $A.get("$Label.c.XC_CL_MassAssSkillOpRemove"));
			helper.populateWorkTypesForRemoveTransfer(component);
		}
		component.set('v.disableTransfer', "true"); 
		component.set('v.readyButton', "true"); 
		component.set("v.spinnerControl", false);
	},

	populateWorkTypesForRemoveTransfer : function(component) {
		/*let listWorkTypePartner = component.get('v.dataWorktype');	// List of WorkType			--> All
		let listPartnerCoverage = component.get('v.dataZipcode');	// List of Partner Coverage	--> Of Partner
		let newWorkTypeList = [];
		let listIdsInserted = [];
		listPartnerCoverage.forEach(pc => {
			for(var i=0; i<listWorkTypePartner.length; i++) {
				if(listWorkTypePartner[i].Name == pc.XC_WorkTypeName__c && !listIdsInserted.includes(listWorkTypePartner[i].Id)) {
					let tempObject = {
						'Id' : listWorkTypePartner[i].Id,
						'Name' : listWorkTypePartner[i].Name
					}
					newWorkTypeList.push(tempObject);
					listIdsInserted.push(listWorkTypePartner[i].Id);
					break;
				}
			}
		});*/
		component.set("v.spinnerControlLoadWorkType", true);
		let action = component.get("c.populateWorkTypesForRemoveTransfer");
		action.setParams({ 
			'listWorkTypePartner' : component.get('v.dataWorktype'),
			'listPartnerCoverage' : component.get('v.dataZipcode')
		});
		action.setCallback(this, function(a) { 
			let state = a.getState();
			if(state === "SUCCESS") {
				var result = a.getReturnValue();
				component.set('v.dataWorktype', result);
				component.set('v.originalDataWorktype', result);
			} else {
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Error",
					message: a.getError(),
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				toastEvent.fire();
			}          
			component.set("v.spinnerControlLoadWorkType", false);  
		});
		$A.enqueueAction(action); 
	},

	/*populateTablesForAdd : function(component, event, helper) {
		console.log('@@@ In populateTables');
		let action = component.get("c.populateTableByAddOperation");
		action.setParams({ 
			listWorkType : component.get('v.dataWorktype'),
			listZipCodeWorkType : component.get('v.dataZipcode')
		});
		
		action.setCallback(this, function(a) { 
			let state = a.getState();
			console.log('@@@ State populateTables ---> ' + state);
			if(state === "SUCCESS") {
				let result = a.getReturnValue(); 
				component.set('v.dataWorktype', result);
				component.set('v.originalDataWorktype', result);
			}
		});
		$A.enqueueAction(action); 
	},*/

	
	// --------------------------------------------------------------------------- For Worktype Table:
	manageWorktypeTableDisplayed : function(component, event, helper) {
		//Righe selezionate attualmente:
		var selectedRows = event.getParam('selectedRows');
		//console.log('@@@ selectedRows for Worktype ---> ', selectedRows);
		//Per le righe selezionate:
		var componentTableWorktype  = component.find("tableWorktypeForAdd");
		var allSelectedRows = componentTableWorktype.get("v.selectedRows");		
		var allSelectedRowIds = [];
		//Se precedentemente non è stato selezionato nulla:
		if(allSelectedRows.length == 0) {
			selectedRows.forEach(function(row) {
				allSelectedRowIds.push(row.Id);
			});
			component.set('v.selectedRowsWorktype', selectedRows);
		}
		//Se precedentemente è stata selezionata uno o più riga:
		else {
			//Si controlla se si viene da una tabella modificata da un filtro:
			var isChangeFilterWorktype = component.get('v.isChangeFilterWorktype');
			var listIdWorktype = [];
			if(component.get('v.filterWorktype') == null || component.get('v.filterWorktype') == '') {
				component.set('v.isChangeFilterWorktype', "false");
			}
			if(isChangeFilterWorktype == "false") {
				console.log('[WARNING] You have not entered a filter now');
				//Id righe precedentemente selezionate:
				listIdWorktype = JSON.parse(JSON.stringify(allSelectedRows));			
			} 
			else {
				console.log('[WARNING] You have entered a filter now');
				//Id righe precedentemente selezionate:
				listIdWorktype = component.get('v.listIdSelectedPrecWorktype');
			}
			//console.log('@@@ listIdWorktype ---> ', listIdWorktype);			
			// Righe (Worktype) selezionate precedentemente:
			var allSelectedWorktype = helper.getObjById(component, listIdWorktype, helper, component.get('v.originalDataWorktype'));
			//console.log('@@@ allSelectedWorktype ---> ', allSelectedWorktype);
			// Le righe mostrate nell'attuale tabella (filtrato o non):
			var currentDataTable = component.get('v.dataWorktype');
			var currentDataTableIds = helper.getIds(component, currentDataTable);

			// Split delle righe selezionate precedentemente in:
				// Lista di righe selezionate e non nella attuale tabella:
			var listRowSelectedNotDisplayed = [];
				// Lista di righe selezionate e nella attuale tabella:
			var listRowSelectedDisplayed = [];
			allSelectedWorktype.forEach(function(row) {
				if(currentDataTableIds.includes(row.Id)) {
					listRowSelectedDisplayed.push(row);
				} else {
					listRowSelectedNotDisplayed.push(row);
				}
			});

			// Popolamento della lista finale degli Id delle righe selezionate:
			var tempAllSelectedRowIds = helper.getIds(component, selectedRows);
			allSelectedRowIds = tempAllSelectedRowIds.concat(helper.getIds(component, listRowSelectedNotDisplayed));
			// Popolamento della lista finale delle Worktype selezionate
			var finalSelectWorktype = listRowSelectedNotDisplayed.concat(selectedRows);
			component.set('v.selectedRowsWorktype', finalSelectWorktype);
		}		
		componentTableWorktype.set("v.selectedRows", allSelectedRowIds);
		component.set('v.listIdSelectedPrecWorktype', allSelectedRowIds);
		component.set('v.selectedRowsCountWorktype', allSelectedRowIds.length);
		console.log('@@@ Final selectedRowsWorktype -> ', component.get('v.selectedRowsWorktype'));
		//console.log('@@@ Final allSelectedRowIds -> ', allSelectedRowIds);
	},

	onChangeTableWorktype : function(component, event, helper) {
		component.set('v.onChangeTableWorktype', true);
		console.log('@@@ In onChangeTableWorktype');
		helper.manageWorktypeTableDisplayed(component, event, helper);
		var typeOperation = component.get('v.preferredOperation');
		var selectedRows = event.getParam('selectedRows');
		if(selectedRows.length == 0) {
			component.set('v.filterZipCode', "");
			component.set('v.filterZipCodeAdd', "");
			component.set('v.filterProvince', "");
			//component.set('v.dataWorktype', component.get('v.originalDataWorktype'));
			component.set('v.dataZipcode', component.get('v.originalDataZipcode'));
			component.set('v.tempDataZipcode', component.get('v.originalDataZipcode'));
			//component.set('v.selectedRowsCountWorktype', 0);
			component.set('v.disableAdd', "true");
			component.set('v.disableRemove', "true");
			component.set('v.selectedRowsCountZipCodeForAdd', "0");
			component.set('v.disableTransfer', "true");
			if(component.get('v.selectedRowsCountWorktype') == 0) {
				component.set('v.isWorktypeSelectedForAdd', "false");
				component.set('v.isFiltered', "false");
			}
			component.set('v.isSelectedProvince', "false"); 
			component.set('v.selectedRowsCountProvince', "0");
			component.set('v.selectedRowsZipCodeAdd', new Array());
			component.set('v.selectedRowsZipCode', new Array());
			component.set('v.selectedRowsProvince', new Array());
		}
		else {
			console.log('@@@ selectedRows: ', selectedRows.length);
			if(typeOperation == 'Remove' || typeOperation == 'Transfer') {
				//var listWorktypeFromComponent = event.getParam('selectedRows');
				var listWorktypeFromComponent = component.get('v.selectedRowsWorktype');
				helper.onSelectRowWorktype(component, event, helper, listWorktypeFromComponent);
			}
			else if(typeOperation == 'Add') {
				component.set('v.isWorktypeSelectedForAdd', "true");
			}
		} 
		component.set('v.onChangeTableWorktype', false);
	},

	onChangeFilterWorktype : function(component, event, helper) { 
		// Id righe precedentemente selezionate:
		var componentTableWorktype  = component.find("tableWorktypeForAdd");
		var allSelectedRows = componentTableWorktype.get("v.selectedRows");
		var listIdWorktype = JSON.parse(JSON.stringify(allSelectedRows));
		console.log('@@@ listIdWorktype -> ', listIdWorktype);
		var newListIdWorktype = helper.cleanListId(component, listIdWorktype);
		component.set('v.listIdSelectedPrecWorktype', newListIdWorktype);
		console.log('@@@ newListIdWorktype -> ', newListIdWorktype);
		var listWorktypeInTable = component.get('v.originalDataWorktype');
		var filterWorktype = component.get('v.filterWorktype');
		console.log('@@@ filterWorktype -> ', filterWorktype);
		if(filterWorktype == '' || filterWorktype == null) {
			component.set('v.dataWorktype', listWorktypeInTable);
		}
		else {
			var newListWorktype = [];
			for(var i=0; i<listWorktypeInTable.length; i++) {
				if(listWorktypeInTable[i].Name.toLowerCase().includes(filterWorktype.toLowerCase())) {
					newListWorktype.push({
						Id: listWorktypeInTable[i].Id,
						Name : listWorktypeInTable[i].Name
					});
				}
			}
			component.set('v.dataWorktype', newListWorktype);
		}

		componentTableWorktype.set("v.selectedRows", newListIdWorktype);
		component.set('v.isChangeFilterWorktype', "true");
	},

	onSelectRowWorktype : function(component, event, helper, listWorktypeFromComponent) { 
		console.log('@@@ In onSelectRowWorktype');
		component.set('v.isFiltered', "true");   
		let newDataZipCode = [];
		let workTypeIds = helper.getIds(component, listWorktypeFromComponent);
		console.log('@@@ workTypeIds -> ', workTypeIds);
		let dataCoverage = component.get('v.originalDataZipcode');
		dataCoverage.forEach(currentItem => {
			console.log('@@@ For item -> ', currentItem);
			if(workTypeIds.includes(currentItem.XC_WorkType__c)) {
				newDataZipCode.push(currentItem);
			}
		});
		// Deselezionare Zip code associati a WorkType deselezionate
		/*let componentTableZipcode  = component.find("tableZipCode");
		let listOldZipcodeSelected = Object.values(componentTableZipcode.get("v.selectedRows"));
		console.log('@@@ listOldZipcodeSelected ---> ', listOldZipcodeSelected);
		let dataWorkType = component.get('v.dataWorktype');
		let listZipcodeNowSelected = [];
		dataWorkType.forEach(function(zipcodeNewSelect) {
			listOldZipcodeSelected.forEach(function(zipcodeOldSelect) {
				if(zipcodeNewSelect.Id == zipcodeOldSelect.XC_PartnerCoverage__c) {
					listZipcodeNowSelected.push(zipcodeNewSelect);
				}
			});
		});*/
		
		//let listIdZipcodeToBeDeselected = helper.getIds(component, listZipcodeNowSelected);
		//componentTableZipcode.set("v.selectedRows", listIdZipcodeToBeDeselected);
		component.set('v.dataZipcode', newDataZipCode);
		component.set('v.selectedRowsCountZipcode', 0);    
	},

	// --------------------------------------------------------------------------- For Zip Code Table:
	manageZipcodeTableDisplayed : function(component, event, helper) {
		//Righe selezionate attualmente:
		var selectedRows = event.getParam('selectedRows');
		//console.log('@@@ selectedRows for Zipcode ---> ', selectedRows);
		//Per le righe selezionate:
		var componentTableZipcode  = component.find("tableZipCode");
		var allSelectedRows = componentTableZipcode.get("v.selectedRows");		
		var allSelectedRowIds = [];
		//Se precedentemente non è stato selezionato nulla:
		if(allSelectedRows.length == 0) {
			selectedRows.forEach(function(row) {
				allSelectedRowIds.push(row.Id);
			});
			component.set('v.selectedRowsZipcode', selectedRows);
		}
		//Se precedentemente è stata selezionata uno o più riga:
		else {
			//Si controlla se si viene da una tabella modificata da un filtro:
			var isChangeFilterZipcode = component.get('v.isChangeFilterZipcode');
			var listIdZipcode = [];
			if(component.get('v.filterZipCode') == null || component.get('v.filterZipCode') == '') {
				component.set('v.isChangeFilterZipcode', "false");
			}
			if(isChangeFilterZipcode == "false") {
				console.log('[WARNING] You have not entered a filter now');
				//Id righe precedentemente selezionate:
				listIdZipcode = JSON.parse(JSON.stringify(allSelectedRows));			
			} 
			else {
				console.log('[WARNING] You have entered a filter now');
				//Id righe precedentemente selezionate:
				listIdZipcode = component.get('v.listIdSelectedPrecZipcode');
			}
			//console.log('@@@ listIdZipcode ---> ', listIdZipcode);			
			// Righe (Zipcode) selezionate precedentemente:
			var allSelectedZipcode = helper.getObjById(component, listIdZipcode, helper, component.get('v.originalDataZipcode'));
			//console.log('@@@ allSelectedZipcode ---> ', allSelectedZipcode);
			// Le righe mostrate nell'attuale tabella (filtrato o non):
			var currentDataTable = component.get('v.dataZipcode');
			var currentDataTableIds = helper.getIds(component, currentDataTable);

			// Split delle righe selezionate precedentemente in:
				// Lista di righe selezionate e non nella attuale tabella:
			var listRowSelectedNotDisplayed = [];
				// Lista di righe selezionate e nella attuale tabella:
			var listRowSelectedDisplayed = [];
			allSelectedZipcode.forEach(function(row) {
				if(currentDataTableIds.includes(row.Id)) {
					listRowSelectedDisplayed.push(row);
				} else {
					listRowSelectedNotDisplayed.push(row);
				}
			});

			// Popolamento della lista finale degli Id delle righe selezionate:
			var tempAllSelectedRowIds = helper.getIds(component, selectedRows);
			allSelectedRowIds = tempAllSelectedRowIds.concat(helper.getIds(component, listRowSelectedNotDisplayed));
			// Popolamento della lista finale delle work type selezionate
			var finalSelectZipcode = listRowSelectedNotDisplayed.concat(selectedRows);
			component.set('v.selectedRowsZipcode', finalSelectZipcode);
		}		
		componentTableZipcode.set("v.selectedRows", allSelectedRowIds);
		component.set('v.listIdSelectedPrecZipcode', allSelectedRowIds);
		component.set('v.selectedRowsCountZipcode', allSelectedRowIds.length);
		console.log('@@@ Final selectedRowsZipcode -> ', component.get('v.selectedRowsZipcode'));
		//console.log('@@@ Final allSelectedRowIds -> ', allSelectedRowIds);
	},

	onChangeTableZipCode : function(component, event, helper) {
		helper.manageZipcodeTableDisplayed(component, event, helper);
		var selectedRows = component.get('v.listIdSelectedPrecZipcode');
		//var selectedRows = event.getParam('selectedRows');
		
		if(selectedRows.length != 0) {
			var selectedValue = component.get('v.preferredOperation');
			if(selectedValue == 'Transfer') {
				component.set('v.titleZipcodeTable', $A.get("$Label.c.XC_CL_MassAssSkillTableTransfer"));
				component.set('v.isDestinationPartner', "true"); 
			} else if(selectedValue == 'Add') {
				component.set('v.titleZipcodeTable', $A.get("$Label.c.XC_CL_MassAssSkillTableAdd"));
				component.set('v.isDestinationPartner', "false"); 
				component.set('v.disableAdd', "false");
			} else if(selectedValue == 'Remove') {
				component.set('v.titleZipcodeTable', $A.get("$Label.c.XC_CL_MassAssSkillTableRemove"));
				component.set('v.isDestinationPartner', "false"); 
				component.set('v.disableRemove', "false");
			}
		} else {
			component.set('v.disableAdd', "true");
			component.set('v.disableRemove', "true");
			component.set('v.disableTransfer', "true");
			component.set('v.destinationPartner', "");
		}
	},

	onChangeFilterZipCode : function(component, event, helper) { 
		// Id righe precedentemente selezionate:
		var componentTableZipcode  = component.find("tableZipCode");
		var allSelectedRows = componentTableZipcode.get("v.selectedRows");
		var listIdZipcode = JSON.parse(JSON.stringify(allSelectedRows));
		var newListIdZipcode = helper.cleanListId(component, listIdZipcode);
		component.set('v.listIdSelectedPrecZipcode', newListIdZipcode);

		var listZipcodeInTable = component.get('v.tempDataZipcode');
		var filterZipcode = component.get('v.filterZipCode');
		if(filterZipcode == '' || filterZipcode == null) {
			component.set('v.dataZipcode', listZipcodeInTable);
		}
		else {
			var newListZipcode = [];
			for(var i=0; i<listZipcodeInTable.length; i++) {
				if(listZipcodeInTable[i].XC_ZipCode__c.toLowerCase().includes(filterZipcode.toLowerCase())) {
					newListZipcode.push({
						Id: listZipcodeInTable[i].Id,
						XC_ZipCode__c : listZipcodeInTable[i].XC_ZipCode__c,
						XC_WorkType__c : listZipcodeInTable[i].XC_WorkType__c,
						XC_ZipCodeWorkType__c : listZipcodeInTable[i].XC_ZipCodeWorkType__c,
						XC_WorkTypeName__c : listZipcodeInTable[i].XC_WorkTypeName__c,
						XC_Account__c : listZipcodeInTable[i].XC_Account__c
					});
				}
			}
			component.set('v.dataZipcode', newListZipcode);
		}

		componentTableZipcode.set("v.selectedRows", newListIdZipcode);
		component.set('v.isChangeFilterZipcode', "true");
	}, 


	// --------------------------------------------------------------------------- For Province Table:
	getProvinces : function(component, event, helper, country){
        var pathProvinces = $A.get("$Resource.XC_STR002_MapCountryProvinces");
        var req = new XMLHttpRequest();
        req.open("GET", pathProvinces);
        req.addEventListener("load", $A.getCallback(function() {
			var JSONMapCountryProvinces = JSON.parse(req.response);
			var listProvinces = JSONMapCountryProvinces[country.toUpperCase()]['listProvinces'];
			component.set('v.nameResourceZipCode', JSONMapCountryProvinces[country.toUpperCase()]['resourceNameMap']);
            if(listProvinces && listProvinces.length>0){  
				var opts = [];
				for(var i=0; i<listProvinces.length; i++) {
					opts.push({
						value: listProvinces[i],
						Id: listProvinces[i]
					});
				} 
				component.set('v.dataProvinces', opts); 
				component.set('v.originalDataProvince', opts); 
				component.set('v.columnsProvince', [
					{label: $A.get("$Label.c.XC_CL_MassAssSkill_Provinces"), fieldName: 'value', type: 'text'}
				]);
            }  
        }));                
		req.send(null); 
	},

	manageProvinceTableDisplayed : function(component, event, helper) {
		//Righe selezionate attualmente:
		var selectedRows = event.getParam('selectedRows');
		//Per le righe selezionate:
		var componentTableProvince  = component.find("tableProvinceForAdd");
		var allSelectedRows = componentTableProvince.get("v.selectedRows");		
		var allSelectedRowIds = [];
		//Se precedentemente non è stato selezionato nulla:
		if(allSelectedRows.length == 0) {
			selectedRows.forEach(function(row) {
				allSelectedRowIds.push(row.Id);
			});
			component.set('v.selectedRowsProvince', selectedRows);
		}
		//Se precedentemente è stata selezionata uno o più riga:
		else {
			//Si controlla se si viene da una tabella modificata da un filtro:
			var isChangeFilterProvince = component.get('v.isChangeFilterProvince');
			var listIdProvince = [];
			if(component.get('v.filterProvince') == null || component.get('v.filterProvince') == '') {
				component.set('v.isChangeFilterProvince', "false");
			}
			if(isChangeFilterProvince == "false") {
				console.log('[WARNING] You have not entered a filter now');
				//Id righe precedentemente selezionate:
				listIdProvince = JSON.parse(JSON.stringify(allSelectedRows));			
			} 
			else {
				console.log('[WARNING] You have entered a filter now');
				//Id righe precedentemente selezionate:
				listIdProvince = component.get('v.listIdSelectedPrecProvince');
			}
			//console.log('@@@ listIdProvince ---> ', listIdProvince);			
			// Righe (Province) selezionate precedentemente:
			var allSelectedProvince = helper.getObjById(component, listIdProvince, helper, component.get('v.originalDataProvince'));
			//console.log('@@@ allSelectedProvince ---> ', allSelectedProvince);
			// Le righe mostrate nell'attuale tabella (filtrato o non):
			var currentDataTable = component.get('v.dataProvinces');
			var currentDataTableIds = helper.getIds(component, currentDataTable);

			// Split delle righe selezionate precedentemente in:
				// Lista di righe selezionate e non nella attuale tabella:
			var listRowSelectedNotDisplayed = [];
				// Lista di righe selezionate e nella attuale tabella:
			var listRowSelectedDisplayed = [];
			allSelectedProvince.forEach(function(row) {
				if(currentDataTableIds.includes(row.Id)) {
					listRowSelectedDisplayed.push(row);
				} else {
					listRowSelectedNotDisplayed.push(row);
				}
			});

			// Popolamento della lista finale degli Id delle righe selezionate:
			var tempAllSelectedRowIds = helper.getIds(component, selectedRows);
			allSelectedRowIds = tempAllSelectedRowIds.concat(helper.getIds(component, listRowSelectedNotDisplayed));
			// Popolamento della lista finale delle work type selezionati
			var finalSelectProvince = listRowSelectedNotDisplayed.concat(selectedRows);
			component.set('v.selectedRowsProvince', finalSelectProvince);
		}		
		componentTableProvince.set("v.selectedRows", allSelectedRowIds);
		component.set('v.listIdSelectedPrecProvince', allSelectedRowIds);
		component.set('v.selectedRowsCountProvince', allSelectedRowIds.length);
		console.log('@@@ Final selectedRowsProvince -> ', component.get('v.selectedRowsProvince'));
		//console.log('@@@ Final allSelectedRowIds -> ', allSelectedRowIds);
	},

	onChangeTableProvince : function(component, event, helper) {
		component.set('v.onChangeTableWorktype', true);
		helper.manageProvinceTableDisplayed(component, event, helper);
		var selectedRows = event.getParam('selectedRows');
		component.set('v.disableAdd', "true");
		if(selectedRows.length == 0) {
			component.set('v.filterZipCodeAdd', "");
			if(component.get('v.selectedRowsCountProvince') == 0) {
				component.set('v.isSelectedProvince', "false"); 
				component.set('v.dataAddZipcode', new Array()); 
				component.set('v.selectedRowsCountZipCodeForAdd', 0);
				component.set('v.disableAdd', "true");
			} 
			component.set('v.dataAddZipcode', new Array()); 
			component.set('v.selectedRowsCountZipCodeForAdd', "0");
		} else {
			helper.getZipCode(component, event, helper);
			component.set('v.isSelectedProvince', "true");
		}
		component.set('v.onChangeTableWorktype', false);
	},

	onChangeFilterProvince : function(component, event, helper) { 
		// Id righe precedentemente selezionate:
		var componentTableProvince  = component.find("tableProvinceForAdd");
		var allSelectedRows = componentTableProvince.get("v.selectedRows");
		var listIdProvince = JSON.parse(JSON.stringify(allSelectedRows));
		var newListIdProvince = helper.cleanListId(component, listIdProvince);
		component.set('v.listIdSelectedPrecProvince', newListIdProvince);

		var listProvinceInTable = component.get('v.originalDataProvince');
		var filterProvince = component.get('v.filterProvince');
		if(filterProvince == '' || filterProvince == null) {
			component.set('v.dataProvinces', listProvinceInTable);
		}
		else {
			var newListProvince = [];
			for(var i=0; i<listProvinceInTable.length; i++) {
				if(listProvinceInTable[i].value.toLowerCase().includes(filterProvince.toLowerCase())) {
					newListProvince.push({
						value: listProvinceInTable[i].value,
						Id : listProvinceInTable[i].Id
					});
				}
			}
			component.set('v.dataProvinces', newListProvince);
		}

		componentTableProvince.set("v.selectedRows", newListIdProvince);
		component.set('v.isChangeFilterProvince', "true");
	},


	// ----------------------------------------------------------------------- For ZipCode Table (for Add Operation):
	manageZipcodeAddTableDisplayed : function(component, event, helper) {
		//Righe selezionate attualmente:
		var selectedRows = event.getParam('selectedRows');
		//console.log('@@@ selectedRows for Province ---> ', selectedRows);
		//Per le righe selezionate:
		var componentTableZipcode  = component.find("tableZipcodeForAdd");
		var allSelectedRows = componentTableZipcode.get("v.selectedRows");		
		var allSelectedRowIds = [];
		var tempSelectedRowsZipCodeAdd = [];
		//Se precedentemente non è stato selezionato nulla:
		if(allSelectedRows.length == 0) {
			selectedRows.forEach(function(row) {
				allSelectedRowIds.push(row.Id);
			}); 
			tempSelectedRowsZipCodeAdd = JSON.parse(JSON.stringify(selectedRows));
		}
		//Se precedentemente è stata selezionata uno o più riga:
		else {
			//Si controlla se si viene da una tabella modificata da un filtro:
			var isChangeFilterZipcode = component.get('v.isChangeFilterZipcodeAdd');
			var listIdZipcode = [];
			if(component.get('v.filterZipCodeAdd') == null || component.get('v.filterZipCodeAdd') == '') {
				component.set('v.isChangeFilterZipcode', "false");
			}
			if(isChangeFilterZipcode == "false") {
				console.log('[WARNING] You have not entered a filter now');
				//Id righe precedentemente selezionate:
				listIdZipcode = JSON.parse(JSON.stringify(allSelectedRows));			
			} 
			else {
				console.log('[WARNING] You have entered a filter now');
				//Id righe precedentemente selezionate:
				listIdZipcode = component.get('v.listIdSelectedPrecZipcodeAdd');
			}
			//console.log('@@@ listIdZipcode ---> ', listIdZipcode);			
			// Righe (Zipcode) selezionate precedentemente:
			var allSelectedZipcode = helper.getObjById(component, listIdZipcode, helper, component.get('v.originalAddZippCode'));
			//console.log('@@@ allSelectedZipcode ---> ', allSelectedZipcode);
			// Le righe mostrate nell'attuale tabella (filtrato o non):
			var currentDataTable = component.get('v.dataAddZipcode');
			var currentDataTableIds = helper.getIds(component, currentDataTable);

			// Split delle righe selezionate precedentemente in:
				// Lista di righe selezionate e non nella attuale tabella:
			var listRowSelectedNotDisplayed = [];
				// Lista di righe selezionate e nella attuale tabella:
			var listRowSelectedDisplayed = [];
			allSelectedZipcode.forEach(function(row) {
				if(currentDataTableIds.includes(row.Id)) {
					listRowSelectedDisplayed.push(row);
				} else {
					listRowSelectedNotDisplayed.push(row);
				}
			});

			// Popolamento della lista finale degli Id delle righe selezionate:
			var tempAllSelectedRowIds = helper.getIds(component, selectedRows);
			allSelectedRowIds = tempAllSelectedRowIds.concat(helper.getIds(component, listRowSelectedNotDisplayed));
			// Popolamento della lista finale delle work type selezionati
			var finalSelectZipcode = listRowSelectedNotDisplayed.concat(selectedRows);
			tempSelectedRowsZipCodeAdd = JSON.parse(JSON.stringify(finalSelectZipcode));
		}		
		var finalSelectedRowsZipCodeAdd = [];
		for(var i=0; i<tempSelectedRowsZipCodeAdd.length; i++) {
			finalSelectedRowsZipCodeAdd.push(tempSelectedRowsZipCodeAdd[i].value);
		}
		component.set('v.selectedRowsZipCodeAdd', finalSelectedRowsZipCodeAdd);
		componentTableZipcode.set("v.selectedRows", allSelectedRowIds);
		component.set('v.listIdSelectedPrecZipcodeAdd', allSelectedRowIds);
		component.set('v.selectedRowsCountZipcodeForAdd', allSelectedRowIds.length);
		console.log('@@@ Final selectedRowsZipcodeForAdd -> ', component.get('v.selectedRowsZipCodeAdd'));
		//console.log('@@@ Final allSelectedRowIds -> ', allSelectedRowIds);
	},

	onChangeTableZipCodeAdd : function(component, event, helper) {
		component.set('v.onChangeTableWorktype', true);
		helper.manageZipcodeAddTableDisplayed(component, event, helper);
		var selectedRows = component.get('v.listIdSelectedPrecZipcodeAdd');

		//var selectedRows = event.getParam('selectedRows');
		//var selectZipCodeToAdd = [];
		//for(var i=0; i<selectedRows.length; i++) {
		//	selectZipCodeToAdd.push(selectedRows[i].value);
		//}
		//component.set('v.selectedRowsZipCodeAdd', Object.values(selectZipCodeToAdd));

		if(selectedRows.length != 0) {
			component.set('v.disableAdd', "false");
		} else {
			component.set('v.disableAdd', "true");
		}
		component.set('v.onChangeTableWorktype', false);
	},

	getZipCode : function(component, event, helper){
		var country = component.get('v.country');
		var pathProvinces = $A.get("$Resource.XC_STR002_MapCountryProvinces");
        var req = new XMLHttpRequest();
        req.open("GET", pathProvinces);
        req.addEventListener("load", $A.getCallback(function() {
			var JSONMapCodeProvinces = JSON.parse(req.response);
			console.log('@@@ Get Zip code for selected Provinces');
			var listRowSelectedProvince = component.get('v.selectedRowsProvince');
			console.log('@@@ For Provinces ---> ', listRowSelectedProvince);
			var listCodeProvinceToAdd = [];
			for(var i=0; i<listRowSelectedProvince.length; i++) {
				listCodeProvinceToAdd.push(JSONMapCodeProvinces[country.toUpperCase()]['mapNameCode'][listRowSelectedProvince[i].value]);
			} 
            console.log('@@@ listCodeProvinceToAdd ---> ', listCodeProvinceToAdd);

            if(listCodeProvinceToAdd && listCodeProvinceToAdd.length>0) { 
				let nameStaticResZipCode = component.get('v.nameResourceZipCode');
                var path = $A.get("$Resource."+nameStaticResZipCode);
				var req2 = new XMLHttpRequest();
				req2.open("GET", path);
				req2.addEventListener("load", $A.getCallback(function() {
					var JSONListZipCodesAdd = JSON.parse(req2.response);
					var listZipCodeToAdd = new Array();
					for(var i=0; i<listCodeProvinceToAdd.length; i++) {
						listZipCodeToAdd.push.apply(listZipCodeToAdd, JSONListZipCodesAdd[listCodeProvinceToAdd[i]]);
					} 
					console.log('@@@ listZipCodeToAdd ---> ', listZipCodeToAdd);

					if(listZipCodeToAdd && listZipCodeToAdd.length>0){ 
						var zipCodesToAdd = [];
						for(var i=0; i<listZipCodeToAdd.length; i++) {
							zipCodesToAdd.push({
								value: listZipCodeToAdd[i],
								Id: listZipCodeToAdd[i]
							});
						}
						component.set('v.dataAddZipcode', zipCodesToAdd); 
						// Deselezionare Zip code associati a work type deselezionati
						var componentTableZipcode  = component.find("tableZipcodeForAdd");
						var listOldZipcodeSelected = Object.values(componentTableZipcode.get("v.selectedRows"));
						var listZipcodeNowSelected = [];
						zipCodesToAdd.forEach(function(zipcodeNewSelect) {
							listOldZipcodeSelected.forEach(function(zipcodeOldSelect) {
								if(zipcodeNewSelect.Id == zipcodeOldSelect) {
									listZipcodeNowSelected.push(zipcodeNewSelect);
								}
							});
						});
						var listIdZipcodeToBeDeselected = helper.getIds(component, listZipcodeNowSelected);
						componentTableZipcode.set("v.selectedRows", listIdZipcodeToBeDeselected);
						component.set('v.selectedRowsCountZipcodeForAdd', listIdZipcodeToBeDeselected.length);

						component.set('v.columnsZipCodeAdd', [
							{label: $A.get("$Label.c.XC_CL_ZipCode"), fieldName: 'value', type: 'text'}
						]);
						component.set('v.originalAddZippCode', zipCodesToAdd);
					}
					else {
						component.set('v.dataAddZipcode', new Array()); 
					}
				}));                
				req2.send(null);
			}   
		}));      
		req.send(null);
        component.set("v.disabledProvince", true);
    },

	onChangeFilterZipCodeAdd : function(component, event, helper) { 
		// Id righe precedentemente selezionate:
		var componentTableZipcode  = component.find("tableZipcodeForAdd");
		var allSelectedRows = componentTableZipcode.get("v.selectedRows");
		var listIdZipcode = JSON.parse(JSON.stringify(allSelectedRows));
		var newListIdZipcode = helper.cleanListId(component, listIdZipcode);
		component.set('v.listIdSelectedPrecZipcodeAdd', newListIdZipcode);

		var listZipcodeInTable = component.get('v.originalAddZippCode');
		var filterZipcode = component.get('v.filterZipCodeAdd');
		if(filterZipcode == '' || filterZipcode == null) {
			component.set('v.dataAddZipcode', listZipcodeInTable);
		} 
		else {
			var newListZipcode = [];
			for(var i=0; i<listZipcodeInTable.length; i++) {
				if(listZipcodeInTable[i].value.toLowerCase().includes(filterZipcode.toLowerCase())) {
					newListZipcode.push({
						value: listZipcodeInTable[i].value,
						Id : listZipcodeInTable[i].Id
					});
				}
			}
			component.set('v.dataAddZipcode', newListZipcode);
		}

		componentTableZipcode.set("v.selectedRows", newListIdZipcode);
		component.set('v.isChangeFilterZipcodeAdd', "true");
	}
	
})