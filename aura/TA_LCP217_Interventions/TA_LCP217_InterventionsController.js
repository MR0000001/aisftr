({
    doInit : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> doInit >> Start');
        helper.init(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> doInit >> End');
    },

    handleShowDetail : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleShowDetail >> Start');
        helper.showDetail(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> handleShowDetail >> End');
    },
   
    handleSearchDocument : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleSearchDocument >> Start');
        helper.searchDocument(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> handleSearchDocument >> End');
    },

    handleCloseWoli : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleCloseWoli >> Start');
        helper.closeWoli(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> handleCloseWoli >> End');
    },

    handleRemovePhoto : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleRemovePhoto >> Start');
        helper.removePhoto(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> handleRemovePhoto >> End');
    },

    handleInsertMeasure : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleInsertMeasure >> Start');
        helper.insertMeasure(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> handleInsertMeasure >> End');
    },

    handleCallDoxee : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleCallDoxee >> Start');
        helper.callDoxee(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> handleCallDoxee >> End');
    },

    handleDeletePhoto : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleDeletePhoto >> Start');
        helper.deletePhoto(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> handleDeletePhoto >> End');
    },

    handleShowDescription : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleShowDescription >> Start');
        helper.showDescription(component, event, helper);
        console.log('TA_LCP217_Interventions >> Controller >> handleShowDescription >> End');
    },

    handleCreateRecord: function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleCreateRecord >> Start');
        component.set('v.buttonType','new');
        component.set('v.formRecordTypeId',null);
        component.set('v.recordSubmitId', null);
        component.set("v.parentId",component.get("v.workOrderId"));
        component.set('v.objectName','WorkOrderLineItem');
        component.set("v.checkLegalEntity",true);
        component.set('v.showComponentEditRecord', false);
        component.set('v.showComponentCreateRecord', !component.get('v.showComponentCreateRecord'));
        let element = component.find("createModalComponent");
        console.log('elementCreateRecord :',element);
        element.set("v.modalTitleRT",$Label.c.TA_WorkOrderLineItem_Title);
        element.set("v.modalTitleRecord",'New Work Order Line Item');
        console.log('TA_LCP217_Interventions >> Controller >> handleCreateRecord >> End');
    },

    handleEditRecord: function(component, event, helper) {
        /*
        let recordSubmit = {'id':event.target.id};
        component.set('v.woliIdToEdit', event.target.id);
        component.set('v.formRecordTypeId',event.target.name);
        component.set('v.recordSubmit', recordSubmit);
        component.set('v.buttonType','edit');
        component.set('v.objectName','WorkOrderLineItem');
        component.set('v.showComponentEditRecord', !component.get('v.showComponentEditRecord'));
        component.set('v.showComponentCreateRecord', !component.get('v.showComponentCreateRecord'));
        */
        console.log('TA_LCP217_Interventions >> Controller >> handleEditRecord >> Start');
        helper.editRecord(component,event.target.id,event.target.name,'WorkOrderLineItem', 'Edit WorkOrderLineItem');
        console.log('TA_LCP217_Interventions >> Controller >> handleEditRecord >> End');
    },

    handleRefresh : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleRefresh >> Start');
        console.log('event.getParams: ' + JSON.stringify(event.getParams()));
        let isRefresh = (event.getParam("params")==null || event.getParam("params").refresh==null) || (event.getParam("params")  && event.getParam("params").refresh!='false');
        if(event.getParam("action") == 'refresh intervention') {           
            if(event.getParam("params") && event.getParam("params").showComponentLabel){
                var showComponentLabel = 'v.'+event.getParam("params").showComponentLabel;
                console.log("@@@@showComponentLabel: "+showComponentLabel);
                component.set(showComponentLabel,false);
            }
            if(isRefresh){
                //helper.init(component, true);
                if(event.getParam("params") && event.getParam("params").isInsert){
                    console.log("params true: " + event.getParam("params").isInsert);
                    helper.init(component,event,helper, true, null);

                }
                if(event.getParam("params") && !event.getParam("params").isInsert){
                    console.log("params true: " + event.getParam("params").isInsert);
                    helper.init(component,event,helper, true, component.get("v.infoBag.actionResponse"));
                }
            }

        }
        console.log('TA_LCP217_Interventions >> Controller >> handleRefresh >> End');
    },

    handleResponseLayout : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller handleResponseLayout objData >>: ' + JSON.stringify(event.getParam('layoutData')));
    },
    handleStartFlow : function(component,event,helper){
        console.log('TA_LCP217_Interventions >> Controller >> startFlow >> Start');
        let recordSubmitId = event.target.id;
        console.log('recordSubmitId: '+recordSubmitId);
        component.set("v.showComponentFlow",true);
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        var inputVariables = [{ name : "recordId", type : "String", value: recordSubmitId}];
        flow.startFlow("TAM_TACreationWiz",inputVariables);
        console.log('TA_LCP217_Interventions >> Controller >> startFlow >> End');
    },
    handleManageShowComponent : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleManageShowComponent >> Start');
        component.set('v.showComponentFlow', !component.get('v.showComponentFlow'));
        console.log('TA_LCP217_Interventions >> Controller >> handleManageShowComponent >> End');
    },
    handleManageShowComponentAddPC : function(component, event, helper) {
            console.log('TA_LCP217_Interventions >> Controller >> handleManageShowComponentAddPC >> Start');
            console.log(component.get('v.showComponentAddPC'));
            component.set('v.showComponentAddPC', !component.get('v.showComponentAddPC'));
            console.log('TA_LCP217_Interventions >> Controller >> handleManageShowComponentAddPC >> End');
        },
    handleManageShowComponentApproval : function(component, event, helper) {
          console.log('TA_LCP217_Interventions >> Controller >> handleManageShowComponentAddPC >> Start');
          console.log(component.get('v.showComponentApprl'));
          component.set('v.showComponentApprl', !component.get('v.showComponentApprl'));
          console.log('TA_LCP217_Interventions >> Controller >> handleManageShowComponentAddPC >> End');
    },
    handleStatusChange : function(component,event,helper){
        console.log('TA_LCP217_Interventions >> Controller >> handleStatusChange >> Start');
        console.log('event status: '+event.getParam('status'));
        if (event.getParam('status') === "FINISHED") {
            component.set('v.showComponentFlow', !component.get('v.showComponentFlow'));
            helper.fireToggleSpinnerEvent(component, true, 'TA_LCP217_Interventions');
            helper.init(component,event,helper, true, null);
        }
        console.log('TA_LCP217_Interventions >> Controller >> handleStatusChange >> End');
    },

    handleShowProductConsumed : function(component,event,helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleShowProductConsumed >> Start');
        let idClicked = event.target.id;
        let idClickedList = idClicked.split("_");
        console.log(idClicked.split("_"));

        console.log('idClicked: ',event.target.id);
        if(idClickedList[1] == 'PCAccordion') {
            var element= document.getElementById(idClickedList[0]+'_Details');
            element.classList.toggle("slds-hide");
            let macroblocklist = component.get("v.infoBag.macroBlockList");
            macroblocklist[idClickedList[2]].woliListWrapper[idClickedList[3]].productConsumedBl.showRecord =! macroblocklist[idClickedList[2]].woliListWrapper[idClickedList[3]].productConsumedBl.showRecord;
            component.set("v.infoBag.macroBlockList",macroblocklist);
            console.log("booleano: "+macroblocklist[idClickedList[2]].woliListWrapper[idClickedList[3]].productConsumedBl.showRecord);
        }
        console.log('TA_LCP217_Interventions >> Controller >> handleShowProductConsumed >> End');
    },

    handleCreateProductConsumed : function(component,event,helper){
        console.log('TA_LCP217_Interventions >> Controller >> handleCreateProductConsumed >> Start');
        component.set('v.buttonType','new');
        let objectId = event.target.id;

        console.log("event.target.id: ",objectId.split("_")[0]);
        component.set("v.parentId",objectId.split("_")[0]);
        component.set('v.recordSubmitId', null);
        component.set('v.formRecordTypeId',null);
        component.set('v.objectName','XC_ProductConsumed__c');
        component.set("v.checkLegalEntity",false);
        component.set('v.showComponentEditRecord', false);
        component.set('v.showComponentCreateRecord', !component.get('v.showComponentCreateRecord'));
        let element = component.find("createModalComponent");
        console.log('elementCreateRecord :',element);
        element.set("v.modalTitleRT",'Product Consumed');
        element.set("v.modalTitleRecord",'New Product Consumed');
        console.log('TA_LCP217_Interventions >> Controller >> handleCreateProductConsumed >> End');
    },
    handleEditPCRecord : function(component,event,helper){
        console.log('TA_LCP217_Interventions >> Controller >> handleEditPCRecord >> Start');
        helper.editRecord(component,event.target.id,event.target.name,'XC_ProductConsumed__c','Edit Product Consumed');
        console.log('TA_LCP217_Interventions >> Controller >> handleEditPCRecord >> End');
    },
    handleEditTARecord : function(component,event,helper){
        console.log('TA_LCP217_Interventions >> Controller >> handleEditPCRecord >> Start');
        helper.editRecord(component,event.target.id,event.target.name,'Asset','Edit Asset');
        console.log('TA_LCP217_Interventions >> Controller >> handleEditPCRecord >> End');
    },

    handleGoodIssueExecution : function (component,event,helper){
        console.log('TA_LCP217_Interventions >> Controller >> handleGoodIssueExecution >> Start');
        component.set("v.WOLIRecordId",event.target.id);
        component.set('v.showComponentGoodIssue', !component.get('v.showComponentGoodIssue'));
        console.log('TA_LCP217_Interventions >> Controller >> handleGoodIssueExecution >> End');
    },
    handleAction : function(component,event,helper){
        console.log('TA_LCP217_Interventions >> Controller >> handleAction >> Start');
        let recordId = event.target.name.split("$")[0];
        let recordRTId = event.target.name.split("$")[1];
        let actionApiName = event.target.name.split("$")[2];
        let targetObject = event.target.name.split("$")[3];
        let actionLabel = event.target.name.split("$")[4];
        console.log("actionApiName",actionApiName);
        console.log('actionLabel: '+actionLabel);
        if(actionApiName.indexOf('Edit')!=-1){
            helper.editRecord(component,recordId,recordRTId,targetObject,'Edit '+targetObject);
        }
        if(actionApiName.indexOf('XC_WOLIAddProductConsumed')!=-1){
            helper.showActionModal(component,"v.showComponentAddPC",recordId);
        }
        if(actionApiName.indexOf('TAM_CreateAsset')!=-1){
            component.set("v.modalTitle",actionLabel);
            helper.startFlow(component,recordId,"TAM_TACreationWiz");
        }
        if(actionApiName.indexOf("XC_CreateGoodIssueFromButtonB2B")!=-1){
            component.set("v.modalTitle",actionLabel);
            helper.startFlow(component,recordId,"XC_FL_CreateGoodIssueFromButtonB2B");
        }
        if(actionApiName.indexOf("XC_CreatePPFromButtonB2B")!=-1){
            component.set("v.modalTitle",actionLabel);
            helper.startFlow(component,recordId,"XC_FL_CreatePPFromButtonB2B");
        }
        if(actionApiName.indexOf('XC_GoodsIssueExecution')!=-1){
            helper.showActionModal(component,"v.showComponentGoodIssue",recordId);
        }
        if(actionApiName.indexOf('XC_RMAExecution')!=-1){
            helper.showActionModal(component,"v.showComponentRMA",recordId);
        }
        if(actionApiName.indexOf('XC_SelectWarehouse')!=-1){
            helper.showActionModal(component,"v.showComponentWarehouse",recordId);
        }
        if(actionApiName.indexOf('Submit')!=-1){
            component.set("v.modalTitle",actionLabel);
            helper.showActionModal(component,"v.showComponentApprl",recordId);
        }
        console.log('TA_LCP217_Interventions >> Controller >> handleAction >> End');
    },
    handleApprovalRequest : function (component,event,helper){
        helper.fireToggleSpinnerEvent(component, true, 'TA_LCP217_Interventions');
        let action = component.get("c.sendApprovalRequest");
        action.setParam("recordId", component.get("v.WOLIRecordId"));
        action.setParam("comment", component.get("v.comments"));
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                console.log('response: ',response.getReturnValue());
                component.set("v.showComponentApprl",false);
                helper.init(component, true);
            } else if(response.getState() == "ERROR") {
                console.log(response.getError());
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", response.getError()[0].pageErrors[0].message);
                component.set("v.showComponentApprl",false);

            }
            helper.fireToggleSpinnerEvent(component, false, 'TA_LCP217_Interventions');

        });
        $A.enqueueAction(action);
    },

    handleShowChildRecord : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Controller >> handleShowChildRecord >> Start');
        let idClicked = event.currentTarget.id;
        let idClickedList = idClicked.split("_");
        let accordionSection = idClickedList[0];
        let macroBlockIndex = idClickedList[1];
        let woliIndex = idClickedList[2];
        let infoBag = component.get("v.infoBag");

        if(accordionSection == 'ProductConsumed') {
            if(infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].productConsumedBl.recordList.length) {
                infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].productConsumedBl.showRecord = !infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].productConsumedBl.showRecord;
            }
        } else if(accordionSection == 'ProductRequired') {
            if(infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].productRequiredBl.recordList.length) {
                infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].productRequiredBl.showRecord = !infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].productRequiredBl.showRecord;
            }
        } else if(accordionSection == 'PositionRequired') {
            if(infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].positionRequiredBl.recordList.length) {
                infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].positionRequiredBl.showRecord = !infoBag.macroBlockList[macroBlockIndex].woliListWrapper[woliIndex].positionRequiredBl.showRecord;
            }
        }

        component.set("v.infoBag", infoBag);
        console.log('TA_LCP217_Interventions >> Controller >> handleShowChildRecord >> End');
    }
})