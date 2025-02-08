/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 12/06/2019
* @description XC_LCP119_ServiceResourceManagement - Helper Class
*/

({
	init : function(component, event, helper) { 
		component.set('v.spinnerControl', true);
		let accountId = component.get('v.recordId');
		console.log('@@@ accountId ---> ', accountId);

		let action = component.get("c.getServiceResourceByPartner");
		action.setParams({ 
			'accountId' : accountId
		});
		action.setCallback(this, function(a) { 
			let state = a.getState();
			console.log('@@@ State init ---> ' + state);
			if(state === "SUCCESS") {
				component.set('v.spinnerControl', false);
				let result = a.getReturnValue(); 
				if(result == null) {
					let toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
						message: $A.get("$Label.c.XC_CL_SerResMangement_ErrorAccessData"),
						key: 'info_alt',
						type: 'error',
						mode: 'dismissible', 
						mode: 'pester'
					});
					toastEvent.fire();
				}
				else {
					console.log('@@@ result ', result);
					let listServiceResourceDocument = result.listServiceResourceDocument;
					let listServiceResourceStatus = result.listServiceResourceStatus;
					let listServiceResourceSkill = result.listServiceResourceSkill;
					let listDataResult = [];

					listServiceResourceStatus.forEach(element => {
						let mapDocument = { 
							'Id' : element.Id,
							'urlServiceResource' : '/one/one.app?#/sObject/' + element.Id + '/view',
							'nameServiceResource' : element.nameServiceResource,
							'label' : element.label,
							'color' : element.color,
							'_children' : helper.getMapSkill(component, helper, element.Id, listServiceResourceSkill, listServiceResourceDocument)
						}
						listDataResult.push(mapDocument);
					});
					console.log('@@@ listDataResult ---> ', listDataResult);
					component.set('v.data', listDataResult);
				}
			}
			else {
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
					message: $A.get("$Label.c.XC_CL_SerResMangement_ErrorMess"), //Cambiare il messaggio!!
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				toastEvent.fire();
			}
		});
		$A.enqueueAction(action);
		helper.populateNameColumns(component);
	}, 

	getMapSkill : function(component, helper, srId, listServiceResourceSkill, listServiceResourceDocument) {
		let listSkill = [];
		listServiceResourceSkill.forEach(element => {
			if(element.Id == srId) {
				let mapSkill = {
					'Id' : element.nameSkill,
					'nameSkill' : element.nameSkill,
					'active' : element.active,
					'_children' : helper.getMapDoc(component, element.nameSkill, srId, listServiceResourceDocument)
				}
				listSkill.push(mapSkill);
			}
		});
		return listSkill;
	},

	getMapDoc : function(component, nameSkill, srId, listServiceResourceDocument) {
		console.log('*** For Skill: ' + nameSkill + ' and Service Resource ' + srId);
		let listDocument = [];
		let srFound = false;
		let srdFound = false;
		listServiceResourceDocument.forEach(element => {
			if(srId in element) {
				srFound = true;
				let mapSrd = element[srId];
				Object.keys(mapSrd).forEach(function(key) {
					if(nameSkill == key && Object.keys(mapSrd[key]).length != 0) {
						srdFound = true;
						let listDocumentForSkill = mapSrd[key];
						listDocumentForSkill.forEach(element => {
							let mapDocument = {
								'Id' : element['nameDocument'],
								'nameDocument' : element['nameDocument'],
								'type' : element['type'],
								'startDate' : element['startDate'],
								'endDate' : element['endDate']
							}
							listDocument.push(mapDocument);
						});
					}
				});
			} 
		});
		if(!srFound || !srdFound) {
			// Create a row for No document found
			let mapDocument = {
				'nameDocument' : $A.get("$Label.c.XC_CL_SerResMangement_NoDocFound"),
				'type' : '-',
				'startDate' : '-',
				'endDate' : '-'
			}
			listDocument.push(mapDocument);
		}
		return listDocument;
	},

	populateNameColumns : function(component) {
		let columns = [
            { type: 'url', fieldName: 'urlServiceResource', initialWidth: 180, label: $A.get("$Label.c.XC_CL_SerResMangement_ServiceResource"), typeAttributes: { 
				label: {fieldName: 'nameServiceResource'},
				target: '_self'
			}},
            { label: $A.get("$Label.c.XC_CL_SerResMangement_Status"), initialWidth: 80, /*fieldName: 'label', /* Decomment to print message near icon */  cellAttributes: { 
				iconName: {
					fieldName: 'color'
				}
			}},
            { type: 'text', fieldName: 'nameSkill', initialWidth: 180, label: $A.get("$Label.c.XC_CL_SerResMangement_Skill") },
			{ label: $A.get("$Label.c.XC_CL_SerResMangement_Active"), initialWidth: 80, cellAttributes: { 
				iconName: { fieldName: 'active'	}
			}},
			{ type: 'text', fieldName: 'nameDocument', label: $A.get("$Label.c.XC_CL_SerResMangement_Document") },
			{ type: 'text', fieldName: 'type', label: 'Type', initialWidth: 60},
			{ type: 'text', fieldName: 'startDate', label: $A.get("$Label.c.XC_CL_SerResMangement_StartDate") },
			{ type: 'text', fieldName: 'endDate', label: $A.get("$Label.c.XC_CL_SerResMangement_EndDate") }
		];
		component.set('v.columns', columns);
	},

	getIcon : function (component, row, doneCallback) {
		var icon = '';
		if(row['color'] == 'green') {
		   icon = 'utility:check';
		}else {
		   icon = 'utility:add';
		}     
		return icon;
   },

})