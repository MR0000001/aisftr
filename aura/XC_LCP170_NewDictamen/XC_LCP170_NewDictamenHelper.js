/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 06/11/2019
* @description Helper class for component XC_LCP170_NewDictamen
*/

({
    init : function(component, helper, event) {
        console.log('@@@ In Component XC_LCP170_NewDictamen');
        component.set("v.spinnerControl", true);
        let action = component.get("c.getVisibleRecordType");
        action.setParams({
            "workOrderId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            let mapRT = [];
            if(a) {
                let result = a.getReturnValue();
                console.log('@@@ Result init -> ', result);

                if(result.workOrder.Status != $A.get("$Label.c.XC_CL_WorkOrder_InProgress")) {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
                        message: $A.get("$Label.c.XC_CL_ErrorCreateDictamen"),
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set('v.errorWoStatus', true);
                }
                else if(result.existDictamenItems) {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
                        message: $A.get("$Label.c.XC_CL_DictamenExists"),
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set('v.errorWoDictamen', true);
                }
                else {
                    let listRecordType = result.recordTypeList;
                    for(let i=0; i <listRecordType.length; i++) {
                        mapRT.push({
                            'label': listRecordType[i].Name,
                            'value': listRecordType[i].Id
                        });
                    }
                    component.set("v.visibleRecordType", mapRT);
                    component.set("v.workOrder", result.workOrder);
                    console.log('@@@ visibleRecordType -> ', mapRT);
                }
            }
            component.set("v.spinnerControl", false);
        });
        $A.enqueueAction(action);   
    },

    createDictamen : function(component, helper, event) {
        component.set("v.spinnerControl", true);
        let recordTypeSelected = component.get('v.recordTypeValue');
        console.log('@@@ Selected recordType -> ', recordTypeSelected);
        component.set('v.recordTypeSelected', true);

        let mapRT = component.get("v.visibleRecordType"); 
        let recordTypeLabel = '';
        for(let i=0; i<mapRT.length; i++) {
            if(mapRT[i].value == recordTypeSelected) {
                recordTypeLabel = mapRT[i].label;
                break;
            }
        }

        let createRecordEvent = $A.get("e.force:createRecord");
        let workOrder = component.get('v.workOrder');
        let defaultFieldsValue = {
            "XC_WorkOrder__c" : component.get("v.recordId")
        };

        // ------------------------------------------------------------------------ For repair:
        if(recordTypeLabel == 'Repair') {
            defaultFieldsValue = {
                "XC_WorkOrder__c" : component.get("v.recordId"),
                "XC_Asset__c" : workOrder.AssetId
            }
        }
        // ------------------------------------------------------------------------ For Maintenance Luz:
        else if(recordTypeLabel == 'Maintenance Luz') {
            let defect = '';
            if(workOrder.XC_AffectedEquipment__c) {
                defect = $A.get("$Label.c.XC_CL_ProductTypeEquipment");
            } else if(workOrder.XC_AffectedInstallation__c) {
                defect = $A.get("$Label.c.XC_CL_WorkType_Installation");
            }

            let equipmentEletric = '';
            //equipmentEletric = $A.get("$Label.c.XC_CL_Termo");
            equipmentEletric = $A.get("$Label.c.XC_CL_Air");

            defaultFieldsValue = {
                "XC_WorkOrder__c" : component.get("v.recordId"),
                "XC_Asset__c" : workOrder.AssetId,
                "XC_DefectsFoundIn__c" : defect,
                "XC_AffectedEquipmentEle__c" : equipmentEletric
            }
        } 
        // ------------------------------------------------------------------------ For Maintenance Gas:
        else if(recordTypeLabel == 'Maintenance Gas') {   
            defaultFieldsValue = {
                "XC_WorkOrder__c" : component.get("v.recordId"),
                "XC_Asset__c" : workOrder.AssetId,
                "XC_Equipment__c" : workOrder.XC_AffectedEquipment__c,
                "XC_Installation__c" : workOrder.XC_AffectedInstallation__c
            }         
        }
        // ------------------------------------------------------------------------ For Repair No Fault:
        else if(recordTypeLabel == 'Repair No Fault') {   
            defaultFieldsValue = {
                "XC_WorkOrder__c" : component.get("v.recordId"),
                "XC_Result__c" : $A.get("$Label.c.XC_CL_Dictamen_WithoutDefect")
            }         
        }

        createRecordEvent.setParams({
            "entityApiName": 'XC_DictamenItem__c',
            "recordTypeId" : recordTypeSelected,
            'defaultFieldValues': defaultFieldsValue
        });
        createRecordEvent.fire();
        component.set("v.spinnerControl", false);
    }

})