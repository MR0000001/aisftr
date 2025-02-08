({
    /*initialize : function(component, event, helper) {
		let action = component.get("c.initialize");

        let skillsToShow = parseInt(JSON.parse(component.get('v.fieldSet')).custom.skillsToShow);
        console.log('skillsToShow>>> ' + skillsToShow);

        action.setParams({
            'recordId' : component.get("v.partnerId")
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log('@state@ '+state);

            if (state === "SUCCESS") {
                let storeResponse = response.getReturnValue();
                
                let nextDisabled = storeResponse.serviceResourceList.length > skillsToShow ? true : false;

                storeResponse.serviceResourceList.forEach(function(singleServiceResource) {
                    singleServiceResource.showSkills = true;
                    singleServiceResource.skillsIndex = 1;
                    singleServiceResource.previousDisabled = false;
                    singleServiceResource.nextDisabled = nextDisabled;
                    console.log('@@>> singleServiceResource >>> ' + JSON.stringify(singleServiceResource));

                    singleServiceResource.paginatedServiceResourceSkills = [];
                    let index = 0;

                    singleServiceResource.ServiceResourceSkills.forEach(function(singleSkill) {
                        singleSkill.RelatedDocuments = [];
                        let singleDocument = storeResponse.skillNameToDocumentMap[singleSkill.Skill.MasterLabel];

                        singleServiceResource.Service_Resource_Documents__r.forEach(function(relatedDocument) {
                            if(singleDocument.nameDocument == relatedDocument.Name){
                                singleDocument.startDate = relatedDocument.XC_StartDateOfValidity__c;
                                singleDocument.endDate = relatedDocument.XC_ExpirationDateOfValidity__c;
                            }
                        });
                            
                        singleSkill.RelatedDocuments.push(singleDocument);
                        if(index < skillsToShow){
                            singleServiceResource.paginatedServiceResourceSkills.push(singleSkill);
                        }
                        index ++;
                    });

                });

                component.set("v.serviceResourceList", storeResponse.serviceResourceList);

                component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
                component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
                component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
                component.set("v.skillsToShow", skillsToShow);

                helper.fireSendInitStateEvt(component, true);
                component.set('v.isInitialized', true);
                console.log('initialize finita');

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
        }); //Action

        console.log('@ACTION@:'+action);
        $A.enqueueAction(action);
    },*/

    initialize : function(component, event, helper) { 

		let action = component.get("c.getServiceResourceByPartner");

        let skillsToShow = parseInt(JSON.parse(component.get('v.fieldSet')).custom.skillsToShow);
        console.log('skillsToShow>>> ' + skillsToShow);

        action.setParams({
            'accountId' : component.get("v.partnerId")
        });

		action.setCallback(this, function(a) { 
			let state = a.getState();
			console.log('@@@ State init ---> ' + state);
			if(state === "SUCCESS") {
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
					
                    //let nextDisabled = storeResponse.serviceResourceList.length > skillsToShow ? true : false;
                    let nextDisabled = false;
					let listServiceResourceDocument = result.listServiceResourceDocument;
					let listServiceResourceStatus = result.listServiceResourceStatus;
					let listServiceResourceSkill = result.listServiceResourceSkill;

					let serviceResourceList = [];

					listServiceResourceStatus.forEach(item => {

						let singleServiceResource = { 
							'Id' : item.Id,
							'Name' : item.nameServiceResource,
                            'Status' : item.color, 
							'ServiceResourceSkills' : helper.getMapSkill(component, helper, item.Id, listServiceResourceSkill, listServiceResourceDocument)
						}

                        singleServiceResource.showSkills = false; //ENXCRM-211 | BGO 20062022
                        singleServiceResource.skillsIndex = 1;
                        singleServiceResource.previousDisabled = false;
                        singleServiceResource.nextDisabled = nextDisabled;

                        singleServiceResource.paginatedServiceResourceSkills = [];
                        let index = 0;

                        singleServiceResource.ServiceResourceSkills.forEach(function(singleSkill) {
                                
                            if(index < skillsToShow){
                                singleServiceResource.paginatedServiceResourceSkills.push(singleSkill);
                            }
                            index ++;
                        });

						serviceResourceList.push(singleServiceResource);
					});
					console.log('@@>> serviceResourceList >>> ', serviceResourceList);
					component.set("v.serviceResourceList", serviceResourceList);

                    component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
                    component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
                    component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
                    component.set("v.skillsToShow", skillsToShow);

                    helper.fireSendInitStateEvt(component, true);
                    component.set('v.isInitialized', true);
                    console.log('initialize finita');
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
	}, 

	getMapSkill : function(component, helper, srId, listServiceResourceSkill, listServiceResourceDocument) {
		let listSkill = [];
		listServiceResourceSkill.forEach(element => {
			if(element.Id == srId) {
				let mapSkill = {
					'Id' : element.Id,
					'Name' : element.nameSkill,
					'Active' : element.active,
					'SkillDocuments' : helper.getMapDoc(component, element.nameSkill, srId, listServiceResourceDocument)
				}
				listSkill.push(mapSkill);
			}
		});
		return listSkill;
	},

	getMapDoc : function(component, nameSkill, srId, listServiceResourceDocument) {
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

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP265_PartnerSkills >> Helper >> fireSendInitStateEvt >> Start');
        
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" :  "TA_LCP265_PartnerSkills",
            "initState"   :  isInitialized
        });

        sendInitStateEvt.fire();
        console.log('TA_LCP265_PartnerSkills >> Helper >> fireSendInitStateEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP265_PartnerSkills#fireToggleSpinnerEvent#invoked');

        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP265_PartnerSkills",
            "toggleSpinner"   : toggleSpinner
        });

        toggleSpinnerEvent.fire();
        console.log('TA_LCP265_PartnerSkills#fireToggleSpinnerEvent#finish');
    },

    toggleSkills : function(component, event, helper) {
        console.log('TA_LCP265_PartnerSkills#toggleSkills#invoked');
        let currentServiceResourceId = event.currentTarget.id;
        console.log('currentServiceResourceId >>>>> ' + currentServiceResourceId);

        let serviceResourceList = component.get('v.serviceResourceList');        

        serviceResourceList.forEach(function(singleServiceResource) {
            if(singleServiceResource.Id == currentServiceResourceId){
                singleServiceResource.showSkills = !singleServiceResource.showSkills;
            }
        });
        
        component.set("v.serviceResourceList", serviceResourceList);
        console.log('TA_LCP265_PartnerSkills#toggleSkills#finish');
    },

    goPrevious : function(component, event, helper) {
        console.log('TA_LCP265_PartnerSkills#handleGoPrevious#invoked');
        let currentServiceResourceId = event.currentTarget.id;
        let skillsToShow = component.get("v.skillsToShow");
        console.log('currentServiceResourceId >>>>> ' + currentServiceResourceId);

        let serviceResourceList = component.get('v.serviceResourceList');
        let updateServiceResourceList  = false;

        serviceResourceList.forEach(function(singleServiceResource) {
            if(singleServiceResource.Id == currentServiceResourceId && !singleServiceResource.previousDisabled){

                if(singleServiceResource.skillsIndex == 1){

                    return;
                }

                singleServiceResource.nextDisabled = false;

                singleServiceResource.paginatedServiceResourceSkills = [];
                let startingPoint = (singleServiceResource.skillsIndex - 2) * skillsToShow;
                console.log('current skillsIndex >>> ' + singleServiceResource.skillsIndex);
                console.log('starting point >>> ' + startingPoint)

                for(let i = startingPoint; i < startingPoint + skillsToShow; i++) {
                    if(singleServiceResource.ServiceResourceSkills[i]){
                        singleServiceResource.paginatedServiceResourceSkills.push(singleServiceResource.ServiceResourceSkills[i]);
                    }
                }

                let skillsIndexToBe = singleServiceResource.skillsIndex;

                if(skillsIndexToBe -- == 0){
                    singleServiceResource.previousDisabled = true;
                    
                } else {
                    updateServiceResourceList = true;
                    singleServiceResource.skillsIndex --;
                    singleServiceResource.previousDisabled = false;
                }
                
            }
        });
        
        if(updateServiceResourceList){
            component.set("v.serviceResourceList", serviceResourceList);
        }
        
        console.log('TA_LCP265_PartnerSkills#handleGoPrevious#finish');
    },

    goNext : function(component, event, helper) {
        console.log('TA_LCP265_PartnerSkills#handleGoNext#invoked');
        let currentServiceResourceId = event.currentTarget.id;
        let skillsToShow = component.get("v.skillsToShow");
        console.log('currentServiceResourceId >>>>> ' + currentServiceResourceId);

        let serviceResourceList = component.get('v.serviceResourceList');
        let updateServiceResourceList  = false;

        serviceResourceList.forEach(function(singleServiceResource) {
            if(singleServiceResource.Id == currentServiceResourceId && !singleServiceResource.nextDisabled){

                singleServiceResource.previousDisabled = false;

                singleServiceResource.paginatedServiceResourceSkills = [];
                let startingPoint = singleServiceResource.skillsIndex * skillsToShow;

                for(let i = startingPoint; i < startingPoint + skillsToShow; i++) {
                    if(singleServiceResource.ServiceResourceSkills[i]){
                        singleServiceResource.paginatedServiceResourceSkills.push(singleServiceResource.ServiceResourceSkills[i]);
                    }
                }
                
                let skillsIndexToBe = singleServiceResource.skillsIndex;

                if(skillsIndexToBe ++ > singleServiceResource.ServiceResourceSkills.length / skillsToShow){
                    singleServiceResource.nextDisabled = true;
                } else {
                    updateServiceResourceList = true;
                    singleServiceResource.skillsIndex ++;
                    singleServiceResource.nextDisabled = false;
                }

                console.log('current skillsIndex >>> ' + singleServiceResource.skillsIndex);
                
            }
        });
        
        if(updateServiceResourceList){
            component.set("v.serviceResourceList", serviceResourceList);
        }
        
        console.log('TA_LCP265_PartnerSkills#handleGoNext#finish');
    }
})