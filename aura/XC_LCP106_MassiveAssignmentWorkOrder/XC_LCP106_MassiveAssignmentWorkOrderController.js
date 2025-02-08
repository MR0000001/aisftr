({
    init : function(component, event, helper) { 
        helper.doInit(component, event, helper);
        helper.setWorkspace(component, event, helper);
    },

    selectedOriginPartner : function(component, event, helper) { 
        let orPartner = component.get('v.originPartner');
        if(orPartner != '' && orPartner != null && orPartner != undefined) {
            component.set('v.showChooseOutOfDateForFilterSelection', true);
        } else {
            helper.cleanAttributes(component, event, helper);
            component.set('v.showChooseOperation', false);
            component.set('v.showOriginPartner', true);
        }
    },

    searchWorkOrder : function(component, event, helper) { 
        if(component.get('v.loadWorkOrder') == true) {
            helper.searchWorkOrder(component, event, helper, false); 
        }
    },

    applyInitialFilter : function(component, event, helper) { 
        helper.searchWorkOrder(component, event, helper, false); 
    },

    applyInitialFilterLimited : function(component, event, helper) { 
        helper.searchWorkOrder(component, event, helper, true); 
    },

    resetInitialFilter : function(component, event, helper) { 
        let originPartner = component.get('v.originPartner');
        component.set('v.originPartner', '');
        component.set('v.originPartner', originPartner);
    },

    onChangeTable : function(component, event, helper) {
        helper.onChangeTable(component, event, helper); 
    }, 

    assignWorkOrder : function(component, event, helper) { 
        helper.assignWorkOrder(component, event, helper);
    },

    viewLogs : function(component, event, helper) { 
        helper.viewLogs(component, event, helper); 
    },

    enableButton : function(component, event, helper) { 
        helper.enableButton(component, event, helper); 
    }, 

    changeOutOfDate : function(component, event, helper) { 
        helper.changeOutOfDate(component, event, helper); 
    },
    
    changeViewAll : function(component, event, helper) { 
        helper.changeViewAll(component, event, helper); 
    },

    changeColorMouseOverSelectManual : function(component, event, helper) { 
        component.find('cardOperationManualSelection').set("v.class", "classOperationOver");
    },

    changeColorMouseOutSelectManual : function(component, event, helper) { 
        component.find('cardOperationManualSelection').set("v.class", "classOperation");
    },

    changeColorMouseClickSelectManual : function(component, event, helper) { 
        helper.changeColorMouseClickSelectManual(component, event, helper);
    },

    changeColorMouseOverFilter : function(component, event, helper) { 
        component.find('cardOperationFilterSelection').set("v.class", "classOperationOver");
    },

    changeColorMouseClickFilter : function(component, event, helper) { 
        component.find('cardOperationFilterSelection').set("v.class", "classOperationChoosed");
        component.set('v.showChooseOperation', false);
        //component.set('v.showChooseOutOfDateForFilterSelection', true);
        component.set('v.showOriginPartner', true);
    },

    changeColorMouseOutFilter : function(component, event, helper) { 
        component.find('cardOperationFilterSelection').set("v.class", "classOperation");
    },

    changeColorMouseOverExcel : function(component, event, helper) { 
        component.find('cardOperationExcelSelection').set("v.class", "classOperationOver");
    },

    changeColorMouseClickExcel : function(component, event, helper) { 
        component.set('v.spinnerControl', true);
        component.set('v.viewAllToggle', true);
        component.set('v.showChooseOperation', false);
        component.set('v.showLoadExcelOption', true);
        component.set('v.valueStep', "2");
        component.set('v.spinnerControl', false);
    },

    changeColorMouseOutExcel : function(component, event, helper) { 
        component.find('cardOperationExcelSelection').set("v.class", "classOperation");
    },

    selectFilterShow : function(component, event, helper) { 
        let valueButton = component.get('v.notHideFilter');
        if(valueButton == true) {
            component.set('v.notHideFilter', false);
            component.find('buttonFilter').set("v.label", "Show filters");
        } else {
            component.set('v.notHideFilter', true);
            component.find("provincesFilterTable").set("v.selectedRows", component.get('v.selectedProvinces'));
            component.find("statusFilterTable").set("v.selectedRows", component.get('v.selectedStatus'));
            component.find("statusReasonFilterTable").set("v.selectedRows", component.get('v.selectedStatusReason'));
            component.find("worktypeFilterTable").set("v.selectedRows", component.get('v.selectedWorkType'));
            component.find("zipCodeFilterTable").set("v.selectedRows", component.get('v.selectedZipCode'));
            component.find('buttonFilter').set("v.label", "Hide filters");
        }
    },

    workTypeFiltered : function(component, event, helper) {
        let data = component.get("v.workTypeOptionsOriginal"),
            term = component.get("v.filterWorkType"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.label));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.workTypeOptions", results);
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowWorkType');
        let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.value);
        });
        component.find("worktypeFilterTable").set("v.selectedRows", valuesSelected);
    },

    zipCodeFiltered : function(component, event, helper) {
        let data = component.get("v.zipCodeOptionsOriginal"),
            term = component.get("v.filterZipCode"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.label));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.zipCodeOptions", results);
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowZipcode');
        let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.value);
        });
        component.find("zipCodeFilterTable").set("v.selectedRows", valuesSelected);
    },

    statusFiltered : function(component, event, helper) {
        let data = component.get("v.statusOptionsOriginal"),
            term = component.get("v.filterStatus"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.label));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.statusOptions", results);
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowStatus');
        let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.value);
        });
        component.find("statusFilterTable").set("v.selectedRows", valuesSelected);
    },

    statusReasonFiltered : function(component, event, helper) {
        let data = component.get("v.statusReasonOptionsOriginal"),
            term = component.get("v.filterStatusReason"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.label));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.statusReasonOptions", results);
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowStatusReason');
        let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.value);
        });
        component.find("statusReasonFilterTable").set("v.selectedRows", valuesSelected);
    },

    provincesFiltered : function(component, event, helper) {
        let data = component.get("v.provincesOptionsOriginal"),
            term = component.get("v.filterProvinces"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.label));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.provincesOptions", results);
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowProvince');
        let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.value);
        });
        component.find("provincesFilterTable").set("v.selectedRows", valuesSelected);
    },

    addSelectedWorkType : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        let allSelectedTemp = component.get('v.oldSelectedRowWorkType').concat(rowNowSelectedForCurrentData);
        let statusOption = component.get('v.workTypeOptions');
        let differenceStatusOptionSelected = statusOption.filter(n => !rowNowSelectedForCurrentData.includes(n));
        allSelectedTemp = allSelectedTemp.filter(n => !differenceStatusOptionSelected.includes(n));
        let allSelected = allSelectedTemp.filter((thing, index) => {
            const _thing = JSON.stringify(thing);
            return index === allSelectedTemp.findIndex(obj => {
              return JSON.stringify(obj) === _thing;
            });
        });
        component.set('v.oldSelectedRowWorkType', allSelected);
        component.set('v.selectedWorkType', allSelected);
    },

    addSelectedZipcode : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        let allSelectedTemp = component.get('v.oldSelectedRowZipcode').concat(rowNowSelectedForCurrentData);
        let statusOption = component.get('v.zipCodeOptions');
        let differenceStatusOptionSelected = statusOption.filter(n => !rowNowSelectedForCurrentData.includes(n));
        allSelectedTemp = allSelectedTemp.filter(n => !differenceStatusOptionSelected.includes(n));
        let allSelected = allSelectedTemp.filter((thing, index) => {
            const _thing = JSON.stringify(thing);
            return index === allSelectedTemp.findIndex(obj => {
              return JSON.stringify(obj) === _thing;
            });
        });
        component.set('v.oldSelectedRowZipcode', allSelected);
        component.set('v.selectedZipCode', allSelected);
    },

    addSelectedStatus : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        let allSelectedTemp = component.get('v.oldSelectedRowStatus').concat(rowNowSelectedForCurrentData);
        let statusOption = component.get('v.statusOptions');
        let differenceStatusOptionSelected = statusOption.filter(n => !rowNowSelectedForCurrentData.includes(n));
        allSelectedTemp = allSelectedTemp.filter(n => !differenceStatusOptionSelected.includes(n));
        let allSelected = allSelectedTemp.filter((thing, index) => {
            const _thing = JSON.stringify(thing);
            return index === allSelectedTemp.findIndex(obj => {
              return JSON.stringify(obj) === _thing;
            });
        });
        component.set('v.oldSelectedRowStatus', allSelected);
        component.set('v.selectedStatus', allSelected);
    },

    addSelectedStatusReason : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        let allSelectedTemp = component.get('v.oldSelectedRowStatusReason').concat(rowNowSelectedForCurrentData);
        let statusOption = component.get('v.statusReasonOptions');
        let differenceStatusOptionSelected = statusOption.filter(n => !rowNowSelectedForCurrentData.includes(n));
        allSelectedTemp = allSelectedTemp.filter(n => !differenceStatusOptionSelected.includes(n));
        let allSelected = allSelectedTemp.filter((thing, index) => {
            const _thing = JSON.stringify(thing);
            return index === allSelectedTemp.findIndex(obj => {
              return JSON.stringify(obj) === _thing;
            });
        });
        component.set('v.oldSelectedRowStatusReason', allSelected);
        component.set('v.selectedStatusReason', allSelected);
    },

    applyFilter : function(component, event, helper) { 
        helper.applyFilter(component, event, helper);
        component.find('tableWorkOrders').set('v.enableInfiniteLoading', true);
    },

    addSelectedProvinces : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        let allSelectedTemp = component.get('v.oldSelectedRowProvince').concat(rowNowSelectedForCurrentData);
        let statusOption = component.get('v.provincesOptions');
        let differenceStatusOptionSelected = statusOption.filter(n => !rowNowSelectedForCurrentData.includes(n));
        allSelectedTemp = allSelectedTemp.filter(n => !differenceStatusOptionSelected.includes(n));
        let allSelected = allSelectedTemp.filter((thing, index) => {
            const _thing = JSON.stringify(thing);
            return index === allSelectedTemp.findIndex(obj => {
              return JSON.stringify(obj) === _thing;
            });
        });
        component.set('v.oldSelectedRowProvince', allSelected);
        component.set('v.selectedProvinces', allSelected);
        if(allSelected.length == 0) {
            component.set('v.showTableZipCode', false);
            component.set('v.oldSelectedRowZipcode', new Array());
            component.set('v.selectedZipCode', component.get('v.listAllZipCode'));
        } else {
            component.set('v.showTableZipCode', true);
            helper.filterZipCodeFromProvinces(component, event, helper);
        }
    },

    loadMoreDataTableWorkOrder : function(component, event, helper) {
        let offSetWorkOrder = component.get('v.offSetWorkOrder'),   
            indexOffsetWorkOrder = component.get('v.indexOffsetWorkOrder'), 
            allOffsetData = JSON.parse(JSON.stringify(component.get('v.offsetListData'))),
            data = component.get('v.data');

        if(data.length == allOffsetData.length) {
            return;
        }

        if(allOffsetData && allOffsetData.length != 0) {
            for(let j=indexOffsetWorkOrder; j<indexOffsetWorkOrder+offSetWorkOrder; j++) {
                data.push(allOffsetData[j]);
            }
            event.getSource().set("v.isLoading", true);    
            component.set("v.data", data);   
            component.set('v.indexOffsetWorkOrder', indexOffsetWorkOrder+offSetWorkOrder);
            component.set('v.summaryWorkOrdersView', '<b>' + $A.get("$Label.c.XC_CL_MassiveWoWorkOrderShown") + ' </b>' + (indexOffsetWorkOrder+offSetWorkOrder).toString() +'/'+ allOffsetData.length.toString());
            event.getSource().set("v.isLoading", false);
        } else {
            component.find('tableWorkOrders').set('v.enableInfiniteLoading', false);
            component.set('v.summaryWorkOrdersView', '<b>' + $A.get("$Label.c.XC_CL_MassiveWoWorkOrderShown") + ' </b>' + data.length.toString() +'/'+ data.length.toString());
        }
    },

    onSaveTypeWOfilter : function(component, event, helper) {
        let preffOption = component.get('v.preferredTypeWOFilter');
        if(preffOption == '' || preffOption == null || preffOption == undefined) {
            $A.createComponent("ui:outputText", {
                "value" : $A.get("$Label.c.XC_CL_InsertChoice")
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
        component.set('v.valueStep', "3");
        component.set('v.showChooseOutOfDateForFilterSelection', false);
        component.set('v.loadWorkOrder', true);
        //component.set('v.showFilterSelection', true);
        //component.set('v.disabledButton', "false");
        //component.set('v.showDestinationPartner', true);
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
        component.set('v.columnsProvinces', [
            { label: 'Province', fieldName: 'label', type: 'text' }
        ]);
        component.set('v.operationSelected','filter');
        component.set('v.viewAllToggle', true);
    },

    handleClickStatefulButtonOrigin : function(component, event, helper) {
        let originPartner = component.get('v.originPartner');
        if(originPartner != null && originPartner != undefined && originPartner != '') {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
				title: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkError"),
				message: $A.get("$Label.c.XC_CL_ErrorSelectPartner"),
				key: 'info_alt',
				type: 'error',
				mode: 'dismissible'
			});
			toastEvent.fire();
        } else {
            let buttonState = !component.get('v.valueSearchChoiceOrigin');
            component.set('v.valueSearchChoiceOrigin', buttonState);
            if(buttonState) {
                component.set('v.fieldOrigin', 'Name');
            } else {
                component.set('v.fieldOrigin', 'XC_InternalCommercialCode__c');
            }
        }
    },

    handleClickStatefulButtonDestination : function(component, event, helper) {
        let buttonState = !component.get('v.valueSearchChoiceDestination');
        component.set('v.valueSearchChoiceDestination', buttonState);
        if(buttonState) {
            component.set('v.fieldDestination', 'Name');
        } else {
            component.set('v.fieldDestination', 'XC_InternalCommercialCode__c');
        }
    },

    resetAll : function(component, event, helper) { 
        helper.cleanAttributes(component, event, helper);
        component.set('v.originPartner', "");
    },

    handleFilesChange : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let files = component.find("file").get("v.files");
        if(!files || files == null || files == undefined || files.length == 0) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": $A.get("$Label.c.XC_CL_ErrorExcel"),
                "type": "error"
            });
            toastEvent.fire();  
            component.set('v.spinnerControl', false);
            component.find('file').set("v.class", "errorUpload");
        } else {
            component.find('file').set("v.class", "successUpload");
            component.set('v.labelForUpload', files[0].name);
        }        
        component.set('v.spinnerControl', false);
    },

    uploadFile : function(component, event, helper) {
        helper.uploadFile(component, event, helper);
    },

    downloadExceltemplate : function(component, event, helper) {
        window.location.href =  window.location.origin + $A.get('$Resource.XC_SR_TemplateMassiveWorkOrder');
    }

})