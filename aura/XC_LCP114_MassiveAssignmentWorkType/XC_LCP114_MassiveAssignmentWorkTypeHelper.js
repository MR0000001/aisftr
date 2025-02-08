/*
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 24/09/2020
    * @description XC_LCP114_MassiveAssignmentWorkType_Helper – Helper for component XC_LCP114_MassiveAssignmentWorkType
*/

({
    checkAccountUser: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        let action = component.get("c.getUserInformation");
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue().split("_");
                let isPartner = result[0] === 'partner';
                if (isPartner) {
                    component.set('v.originPartner', result[1]);
                    component.set('v.disabledOriginPartner', true);
                }
                component.set('v.legalEntity', result[2]);
            } else {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: JSON.parse(JSON.stringify(a.getError())),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);
    },

    doInit: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        let idOriginPartner = component.get('v.originPartner');
        let oldOriginPartner = component.get('v.originPartnerStored');
        if ((idOriginPartner !== '' && (oldOriginPartner === '' || oldOriginPartner === undefined || oldOriginPartner == null))
            || (idOriginPartner !== '' && oldOriginPartner !== '' && oldOriginPartner !== undefined && oldOriginPartner != null && idOriginPartner === oldOriginPartner)) {
            component.set('v.originPartnerStored', idOriginPartner);
            component.set('v.filterStrikeLookupDestination', "RecordType.Name = 'Partner' AND Id != '" + idOriginPartner + "'");
            component.set('v.partnerChoosed', true);
            //component.set('v.showTypeOperationMassive', true);
        } else {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: "Please, reset all tool to select another Partner",
                key: 'info_alt',
                type: 'warning',
                mode: 'dismissible',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set('v.originPartner', component.get('v.originPartnerStored'));
        }
        component.set('v.spinnerControl', false);
    },

    cleanAttributes: function (component, event, helper) {
        component.set('v.valueProgressionBar', 1);
        component.set('v.originPartner', '');
        component.set('v.disabledOriginPartner', false);
        component.set('v.showOriginPartner', false);
        component.set('v.fieldOrigin', 'Name');
        component.set('v.disabledButtonsUpload', false);
        component.set('v.valueSearchChoiceOrigin', true);
        component.set('v.fieldDestination', 'Name');
        component.set('v.legalEntity', '');
        component.set('v.valueSearchChoiceDestination', true);
        component.set('v.showDestinationPartner', false);
        component.set('v.destinationPartner', '');
        component.set('v.originPartnerStored', '');
        component.set('v.preferredOperation', '');
        component.set('v.filterStrikeLookupDestination', '');
        component.set('v.filterZipCodeCoverage', '');
        component.set('v.showEndButton', false);
        component.set('v.partnerChoosed', false);
        component.set('v.showTypeOperationMassive', false);
        component.set('v.isAddReady', false);
        component.set('v.isAdd', false);
        component.set('v.partnerName', '');
        component.set('v.quantityRowForOperation', '');
        component.set('v.filterWorkType', '');
        component.set('v.columnsWorkType', []);
        component.set('v.workTypeOptions', []);
        component.set('v.workTypeOptionsOriginal', []);
        component.set('v.workTypeOptionsOriginalForSegment', []);
        component.set('v.oldSelectedRowWorkType', []);
        component.set('v.dataProvinces', []);
        component.set('v.originalDataProvince', []);
        component.set('v.selectedWorkType', []);
        component.set('v.dataSummaryCoverages', []);
        component.set('v.disabledPickList', false);
        component.set('v.showLoadExcelOption', false);
        component.set('v.labelForUpload', "Choose file...");
        component.set('v.isTransferRemoveReady', false);
        component.set('v.workTypeFilteredForCoverage', false);
        //component.set('v.showSegmentSelection', false);
        component.set('v.showInfoMessageDown', false);
        component.set('v.enableInfiniteLoadingAddSummary', true);
        component.set('v.enableInfiniteLoadingRemoveTransfer', true);
        component.set('v.showTableZipCode', false);
        component.set('v.disableButtonLaunch', true);
        component.set('v.filterZipCode', '');
        component.set('v.country', '');
        component.set('v.columnsZipcode', []);
        component.set('v.dataForOperation', []);
        component.set('v.zipCodeOptions', []);
        component.set('v.zipCodeOptionsOriginal', []);
        component.set('v.oldSelectedRowProvince', []);
        component.set('v.selectedProvinces', []);
        component.set('v.oldSelectedRowZipcode', []);
        component.set('v.selectedZipCode', []);
        component.set('v.listAllZipCode', []);
        component.set('v.filterProvinces', '');
        component.set('v.columnsProvinces', []);
        component.set('v.dataProvinces', []);
        component.set('v.dataProvincesOriginal', []);
        component.set('v.selectedPartnerCoverage', []);
        component.set('v.mapProvinceListZipCode', new Object());
        component.set('v.showCleanExcelFile', false);
        component.set('v.valueShowCleanExcelFile', false);
        component.set('v.dataSummaryAdd', []);
        component.set('v.offsetListDataCoverageCombo', []);
        component.set('v.isTransferRemoveInitialFilter', false);
        component.set('v.showInfoFinalMessage', false);
        component.set('v.isTransferRemove', false);
        component.set('v.selectedFilterTableCoverages', false);
        component.set('v.showInfoMessageDownTypeOperation', false);
        component.set('v.columnsPartnerCoverage', []);
        component.set('v.dataPartnerCoverage', []);
        component.set('v.dataPartnerCoverageFiltered', []);
        component.set('v.dataPartnerCoverageFilteredOriginal', []);
        component.set('v.applyInitialFilter', false);
        component.set('v.oldSelectedRowPartnerCoverage', []);
        component.set('v.summaryTransferRemoveCoverageComboView', '');
        component.set('v.isOtherOperation', false);
        component.set('v.spinnerControlWithoutBack', false);
        component.set('v.disableMassiveOption', false);
        component.set('v.indexOffsetCoverageCombo', 0);
    },

    onChangePicklist: function (component, event, helper) {
        component.set('v.showInfoMessageDownTypeOperation', true);
        component.set("v.spinnerControl", true);
        let selectedValue = component.get('v.preferredOperation');
        component.set('v.disabledPickList', true);

        if (selectedValue === 'Transfer' || selectedValue === 'Remove') {
            helper.applyInitialFilters(component, event, helper);
            window.setTimeout($A.getCallback(function () {
                //component.set("v.spinnerControl", false);
                let selectSegmentComponent = component.find('selectSegment');
                if (component.get('v.showSegmentSelection') === true && selectSegmentComponent != null) {
                    selectSegmentComponent.set('v.value', 'B2C');
                }
                helper.onChangeSegment(component, event, helper);
            }), 5000);
        } else if (selectedValue === 'Add') {
            component.set('v.isAdd', true);
            component.set('v.showEndButton', true);
            component.set('v.disableButtonLaunch', true);
            //window.setTimeout($A.getCallback(function(){
            //component.set("v.spinnerControl", false);
            //}), 5000);
        }
    },

    filterZipCodeFromProvinces: function (component, event, helper) {
        component.set('v.spinnerControlZipCode', true);
        let zipCodeFiltered = [];
        let provincesSelected = component.get('v.selectedProvinces');
        let mapProvinceZipCodes = component.get('v.mapProvinceListZipCode');

        provincesSelected.forEach(province => {
            let listZipCode = mapProvinceZipCodes.hasOwnProperty(province.value) ? mapProvinceZipCodes[province.value] : null;
            if (listZipCode != null) {
                zipCodeFiltered = zipCodeFiltered.concat(listZipCode);
            }
        });

        if (zipCodeFiltered.length > 0) {
            zipCodeFiltered = zipCodeFiltered.filter((thing, index) => {
                const _thing = JSON.stringify(thing);
                return index === zipCodeFiltered.findIndex(obj => {
                    return JSON.stringify(obj) === _thing;
                });
            });
            if (zipCodeFiltered.length !== 0) {
                component.set('v.zipCodeOptions', zipCodeFiltered);
                component.set('v.zipCodeOptionsOriginal', zipCodeFiltered);
            } else {
                component.set('v.showTableZipCode', false);
                component.set('v.oldSelectedRowZipcode', new Array());
                component.set('v.selectedZipCode', component.get('v.listAllZipCode'));
            }
        }
        window.setTimeout($A.getCallback(function () {
            component.set('v.spinnerControlZipCode', false);
        }), 500);
    },

    handleAddOperation: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        let partnerInInput = component.get('v.originPartner');
        if (partnerInInput == null || partnerInInput === "") {
            component.set('v.spinnerControl', false);
            return;
        }
        component.set('v.columnsWorkType', [
            {label: "Work Type", fieldName: 'Name', type: 'text'}
        ]);
        component.set('v.columnsProvinces', [
            {label: $A.get("$Label.c.XC_CL_MassAssSkill_Provinces"), fieldName: 'value', type: 'text'}
        ]);
        component.set('v.columnsZipCode', [
            {label: $A.get("$Label.c.XC_CL_ZipCode"), fieldName: 'value', type: 'text'}
        ]);
        let action = component.get("c.initAddOperation");
        action.setParams({
            'accountId': partnerInInput
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                if (result.success) {
                    component.set('v.country', result.country);
                    component.set('v.workTypeOptions', result.listWorkType);
                    component.set('v.workTypeOptionsOriginalForSegment', result.listWorkType);
                    component.set('v.showSegmentSelection', result.isAdmin);
                    let selectSegmentComponent = component.find('selectSegment');
                    if (result.isAdmin && selectSegmentComponent != null) {
                        selectSegmentComponent.set('v.value', 'B2C');
                    }
                    helper.onChangeSegment(component, event, helper);
                    component.set('v.workTypeOptionsOriginal', result.listWorkType);
                    component.set('v.dataProvinces', result.listProvinces);
                    component.set('v.dataProvincesOriginal', result.listProvinces);
                    component.set('v.mapProvinceListZipCode', result.mapProvinceListZipcode);
                    component.set('v.partnerName', result.accountName);
                } else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: result.message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
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
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);
    },

    applyFiltersAdd: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        let worktypeSelected = component.get('v.selectedWorkType');
        let zipcodeSelected = component.get('v.selectedZipCode');
        component.set('v.columnsSummaryAdd', [
            {label: $A.get("$Label.c.XC_CL_WorkType"), fieldName: 'WorkType', type: 'text'},
            {label: $A.get("$Label.c.XC_CL_ZipCode"), fieldName: 'ZipCode', type: 'text'}
        ]);
        let listOutputDatatable = [];
        let dataForOperation = [];
        for (let i = 0; i < worktypeSelected.length; i++) {
            for (let j = 0; j < zipcodeSelected.length; j++) {
                let mapOutput = {
                    'WorkType': worktypeSelected[i].Name,
                    'ZipCode': zipcodeSelected[j].value
                };
                listOutputDatatable.push(mapOutput);
                let mapForOperation = {
                    'WorkType': worktypeSelected[i].Id,
                    'ZipCode': zipcodeSelected[j].value
                };
                dataForOperation.push(mapForOperation);
            }
        }


        let offSetCoverageCombo = component.get('v.offSetCoverageCombo');
        if (listOutputDatatable.length <= offSetCoverageCombo) {
            component.set('v.dataSummaryAdd', listOutputDatatable);
            component.set('v.offsetListDataCoverageCombo', new Array());
            component.set('v.summaryCoverageComboView', '<b>' + $A.get("$Label.c.XC_CL_MassiveWT_CovShown") + '</b>' + (listOutputDatatable.length).toString() + '/' + listOutputDatatable.length.toString());
        } else {
            let covToShow = [];
            for (let i = 0; i < offSetCoverageCombo; i++) {
                covToShow.push(listOutputDatatable[i]);
            }
            component.set('v.dataSummaryAdd', covToShow);
            component.set('v.indexOffsetCoverageCombo', offSetCoverageCombo);
            component.set('v.offsetListDataCoverageCombo', listOutputDatatable);
            component.set('v.summaryCoverageComboView', '<b>' + $A.get("$Label.c.XC_CL_MassiveWT_CovShown") + '</b>' + (offSetCoverageCombo).toString() + '/' + listOutputDatatable.length.toString());
        }
        component.set('v.dataForOperation', dataForOperation);
        if (listOutputDatatable.length > 0) {
            component.set('v.disableButtonLaunch', false);
        } else {
            component.set('v.disableButtonLaunch', true);
        }
        component.set('v.isAddReady', true);
        component.set('v.valueProgressionBar', 85);
        component.set('v.showInfoMessageDown', true);
        //component.find('tableCoveragesCombo').set('v.enableInfiniteLoading', true);
        component.set('v.enableInfiniteLoadingAddSummary', true);
        window.setTimeout($A.getCallback(function () {
            component.set("v.spinnerControl", false);
        }), 3000);
    },

    launchOperationAdd: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        if (component.get('v.originPartner') === '') {
            $A.createComponent("ui:outputText", {
                    "value": $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderTitleDestPartner")
                },
                function (contentComponent, status, error) {
                    if (status === "SUCCESS") {
                        let modalBody = contentComponent;
                        component.find('overlayLib').showCustomModal({
                            header: 'Warning',
                            body: modalBody,
                            showCloseButton: true,
                            cssClass: "mymodal",
                        });
                    } else {
                        throw console.log('Error: ', JSON.parse(JSON.stringify(error)));
                    }
                    component.set('v.spinnerControl', false);
                });
            return;
        }
        component.set('v.showInfoFinalMessage', true);
        component.set('v.disableButtonLaunch', true);
        window.setTimeout($A.getCallback(function () {
            let allOk = true;
            let promiseOperationAdd = new Promise((resolve, reject) => {
                let action = component.get("c.addOperation");
                action.setParams({
                    'listCombo': component.get('v.dataForOperation'),
                    'accountId': component.get('v.originPartner')
                });
                action.setCallback(this, function (a) {
                    let state = a.getState();
                    if (state === "SUCCESS") {
                        let result = a.getReturnValue();
                        if (result.success) {
                            var modalBody;
                            console.log('@@@result.statusLogId: ' + result.statusLogId);
                            $A.createComponent("c:XC_LCP114_MassiveAssignmentWorkTypeSuccess", {
                                    'partnerName': component.get('v.partnerName'),
                                    'typeOperation': 'Add',
                                    'statusLogId': result.statusLogId //NF_ToBeValidatedByLore Added
                                },
                                function (content, status) {
                                    if (status === "SUCCESS") {
                                        modalBody = content;
                                        component.find('overlayLib').showCustomModal({
                                            header: $A.get("$Label.c.XC_CL_Confirmation"),
                                            body: modalBody,
                                            showCloseButton: true,
                                            cssClass: "mymodal",
                                            closeCallback: function () {
                                                //helper.cleanAttributes(component, event, helper);
                                                location.reload();
                                            }
                                        })
                                    }
                                });
                        } else {
                            allOk = false;
                            component.set('v.spinnerControlWithoutBack', false);
                            $A.createComponent("ui:outputText", {
                                    "value": result.message
                                },
                                function (contentComponent, status, error) {
                                    if (status === "SUCCESS") {
                                        let modalBody = contentComponent;
                                        component.find('overlayLib').showCustomModal({
                                            header: 'Error',
                                            body: modalBody,
                                            showCloseButton: true,
                                            cssClass: "mymodal",
                                        });
                                    } else {
                                        throw console.log('(-_-) Error to create steps: ', JSON.parse(JSON.stringify(error)));
                                    }
                                    component.set('v.disableButtonLaunch', false);
                                    //component.set('v.showSpinner', false);
                                });
                        }
                    } else {
                        allOk = false;
                        component.set('v.spinnerControlWithoutBack', false);
                        component.set('v.disableButtonLaunch', false);
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
                    //component.set('v.spinnerControl', false);
                    resolve();
                });
                $A.enqueueAction(action);
            });

            promiseOperationAdd.then(
                function () {
                    window.setTimeout($A.getCallback(function () {
                        if (allOk) {
                            component.set('v.spinnerControlWithoutBack', true);
                        }
                        component.set("v.spinnerControl", false);
                    }), 3000);
                }).catch(
                (reason) => {
                    console.log('/!\ Error: ' + reason);
                });
        }), 200); /*NF_ToBeValidatedByLore Reduce useless timeout*/
    },

    applyInitialFilters: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        window.setTimeout($A.getCallback(function () {
            let listZipCodeSelectedTemp = component.get('v.selectedZipCode');
            let listWorkTypeSelectedTemp = component.get('v.selectedWorkType');
            let listZipCodeSelected = [];
            let listWorkTypeSelected = [];
            listZipCodeSelectedTemp.forEach(element => {
                listZipCodeSelected.push(element['value']);
            });
            listWorkTypeSelectedTemp.forEach(element => {
                listWorkTypeSelected.push(element['Name']);
            });
            let action = component.get("c.getPartnerCoverage");
            action.setParams({
                'accountId': component.get('v.originPartner'),
                /*'cutoff': component.get('v.cutoffOperation'), /NicoloFodera 20220715 Removed*/
                'typeOfOperation': component.get('v.preferredOperation'), /*NicoloFodera 20220715 Added*/
                'listZipCodeSelected': listZipCodeSelected,
                'listWorkTypeSelected': listWorkTypeSelected
            });
            action.setCallback(this, function (a) {
                let state = a.getState();
                component.set('v.columnsWorkType', [
                    {label: $A.get("$Label.c.XC_CL_WorkType"), fieldName: 'Name', type: 'text'}
                ]);
                component.set('v.columnsProvinces', [
                    {label: $A.get("$Label.c.XC_CL_MassAssSkill_Provinces"), fieldName: 'value', type: 'text'}
                ]);
                component.set('v.columnsZipCode', [
                    {label: $A.get("$Label.c.XC_CL_ZipCode"), fieldName: 'value', type: 'text'}
                ]);
                if (state === "SUCCESS") {
                    let result = a.getReturnValue();
                    component.set('v.partnerName', result.accountName);
                    if (result.success) {
                        let listCoverages = result.listPartnerCoverage;
                        component.set('v.columnsPartnerCoverage', [
                            {label: $A.get("$Label.c.XC_CL_WorkType"), fieldName: 'XC_WorkTypeName__c', type: 'text'},
                            {label: $A.get("$Label.c.XC_CL_ZipCode"), fieldName: 'XC_ZipCode__c', type: 'text'}
                        ]);
                        component.set('v.dataPartnerCoverage', listCoverages);
                        component.set('v.summaryCoverageComboView', 'Coverages for ' + result.accountName + ': ' + listCoverages.length);
                        component.set('v.filterWorkType', '');
                        component.set('v.oldSelectedRowWorkType', []);
                        component.set('v.workTypeOptions', result.listWorkType);
                        component.set('v.workTypeOptionsOriginalForSegment', result.listWorkType);
                        component.set('v.showSegmentSelection', result.isAdmin);
                        let selectSegmentComponent = component.find('selectSegment');
                        if (result.isAdmin && selectSegmentComponent != null) {
                            selectSegmentComponent.set('v.value', 'B2C');
                        }
                        helper.onChangeSegment(component, event, helper);
                        component.set('v.workTypeOptionsOriginal', result.listWorkType);
                        component.set('v.isTransferRemoveInitialFilter', false);
                        window.setTimeout($A.getCallback(function () {
                            component.set('v.spinnerControl', false);
                            component.set('v.applyInitialFilter', false);
                            component.set('v.isTransferRemove', true);
                            let selectSegmentComponent = component.find('selectSegment');
                            if (component.get('v.showSegmentSelection') === true && selectSegmentComponent != null) {
                                selectSegmentComponent.set('v.value', 'B2C');
                            }
                            helper.onChangeSegment(component, event, helper);
                        }), 4000);
                        component.set('v.valueProgressionBar', 55);
                    } else {
                        $A.createComponent("ui:outputText", {
                                "value": result.message
                            },
                            function (contentComponent, status, error) {
                                if (status === "SUCCESS") {
                                    let modalBody = contentComponent;
                                    component.find('overlayLib').showCustomModal({
                                        header: 'Warning',
                                        body: modalBody,
                                        showCloseButton: true,
                                        cssClass: "mymodal",
                                    });
                                    component.set('v.spinnerControl', false);
                                } else {
                                    throw console.log('(-_-) Error to create steps: ', JSON.parse(JSON.stringify(error)));
                                }
                            });
                        let oldApplyInitialFilter = component.get('v.applyInitialFilter');
                        if (result.applyInitialFilter && !oldApplyInitialFilter) {
                            let actionPart2 = component.get("c.getPartnerCoveragePart2");
                            actionPart2.setParams({
                                'accountId': component.get('v.originPartner'),
                                'resultPart2Temp': JSON.stringify(result)
                            });
                            actionPart2.setCallback(this, function (aPart2) {
                                let statePart2 = aPart2.getState();
                                if (statePart2 === "SUCCESS") {
                                    let resultPart2 = aPart2.getReturnValue();
                                    if (resultPart2.success) {
                                        component.set('v.applyInitialFilter', true);
                                        component.set('v.isTransferRemoveInitialFilter', true);
                                        component.set('v.country', resultPart2.country);
                                        component.set('v.workTypeOptions', resultPart2.listWorkType);
                                        component.set('v.workTypeOptionsOriginalForSegment', resultPart2.listWorkType);
                                        component.set('v.showSegmentSelection', resultPart2.isAdmin);
                                        let selectSegmentComponent = component.find('selectSegment');
                                        if (resultPart2.isAdmin && selectSegmentComponent != null) {
                                            selectSegmentComponent.set('v.value', 'B2C');
                                        }
                                        helper.onChangeSegment(component, event, helper);
                                        component.set('v.workTypeOptionsOriginal', resultPart2.listWorkType);
                                        component.set('v.dataProvinces', resultPart2.listProvinces);
                                        component.set('v.dataProvincesOriginal', resultPart2.listProvinces);
                                        component.set('v.mapProvinceListZipCode', resultPart2.mapProvinceListZipcode);
                                    } else {
                                        $A.createComponent("ui:outputText", {
                                                "value": resultPart2.message
                                            },
                                            function (contentComponentPart2, statusPart2, errorPart2) {
                                                if (statusPart2 === "SUCCESS") {
                                                    let modalBody = contentComponentPart2;
                                                    component.find('overlayLib').showCustomModal({
                                                        header: 'Warning',
                                                        body: modalBody,
                                                        showCloseButton: true,
                                                        cssClass: "mymodal",
                                                    });
                                                    component.set('v.spinnerControl', false);
                                                } else {
                                                    throw console.log('(-_-) Error to create steps: ', JSON.parse(JSON.stringify(errorPart2)));
                                                }
                                            });
                                    }
                                } else {
                                    let toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title: "Error",
                                        message: aPart2.getError(),
                                        key: 'info_alt',
                                        type: 'error',
                                        mode: 'dismissible',
                                        mode: 'pester'
                                    });
                                    toastEvent.fire();
                                    component.set('v.spinnerControl', false);
                                }
                            });
                            $A.enqueueAction(actionPart2);
                        }
                    }
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
                    component.set('v.spinnerControl', false);
                }
            });
            $A.enqueueAction(action);
        }), 1500);
    },

    filterPartnerCoverage: function (component, event, helper, listWorkType) {
        component.set('v.spinnerControl', true);
        let workTypeFilteredForCoverage = component.get('v.workTypeFilteredForCoverage');
        window.setTimeout($A.getCallback(function () {
            let dataToShow = [];
            let dataCoverages = component.get('v.dataPartnerCoverage');
            let listWorkTypeName = [];
            listWorkType.forEach(element => {
                listWorkTypeName.push(element.Name);
            });
            dataCoverages.forEach(element => {
                if (listWorkTypeName.includes(element.XC_WorkTypeName__c)) {
                    dataToShow.push(element);
                }
            });
            component.set('v.dataPartnerCoverageFiltered', dataToShow);
            component.set('v.dataPartnerCoverageFilteredOriginal', dataToShow);
            component.set('v.summaryCoverageComboView', 'Coverages filtered for ' + component.get('v.partnerName') + ': ' + dataToShow.length + '/' + dataCoverages.length);
            component.set("v.spinnerControl", false);
            if (workTypeFilteredForCoverage) {
                component.set('v.workTypeFilteredForCoverage', false);
            }
        }), workTypeFilteredForCoverage ? 0 : 2000);
    },

    selectedPartnerCoverage: function (component, event, helper, coverageSelected) {
        component.set('v.columnsSummaryAdd', [
            {label: $A.get("$Label.c.XC_CL_WorkType"), fieldName: 'XC_WorkTypeName__c', type: 'text'},
            {label: $A.get("$Label.c.XC_CL_ZipCode"), fieldName: 'XC_ZipCode__c', type: 'text'}
        ]);
        let offset = component.get('v.offSetCoverageCombo');
        if (coverageSelected.length > offset) {
            let coverageOffset = [];
            for (let i = 0; i < offset - 1; i++) {
                coverageOffset.push(coverageSelected[i]);
            }
            component.set('v.dataSummaryCoverages', coverageOffset);
            component.get('v.indexOffsetCoverageCombo', offset);
            component.set('v.summaryTransferRemoveCoverageComboView', '<b>Coverages for Partner ' + component.get('v.partnerName') + ': </b>' + coverageOffset.length.toString() + '/' + coverageSelected.length.toString());
        } else {
            component.set('v.dataSummaryCoverages', coverageSelected);
            component.set('v.summaryTransferRemoveCoverageComboView', '<b>Coverages for Partner ' + component.get('v.partnerName') + ': </b>' + coverageSelected.length.toString() + '/' + coverageSelected.length.toString());
        }
        component.set('v.isTransferRemoveReady', true);
        component.set('v.valueProgressionBar', 85);
        component.set('v.showInfoMessageDown', true);
        let cmpRemoveTransfer = component.find('layoutItemButtonRemoveTransfer');
        if (cmpRemoveTransfer) {
            cmpRemoveTransfer.set('v.class', 'classCenter');
        }
        if (component.get('v.dataSummaryCoverages').length > 0) {
            component.set('v.showEndButton', true);
            if (component.get('v.preferredOperation') === 'Transfer') {
                component.set('v.isOtherOperation', true);
            } else {
                component.set('v.isOtherOperation', false);
            }
            component.set('v.disableButtonLaunch', false);
            if (component.get('v.showLoadExcelOption')) {
                component.set('v.oldSelectedRowPartnerCoverage', coverageSelected);
            }
        } else {
            component.set('v.showEndButton', false);
            component.set('v.disableButtonLaunch', true);
        }
        //component.find('tableCoveragesComboRemoveTransfer').set('v.enableInfiniteLoading', true);
        component.set('v.enableInfiniteLoadingRemoveTransfer', true);
        window.setTimeout($A.getCallback(function () {
            component.set('v.spinnerControl', false);
        }), 1000);
    },

    launchOperationOther: function (component, event, helper, operationSelected) {
        component.set('v.spinnerControl', true);
        if (operationSelected === 'Transfer' && (component.get('v.destinationPartner') === '' || component.get('v.originPartner') === '')) {
            $A.createComponent("ui:outputText", {
                    "value": $A.get("$Label.c.XC_CL_MassiveAssignmentWorkOrderTitleDestPartner")
                },
                function (contentComponent, status, error) {
                    if (status === "SUCCESS") {
                        let modalBody = contentComponent;
                        component.find('overlayLib').showCustomModal({
                            header: 'Warning',
                            body: modalBody,
                            showCloseButton: true,
                            cssClass: "mymodal",
                        });
                    } else {
                        throw console.log('Error: ', JSON.parse(JSON.stringify(error)));
                    }
                    component.set('v.spinnerControl', false);
                });
            return;
        }
        component.set('v.spinnerControlWithoutBack', true);
        component.set('v.showInfoFinalMessage', true);
        component.set('v.disableButtonLaunch', true);
        let listCoverages = component.get('v.oldSelectedRowPartnerCoverage');
        let coverageIds = [];
        for (let i = 0; i < listCoverages.length; i++) {
            coverageIds.push(listCoverages[i].Id);
        }
        window.setTimeout($A.getCallback(function () {
            let promiseOtherOperation = new Promise((resolve, reject) => {
                let action = component.get("c.otherOperation");
                action.setParams({
                    'setCoverageIds': coverageIds,
                    'accountId': component.get('v.originPartner'),
                    'destinationPartner': component.get('v.destinationPartner'),
                    'typeOfOperation': operationSelected
                });
                action.setCallback(this, function (a) {
                    let state = a.getState();
                    let errorsT = a.getError();
                    if (state === "SUCCESS") {
                        let result = a.getReturnValue();
                        if (result.success) {
                            var modalBody;
                            if (operationSelected === 'Remove') {
                                $A.createComponent("c:XC_LCP114_MassiveAssignmentWorkTypeSuccess", {
                                        'partnerName': component.get('v.partnerName'),
                                        'typeOperation': 'Add',
                                        'statusLogId': result.statusLogId
                                    },
                                    function (content, status) {
                                        if (status === "SUCCESS") {
                                            modalBody = content;
                                            component.find('overlayLib').showCustomModal({
                                                header: $A.get("$Label.c.XC_CL_Confirmation"),
                                                body: modalBody,
                                                showCloseButton: true,
                                                cssClass: "mymodal",
                                                closeCallback: function () {
                                                    //helper.cleanAttributes(component, event, helper);
                                                    location.reload();
                                                }
                                            })
                                        }
                                    });
                            } else {
                                $A.createComponent("c:XC_LCP114_MassiveAssignmentWorkTypeSuccess", {
                                        'partnerName': component.get('v.partnerName'),
                                        'typeOperation': 'Add',
                                        'statusLogId': result.statusLogId
                                    },
                                    function (content, status) {
                                        if (status === "SUCCESS") {
                                            modalBody = content;
                                            component.find('overlayLib').showCustomModal({
                                                header: $A.get("$Label.c.XC_CL_Confirmation"),
                                                body: modalBody,
                                                showCloseButton: true,
                                                cssClass: "mymodal",
                                                closeCallback: function () {
                                                    //helper.cleanAttributes(component, event, helper);
                                                    location.reload();
                                                }
                                            })
                                        }
                                    });
                            }
                        } else {
                            component.set('v.spinnerControlWithoutBack', false);
                            $A.createComponent("ui:outputText", {
                                    "value": result.message
                                },
                                function (contentComponent, status, error) {
                                    if (status === "SUCCESS") {
                                        let modalBody = contentComponent;
                                        component.find('overlayLib').showCustomModal({
                                            header: 'Error',
                                            body: modalBody,
                                            showCloseButton: true,
                                            cssClass: "mymodal",
                                        });
                                    } else {
                                        throw console.log('(-_-) Error to create steps: ', JSON.parse(JSON.stringify(error)));
                                    }
                                    component.set('v.disableButtonLaunch', false);
                                    //component.set('v.showSpinner', false);
                                });
                        }
                    } else {
                        let errors = a.getError();
                        component.set('v.spinnerControlWithoutBack', false);
                        component.set('v.disableButtonLaunch', false);
                        let parseErrorMessage = '';
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                parseErrorMessage = errors[0].message;
                            }
                        }
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error",
                            message: "Please, try to reduce the number of coverage to manage [" + parseErrorMessage + "]",
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    //component.set('v.spinnerControl', false);
                    resolve();
                });
                $A.enqueueAction(action);
            });

            promiseOtherOperation.then(
                function () {
                    window.setTimeout($A.getCallback(function () {
                        component.set("v.spinnerControl", false);
                    }), 6000);
                }).catch(
                (reason) => {
                    console.log('Error: ' + reason);
                });
        }), 2000);
    },

    onChangeSegment: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        let selectSegmentComponent = component.find('selectSegment');
        let filterSegment = '';
        if (component.get('v.showSegmentSelection') === false || selectSegmentComponent == null) {
            filterSegment = 'B2C';
        } else {
            filterSegment = selectSegmentComponent.get('v.value');
        }
        let wtOriginal = component.get('v.workTypeOptionsOriginalForSegment');
        if (filterSegment === "All") {
            component.set('v.workTypeOptions', wtOriginal);
        } else {
            let newWtList = [];
            wtOriginal.forEach(element => {
                if (element.XC_Segment__c === filterSegment) {
                    newWtList.push(element);
                }
            });

            if (newWtList.length === 0) {
                /*let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: $A.get("$Label.c.XC_CL_NoWorkType") + ' ('+filterSegment+')',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible',
                    mode: 'pester'
                });
                toastEvent.fire();*/
                component.set('v.workTypeOptions', []);
            } else {
                component.set('v.workTypeOptions', newWtList);
            }
        }
        component.set('v.spinnerControl', false);
    },

    uploadFile: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        let files = component.find("file").get("v.files");
        if (!files || files.length === 0 || !files[0].name.includes('xls')) {
            $A.createComponent("ui:outputText", {
                "value": "You have to select a valid Excel file"
            }, function (contentComponent, status, error) {
                if (status === "SUCCESS") {
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
        if (fileTemp) {
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
                    workbook.SheetNames.forEach(function (sheetName) {
                        let XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);
                        json_object = JSON.stringify(XL_row_object);
                    });
                    let result = json_object;//helper.CSV2JSON(component, csv);
                    if (!(result != null && result !== '')) {
                        $A.createComponent("ui:outputText", {
                            "value": "Excel must not be empty and the columns must be separated by semicolon"
                        }, function (contentComponent, status, error) {
                            if (status === "SUCCESS") {
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
                    helper.doSummary(component, event, helper, result);
                } catch (error) {
                    $A.createComponent("ui:outputText", {
                        "value": error.toString()
                    }, function (contentComponent, status, error) {
                        if (status === "SUCCESS") {
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
        component.set('v.spinnerControl', false);
    },

    CSV2JSON: function (component, csv) {
        let arr = csv.split('\n');
        arr.pop();
        let jsonObj = [];
        let headers = arr[0].split(';');
        for (let i = 1; i < arr.length; i++) {
            let data = arr[i].split(',');
            let obj = {};
            for (let j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
            }
            jsonObj.push(obj);
        }
        let json = JSON.stringify(jsonObj);
        return json;
    },

    doSummary: function (component, event, helper, jsonstr) {
        component.set('v.spinnerControl', true);
        let cleanArrayExcel = component.find('cleanExcelFile').get('v.value');//component.get('v.valueShowCleanExcelFile');
        window.setTimeout($A.getCallback(function () {
            let operation = component.get('v.preferredOperation');
            if (operation === 'Add') {
                let pcArray = JSON.parse(jsonstr);
                let listWorkTypeName = [];
                if (cleanArrayExcel) {
                    let pcArrayTemp = [];
                    let listForDuplicate = [];
                    pcArray.forEach(element => {
                        let keyDuplicate = element.WorkTypeName + element.PostalCode;
                        if (!listForDuplicate.includes(keyDuplicate)) {
                            listForDuplicate.push(keyDuplicate);
                            pcArrayTemp.push(element);
                            listWorkTypeName.push(element.WorkTypeName);
                        }
                    });
                    pcArray = pcArrayTemp;
                } else {
                    pcArray.forEach(element => {
                        listWorkTypeName.push(element.WorkTypeName);
                    });
                }
                let action = component.get("c.uploadFileCsvAdd");
                action.setParams({
                    "legalEntity": component.get('v.legalEntity'),
                    "listWorkTypeName": listWorkTypeName,
                    "accountId": component.get('v.originPartner')
                });
                action.setCallback(this, function (response) {
                    let state = response.getState();
                    component.set('v.spinnerControl', true);
                    if (state === "SUCCESS") {
                        let result = response.getReturnValue();
                        if (result.mapNameIdWorkType == null || !result.success) {
                            $A.createComponent("ui:outputText", {
                                "value": "WorkType not found"
                            }, function (contentComponent, status, error) {
                                if (status === "SUCCESS") {
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
                            let mapNameSegmentIdWorkType = result.mapNameIdWorkType;
                            let worktypeSelected = [];
                            let zipcodeSelected = [];
                            let listOutputDatatable = [];
                            let dataForOperation = [];
                            pcArray.forEach(element => {
                                if (mapNameSegmentIdWorkType.hasOwnProperty(element.WorkTypeName)) {
                                    let postalCodeTemp = element.PostalCode.toString();
                                    let postalCodeFinal = postalCodeTemp.length === 1 ? '0000' + postalCodeTemp : (
                                        postalCodeTemp.length === 2 ? '000' + postalCodeTemp : (
                                            postalCodeTemp.length === 3 ? '00' + postalCodeTemp : (
                                                postalCodeTemp.length === 4 ? '0' + postalCodeTemp : postalCodeTemp
                                            )));
                                    zipcodeSelected.push({
                                        Id: element.PostalCode,
                                        value: postalCodeFinal
                                    });
                                    worktypeSelected.push({
                                        Id: mapNameSegmentIdWorkType[element.WorkTypeName],
                                        Name: element.WorkTypeName,
                                        XC_Segment__c: 'B2C'
                                    });

                                    let mapOutput = {
                                        'WorkType': element.WorkTypeName,
                                        'ZipCode': postalCodeFinal
                                    };
                                    listOutputDatatable.push(mapOutput);
                                    let mapForOperation = {
                                        'WorkType': mapNameSegmentIdWorkType[element.WorkTypeName],
                                        'ZipCode': postalCodeFinal
                                    };
                                    dataForOperation.push(mapForOperation);
                                }
                            });
                            component.set('v.selectedWorkType', worktypeSelected);
                            component.set('v.selectedZipCode', zipcodeSelected);

                            // For summary add:
                            component.set('v.columnsSummaryAdd', [
                                {label: $A.get("$Label.c.XC_CL_WorkType"), fieldName: 'WorkType', type: 'text'},
                                {label: $A.get("$Label.c.XC_CL_ZipCode"), fieldName: 'ZipCode', type: 'text'}
                            ]);

                            let offSetCoverageCombo = component.get('v.offSetCoverageCombo');
                            if (listOutputDatatable.length <= offSetCoverageCombo) {
                                component.set('v.dataSummaryAdd', listOutputDatatable);
                                component.set('v.offsetListDataCoverageCombo', new Array());
                                component.set('v.summaryCoverageComboView', '<b>' + $A.get("$Label.c.XC_CL_MassiveWT_CovShown") + '</b>' + (listOutputDatatable.length).toString() + '/' + listOutputDatatable.length.toString());
                            } else {
                                let covToShow = [];
                                for (let i = 0; i < offSetCoverageCombo; i++) {
                                    covToShow.push(listOutputDatatable[i]);
                                }
                                component.set('v.dataSummaryAdd', covToShow);
                                component.set('v.indexOffsetCoverageCombo', offSetCoverageCombo);
                                component.set('v.offsetListDataCoverageCombo', listOutputDatatable);
                                component.set('v.summaryCoverageComboView', '<b>' + $A.get("$Label.c.XC_CL_MassiveWT_CovShown") + '</b>' + (offSetCoverageCombo).toString() + '/' + listOutputDatatable.length.toString());
                            }
                            component.set('v.dataForOperation', dataForOperation);
                            if (listOutputDatatable.length > 0) {
                                component.set('v.disableButtonLaunch', false);
                            } else {
                                component.set('v.disableButtonLaunch', true);
                            }
                            component.set('v.isAddReady', true);
                            component.set('v.valueProgressionBar', 85);
                            component.set('v.showInfoMessageDown', true);
                            component.set('v.enableInfiniteLoadingAddSummary', true);
                            component.set('v.partnerName', result.partnerName);
                            component.set('v.showEndButton', true);
                            component.set('v.disabledButtonsUpload', true);
                            window.setTimeout($A.getCallback(function () {
                                component.set("v.spinnerControl", false);
                            }), 3000);
                        }
                    } else {
                        $A.createComponent("ui:outputText", {
                            "value": JSON.parse(JSON.stringify(response.getError()))[0].message
                        }, function (contentComponent, status, error) {
                            if (status === "SUCCESS") {
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
            } else {
                /*NicoloFodera 20220715 Added[start]*/
                let fileListSize = JSON.parse(jsonstr).length;
                let errorLimitMessage = '';
                try {
                    if (component.get('v.preferredOperation') === 'Remove' && fileListSize > parseInt($A.get("$Label.c.XC_CL_MassiveWT_LimitRecordOperationRemove"))) {
                        errorLimitMessage = '[Remove] ' + $A.get("$Label.c.XC_CL_ErrorAdd	").replace('{0}', $A.get("$Label.c.XC_CL_MassiveWT_LimitRecordOperationRemove"));
                    } else if (component.get('v.preferredOperation') === 'Transfer' && fileListSize > parseInt($A.get("$Label.c.XC_CL_MassiveWT_LimitRecordOperationTransfer"))) {
                        errorLimitMessage = '[Transfer] ' + $A.get("$Label.c.XC_CL_ErrorAdd	").replace('{0}', $A.get("$Label.c.XC_CL_MassiveWT_LimitRecordOperationTransfer"));
                    }
                } catch (err) {
                    console.log('check limit operation log--->', err.message);
                }
                if (errorLimitMessage !== '') {
                    $A.createComponent("ui:outputText", {
                        "value": errorLimitMessage
                    }, function (contentComponent, status, error) {
                        if (status === "SUCCESS") {
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
                    component.set('v.spinnerControl', false);
                    return;
                }
                console.log('check limit operation loadsadasg--->');
                /*NicoloFodera 20220715 Added [end]*/
                let action = component.get("c.uploadFileCsvOtherOperation");
                action.setParams({
                    "strfromlex": jsonstr,
                    "accountId": component.get('v.originPartner'),
                    "legalEntity": component.get('v.legalEntity'),
                    "cleanArrayExcel": cleanArrayExcel
                });
                action.setCallback(this, function (response) {
                    let state = response.getState();
                    if (state === "SUCCESS") {
                        let result = response.getReturnValue();
                        if (result.listPcToReturn.length === 0) {
                            $A.createComponent("ui:outputText", {
                                "value": "No coverages to show"
                            }, function (contentComponent, status, error) {
                                if (status === "SUCCESS") {
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
                            helper.selectedPartnerCoverage(component, event, helper, result.listPcToReturn);
                            component.set('v.partnerName', result.partnerName);
                            component.set('v.disabledButtonsUpload', true);
                        }
                    } else {
                        $A.createComponent("ui:outputText", {
                            "value": JSON.parse(JSON.stringify(response.getError()))[0].message
                        }, function (contentComponent, status, error) {
                            if (status === "SUCCESS") {
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
            }
            component.set('v.spinnerControl', false);
        }), 5000);
    },

    // Lorenzo Evangelisti - lorenzo.evangelisti@webresults.it 31/05/2022 view logs [START]
    viewLogs: function (component, event, helper) {
        component.set("v.spinnerControl", true);
        let action = component.get("c.populateLogsWrapper");
        action.setParams({
            'dirtyData': false
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.spinnerControl", false);
                let result = a.getReturnValue();
                if (result.success && result.listViews.length !== 0) {
                    let navEvent = $A.get("e.force:navigateToList");
                    navEvent.setParams({
                        "listViewId": result.listViews[0].Id,
                        "listViewName": result.listViews[0].Name,
                        "scope": "XC_MassiveAssignWorkTypeOperationStatus__c"
                    });
                    navEvent.fire();
                } else {
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
    }
    // Lorenzo Evangelisti - lorenzo.evangelisti@webresults.it 31/05/2022 view logs [END]

})