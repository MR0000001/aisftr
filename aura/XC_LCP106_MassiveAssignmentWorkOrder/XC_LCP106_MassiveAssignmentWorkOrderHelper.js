({
	doInit : function(component, event, helper) { 
        let action = component.get("c.getInitialInformation");
		action.setCallback(this, function (a) {
			let state = a.getState();
			if(state === "SUCCESS") {
				component.set('v.spinnerControl', false);
				let result = a.getReturnValue();
				component.set('v.messageForUpdateDueDate', $A.get("$Label.c.XC_CL_MassiveWoUpdateDueDate") + "(" + result.dueDateCM + " " + $A.get("$Label.c.XC_CL_Days") + ")");
				component.set('v.isNotCaringAgent', result.isNotCaringAgent);
				if(!result.isNotCaringAgent) {
					helper.changeColorMouseClickSelectManual(component, event, helper);
				}
			}
			else {
				console.log('@@@ Error init: ' + a.getError());
			}
		});
		$A.enqueueAction(action);
	},

	changeColorMouseClickSelectManual : function(component, event, helper) {
		let whereCondition = component.get('v.originPartner');
        whereCondition = whereCondition.substring(0, whereCondition.length - 3)
        //whereCondition = "XC_AssignedPartner__c = '" + whereCondition + "'";
        //whereCondition = whereCondition + " AND XC_Check_Final_Status__c = false AND (Status = '" + $A.get("$Label.c.XC_CL_WorkOrder_Assigned") + "' OR Status = '" + $A.get("$Label.c.XC_CL_OnHold") +"')";
        whereCondition = whereCondition + " XC_Check_Final_Status__c = false AND (Status = '" + $A.get("$Label.c.XC_CL_WorkOrder_Assigned") + "' OR Status = '" + $A.get("$Label.c.XC_CL_OnHold") + "' OR Status = '" + $A.get("$Label.c.XC_CL_Configuration_TypeNew") + "')";
        whereCondition = whereCondition + " AND XC_OutOfDate__c = false";
        component.set('v.filterWorkOrderMultiLookup', whereCondition);
        let filterQueryDestination = "RecordType.Name = 'Partner' AND Id != '" + component.get('v.originPartner') + "' AND Name != 'No Candidate Found'";
		component.set('v.filterStrikeLookupDestination', filterQueryDestination);
        component.find('cardOperationManualSelection').set("v.class", "classOperationChoosed");
        component.set('v.showChooseOperation', false);
        component.set('v.showManualSelection', true);
        component.set('v.valueStep', "2");
        //component.set('v.disabledButton', "false");
        component.set('v.showDestinationPartner', true);
        component.set('v.operationSelected','manual');
        component.set('v.viewAllToggle', false);
        component.set('v.partnerChoosed', true);
	},
	
	
	searchWorkOrder: function (component, event, helper, initialLimitedFilter) {
		component.set('v.spinnerControl', true);
		if (component.get('v.originPartner') != '') {
			let cutoff = component.get('v.maxNumberWorkorder');
			let listZip = new Array();
			let listWt = new Array();
			if(component.get('v.showInitialRequiredFilter')) {
				let listZipTemp = component.get('v.selectedZipCode');
				let listWtTemp = component.get('v.selectedWorkType');
				for(let i=0; i<listZipTemp.length; i++){
					listZip.push(listZipTemp[i].value);
				}
				for(let i=0; i<listWtTemp.length; i++){
					listWt.push(listWtTemp[i].value);
				}
			}
			let outOfDate = component.get('v.preferredTypeWOFilter');
			let action = component.get("c.getResultWrapperByPartner");
			action.setParams({
				'idAssignedPartner': component.get('v.originPartner'),
				'isOutOfDateFilter': outOfDate=='TypeWOOutofDate' ? true : false,
				'cutoff': cutoff,
				'initialFilter': component.get('v.showInitialRequiredFilter'),
				'listZipCodeSelectedString': JSON.stringify(listZip),
				'listWorkTypeSelectedString': JSON.stringify(listWt),
				'initialLimitedFilter': initialLimitedFilter
			});
			action.setCallback(this, function (a) {
				let state = a.getState();
				if(state === "SUCCESS") {
					component.set('v.spinnerControl', false);
					let result = a.getReturnValue();
					if(result.listWorkOrder.length == 0) {
						$A.createComponent("ui:outputText", {
							"value" : "No Work Order found"
						}, function(contentComponent, status, error) {
							if(status === "SUCCESS") {
								var modalBody = contentComponent;
								component.find('overlayLib').showCustomModal({
									header: "Warning",
									body: modalBody, 
									showCloseButton: true,
									cssClass: "mymodal",
								})
							} else {
								console.log('(-_-) Error: ', JSON.parse(JSON.stringify(error)));
							}
						});
						let originPartner = component.get('v.originPartner');
						helper.cleanAttributes(component, event, helper);
						component.set('v.showChooseOperation', false);
						component.set('v.showOriginPartner', true);
						component.set('v.showChooseOutOfDateForFilterSelection', true);
						component.set('v.originPartner', originPartner);
						return;
					}
					if(result.initialFilterRequired) {
						if(result.check = false) {
							$A.createComponent("ui:outputText", {
								"value" : "You have to select a Work Type and/or Zip Code!"
							}, function(contentComponent, status, error) {
								if(status === "SUCCESS") {
									var modalBody = contentComponent;
									component.find('overlayLib').showCustomModal({
										header: "Warning",
										body: modalBody, 
										showCloseButton: true,
										cssClass: "mymodal",
									})
								} else {
									console.log('(-_-) Error: ', JSON.parse(JSON.stringify(error)));
								}
							});
							return;
						}
						component.set('v.workTypeOptions', new Array());
						component.set('v.zipCodeOptions', new Array());
						component.set('v.workTypeOptionsOriginal', new Array());
						component.set('v.zipCodeOptionsOriginal', new Array());
						component.set('v.listAllZipCode', new Array());
						component.set('v.provincesOptions', new Array());
						component.set('v.mapProvinceListZipCode', new Array());
						component.set('v.provincesOptionsOriginal', new Array());
						component.set('v.oldSelectedRowWorkType', new Array());
						component.set('v.selectedWorkType', new Array());
						component.set('v.oldSelectedRowZipcode', new Array());
						component.set('v.selectedZipCode', new Array());
						$A.createComponent("ui:outputText", {
							"value" : "This Partner has " + result.countWorkOrder + " WorkOrders. For a correct visualization you can work with "+ cutoff +" WorkOrder at time. Insert filters to recalculate data to show."
						}, function(contentComponent, status, error) {
							if(status === "SUCCESS") {
								var modalBody = contentComponent;
								component.find('overlayLib').showCustomModal({
									header: "Warning",
									body: modalBody, 
									showCloseButton: true,
									cssClass: "mymodal",
								})
							} else {
								console.log('(-_-) Error: ', JSON.parse(JSON.stringify(error)));
							}
						});
						component.set('v.workTypeOptions', result.listWorkType);
						component.set('v.zipCodeOptions', result.listZipCode);
						component.set('v.workTypeOptionsOriginal', result.listWorkType);
						component.set('v.zipCodeOptionsOriginal', result.listZipCode);
						component.set('v.listAllZipCode', result.listZipCode);
						component.set('v.provincesOptions', result.listProvinces);
						component.set('v.mapProvinceListZipCode', result.mapProvinceListZipcode);
						component.set('v.provincesOptionsOriginal', result.listProvinces);
						component.set('v.showInitialRequiredFilter', true);
						component.set('v.infoBoxForInitialInfo', 'Select initial ' + component.get('v.maxNumberWorkorder') + ' Work Order for massive transfer');
					} else {
						try {
							component.set('v.workTypeOptions', new Array());
							component.set('v.zipCodeOptions', new Array());
							component.set('v.workTypeOptionsOriginal', new Array());
							component.set('v.zipCodeOptionsOriginal', new Array());
							component.set('v.listAllZipCode', new Array());
							component.set('v.provincesOptions', new Array());
							component.set('v.mapProvinceListZipCode', new Array());
							component.set('v.provincesOptionsOriginal', new Array());
							component.set('v.oldSelectedRowWorkType', new Array());
							component.set('v.selectedWorkType', new Array());
							component.set('v.oldSelectedRowZipcode', new Array());
							component.set('v.selectedZipCode', new Array());
							component.set('v.showInitialRequiredFilter', false);
							component.set('v.workTypeOptions', result.listWorkType);
							component.set('v.zipCodeOptions', result.listZipCode);
							component.set('v.statusOptions', result.listStatus);
							component.set('v.statusReasonOptions', result.listStatusReason);
							component.set('v.workTypeOptionsOriginal', result.listWorkType);
							component.set('v.zipCodeOptionsOriginal', result.listZipCode);
							component.set('v.listAllZipCode', result.listZipCode);
							component.set('v.statusOptionsOriginal', result.listStatus);
							component.set('v.statusReasonOptionsOriginal', result.listStatusReason);
							component.set('v.provincesOptions', result.listProvinces);
							component.set('v.mapProvinceListZipCode', result.mapProvinceListZipcode);
							component.set('v.provincesOptionsOriginal', result.listProvinces);
							component.set('v.countryUser', result.countryUser);
							component.set('v.columns', [
								{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkNumber"), fieldName: 'WorkOrderNumber', type: 'text' },
								{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderWorkType"), fieldName: 'XC_WorkTypeLabel__c', type: 'text' },
								{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderZipCode"), fieldName: 'PostalCode', type: 'text' },
								{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderStatus"), fieldName: 'Status', type: 'text' },
								{ label: 'Create Date', fieldName: 'CreatedDate', type: 'date' }
							]);
							let offSetWorkOrder = component.get('v.offSetWorkOrder');
							if(result.listWorkOrder.length <= offSetWorkOrder) {
								component.set('v.data', result.listWorkOrder);
								component.set('v.offsetListData', result.listWorkOrder);
								//component.set('v.offsetListData', new Array());
								component.set('v.summaryWorkOrdersView', '<b>Work Order shown:</b> '+ (result.listWorkOrder.length).toString() +'/'+ result.listWorkOrder.length.toString());
							} else {
								let woToShow = [];
								for(let i=0; i<offSetWorkOrder; i++) {
									woToShow.push(result.listWorkOrder[i]);
								}
								component.set('v.data', woToShow);
								component.set('v.indexOffsetWorkOrder', offSetWorkOrder);
								component.set('v.offsetListData', result.listWorkOrder);
								component.set('v.summaryWorkOrdersView', '<b>Work Order shown:</b> '+ (offSetWorkOrder).toString() +'/'+ result.listWorkOrder.length.toString());
							}
							component.set('v.originalData', result.listWorkOrder);
							helper.populateProductPicklist(component, event, helper);
							component.set('v.partnerChoosed', true);
							/*let typeOperation = component.get('v.operationSelected');
							if(typeOperation == '' || typeOperation == null || typeOperation == undefined) {
								component.set('v.showChooseOperation', true);
							}*/
							component.set('v.showFilterSelection', true);
							component.set('v.showDestinationPartner', true);
							let outOfDate = component.get('v.preferredTypeWOFilter');
							if(outOfDate=='TypeWOOutofDate') {
								component.set('v.updateDueDate', true);
								component.find('inputOutOfDate').set('v.disabled', true);
							} else {
								component.set('v.updateDueDate', false);
								component.find('inputOutOfDate').set('v.disabled', false);
							}
						}
						catch(error) {
							console.log('@@@@@ Error: ', error);
						}
					}
				}
				else {
					console.log('@@@ Error search work order: ' + a.getError());
				}
			});
			$A.enqueueAction(action);
			//component.set('v.disabledButton', "false");
		} else {
			helper.cleanAttributes(component, event, helper);
			component.set('v.showChooseOperation', true);
		}
		let filterQueryDestination = "RecordType.Name = 'Partner' AND Id != '" + component.get('v.originPartner') + "' AND Name != 'No Candidate Found'";
		component.set('v.filterStrikeLookupDestination', filterQueryDestination);
	},

	populateProductPicklist: function(component, event,  helpler) {
		component.set('v.spinnerControl', true);
		let listWorkOrder = component.get('v.originalData');
		let optsCheck = [];
		let opts = [];
		listWorkOrder.forEach(wo => {
			if (!optsCheck.includes(wo.XC_Conga_AssetProductName__c)){
				optsCheck.push(wo.XC_Conga_AssetProductName__c);
			}
		});

		optsCheck.forEach(element => {
			opts.push({
				value: element,
				label: element
			});
		});
		component.set('v.productOptions', opts);
        component.set('v.spinnerControl', false);
	},

	cleanAttributes: function (component, event, helper) {
		component.set('v.showOriginPartner', false);
		component.set('v.showLoadExcelOption', false);
		component.set('v.valueSearchChoiceOrigin', true);
		component.set('v.labelForUpload', 'Choose file...');
		component.set('v.preferredTypeWOFilter', "");
		component.set('v.fieldOrigin','Name');
		component.set('v.showExcelWorkOrder', false);
		component.set('v.fieldDestination','Name');
		component.set('v.valueSearchChoiceDestination', true);
		component.set('v.partnerChoosed', "false");
		component.set('v.destinationPartner', "");
		component.set('v.workTypeOptions', new Array());
		component.set('v.zipCodeOptions', new Array());
		component.set('v.statusOptions', new Array());
		component.set('v.statusReasonOptions', new Array());
		component.set('v.provincesOptions', new Array());
		component.set('v.selectedStatus', new Array());
		component.set('v.selectedStatusReason', new Array());
		component.set('v.selectedWorkType', new Array());
		component.set('v.selectedZipCode', new Array());
		component.set('v.workOrderFiltered', new Array());
		component.set('v.columnsWorkType', new Array());
		component.set('v.oldSelectedRowStatus', new Array());
		component.set('v.oldSelectedRowStatusReason', new Array());
		component.set('v.oldSelectedRowWorkType', new Array());
		component.set('v.oldSelectedRowZipcode', new Array());
		component.set('v.oldSelectedRowProvince', new Array());
		component.set('v.data', new Array());
		component.set('v.originalData', new Array());
		component.set('v.outOfDate', false);
		component.set('v.updateDueDate', false);
		component.set('v.disabledButton', true);
		component.set("v.spinnerControl", false);
		component.set('v.showInitialRequiredFilter', false);
		component.set("v.viewAllToggle", false);
		component.set('v.showTableZipCode', false);
		component.set("v.dataString", "");
		component.set("v.filterZipCode", "");
		component.set("v.filterStatus", "");
		component.set("v.filterStatusReason", "");
		component.set("v.filterWorkType", "");
		component.set('v.showManualSelection', false);
		component.set('v.showDestinationPartner', false);
		component.set('v.showFilterSelection', false);
		component.set('v.showChooseOutOfDateForFilterSelection', false);
		component.set('v.loadWorkOrder', false);
		component.set('v.operationSelected', '');
		component.set('v.comments', '');
		component.set('v.showChooseOperation', true);
		component.find('inputOutOfDate').set('v.disabled', false);

		component.set('v.valueStep', "1");
	},

	changeOutOfDate: function (component, event, helper) {
		component.set("v.spinnerControl", true);
		let outOfDate = component.get('v.outOfDate');
		component.set('v.dataString', "");
		if(outOfDate) {
			component.set('v.showManualSelection', false);
			let whereCondition = component.get('v.filterWorkOrderMultiLookup').replace('XC_OutOfDate__c = false', 'XC_OutOfDate__c = true');
			component.set('v.filterWorkOrderMultiLookup', whereCondition);
			component.set('v.showManualSelection', true);
			component.set('v.updateDueDate', true);
			component.find('inputOutOfDate').set('v.disabled', true);
		} else {
			component.set('v.showManualSelection', false);
			let whereCondition = component.get('v.filterWorkOrderMultiLookup');
			whereCondition = whereCondition.replace('XC_OutOfDate__c = true', 'XC_OutOfDate__c = false');
			component.set('v.filterWorkOrderMultiLookup', whereCondition);
			component.set('v.showManualSelection', true);
			component.set('v.updateDueDate', false);
			component.find('inputOutOfDate').set('v.disabled', false);
		}
		/*let partnerChoosed;
		if (outOfDate == true) {
			let whereCondition = component.get('v.filterWorkOrderMultiLookup');
			whereCondition = whereCondition.replace('XC_OutOfDate__c = false', 'XC_OutOfDate__c = true');
			component.set('v.filterWorkOrderMultiLookup', whereCondition);
			partnerChoosed = component.get('v.partnerChoosed');
			let typeOperation = component.get('v.operationSelected');
			let showInitialRequiredFilter = component.get('v.showInitialRequiredFilter');
			helper.cleanAttributes(component, event, helper);
			component.set('v.operationSelected', typeOperation);
			if(typeOperation == 'manual') {
				component.set('v.showChooseOperation', false);
				component.set('v.showManualSelection', true);
				//component.set('v.disabledButton', "false");
				component.set('v.showDestinationPartner', true);
				component.set('v.operationSelected','manual');
			} else {
				component.set('v.showChooseOperation', false);
				component.set('v.loadWorkOrder', true);
				//component.set('v.disabledButton', "false");
				component.set('v.showDestinationPartner', true);
				component.set('v.columnsWorkType', [
					{ label: 'Work Type', fieldName: 'label', type: 'text' }
				]);
				component.set('v.columnsZipcode', [
					{ label: 'Zip Code', fieldName: 'label', type: 'text' }
				]);
				component.set('v.columnsStatus', [
					{ label: 'Status', fieldName: 'label', type: 'text' }
				]);
				component.set('v.columnsStatusReason', [
					{ label: 'Status Reason', fieldName: 'label', type: 'text' }
				]);
				component.set('v.operationSelected','filter');
			}
			component.set('v.partnerChoosed', partnerChoosed);
			component.set('v.outOfDate', outOfDate);
			component.set('v.showInitialRequiredFilter', showInitialRequiredFilter);
			//helper.filterByOutOfDate(component, outOfDate);
		} else {
			let whereCondition = component.get('v.filterWorkOrderMultiLookup');
			whereCondition = whereCondition.replace('XC_OutOfDate__c = true', 'XC_OutOfDate__c = false');
			component.set('v.filterWorkOrderMultiLookup', whereCondition);
			partnerChoosed = component.get('v.partnerChoosed');
			let typeOperation = component.get('v.operationSelected');
			helper.cleanAttributes(component, event, helper);
			component.set('v.operationSelected', typeOperation);
			if(typeOperation == 'manual') {
				component.set('v.showManualSelection', true);
				//component.set('v.disabledButton', "false");
				component.set('v.showDestinationPartner', true);
				component.set('v.operationSelected','manual');
			} else {
				component.set('v.loadWorkOrder', true);
				//component.set('v.disabledButton', "false");
				component.set('v.showDestinationPartner', true);
				component.set('v.columnsWorkType', [
					{ label: 'Work Type', fieldName: 'label', type: 'text' }
				]);
				component.set('v.columnsZipcode', [
					{ label: 'Zip Code', fieldName: 'label', type: 'text' }
				]);
				component.set('v.columnsStatus', [
					{ label: 'Status', fieldName: 'label', type: 'text' }
				]);
				component.set('v.columnsStatusReason', [
					{ label: 'Status Reason', fieldName: 'label', type: 'text' }
				]);
				component.set('v.operationSelected','filter');
			}
			component.set('v.partnerChoosed', partnerChoosed);
			component.set('v.outOfDate', outOfDate);
			if(typeOperation != 'manual') {
				helper.searchWorkOrder(component, event, helper, false);
			}
			component.set('v.showChooseOperation', false);
		}
		let selectedProvinces = component.get('v.selectedProvinces');
        if(selectedProvinces.length == 0) {
			component.set('v.showTableZipCode', false);
			component.set('v.oldSelectedRowZipcode', new Array());
            component.set('v.selectedZipCode', component.get('v.listAllZipCode'));
        } else {
			component.set('v.showTableZipCode', true);
			helper.filterZipCodeFromProvinces(component, event, helper);
        }
		component.set('v.partnerChoosed', "true");*/
		component.set("v.spinnerControl", false);
	},

	changeViewAll: function (component, event, helper) {
		component.set('v.spinnerControl', true);
		let listData = component.get('v.data');
		let listOriginalData = component.get('v.originalData');
		let viewAllToggle = component.get('v.viewAllToggle');
		component.set('v.data', new Array());
		//component.set('v.disabledButton', true);

		if (viewAllToggle == true) {
			//helper.cleanAttributes(component, event, helper);
			//helper.searchWorkOrder(component, event, helper, false);
			component.set("v.dataString", "");
			listOriginalData = component.get('v.originalData');
			//component.set('v.data', listOriginalData);
			let offSetWorkOrder = component.get('v.offSetWorkOrder');
			if(listOriginalData.length <= offSetWorkOrder) {
				component.set('v.data', listOriginalData);
				component.set('v.offsetListData', listOriginalData);
				//component.set('v.offsetListData', new Array());
				component.set('v.summaryWorkOrdersView', '<b>Work Order shown: </b>'+ (listOriginalData.length).toString() +'/'+ listOriginalData.length.toString());
			} else {
				let woToShow = [];
				for(let i=0; i<offSetWorkOrder; i++) {
					woToShow.push(listOriginalData[i]);
				}
				component.set('v.data', woToShow);
				component.set('v.indexOffsetWorkOrder', offSetWorkOrder);
				component.set('v.offsetListData', listOriginalData);
				component.set('v.summaryWorkOrdersView', '<b>Work Order shown: </b>'+ (offSetWorkOrder).toString() +'/'+ listOriginalData.length.toString());
			}
		} else {
			component.set("v.dataString", "");
			//helper.cleanAttributes(component, event, helper);			
		}
		listData = component.get('v.data');
		component.set("v.spinnerControl", false);
	},

	onChangeTable : function(component, event, helper) {
		component.set("v.spinnerControl", true);
		let newData = [];
		if(helper.checkDates(component)) {
			let listFilterWorkTypeTemp = component.get('v.selectedWorkType');
			let listFilterWorkType = [];
			listFilterWorkTypeTemp.forEach(element => {
				listFilterWorkType.push(element.label);
			});
			let listFilterPostalCodeTemp = component.get('v.selectedZipCode');
			let listFilterPostalCode = [];
			listFilterPostalCodeTemp.forEach(element => {
				listFilterPostalCode.push(element.label);
			});
			let listFilterStatusTemp = component.get('v.selectedStatus');
			let listFilterStatus = [];
			listFilterStatusTemp.forEach(element => {
				listFilterStatus.push(element.label);
			});
			let listFilterStatusReasonTemp = component.get('v.selectedStatusReason');
			let listFilterStatusReason = [];
			listFilterStatusReasonTemp.forEach(element => {
				listFilterStatusReason.push(element.label);
			});
			let listFilterProductString = component.get('v.selectedProductString');
			let listFilterProduct = listFilterProductString != null ? listFilterProductString.split(";") : [""];
			let listFilterStartDate = component.get('v.selectedStartDate');
			let listFilterEndDate = component.get('v.selectedEndDate');
			let listOriginalData = component.get('v.originalData');		
			
			for(let i in listOriginalData) {
				if(
					(listFilterWorkType.includes(listOriginalData[i].XC_WorkTypeLabel__c) || listFilterWorkType.length == 0)         &&
					(listFilterPostalCode.includes(listOriginalData[i].PostalCode) || listFilterPostalCode.length == 0) 	         &&
					(listFilterStatus.includes(listOriginalData[i].Status) || listFilterStatus.length == 0)                          &&
					(listFilterStatusReason.includes(listOriginalData[i].XC_StatusReasonFormula__c) || listFilterStatusReason.length == 0) 	         &&
					(listFilterProduct.includes(listOriginalData[i].XC_Conga_AssetProductName__c) || listFilterProduct.length == 0 || listFilterProduct[0] == "") &&
					((new Date(listOriginalData[i].CreatedDate) >= new Date(listFilterStartDate) && new Date(listOriginalData[i].CreatedDate) <= new Date(listFilterEndDate)) || listFilterStartDate == "" || listFilterEndDate == "" || listFilterStartDate == null || listFilterEndDate == null)
				) {
					newData.push(listOriginalData[i]);
				}
			}
			//component.set('v.data', newData);
			let offSetWorkOrder = component.get('v.offSetWorkOrder');
			if(newData.length <= offSetWorkOrder) {
				component.set('v.data', newData);
				component.set('v.offsetListData', newData);
				//component.set('v.offsetListData', new Array());
				component.set('v.summaryWorkOrdersView', '<b>Work Order shown: </b>'+ (newData.length).toString() +'/'+ newData.length.toString());
			} else {
				let woToShow = [];
				for(let i=0; i<offSetWorkOrder; i++) {
					woToShow.push(newData[i]);
				}
				component.set('v.data', woToShow);
				component.set('v.indexOffsetWorkOrder', offSetWorkOrder);
				component.set('v.offsetListData', newData);
				component.set('v.summaryWorkOrdersView', '<b>Work Order shown: </b>'+ (offSetWorkOrder).toString() +'/'+ newData.length.toString());
			}
		}
		component.set("v.spinnerControl", false);
	},

	checkDates: function(component){
		component.set('v.spinnerControl', true);
		let listFilterStartDate = component.get('v.selectedStartDate');
		let listFilterEndDate = component.get('v.selectedEndDate');
		
		if ( (listFilterStartDate != "" && listFilterEndDate != "" && listFilterStartDate != null && listFilterEndDate != null)  || 
			((listFilterStartDate == "" && listFilterEndDate == "") || (listFilterStartDate == null && listFilterEndDate == null) || 
			(listFilterStartDate == "" && listFilterEndDate == null) || (listFilterStartDate == null && listFilterEndDate == "")) ){
			component.set('v.spinnerControl', true);
			return true;
		}else{
			let toastEvent = $A.get("e.force:showToast");
			let errorMessage;
			if (listFilterStartDate == "" || listFilterStartDate == null){
				errorMessage = $A.get("$Label.c.XC_CL_StartDate_Populate");
			}
			
			if (listFilterEndDate == "" || listFilterEndDate == null){
				errorMessage = $A.get("$Label.c.XC_CL_EndDate_Populate");
			}
			toastEvent.setParams({
				title: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkError"),
				message: errorMessage,
				key: 'info_alt',
				type: 'error',
				mode: 'dismissible'
			});
			toastEvent.fire();
			component.set('v.spinnerControl', true);
			return false;
		}
	},

	filterByOutOfDate: function (component, outOfDate) {
		component.set('v.spinnerControl', true);
		if(outOfDate) {
			let listZip = new Array();
			let listWt = new Array();
			if(component.get('v.showInitialRequiredFilter')) {
				let listZipTemp = component.get('v.selectedZipCode');
				let listWtTemp = component.get('v.selectedWorkType');
				for(let i=0; i<listZipTemp.length; i++){
					listZip.push(listZipTemp[i].value);
				}
				for(let i=0; i<listWtTemp.length; i++){
					listWt.push(listWtTemp[i].value);
				}
			}
			let action = component.get("c.getResultWrapperByPartner");
			action.setParams({
				'idAssignedPartner': component.get('v.originPartner'),
				'isOutOfDateFilter': outOfDate,
				'cutoff': component.get('v.maxNumberWorkorder'),
				'initialFilter': component.get('v.showInitialRequiredFilter'),
				'listZipCodeSelectedString': JSON.stringify(listZip),
				'listWorkTypeSelectedString': JSON.stringify(listWt),
				'initialLimitedFilter': false
			});
			action.setCallback(this, function (a) {
				let state = a.getState();
				component.set("v.spinnerControl", false);
				if (state === "SUCCESS") {
					let result = a.getReturnValue();
					//component.set('v.data', result.listWorkOrder);
					let offSetWorkOrder = component.get('v.offSetWorkOrder');
					if(result.listWorkOrder.length <= offSetWorkOrder) {
						component.set('v.data', result.listWorkOrder);
						component.set('v.offsetListData', result.listWorkOrder);
						//component.set('v.offsetListData', new Array());
						component.set('v.summaryWorkOrdersView', '<b>Work Order shown: </b>'+ (result.listWorkOrder).toString() +'/'+ result.listWorkOrder.toString());
					} else {
						let woToShow = [];
						for(let i=0; i<offSetWorkOrder; i++) {
							woToShow.push(result.listWorkOrder[i]);
						}
						component.set('v.data', woToShow);
						component.set('v.indexOffsetWorkOrder', offSetWorkOrder);
						component.set('v.offsetListData', result.listWorkOrder);
						component.set('v.summaryWorkOrdersView', '<b>Work Order shown: </b>'+ (offSetWorkOrder).toString() +'/'+ result.listWorkOrder.toString());
					}
					component.set('v.originalData', result.listWorkOrder);
					component.set('v.workTypeOptions', result.listWorkType);
					component.set('v.zipCodeOptions', result.listZipCode);
					component.set('v.statusOptions', result.listStatus);
					component.set('v.statusReasonOptions', result.listStatusReason);
					component.set('v.provincesOptions', result.listProvinces);
					component.set('v.provincesOptionsOriginal', result.listProvinces);
					component.set('v.columns', [
						{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkNumber"), fieldName: 'WorkOrderNumber', type: 'text' },
						{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderWorkType"), fieldName: 'XC_WorkTypeLabel__c', type: 'text' },
						{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderZipCode"), fieldName: 'PostalCode', type: 'text' },
						{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderStatus"), fieldName: 'Status', type: 'text' }
					]);
					let idOriginPartner = component.get('v.originPartner');
					component.set('v.partnerChoosed', true);
					//component.set('v.filterStrikeLookupDestination', "RecordType.Name = 'Partner' AND Id != '" + idOriginPartner + "' AND Name != 'No Candidate Found'");
				} else {
					component.set("v.outOfDate", !outOfDate);
				}
			});
			$A.enqueueAction(action);
		}
	},

	enableButton: function (component, event, helper) {
		let destinationPartner = component.get('v.destinationPartner');
		let massiveMethod = component.get('v.viewAllToggle');
		let workorderSelected = component.get('v.dataString');

		if(!massiveMethod) {
			// For single method:
			if(workorderSelected != null && workorderSelected != undefined && workorderSelected != '') {
				if(destinationPartner != null && destinationPartner != undefined && destinationPartner != '') {
					component.set('v.valueStep', "4");
				} else {
					component.set('v.valueStep', "3");
				}
			} else {
				component.set('v.valueStep', "2");
			}
			if(destinationPartner != null && destinationPartner != undefined && destinationPartner != '') {
				if(workorderSelected != null && workorderSelected != undefined && workorderSelected != '') {
					component.set('v.valueStep', "4");
				} else {
					component.set('v.valueStep', "2");
				}
			} else {
				if(workorderSelected != null && workorderSelected != undefined && workorderSelected != '') {
					component.set('v.valueStep', "3");
				} else {
					component.set('v.valueStep', "2");
				}
			}
		} else {
			if(destinationPartner != null && destinationPartner != undefined && destinationPartner != '') {
				component.set('v.valueStep', "4");
			} else  {
				component.set('v.valueStep', "3");
			}
		}
		
		let checkOptions = (!massiveMethod && workorderSelected != null && workorderSelected != undefined && workorderSelected != '') || massiveMethod;
		if(destinationPartner != null && destinationPartner != undefined && destinationPartner != '' && checkOptions) {
			component.set('v.disabledButton', "false");
		} else {
			component.set('v.disabledButton', "true");
		}
	},

	viewLogs: function (component, event, helper) {
		component.set("v.spinnerControl", true);
		let action = component.get("c.populateWrapperResult");
		action.setParams({
			'dirtyData': false
		});
		action.setCallback(this, function (a) {
			let state = a.getState();
			if (state === "SUCCESS") {
				component.set("v.spinnerControl", false);
				let result = a.getReturnValue();
				if (result.success && result.listViews.length != 0) {
					let navEvent = $A.get("e.force:navigateToList");
					navEvent.setParams({
						"listViewId": result.listViews[0].Id,
						"listViewName": result.listViews[0].Name,
						"scope": "XC_MassiveAssignmentWorkOrderLog__c"
					});
					navEvent.fire();
				}
				else {
					let toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkError"),
						message: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderErrorViewLogs"),
						key: 'info_alt',
						type: 'success',
						mode: 'dismissible'
					});
					toastEvent.fire();
				}
			}
		});
		$A.enqueueAction(action);
	},

	applyFilter : function(component, event, helper) {
		component.set('v.spinnerControl', true);
		helper.onChangeTable(component, event, helper);
		component.set('v.spinnerControl', false);
	},

	filterZipCodeFromProvinces : function(component, event, helper) {
		let zipCodeFiltered = [];
		let provincesSelected = component.get('v.selectedProvinces');
		let mapProvinceZipCodes = component.get('v.mapProvinceListZipCode');

		provincesSelected.forEach(province => {
			let listZipCode = mapProvinceZipCodes.hasOwnProperty(province.value) ? mapProvinceZipCodes[province.value] : null;
			if(listZipCode != null) {
				zipCodeFiltered = zipCodeFiltered.concat(listZipCode);
			}
		});

		zipCodeFiltered = zipCodeFiltered.filter((thing, index) => {
            const _thing = JSON.stringify(thing);
            return index === zipCodeFiltered.findIndex(obj => {
              return JSON.stringify(obj) === _thing;
            });
        });
		if(zipCodeFiltered.length != 0) {
			component.set('v.zipCodeOptions', zipCodeFiltered);
			component.set('v.zipCodeOptionsOriginal', zipCodeFiltered);
		} else {
			component.set('v.showTableZipCode', false);
			component.set('v.oldSelectedRowZipcode', new Array());
            component.set('v.selectedZipCode', component.get('v.listAllZipCode'));
		}
	},

	assignWorkOrder: function (component, event, helper) {
		component.set("v.spinnerControl", true);
		if (component.get('v.destinationPartner') == "") {
			//component.set('v.disabledButton', "true");
			component.set("v.spinnerControl", false);
			let toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				title: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkError"),
				message: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderPartnerNeeded"),
				key: 'info_alt',
				type: 'error',
				mode: 'dismissible'
			});
			toastEvent.fire();
		} else {
			let massiveMood = component.get('v.viewAllToggle');
			let listWorkOrder = [];
			//let originalData = component.get('v.originalData');
			if(!massiveMood) {
				let dataString = component.get('v.dataString');
				let dataStringArray = dataString.split(";");
				dataStringArray.forEach(woTemp => {
					/*for(let index=0; index<originalData.length; index++) {
						const original = originalData[index];
						if(original.Id == woTemp) {*/
							let mapWorkOrder = {
								'Id' : woTemp
							};
							listWorkOrder.push(mapWorkOrder);
							/*break;
						}
					}*/
				});
			} else {
				listWorkOrder = component.get('v.offsetListData');
			}

			let action = component.get("c.assignPartnerToWorkOrder");
			let mapAssign = {
				'originPartner': component.get('v.originPartner'),
				'destinationPartner': component.get('v.destinationPartner'),
				'updateDueDate': component.get('v.updateDueDate'),
				'outOfDate': component.get('v.outOfDate'),
				'comments': component.get('v.comments'),
				'moodAllWo': massiveMood,
				'checkCoverage': component.get('v.checkCoverage'),
				'assignToPartner': component.get('v.assignToPartner')
			}
			let mapAssignString = JSON.stringify(mapAssign);
			action.setParams({
				'mapAssignString': mapAssignString,
				'listWorkOrder': listWorkOrder
			});
			action.setCallback(this, function (a) {
				let state = a.getState();
				if (state === "SUCCESS") {
					let result = a.getReturnValue();
					if(result.success) {
						let toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							title: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderSuccess"),
							message: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderRequestAccepted"),
							key: 'info_alt',
							type: 'warning',
							mode: 'dismissible'
						});
						toastEvent.fire();
						let result = a.getReturnValue();
						if(result.dirtyData == true) {
							let toastAlertDirtyData = $A.get("e.force:showToast");
							toastAlertDirtyData.setParams({
								title: "Attention",
								message: "Some Work Orders have been deleted from the list because some data are missing (such as Legal Entity, Work Type, Segment, etc...)",
								key: 'info_alt',
								type: 'error',
								mode: 'dismissible'
							});
							toastAlertDirtyData.fire();
						}

						helper.cleanAttributes(component, event, helper);
						$A.get('e.force:refreshView').fire();
						result = a.getReturnValue();
						if (result.listViews.length != 0) {
							let navEvent = $A.get("e.force:navigateToList");
							navEvent.setParams({
								"listViewId": result.listViews[0].Id,
								"listViewName": result.listViews[0].Name,
								"scope": "XC_MassiveAssignmentWorkOrderLog__c"
							});
							navEvent.fire();
						}
					} else {
						component.set("v.spinnerControl", false);
						let toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							title: $A.get("$Label.c.XC_CL_ErrorsOccurred"),
							message: result.resultMessage,
							key: 'info_alt',
							type: 'error',
							mode: 'dismissible'
						});
						toastEvent.fire();
					}
				} else {
					component.set("v.spinnerControl", false);
					let toastEventError = $A.get("e.force:showToast");
					toastEventError.setParams({
						title: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkError"),
						message: JSON.parse(JSON.stringify(a.getError())),
						key: 'info_alt',
						type: 'error',
						mode: 'dismissible'
					});
					toastEventError.fire();
				}
			});
			$A.enqueueAction(action);
		}
	},

	uploadFile : function(component, event, helper) {
		component.set('v.spinnerControl', true);
		component.set('v.viewAllToggle', true);
        let files = component.find("file").get("v.files");
        if(!files || files == null || files == undefined || files.length == 0 || !files[0].name.includes('xls')) {
			$A.createComponent("ui:outputText", {
				"value" : $A.get("$Label.c.XC_CL_ErrorExcel")
			}, function(contentComponent, status, error) {
				if(status === "SUCCESS") {
					var modalBody = contentComponent;
					component.find('overlayLib').showCustomModal({
						header: "Warning",
						body: modalBody, 
						showCloseButton: true,
						cssClass: "mymodal",
					})
				} else {
					console.log('(-_-) Error: ', JSON.parse(JSON.stringify(error)));
				}
			});
            component.find('file').set("v.class", "errorUpload"); 
            component.set('v.spinnerControl', false);
            return;
        }
        let fileTemp = files[0];
        if(fileTemp) {
            let reader = new FileReader();
            //reader.readAsText(file, "UTF-8");
			reader.readAsBinaryString(fileTemp);
            reader.onload = function (evt) {
				try {
					let csv = evt.target.result;
                    let workbook = XLSX.read(csv, {
                        type: 'binary'
                    });
                    let json_object;
                    workbook.SheetNames.forEach(function(sheetName) {
                        let XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);
                        json_object = JSON.stringify(XL_row_object);
                    });
                    let result = json_object;//helper.CSV2JSON(component, csv);
					helper.runWO(component,event, helper, result);
				} catch(error) {
					$A.createComponent("ui:outputText", {
						"value" : error.toString()
					}, function(contentComponent, status, error) {
						if(status === "SUCCESS") {
							var modalBody = contentComponent;
							component.find('overlayLib').showCustomModal({
								header: "Error",
								body: modalBody, 
								showCloseButton: true,
								cssClass: "mymodal",
							})
						} else {
							console.log('(-_-) Error: ', JSON.parse(JSON.stringify(error)));
						}
					}); 
					component.find('file').set("v.class", "errorUpload");
				}
            }
            reader.onerror = function (evt) {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error to read CSV file",
                    "type": "error"
                });
                toastEvent.fire();  
                component.set('v.spinnerControl', false);
                return;
            }
        } else {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": "Error to upload CSV file",
                "type": "error"
            });
            toastEvent.fire();  
            component.set('v.spinnerControl', false);
            return;
        }
	},
	
	CSV2JSON : function (component,csv) {
        let arr = csv.split('\n');
        arr.pop();
        let jsonObj = [];
        let headers = arr[0].split(',');
        for(let i=1; i<arr.length; i++) {
            let data = arr[i].split(',');
            let obj = {};
            for(let j=0; j<data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
            }
            jsonObj.push(obj);
        }
        let json = JSON.stringify(jsonObj);
        return json;
	},
	
	runWO : function(component, event, helper, jsonstr) {
        let action = component.get("c.uploadFileCsv");
        action.setParams({
            "strfromlex" : jsonstr
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {  
				let result = response.getReturnValue();
				if(result.length == 0) {
					$A.createComponent("ui:outputText", {
						"value" : "No Work Order to show"
					}, function(contentComponent, status, error) {
						if(status === "SUCCESS") {
							var modalBody = contentComponent;
							component.find('overlayLib').showCustomModal({
								header: "Error",
								body: modalBody, 
								showCloseButton: true,
								cssClass: "mymodal",
							})
						} else {
							console.log('(-_-) Error: ', JSON.parse(JSON.stringify(error)));
						}
					}); 
					component.find('file').set("v.class", "errorUpload"); 
				} else {
					component.set('v.columns', [
						{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkNumber"), fieldName: 'WorkOrderNumber', type: 'text' },
						{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderWorkType"), fieldName: 'XC_WorkTypeLabel__c', type: 'text' },
						{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderZipCode"), fieldName: 'PostalCode', type: 'text' },
						{ label: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderStatus"), fieldName: 'Status', type: 'text' },
						{ label: 'Create Date', fieldName: 'CreatedDate', type: 'date' }
					]);
					let offSetWorkOrder = component.get('v.offSetWorkOrder');
					if(result.length <= offSetWorkOrder) {
						component.set('v.data', result);
						component.set('v.offsetListData', result);
						//component.set('v.offsetListData', new Array());
						component.set('v.summaryWorkOrdersView', '<b>Work Order shown:</b> '+ result.length.toString() +'/'+ result.length.toString());
					} else {
						let woToShow = [];
						for(let i=0; i<offSetWorkOrder; i++) {
							woToShow.push(result[i]);
						}
						component.set('v.data', woToShow);
						component.set('v.indexOffsetWorkOrder', offSetWorkOrder);
						component.set('v.offsetListData', result);
						component.set('v.summaryWorkOrdersView', '<b>Work Order shown:</b> '+ offSetWorkOrder.toString() +'/'+ result.length.toString());
					}
					component.set('v.showLoadExcelOption', false);
					component.set('v.showExcelWorkOrder', true);
					component.set('v.partnerChoosed', true);
					component.set('v.showDestinationPartner', true);
					component.set('v.viewAllToggle', true);
					component.set('v.valueStep', "3");
				}
            }
            else {
                $A.createComponent("ui:outputText", {
					"value" : JSON.parse(JSON.stringify(response.getError()))[0].message
				}, function(contentComponent, status, error) {
					if(status === "SUCCESS") {
						var modalBody = contentComponent;
						component.find('overlayLib').showCustomModal({
							header: "Error",
							body: modalBody, 
							showCloseButton: true,
							cssClass: "mymodal",
						})
					} else {
						console.log('(-_-) Error: ', JSON.parse(JSON.stringify(error)));
					}
				}); 
				component.find('file').set("v.class", "errorUpload"); 
            }
            component.set('v.spinnerControl', false);
        }); 
		$A.enqueueAction(action); 
    },

	setWorkspace : function(component, event, helper) {
        console.log('@@@ Welcome in the fantastic component LCP106!');
        let workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url : '/lightning/n/XC_MassiveWorkOrderAssignment',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response ,
                label: "Massive WorkOrder Assignment" 
            });
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: "utility:planning_poker",
            });
        }); 
    },

})