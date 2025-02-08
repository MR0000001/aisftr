({
    getWarehouseListHelper : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Helper >> getWarehouseListHelper >> Start');
        let action = component.get("c.getWarehouseList");
        let recordId = component.get("v.parentRecordId");

        var filterMap = {};
        filterMap["warehouseNameFilter"] = component.find("warehouseNameFilter").get("v.value");
        filterMap["warehouseCodeFilter"] = component.find("warehouseCodeFilter").get("v.value");
        filterMap["warehouseCoverageFilter"] = component.find("warehouseCoverageFilter").get("v.value");
        filterMap["warehouseLegalEntityFilter"] = component.find("warehouseLegalEntityFilter").get("v.checked");

        action.setParams({
            'recordId': recordId,
            'filterMap': JSON.stringify(filterMap)
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP251_SelectWarehouse >> Helper >> getWarehouseListHelperCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() && JSON.parse(response.getReturnValue()).length > 0) {
                    component.set("v.warehouseList", JSON.parse(response.getReturnValue()));
                } else {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", $A.get('$Label.c.TA_Error') + ': ' + $A.get('$Label.c.XC_CL_NoWarehouseFound')); // TO DO CUSTOM LABEL
                }
                // component.set("v.warehouseList", JSON.parse('[{"wareHouseZipPostalCode":"09040","wareHouseStreet":"VIA MARMILLA","wareHouseStateProvince":"CA","warehouseName":"S.I.E. SARDINIA","wareHouseCountry":"Italy","warehouseCode":"SA09","wareHouseCity":"FURTEI","recordId":"aA97a000000Gtu5CAC","provinceCoverage":null,"legalEntity":"EnelSole"},{"wareHouseZipPostalCode":"09025","wareHouseStreet":"via grazia deledda 9, 09025","wareHouseStateProvince":"VS","warehouseName":"s.i.e.sardinia impianti elettrici","wareHouseCountry":"Italy","warehouseCode":"SARD","wareHouseCity":"Sanluri","recordId":"aA97a0000008VukCAE","provinceCoverage":null,"legalEntity":"EnelSole"}]'));
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            component.set("v.isSearchView", false);
            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP251_SelectWarehouse >> Helper >> getWarehouseListHelperCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP251_SelectWarehouse >> Helper >> getWarehouseListHelper >> End');
    },

    selectWarehouse : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Helper >> selectWarehouse >> Start');
        let selectedWarehouseOld = component.get("v.selectedWarehouse");
        if(selectedWarehouseOld) {
            let cardToDeselect = document.getElementById(selectedWarehouseOld);
            cardToDeselect.classList.remove('ta-card-selected');
        }

        component.set("v.selectedWarehouse", event.currentTarget.id);
        let cardSelected = document.getElementById(event.currentTarget.id);
        cardSelected.classList.add('ta-card-selected');
        console.log('TA_LCP251_SelectWarehouse >> Helper >> selectWarehouse >> End');
    },

    setWarehouse : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Helper >> setWarehouse >> Start');
        let recordId = component.get("v.parentRecordId");
        let selectedWarehouse = component.get("v.selectedWarehouse");
        let warehouseList = component.get("v.warehouseList");

        let selectedWar = {};
        warehouseList.forEach(function(warehouse) {
            if(warehouse.recordId == selectedWarehouse) {
                selectedWar = warehouse;
            }
        });

        let action = component.get("c.setWarehouse");
        action.setParams({
            'recordId': recordId,
            'warehouse': JSON.stringify(selectedWar)
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP251_SelectWarehouse >> Helper >> setWarehouseCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", false);
                component.set("v.toastMessage", $A.get('$Label.c.XC_CL_Success'));
                helper.closeModal(component, event, helper);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", false);
                component.set("v.toastMessage", $A.get('$Label.c.TA_Error'));
            }

            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP251_SelectWarehouse >> Helper >> setWarehouseCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP251_SelectWarehouse >> Helper >> setWarehouse >> End');
    },

    search : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Helper >> search >> Start');
        let pageRef = component.get("v.pageReference");
        if(pageRef != null && pageRef != undefined) {
            let state = pageRef.state;
            let base64Context = state.inContextOfRef;
            if(base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
            let addressableContext = JSON.parse(window.atob(base64Context));
            component.set("v.parentRecordId", addressableContext.attributes.recordId);
        } else {
            component.set("v.parentRecordId", component.get("v.recordId"));
        }
        helper.getWarehouseListHelper(component, event, helper);
        console.log('TA_LCP251_SelectWarehouse >> Helper >> search >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP251_SelectWarehouse >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP251_SelectWarehouse",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP251_SelectWarehouse >> Helper >> fireToggleSpinnerEvent >> End');
    },

    closeModal : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Helper >> closeModal >> Start');
        component.set("v.isInitialized", false);
        component.set("v.isSearchView", true);
        component.set("v.warehouseList", undefined);
        component.set("v.selectedWarehouse", undefined);
        console.log('TA_LCP251_SelectWarehouse >> Helper >> closeModal >> End');
    }
})