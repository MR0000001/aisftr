({
    doInit : function(component,event,helper) {
        component.set("v.spinnerControl",true);
        let action = component.get("c.initOrderComposer");
        let paramsObj = {
            "opportunityId" : component.get("v.opportunityId"),
            "isFullFlow" : component.get("v.isFullFlow"),
            "defaultCatalogCategories" : component.get("v.defaultCatalogCategories")
        };
        action.setParams({params : paramsObj});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                component.set("v.catalogId",result.catalogId);
                component.set("v.categoryList",result.availableCategories);
                component.set("v.b2wAuth",result.b2wAuth);
                component.set("v.defaultBPLIId",result.defaultBpli);
                component.set("v.preferredlanguageofcontact",result.preferredlanguageofcontact);
                component.set("v.isExternalCallCenterUser",result.isExternalCallCenterUser);
                helper.manageAvailableCategoryPicklist(component,event,helper);

                component.set("v.showOrderMenu",true);
                //component.set("v.spinnerControl",false);
                
                let sectionValidityMap = {};
                sectionValidityMap['mainSection'] = false;

                if(component.get("v.isFullFlow") && component.get("v.isExternalCallCenterUser")){
                    sectionValidityMap['orderData'] = false;
                }

                component.set("v.validSections",sectionValidityMap);
                let sectionFieldValueMap = {};
                component.set("v.sectionFieldValues",sectionFieldValueMap);
            }else{
                component.set("v.spinnerControl",false);
                console.log('ERROR IN INIT ORDER COMPOSER ' + JSON.stringify(response.getError()[0]));
            }
        });
        $A.enqueueAction(action);
    },

    setEditableValidSection : function(component,event,helper){
        let sectionValidityMap = {};
        sectionValidityMap = component.get("v.validSections");
        let sectionsEditabled = component.get("v.sectionsEditabledBeforeOrder");
        console.log('EDITABLE SECTIONS ARE: ' + sectionsEditabled);
        if(sectionsEditabled){
            sectionsEditabled.forEach((enablSectName)=>{
                sectionValidityMap[enablSectName] = false;
            });
            component.set("v.validSections",sectionValidityMap);
        }
    },

    manageAvailableCategoryPicklist : function(component,event,helper){

        let categoryList = component.get("v.categoryList");
        let catOpts = [];
        if(Array.isArray(categoryList)){
            if(categoryList.length>1){      
                categoryList.forEach((elem)=>{
                    catOpts.push({"label" : elem.categoryName, "value" : elem.categoryId});
                });
                component.set("v.categoryOpts",catOpts);
                component.set("v.showCategoryMenu",true);
                component.set("v.spinnerControl",false);
            }else if(categoryList.length===1){
                component.set("v.selectedCategory",categoryList[0].categoryId);
                helper.retrieveItems(component,event,helper);
            }

        }
    },

    retrieveItems : function(component,event,helper){

        component.set("v.spinnerControl",true);
        component.set("v.itemReadOnly",true);

        let categoryId = component.get("v.selectedCategory");
        let accountId = component.get("v.accountId");
        let opportunityId = component.get("v.opportunityId");
        let catalogId = component.get("v.catalogId");
        let bpliId = component.get("v.defaultBPLIId");
        let directOrder = true;
        let b2wAuth = component.get("v.b2wAuth");
        let categoryForFile = component.get("v.categoryForFile");
        let categoryForExtraSections = component.get("v.categoryForExtraSections");
        let preferredlanguageofcontact = component.get("v.preferredlanguageofcontact");

        let paramsObj = {
            "accountId" : accountId,
            "opportunityId" : opportunityId,
            "catalogId" : catalogId,
            "defaultBpliId" : bpliId,
            "categoryId" : categoryId,
            "directOrder" : directOrder,
            "OrganizationId" : b2wAuth.OrganizationId,
            "ClientId" : b2wAuth.ClientId,
            "token" : b2wAuth.token,
            "ServerURL": b2wAuth.ServerURL,
            "EngineVersion" : b2wAuth.EngineVersion,
            "categoryForFile": categoryForFile,
            "categoryForExtraSections": categoryForExtraSections,
            "preferredlanguageofcontact" : preferredlanguageofcontact
        }

        let action = component.get("c.retrieveProducts");
        action.setParams({params : paramsObj});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result.success){
                    component.set("v.b2wRetrieveInfos",result.b2wInfos);
                    component.set("v.retrievedFullItems",result.resultItems);
                    helper.manageAvailableItemPicklist(component,event,helper);

                }else{
                    helper.showToast(component,'Error','B2W Cannot Retrieve Items','Error');
                }
                console.log('RESULT ' + JSON.stringify(result));
                component.set("v.checkForFileCategory",result.checkForFileCategory);
                if(result.checkForFileCategory && component.get("v.showFileUpload")){
                    let currentSectionValidations = component.get("v.validSections");
                    currentSectionValidations['fileUpload'] = false;
                    component.set("v.validSections",currentSectionValidations);
                }else{
                    let currentSectionValidations = component.get("v.validSections");
                    delete currentSectionValidations['fileUpload'];
                    component.set("v.validSections",currentSectionValidations);
                }
                if(result.checkForExtraSectionsCategory){
                    helper.createInnerExtraSections(component,event,helper);
                }else{
                    let sectionsExtraOrder = component.get("v.sectionsExtraOrder");
                    if(sectionsExtraOrder){
                        helper.destroyInnerExtraSections(component,event,helper);
                    }
                }
            }else{
                helper.showToast(component,'Error',response.getError()[0].message,'error');
                console.log("ERROR IN RETRIEVE ITEMS " + JSON.stringify(response.getError()[0]));
            }
            component.set("v.spinnerControl",false);
        });
        $A.enqueueAction(action);
    },

    createInnerExtraSections : function(component,event,helper){
        let extraSectionsData = component.get("v.extraSectionsData");
        let sectionsExtraOrder = component.get("v.sectionsExtraOrder");
        let currentSectionValidations = component.get("v.validSections");

        for(let index in sectionsExtraOrder){
            let sectionName = sectionsExtraOrder[index];
            let sectionData = extraSectionsData[sectionName];
            if(sectionData){
                currentSectionValidations[sectionName] = false;
                $A.createComponent(
                    "c:"+sectionData.componetName, {
                    "aura:id": sectionName, // 'sectionComp',
                    "recordId": sectionData.recordId,
                    "objectType": sectionData.objectType,
                    "recordTypeId": sectionData.recordTypeId,
                    "fieldsList": sectionData.fields,
                    "sectionName" : sectionName
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
        component.set("v.validSections",currentSectionValidations);
    },

    destroyInnerExtraSections : function(component,event,helper){
        let extraSectionsData = component.get("v.extraSectionsData");
        let sectionsExtraOrder = component.get("v.sectionsExtraOrder");
        let currentSectionValidations = component.get("v.validSections");

        for(let index in sectionsExtraOrder){
            let sectionName = sectionsExtraOrder[index];
            let sectionData = extraSectionsData[sectionName];
            if(sectionData){
                delete currentSectionValidations[sectionName];
                if(component.find(sectionName) && component.find(sectionName)!=null){
                    component.find(sectionName).destroy();
                }
            }
        }
        component.set("v.validSections", currentSectionValidations);
    },

    manageAvailableItemPicklist : function(component,event,helper){

        let ItemsObjList = component.get("v.retrievedFullItems");
        if(Array.isArray(ItemsObjList)){

            let itemsOpts = [];
            ItemsObjList.forEach((elem)=>{
                itemsOpts.push({"label" : elem.productname, "value" : elem.id});
            });
            component.set("v.itemOpts",itemsOpts);
            component.set("v.showItemMenu",true);
            component.set("v.itemReadOnly",false);

        }

    },

    checkRemoveAndUpsert : function(component,event,helper){
        let cart = component.get("v.actualCart");
        if(cart.length>0){
            helper.removeItemAndUpsert(component,event,helper);
        }else{
            helper.upsertItem(component,event,helper,null);
        }

    },

    upsertItem : function(component,event,helper,options){
        
        component.set("v.categoryReadOnly",true);
        component.set("v.spinnerControl",true);

        let itemId = event.getParam("value");
        let b2wInfos = component.get("v.b2wRetrieveInfos");

        let paramsObj;
        if(options){

            let currentItemId = component.get("v.actualCart").filter((e)=>{
                return e.itemCode === options.itemCode;
            })[0].id;

            paramsObj = {
                "itemId" : currentItemId,
                "b2wInfos" : b2wInfos,
                "itemCode" : options.itemCode,
                "changedAttributesMap" : {
                    "pfpId" : options.pfpId,
                    "value" : options.value
                }
            }

        }else{

            paramsObj = {
                "itemId" : itemId,
                "b2wInfos" : b2wInfos
            }

        }

        let action = component.get("c.firstUpsertProduct");
        action.setParams({"params" : paramsObj});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result.success){
                    component.set("v.b2wRetrieveInfos",result.b2wInfos);
                    component.set("v.actualCart",result.resultItems);
                    component.set("v.selectedProductDescription",result.productDescription);
                    component.set("v.productPrice",result.productPrice);
                    component.set("v.productDiscountedPrice",result.productDiscountedPrice);

                    //show attributes > NOT MANAGED FOR THE GO LIVE > [MC - 20210304]
                    /*if(result.resultItems[0].attributes.length>0){
                        component.set("v.showAttributeList",true);
                    }*/

                    //if(result.resultItems[0].attributes.length==0){ //TODO
                        //all attributes are configured automatically then we can do the saving of configuration
                        //component.set("v.showSubmit",true);
                        let currentSectionValidations = component.get("v.validSections");
                        currentSectionValidations['mainSection'] = true;
                        component.set("v.validSections",currentSectionValidations);
                        helper.submitValidation(component,event,helper);
                    /*}else{
                        //TODO: Manage visibile attributes
                        //component.set("v.showSubmit",true);
                    }*/

                    console.log(' RESULT UPSERT ITEMS ' + JSON.stringify(result));
                }else{
                    helper.showToast(component,'Error','B2W Cannot upsert Items','Error');
                }
            }else{
                console.log('ERROR ON UPSERT ' + JSON.stringify(response.getError()[0]));
                helper.showToast(component,'Error',response.getError()[0].message,'Error');

            }
            component.set("v.spinnerControl",false);
        });

        $A.enqueueAction(action);
    },


    removeItemAndUpsert : function(component,event,helper){
        
        component.set("v.selectedProductDescription",null);
        component.set("v.productPrice",null);
        component.set("v.productDiscountedPrice",null);
        component.set("v.categoryReadOnly",true);
        component.set("v.spinnerControl",true);
        let cart = component.get("v.actualCart");
        let removeItemCode = cart[0].itemCode;
        let b2wInfos = component.get("v.b2wRetrieveInfos");

        let paramsObj = {
            "removeItemCode" : removeItemCode,
            "b2wInfos" : b2wInfos
        }

        let action = component.get("c.removeItemFromCart");
        action.setParams({"params" : paramsObj});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result.success){
                    component.set("v.b2wRetrieveInfos",result.b2wInfos);
                    component.set("v.actualCart",result.resultItems);
                    console.log(' RESULT REMOVE ITEMS ' + JSON.stringify(result));
                    //CALL UPSERT ITEMS
                    helper.upsertItem(component,event,helper,null);
                }else{
                    helper.showToast(component,'Error','B2W Cannot remove Items','Error');
                }
            }else{
                console.log('ERROR ON REMOVE ' + JSON.stringify(response.getError()[0]));
                helper.showToast(component,'Error',response.getError()[0].message,'Error');
            }
            component.set("v.spinnerControl",false);
        });
        $A.enqueueAction(action);
    },

    finalSaveConfiguration : function(component,event,helper){

        component.set("v.spinnerControl",true);
        component.set("v.disableSubmit",true);

        let b2wInfos = component.get("v.b2wRetrieveInfos");
        let productDescription = component.get("v.selectedProductDescription");

        let sectionValues = component.get("v.sectionFieldValues");
        let sectionList = [];
        for(let section in sectionValues){
            sectionList.push(sectionValues[section]);
        }

        let paramsObj = {
            "b2wInfos" : b2wInfos,
            "productDescription" : productDescription,
            "validSections" : sectionList
        }
        if (component.find("callType")) {
            paramsObj['callType'] = component.get("v.callType");
        }

        let action = component.get("c.finalSaveConfiguration");
        action.setParams({"params" : paramsObj});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                console.log('SUBMIT RESULT ' + JSON.stringify(result));
                //Check where to redirect based on configuration
                if(component.get("v.isFullFlow")){
                    helper.fireInitSimplifiedSales(component, event, helper);
                } else {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": component.get("v.opportunityId"),
                      "slideDevName": "detail"
                    });
                    navEvt.fire();
                    //refresh necessario per aggiornare la pagina dopo l'edit e il salvataggio
                    $A.get('e.force:refreshView').fire();
                }
            }else{
                console.log('ERROR ON SAVE CONFIGURATION' + JSON.stringify(response.getError()[0]));
                helper.showToast(component,'Error',response.getError()[0].message,'Error');
                component.set("v.disableSubmit",false);
            }
            component.set("v.spinnerControl",false);
        });
        $A.enqueueAction(action);
    },

	fireInitSimplifiedSales: function (component, event, helper) {
        let ev = component.getEvent("XC_AMP_LCE002_SimpleFlowNextStep");
        ev.setParam("nextStep", 'InitSimpleSales');
        ev.fire();
	},

    handleChildCmpEvent : function(component,event,helper){
        let receivedData = event.getParam("data");
        console.log('RECEIVED EVT ON ORDER COMPOSER ' + JSON.stringify(receivedData));
        if(receivedData.type==="CHANGED_ATTRIBUTE"){

            helper.upsertItem(component,event,helper,receivedData.attrData);

        }else{
            helper.handleSectionDataChanges(component,event,helper,receivedData);
        }
    },

    handleEnabledSectionDataChange : function(component,event,helper){
        let enabledSectionData = component.get("v.enabledSectionData");
        helper.handleSectionDataChanges(component,event,helper,enabledSectionData);
    },

    handleSectionDataChanges : function(component,event,helper,receivedData){
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

        helper.submitValidation(component,event,helper);
    },

    submitValidation: function(component,event,helper){
        //check if all sections are valid and then unlock save button
        let currentSectionValidations = component.get("v.validSections");
        let allValid = true;
        for(let section in currentSectionValidations){
            allValid = allValid && currentSectionValidations[section];
        }
        if(allValid){
            component.set("v.showSubmit",true);
        }else{
            component.set("v.showSubmit",false);
        }
    },

    showToast : function(component,title,message,type){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "mode": "pester",
            "variant": type
        });
    }

})