/*
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 24/09/2020
    * @description XC_LCP114_MassiveAssignmentWorkType_Controller – Controller for component XC_LCP114_MassiveAssignmentWorkType
*/

({

    checkAccountUser  : function(component, event, helper) {
        console.log('@@@ Welcome in the fantastic component LCP114!');
        let workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url : '/lightning/n/XC_MassiveAssignmentWorkType',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response ,
                label: "Massive Coverage Assignment" 
            });
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: "utility:target",
            });
        }); 
        helper.checkAccountUser(component, event, helper);
    },

    init : function(component, event, helper) {
        console.log('@@@ You have selected a new Partner');
        helper.doInit(component, event, helper);
        component.set('v.valueProgressionBar', 35);
    },

    changeColorMouseOverSelectMassive : function(component, event, helper) { 
        component.find('cardOperationMassiveWorkType').set("v.class", "classOperationOver");
    },

    changeColorMouseOutSelectMassive : function(component, event, helper) { 
        component.find('cardOperationMassiveWorkType').set("v.class", "classOperation");
    },

    changeColorMouseClickSelectMassive : function(component, event, helper) { 
        component.find('cardOperationMassiveWorkType').set("v.class", "classOperation");
        component.set('v.partnerChoosed', false);
        component.set('v.showTypeOperationMassive', true);
    },

    onChangePicklist : function(component, event, helper) {
        helper.onChangePicklist(component, event, helper);
    },

    workTypeFiltered : function(component, event, helper) {
        // Filter for name WT:
        let data = component.get("v.workTypeOptionsOriginal"),
            term = component.get("v.filterWorkType"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.Name));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        // Filter for Segment WT:
        let showSegmentFilter = component.get('v.showSegmentSelection');
        let termSegment = '';
        let selectSegmentComponent = component.find('selectSegment');
        if(showSegmentFilter && (selectSegmentComponent != null || selectSegmentComponent != undefined)) {
            termSegment = selectSegmentComponent.get('v.value');
        } else {
            termSegment = 'B2C';
        }
        let resultsSegment = results, regexSegment;
        try {
            regexSegment = new RegExp(termSegment, "i");
            resultsSegment = results.filter(row=>regexSegment.test(row.XC_Segment__c));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.workTypeOptions", resultsSegment);
        
        
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowWorkType');
        let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.Id);
        });
        component.set('v.workTypeFilteredForCoverage', true);
        component.find("worktypeFilterTable").set("v.selectedRows", valuesSelected);
    },

    addSelectedWorkType : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        if(rowNowSelectedForCurrentData.length == 0) {
            return;
        } else if(rowNowSelectedForCurrentData.length == component.get('v.workTypeOptions').length) {
            component.set('v.oldSelectedRowWorkType', component.get('v.workTypeOptions'));
            component.set('v.selectedWorkType', component.get('v.workTypeOptions'));
            let showCoverages = component.get('v.selectedFilterTableCoverages');
            if(!showCoverages) {
                component.set('v.selectedFilterTableCoverages', true);
            }
            helper.filterPartnerCoverage(component, event, helper, component.get('v.workTypeOptions'));
            return;
        }
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
        let operation = component.get('v.preferredOperation');
        if(component.get('v.isTransferRemove')==true && (operation == 'Transfer' || operation == 'Remove')) {
            let showCoverages = component.get('v.selectedFilterTableCoverages');
            if(allSelected.length == 0) {
                component.set('v.selectedFilterTableCoverages', false);
                component.set('v.dataPartnerCoverageFiltered', []);
                component.set('v.dataPartnerCoverageFilteredOriginal', []);
                component.set('v.summaryCoverageComboView', 'No Coverages for ' + result.accountName);
            } else {
                if(!showCoverages) {
                    component.set('v.selectedFilterTableCoverages', true);
                }
                helper.filterPartnerCoverage(component, event, helper, allSelected);
            }
        }
    },

    addSelectedPartnerCoverage : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        if(rowNowSelectedForCurrentData.length == 0) {
            return;
        } else if(rowNowSelectedForCurrentData.length == component.get('v.dataPartnerCoverageFilteredOriginal').length) {
            component.set('v.spinnerControl', true);
            window.setTimeout($A.getCallback(function() {
                component.set('v.oldSelectedRowPartnerCoverage', component.get('v.dataPartnerCoverageFilteredOriginal'));
                component.set('v.spinnerControl', false);
            }), 2000);
        } else if(rowNowSelectedForCurrentData.length == component.get('v.dataPartnerCoverageFilteredOriginal').length-1) {
            component.set('v.spinnerControl', true);
            window.setTimeout($A.getCallback(function() {
                $A.createComponent("ui:outputText", {
                    "value" : $A.get("$Label.c.XC_CL_MassiveWt_LoadingTime")
                }, 
                function(contentComponent, status, error) {
                    if(status === "SUCCESS") {
                        let modalBody = contentComponent;
                        component.find('overlayLib').showCustomModal({
                            header: 'Warning',
                            body: modalBody, 
                            showCloseButton: true,
                            cssClass: "mymodal",
                        });
                    } else {
                        throw console.log('(-_-) Error to create console: ', JSON.parse(JSON.stringify(error)));
                    }
                    component.set('v.spinnerControl', false);
                }); 
            }), 2000);
        }else {
            let oldSelection = component.get('v.oldSelectedRowPartnerCoverage').concat(rowNowSelectedForCurrentData);
            let dataNowShown = component.get('v.dataPartnerCoverageFiltered');
            let newDataSelection = [];
            oldSelection.forEach(old => {
                if(dataNowShown.includes(old) && !rowNowSelectedForCurrentData.includes(old)) {
                    
                } else if(!newDataSelection.includes(old)) {
                    newDataSelection.push(old);
                }
            });
            component.set('v.oldSelectedRowPartnerCoverage', newDataSelection);
        }

        /*let oldSelectedRow = component.get('v.oldSelectedRowPartnerCoverage');
        let statusOption = component.get('v.dataPartnerCoverageFiltered');
        let allSelectedConcat = oldSelectedRow.concat(rowNowSelectedForCurrentData);
        let allSelectedTemp = [];
        allSelectedConcat.forEach(element => {
            let isPresentInDataToShow = false;
            let isSelectedNow = false;
            for(let k=0; k<statusOption.length; k++) {
                if(element.Id == statusOption[k].Id) {
                    isPresentInDataToShow = true;
                    break;
                }
            }
            for(let k=0; k<rowNowSelectedForCurrentData.length; k++) {
                if(element.Id == rowNowSelectedForCurrentData[k].Id) {
                    isSelectedNow = true;
                    break;
                }
            }
            if(!(isPresentInDataToShow && !isSelectedNow)) {
                allSelectedTemp.push(element);
            }
        });
        let differenceStatusOptionSelected = statusOption.filter(n => !rowNowSelectedForCurrentData.includes(n));
        allSelectedTemp = allSelectedTemp.filter(n => !differenceStatusOptionSelected.includes(n));
        let allSelected = allSelectedTemp.filter((thing, index) => {
            const _thing = JSON.stringify(thing);
            return index === allSelectedTemp.findIndex(obj => {
            return JSON.stringify(obj) === _thing;
            });
        });
        component.set('v.oldSelectedRowPartnerCoverage', allSelected);*/
    },

    resetAll : function(component, event, helper) {
        /*component.set('v.operationChoosed', false);
        helper.cleanAttributes(component, event, helper);*/
        location.reload();
    },

    changeOperation : function(component, event, helper) {
        component.set('v.valueProgressionBar', 10);
        //let originPartner = component.get('v.originPartner');
        //let disabledOriginPartner = component.get('v.disabledOriginPartner');
        component.set('v.showTypeOperationMassive', false);
        let isAdmin = component.get('v.showSegmentSelection');
        component.set('v.operationChoosed', false);
        helper.cleanAttributes(component, event, helper);
        component.set('v.showSegmentSelection', isAdmin);
        component.set('v.spinnerControl', true);
        window.setTimeout($A.getCallback(function() {
            //component.set('v.showOriginPartner', true);
            //component.set('v.originPartner', originPartner);
            //component.set('v.disabledOriginPartner', disabledOriginPartner);
            //component.set('v.filterStrikeLookupDestination', "RecordType.Name = 'Partner' AND Id != '" + originPartner + "'");
            //component.set('v.partnerChoosed', true);
            component.set('v.showTypeOperationMassive', true);
            component.set('v.spinnerControl', false);
        }), 1500);
    },

    provincesFiltered : function(component, event, helper) {
        let data = component.get("v.dataProvincesOriginal"),
            term = component.get("v.filterProvinces"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.value));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.dataProvinces", results);
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowProvince');
        let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.Id);
        });
        component.find("provincesFilterTable").set("v.selectedRows", valuesSelected);
    },

    addSelectedProvinces : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        if(rowNowSelectedForCurrentData.length == component.get('v.dataProvincesOriginal').length && component.get('v.dataProvincesOriginal').length > 1) {
            /*component.set('v.oldSelectedRowProvince', component.get('v.dataProvinces'));
            component.set('v.selectedProvinces', component.get('v.dataProvinces'));
            component.set('v.showTableZipCode', true);
            helper.filterZipCodeFromProvinces(component, event, helper);*/
            let oldSelectedProvince = component.get('v.oldSelectedRowProvince');
            component.find('provincesFilterTable').set('v.selectedRows', oldSelectedProvince);
            $A.createComponent("ui:outputText", {
                "value" : $A.get("$Label.c.XC_CL_MassiveWt_SelectManuallyProvince")
            }, 
            function(contentComponent, status, error) {
                if(status === "SUCCESS") {
                    let modalBody = contentComponent;
                    component.find('overlayLib').showCustomModal({
                        header: 'Warning',
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "mymodal",
                    });
                } else {
                    throw console.log('(-_-) Error to create console: ', JSON.parse(JSON.stringify(error)));
                }
                component.set('v.spinnerControl', false);
            }); 
            return;
        }
        let oldSelectedProvince = component.get('v.oldSelectedRowProvince');
        let allSelectedTemp = oldSelectedProvince.concat(rowNowSelectedForCurrentData);
        let statusOption = component.get('v.dataProvinces');
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
            component.find('zipCodeFilterTable').set('v.selectedRows', new Array());
            component.set('v.showTableZipCode', false);
            component.set('v.oldSelectedRowZipcode', new Array());
            component.set('v.selectedZipCode', component.get('v.listAllZipCode'));
        } else {
            component.set('v.showTableZipCode', true);
            helper.filterZipCodeFromProvinces(component, event, helper);
        }
    },

    zipCodeFiltered : function(component, event, helper) {
        let data = component.get("v.zipCodeOptionsOriginal"),
            term = component.get("v.filterZipCode"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.value));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.zipCodeOptions", results);
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowZipcode');
        let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.Id);
        });
        component.find("zipCodeFilterTable").set("v.selectedRows", valuesSelected);
    },

    zipCodeCoverageFiltered : function(component, event, helper) {
        let data = component.get("v.dataPartnerCoverageFilteredOriginal"),
            term = component.get("v.filterZipCodeCoverage"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.XC_ZipCode__c));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.dataPartnerCoverageFiltered", results);
        let oldSelectedValuesNotShown = component.get('v.oldSelectedRowPartnerCoverage');
        let dataToShownSelected = [];
        oldSelectedValuesNotShown.forEach(old => {
            if(results.includes(old) && !dataToShownSelected.includes(old)) {
                dataToShownSelected.push(old.Id);
            }
        });
        component.find("tablePartnerCoverage").set("v.selectedRows", dataToShownSelected);
        /*let valuesSelected = [];
        oldSelectedValuesNotShown.forEach(element => {
            valuesSelected.push(element.Id);
        });
        component.find("tablePartnerCoverage").set("v.selectedRows", valuesSelected);*/
    },

    addSelectedZipcode : function(component, event, helper) {
        let rowNowSelectedForCurrentData = event.getParam('selectedRows');
        if(rowNowSelectedForCurrentData.length == 0) {
            return;
        } else if(rowNowSelectedForCurrentData.length == component.get('v.zipCodeOptions').length) {
            component.set('v.oldSelectedRowZipcode', component.get('v.zipCodeOptions'));
            component.set('v.selectedZipCode', component.get('v.zipCodeOptions'));
            return;
        }
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

    handleAddOperation : function(component, event, helper) {
        helper.handleAddOperation(component, event, helper);
    },

    applyFiltersAdd : function(component, event, helper) {
        helper.applyFiltersAdd(component, event, helper);
        component.set('v.valueProgressionBar', 80);
    },

    launchOperation : function(component, event, helper) {
        let operationSelected = component.get('v.preferredOperation');
        if(operationSelected == 'Add') {
            helper.launchOperationAdd(component, event, helper);
        } else {
            helper.launchOperationOther(component, event, helper, operationSelected);
        }
        component.set('v.valueProgressionBar', 95);
    },

    loadMoreDataTableCoverageCombo : function(component, event, helper) {
        let offSetCoverageCombo = component.get('v.offSetCoverageCombo'),   
            indexOffsetCoverageCombo = component.get('v.indexOffsetCoverageCombo'), 
            offsetListDataCoverageCombo = component.get('v.offsetListDataCoverageCombo'),
            data = component.get('v.dataSummaryAdd');
        if(offsetListDataCoverageCombo && offsetListDataCoverageCombo.length != 0 && data.length < offsetListDataCoverageCombo.length) {
            for(let j=indexOffsetCoverageCombo; j<indexOffsetCoverageCombo+offSetCoverageCombo; j++) {
                data.push(offsetListDataCoverageCombo[j]);
            }
            event.getSource().set("v.isLoading", true);    
            component.set('v.indexOffsetCoverageCombo', indexOffsetCoverageCombo+offSetCoverageCombo); 
            component.set("v.dataSummaryAdd", data);    
            component.set('v.summaryCoverageComboView', '<b>'+$A.get("$Label.c.XC_CL_MassiveWT_CovShown")+'</b>'+ (indexOffsetCoverageCombo+offSetCoverageCombo).toString() +'/'+ offsetListDataCoverageCombo.length.toString()); 
            event.getSource().set("v.isLoading", false);
        } else {
            //component.find('tableCoveragesCombo').set('v.enableInfiniteLoading', false);
            component.set('v.enableInfiniteLoadingAddSummary', false);
            component.set('v.summaryCoverageComboView', '<b>'+$A.get("$Label.c.XC_CL_MassiveWT_CovShown")+'</b>'+ data.length.toString() +'/'+ data.length.toString());
        }
    },

    loadMoreDataTableCoverageRemoveTransf : function(component, event, helper) {
        let offSetCoverageCombo = component.get('v.offSetCoverageCombo'),   
            indexOffsetCoverageCombo = component.get('v.indexOffsetCoverageCombo'), 
            offsetListDataCoverageCombo = JSON.parse(JSON.stringify(component.get('v.oldSelectedRowPartnerCoverage'))),
            data = component.get('v.dataSummaryCoverages');
        if(offsetListDataCoverageCombo && offsetListDataCoverageCombo.length != 0 && data.length < offsetListDataCoverageCombo.length) {
            for(let j=indexOffsetCoverageCombo; j<indexOffsetCoverageCombo+offSetCoverageCombo; j++) {
                data.push(offsetListDataCoverageCombo[j]);
            }
            event.getSource().set("v.isLoading", true);    
            component.set("v.dataSummaryCoverages", data);   
            component.set('v.indexOffsetCoverageCombo', indexOffsetCoverageCombo+offSetCoverageCombo);
            component.set('v.summaryTransferRemoveCoverageComboView', '<b>'+$A.get("$Label.c.XC_CL_MassiveWT_CovShownPartner") + component.get('v.partnerName') + ': </b>'+ (indexOffsetCoverageCombo+offSetCoverageCombo).toString() +'/'+ offsetListDataCoverageCombo.length.toString());
            event.getSource().set("v.isLoading", false);
        } else {
            //component.find('tableCoveragesComboRemoveTransfer').set('v.enableInfiniteLoading', false);
            component.set('v.enableInfiniteLoadingRemoveTransfer', false);
            component.set('v.summaryTransferRemoveCoverageComboView', '<b>'+$A.get("$Label.c.XC_CL_MassiveWT_CovShownPartner") + component.get('v.partnerName') + ': </b>'+ data.length.toString() +'/'+ data.length.toString());
        }
    },

    applyInitialFilters : function(component, event, helper) {
        helper.applyInitialFilters(component, event, helper);
    },

    selectedPartnerCoverage : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let coverageSelected = component.get('v.oldSelectedRowPartnerCoverage');
        if(coverageSelected == null || coverageSelected == undefined || coverageSelected.length == 0 || component.find('tablePartnerCoverage').get('v.selectedRows').length == 0) {
            component.set('v.isTransferRemoveReady', false);
            component.set('v.valueProgressionBar', 80);
            component.set('v.showInfoMessageDown', false);
            let cmpRemoveTransfer = component.find('layoutItemButtonRemoveTransfer');
            if(cmpRemoveTransfer && cmpRemoveTransfer != null && cmpRemoveTransfer != undefined) {
                cmpRemoveTransfer.set('v.class', 'classCenter classTopMargin');
            }
            component.set('v.showEndButton', false);
            component.set('v.isOtherOperation', false);
            component.set('v.disableButtonLaunch', true);
            $A.createComponent("ui:outputText", {
                "value" : $A.get("$Label.c.XC_CL_MassiveWT_MissingPC")
            }, 
            function(contentComponent, status, error) {
                if(status === "SUCCESS") {
                    let modalBody = contentComponent;
                    component.find('overlayLib').showCustomModal({
                        header: 'Warning',
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "mymodal",
                    });
                } else {
                    throw console.log('(-_-) Error to create steps: ', JSON.parse(JSON.stringify(error)));
                }
                component.set('v.spinnerControl', false);
            }); 
            return;
        }
        helper.selectedPartnerCoverage(component, event, helper, coverageSelected);
        component.set('v.valueProgressionBar', 65);
    },

    // For menu operation:
    // For Add:
    changeColorMouseOverSelectAdd : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationAdd').set("v.class", "classOperationOver");
        }
    },

    changeColorMouseOutSelectAdd : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationAdd').set("v.class", "classOperation");
        }
    },

    changeColorMouseClickSelectAdd : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationAdd').set("v.class", "classOperationSuccess");
            component.set('v.partnerChoosed', false);
            component.set('v.showTypeOperationMassive', true);
            component.set('v.operationChoosed', true);
            component.set('v.preferredOperation', 'Add');
            component.set('v.valueProgressionBar', 10);
            component.set('v.showOriginPartner', true);
        }
    },

    // For Remove:
    changeColorMouseOverRemove : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationRemove').set("v.class", "classOperationOver");
        }
    },

    changeColorMouseOutRemove : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationRemove').set("v.class", "classOperation");
        }
    },

    changeColorMouseClickRemove : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationRemove').set("v.class", "classOperationSuccess");
            component.set('v.partnerChoosed', false);
            component.set('v.showTypeOperationMassive', true);
            component.set('v.operationChoosed', true);
            component.set('v.preferredOperation', 'Remove');
            component.set('v.valueProgressionBar', 10);
            component.set('v.showOriginPartner', true);
        }
    },

    // For Transfer:
    changeColorMouseOverTransfert : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationTransfert').set("v.class", "classOperationOver");
        }
    },

    changeColorMouseOutTransfert : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationTransfert').set("v.class", "classOperation");
        }
    },

    changeColorMouseClickTransfert : function(component, event, helper) { 
        let choosedOperation = component.get('v.operationChoosed');
        if(!choosedOperation) {
            component.find('cardOperationTransfert').set("v.class", "classOperationSuccess");
            component.set('v.partnerChoosed', false);
            component.set('v.showTypeOperationMassive', true);
            component.set('v.operationChoosed', true);
            component.set('v.preferredOperation', 'Transfer');
            component.set('v.valueProgressionBar', 10);
            component.set('v.showOriginPartner', true);
            component.set('v.showDestinationPartner', true);
            component.set('v.isOtherOperation', true);
        }
    },

    onChangeSegment : function(component, event, helper) { 
        helper.onChangeSegment(component, event, helper);
    },

    handleClickStatefulButtonOrigin : function(component, event, helper) {
        let originPartner = component.get('v.originPartner');
        if(originPartner != null && originPartner != undefined && originPartner != '') {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
				title: $A.get("$Label.c.XC_CL_MassiveAssignmentWorkError"),
				message: 'You have to reset all to search a new Partner',
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

    manualSelection : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let idOriginPartner = component.get('v.originPartner');
        if(idOriginPartner == '' || idOriginPartner == null || idOriginPartner == undefined) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "You have to select a Partner",
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set('v.spinnerControl', false);
        }
        else {
            let timeWaiting = 10000;
            if(component.get('v.preferredOperation') == 'Add') {
                timeWaiting = 2000;
            }
            window.setTimeout($A.getCallback(function(){
                helper.onChangePicklist(component, event, helper);
                component.set('v.disableMassiveOption', true);
                component.set('v.spinnerControl', false);
            }), timeWaiting);
        }
    },

    uploadExcel : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let idOriginPartner = component.get('v.originPartner');
        if(idOriginPartner == '' || idOriginPartner == null || idOriginPartner == undefined) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "You have to select a Partner",
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set('v.spinnerControl', false);
        }
        else {
            component.set('v.disableMassiveOption', true);
            component.set('v.spinnerControl', false);
            component.set('v.showLoadExcelOption', true);
            component.set('v.showCleanExcelFile', true);
        }
    },

    uploadFile : function(component, event, helper) {
        helper.uploadFile(component, event, helper);
    },

    handleFilesChange : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let files = component.find("file").get("v.files");
        if(!files || files == null || files == undefined || files.length == 0) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": "Error Excel file",
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

    downloadCSVtemplate : function(component, event, helper) {
        window.location.href =  window.location.origin + $A.get('$Resource.XC_SR_TemplateMassive');
    },
    
    // Lorenzo Evangelisti - lorenzo.evangelisti@webresults.it 31/05/2022 view logs [START]
    viewLogs : function(component, event, helper) { 
        helper.viewLogs(component, event, helper); 
    }
    // Lorenzo Evangelisti - lorenzo.evangelisti@webresults.it 31/05/2022 view logs [END]
})