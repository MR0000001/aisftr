({
	doInit : function(component, event, helper) {
                
        helper.managePreInitOptions(component,event,helper);

        component.set('v.spinnerControl', true);
		let action = component.get("c.initNewCreationConfig");
        action.setParams({
            'accountRecordTypeId': component.get("v.accountRecordTypeId"),
            'parentOpportunityId': component.get("v.parentOpportunityId") || component.get("v.recordId")
        });
        action.setCallback(this, function (resp) {
            let state = resp.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = JSON.parse(resp.getReturnValue());
                
                component.set('v.userCountry', result.userCountry);
                component.set("v.phonePrefix", result.defaultPhonePrefix);
                component.set("v.preferredLanguage", result.defaultPrefLanguage);
                component.set("v.nationality", result.defaultNationality);
                component.set("v.viewFileUpload",result.viewFileUpload);
                component.set("v.fileUploadRequired",result.fileUploadRequired);
                component.set("v.categoryForFile",result.categoryForFile);
                component.set("v.partnerAMP",result.partnerAMP);
                component.set("v.extraSectionsData", result.extraSections);
                component.set("v.categoryForExtraSections", result.categoriesForExtraSection);
                component.set("v.sectionsExtraOrder", result.sectionsExtraOrder);
                component.set("v.sectionsEditabledBeforeOrder", result.sectionsEditabledBeforeOrder);
                component.set("v.isFullFlow", result.isFullFlow);
                component.set("v.defaultCatalogCategories", result.defaultCatalogCategories);
                component.set("v.segment", result.segment);
                component.set("v.spinnerControl", false);
                component.set("v.cmpInitialized",true);
                
                let options = component.get("v.options");
                if(options.mode==='edit_simple_flow'){
                    component.set("v.showOrderSection",true);
                }

                let extraFieldsObj = {
                    userCountry : result.userCountry,
                    phonePrefix : result.defaultPhonePrefix,
                    preferredLanguage : result.defaultPrefLanguage,
                    nationality : result.defaultNationality
                };

                let sectionValidityMap = {};
                let sectionFieldValueMap = {};
                let defaultCategoryOfInterest = result.defaultCategoryOfInterest;

                

                for(let index in result.sectionsOrder){
                    let sectionName = result.sectionsOrder[index];
                    let sectionData = result.sections[sectionName];

                    sectionValidityMap[sectionName] = false;

                    if(sectionData){
                        $A.createComponent(
                            "c:"+sectionData.componetName, {
                            "aura:id": 'sectionComp',
                            "recordId": sectionData.recordId,
                            "objectType": sectionData.objectType,
                            "recordTypeId": sectionData.recordTypeId,
                            "fieldsList": sectionData.fields,
                            "sectionName" : sectionName,
                            "readOnly" : component.get("v.readOnlyAll"),
                            "extraFields" : extraFieldsObj,
                            "partnerAMP" : component.get("v.partnerAMP"),
                            "categoryOfInterest" : defaultCategoryOfInterest
                        },
                            function (newInp, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    var body = component.get("v.body");
                                    body.push(newInp);
                                    component.set("v.body", body);
                                } else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                } else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                }
                            }
                        );
                    }
                }

                if(component.get("v.showOrderSection")){
                    helper.enableViewEditing(component,event,helper);
                    let orderCreationCmp = component.find('orderCreationCmp');
                    if(orderCreationCmp){
                        orderCreationCmp.set("v.sectionsEditabledBeforeOrder", component.get("v.sectionsEditabledBeforeOrder"));
                    }
                }

                component.set("v.validSections",sectionValidityMap);
                component.set("v.sectionFieldValues",sectionFieldValueMap);
                console.log('MAIN COMPONENT VALID SECTIONS:: ' + JSON.stringify(component.get("v.validSections")));

			}else{
                console.log('ERROR ON INIT MAIN VIEW SECTIONS ' + JSON.stringify(resp.getError()[0]));
            }
            component.set("v.spinnerControl", false);
        });
        $A.enqueueAction(action);
    },
    

    handleChildCommunicationEvent : function(component,event,helper){

        let receivedData = event.getParam('data');
        console.log(' PARENT RECEIVED SECTION DATA ' + JSON.stringify(receivedData));

        let currentSectionValidations = component.get("v.validSections");
        let currentSectionFieldValues = component.get("v.sectionFieldValues");
        currentSectionValidations[receivedData.sectionName] = receivedData.isSectionValid;
        component.set("v.validSections",currentSectionValidations);

        if(receivedData.isSectionValid){
            currentSectionFieldValues[receivedData.sectionName] = receivedData;
        }else{
            delete currentSectionFieldValues[receivedData.sectionName];
        }

        component.set("v.sectionFieldValues",currentSectionFieldValues);
        let orderCreationCmp = component.find('orderCreationCmp');
        let sectionsEditabled = component.get("v.sectionsEditabledBeforeOrder");
        if(orderCreationCmp && sectionsEditabled){
            let isDataToSend = false;
            sectionsEditabled.forEach((sectName)=>{
                if(sectName === receivedData.sectionName){
                    isDataToSend = true;
                }
            });
            if(isDataToSend){
                orderCreationCmp.set("v.enabledSectionData", receivedData);
            }
        }

        //check if all sections are valid and then unlock save button
        let allValid = true;
        for(let section in currentSectionValidations){
            allValid = allValid && currentSectionValidations[section];
        }
        if(allValid){
            component.set("v.disableSubmit",false);
        }else{
            component.set("v.disabledSubmit",false);
        }

    },


    submitSections : function(component,event,helper){

        let sectionValues = component.get("v.sectionFieldValues");
        let sectionList = [];
        for(let section in sectionValues){
            sectionList.push(sectionValues[section]);
        }
        let action = component.get("c.submitFirstStepSections");
        let paramsObj = {
            "partnerAMP" : component.get("v.partnerAMP"),
            "isFullFlow" : component.get("v.isFullFlow"),
            "segment" : component.get("v.segment")
        };
        action.setParams({
            "validSections" : sectionList,
            "paramsInput" : paramsObj
        });

        helper.setReadOnlySections(component,true);
        component.set('v.submitSpinner', true);

        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if (result && result.success){
                    component.set('v.submitSpinner', false);
                    component.set("v.parentOpportunityId",result.opportunityId);
                    component.set("v.createdAccountId",result.accountId);
                    component.set("v.showOrderSection",true);
                    helper.enableViewEditing(component,event,helper);
                }else if(!result.success){
                    helper.showToast(component,'Error',result.errorMessage,'error');
                    helper.setReadOnlySections(component,false);
                }
            }else{
                console.log("ERROR ON SUBMIT : " + JSON.stringify(response.getError()[0]));
                helper.showToast(component,'Error',response.getError()[0].message,'error');
                helper.setReadOnlySections(component,false);
            }
            component.set('v.submitSpinner', false);
        });
        $A.enqueueAction(action);
    },

    enableViewEditing : function(component,event,helper){
        
        let sectionsEditabled = component.get("v.sectionsEditabledBeforeOrder");
        let sections = component.find('sectionComp');
        if(Array.isArray(sections)){
            sections.forEach((sect)=>{
                let sectionName = sect.get("v.sectionName");
                let isEnabled=false;
                sectionsEditabled.forEach((enablSectName)=>{
                    if(enablSectName === sectionName){
                        isEnabled=true;
                    }
                });
                
                sect.set("v.readOnly", !isEnabled);
                
            });
        }
    },

    showToast : function(component,title,message,type){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "mode": "pester",
            "variant": type
        });
    },

    setReadOnlySections : function(component,readOnly){
        let sections = component.find('sectionComp');
        if(Array.isArray(sections)){
            sections.forEach((sect)=>{
                sect.set("v.readOnly",readOnly);
            });
        }
        component.set("v.readOnlyAll",readOnly);

    },

    managePreInitOptions : function(component,event,helper){

        //configure pre-init options

        let options = component.get('v.options');
        if(!options){
            component.set("v.options",{});
        }
        
        let pageReference = component.get("v.pageReference");
        if(pageReference){
            component.set("v.parentOpportunityId",pageReference.state.c__parentOppId);
            if(pageReference.state.c__mode){
                options = component.get("v.options");
                options['mode']=pageReference.state.c__mode;
                component.set("v.options",options);
            }
        }
        //if we have recordId incoming, then we are in "detail mode"
        let defaultRecordId = component.get("v.recordId");
        if(defaultRecordId){
            options = component.get("v.options");
            options['mode']='detail_page';
            component.set("v.options",options);
        }

        //manage options
        options = component.get("v.options");
        if(options.mode==='detail_page'){
            helper.setReadOnlySections(component,true);
            component.set("v.showSubmit",false);
        }else if(options.mode==='edit'){
            helper.setReadOnlySections(component,true);
            component.set("v.showOrderSection",true);
        }else if(options.mode==='child_order'){
            helper.setReadOnlySections(component,true);
            component.set("v.showOrderSection",true);
            component.set("v.showSubmit",false);
            helper.createChildOpportunity(component,event,helper);
        }else if(options.mode==="edit_simple_flow"){
            helper.setReadOnlySections(component,true);
        }
    },


    createChildOpportunity : function(component,event,helper){
        let action = component.get("c.createChildOpportunity");
        let paramsObj = {"accountId" : component.get("v.createdAccountId"), "parentOpportunityId" : component.get("v.parentOpportunityId")};
        action.setParams({"paramsMap" : paramsObj});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result.success){
                    component.set("v.parentOpportunityId",result.opportunityId);
                    component.set("v.showOrderSection",true);
                }else{
                    helper.showToast(component,'Error',result.errorMsg,'error');
                }

            }else{
                helper.showToast(component,'Error',response.getError()[0].message,'error');
                console.log('CREATE CHILD OPP ERROR: ' + JSON.stringify(response.getError()[0]));
            }
        });
        $A.enqueueAction(action);
    }

})