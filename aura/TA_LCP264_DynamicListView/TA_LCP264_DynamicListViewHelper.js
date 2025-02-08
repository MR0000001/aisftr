({
    initialize : function(component, event) {
        console.log('TA_LCP264_DynamicListView >> Helper >> initialize >> Start');

        if(component.get('v.custom').actionRow) {
            let setupDatatableWoRelated = false;
            if(component.get('v.custom').actionRow.method == 'showRelatedWorkOrders') setupDatatableWoRelated = true;

            if(setupDatatableWoRelated) {
                //TODO: Custom Labels
                component.set('v.columnsWorkOrders', [
                    {label: 'WorkOrderNumber', fieldName: 'woNumber', type: 'text'},
                    {label: 'Status', fieldName: 'statusTranslation', type: 'text'},
                    {label:  $A.get("$Label.c.TA_Fault"), fieldName: 'faultType', type: 'text'},
                    {label: 'WorkType Category', fieldName: 'workTypeCategoryTranslation', type: 'text'},
                    {label: 'Id', fieldName: 'id', type: 'text'}
                ]);
                this.getPicklistValues(component);
            }
        }     

        component.set('v.data', []);
        component.set('v.accountNameLike', null);

        let getListViews = component.get('c.getListViews');
        getListViews.setParams({
            'objectName' : component.get('v.custom').objectName
        });

        getListViews.setCallback(this, function(response) {
            console.log('TA_LCP264_DynamicListView >> Helper >> getListViewsCallback >> Start');
            
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() && response.getReturnValue().includes('exception')) {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getReturnValue()));
                } else {
                    component.set('v.listViews', JSON.parse(response.getReturnValue()));
                }        

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            component.set('v.showMainView', true);
            this.fireToggleSpinnerEvent(component, false);

            console.log('TA_LCP264_DynamicListView >> Helper >> getListViewsCallback >> End');
        });
        this.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(getListViews);

        console.log('TA_LCP264_DynamicListView >> Helper >> initialize >> End');
    },

    getPicklistValues : function(component) {
        console.log('TA_LCP264_DynamicListView >> Helper >> getPicklistValues >> Start');
        let getPicklistValues = component.get('c.getPicklistValues');
        getPicklistValues.setCallback(this, function(response) {
            console.log('TA_LCP264_DynamicListView >> Helper >> getPicklistValuesCallback >> Start');
            
            if(response.getState() == "SUCCESS") {
                let result = JSON.parse(response.getReturnValue());
                if(result) {
                    component.set('v.statusPickValues', result.statusPickValues);
                    component.set('v.woTypePickValues', result.woTypePickValues);
                    component.set('v.faultTypePickValues', result.faultTypePickValues);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            component.set('v.showMainView', true);
            this.fireToggleSpinnerEvent(component, false);

            console.log('TA_LCP264_DynamicListView >> Helper >> getPicklistValuesCallback >> End');
        });
        this.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(getPicklistValues);
        console.log('TA_LCP264_DynamicListView >> Helper >> getPicklistValues >> End');
    },

    changeView : function(component) {
        console.log('TA_LCP264_DynamicListView >> Helper >> changeView >> Start');
        
        let getLitViewRecords = component.get('c.getLitViewRecords');
        getLitViewRecords.setParams({
            'filterId' : component.get('v.selectedListViewId'),
            'objectName' : component.get('v.custom').objectName
        });

        getLitViewRecords.setCallback(this, function(response) {
            console.log('TA_LCP264_DynamicListView >> Helper >> getLitViewRecordsCallback >> Start');
            
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue()) {
                    component.set('v.accountNameLike', null);
                    if(response.getReturnValue().includes('exception')) {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", JSON.stringify(response.getReturnValue()));
                    } else {
                        let parsedResponse = JSON.parse(response.getReturnValue());
                        let startColumns = parsedResponse.columns;
                        let startDatas = parsedResponse.records;

                        let startMainFields = component.get('v.custom').mainFields ? component.get('v.custom').mainFields.split(',') : [];
                        let mainFields = [];

                        startMainFields.forEach(mainField => {
                            mainFields.push(mainField.trim());
                        });

                        let finalColumns = [];
                        let finalColumnsFieldNames = [];
                        let finalData = [];

                        startColumns.forEach(startCol => {
                            if(mainFields.includes(startCol['fieldNameOrPath'])) {
                                finalColumns.push( { label: startCol['label'], fieldName: startCol['fieldNameOrPath'], type: 'text' });
                                finalColumnsFieldNames.push(startCol['fieldNameOrPath']);
                            }
                        });

                        let availableColumns =  component.get('v.custom').maxNumberOfFields - finalColumns.length;
                        while(availableColumns > 0) {
                            for(let i in startColumns) {
                                let column = startColumns[i];
                                if(!finalColumnsFieldNames.includes(column['fieldNameOrPath'])) {
                                    finalColumns.push( { label: column['label'], fieldName: column['fieldNameOrPath'], type: 'text' });
                                    finalColumnsFieldNames.push(column['fieldNameOrPath']);
                                    break;
                                }
                            }
                            availableColumns--;
                        }

                        component.set('v.columns', finalColumns);

                        startDatas.forEach(startData => {
                            let loopData = {};
                            startData.columns.forEach(startCol => {
                                loopData[startCol.fieldNameOrPath] = startCol.value;
                            });
                            finalData.push(loopData);
                        });
                        component.set('v.data', finalData);

                        if(component.get('v.custom').actionRow) {
                            let rowAction = component.get('v.custom').actionRow;
                            let tmpColumns = component.get('v.columns');
                            tmpColumns.unshift({
                                label: $A.get("$Label.c." + rowAction.label), 
                                type: 'button', 
                                initialWidth: 135,
                                typeAttributes: { label: $A.get("$Label.c.TA_List"), name: rowAction.method }
                            });
                            component.set('v.columns', tmpColumns);
                        }
                    }       
                }       

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            this.fireToggleSpinnerEvent(component, false);

            console.log('TA_LCP264_DynamicListView >> Helper >> getLitViewRecordsCallback >> End');
        });
        this.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(getLitViewRecords);

        console.log('TA_LCP264_DynamicListView >> Helper >> changeView >> End');
    },

    rowSelection: function(component, selectedRecord, sourceId) {
        this.fireToggleSpinnerEvent(component, true);
        window.location.href = window.location + (sourceId.includes('data-table-wo') ? ('workorder/' + selectedRecord.id) : (component.get('v.custom').objectName.toLowerCase() + '/' + selectedRecord.Id)) + '/detail';
    },

    rowAction : function(component, actionName, actionRow) {
        if(actionName == 'showRelatedWorkOrders') {
            component.set('v.accountName', actionRow.Name);
            this.getRelatedWorkOrders(component, actionRow.Id);
        }
    },

    getRelatedWorkOrders : function(component, accountId) {
        console.log('TA_LCP264_DynamicListView >> Helper >> getRelatedWorkOrders >> Start');
        let _helper = this;
        let getRelatedWorkOrders = component.get('c.getRelatedWorkOrders');
        getRelatedWorkOrders.setParam('accountId', accountId);
        getRelatedWorkOrders.setCallback(this, function(response) {
            console.log('TA_LCP264_DynamicListView >> Helper >> getRelatedWorkOrdersCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let result = JSON.parse(response.getReturnValue()) 
                if(result && !result.includes('exception')) {
                    component.set('v.dataWorkOrders', result);
                    _helper.filterRelatedWorkOrders(component);
                    component.set('v.showMainView', false);
                    component.set('v.showRelatedWorkOrders', true);
                } else {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", result);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            this.fireToggleSpinnerEvent(component, false);

            console.log('TA_LCP264_DynamicListView >> Helper >> getRelatedWorkOrdersCallback >> End');
        });
        this.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(getRelatedWorkOrders);
        console.log('TA_LCP264_DynamicListView >> Helper >> getRelatedWorkOrders >> End');
    },

    filterRelatedWorkOrders : function(component) {
        let selectedWoType = component.get('v.selectedWoType');
        let selectedWoStatus = component.get('v.selectedWoStatus');
        let selectedFaultType = component.get('v.selectedFaultType');
        let dataWorkOrders = component.get('v.dataWorkOrders');

        if(selectedWoType == 'All' && selectedWoStatus == 'All' && selectedFaultType == 'All') component.set('v.filteredDataWorkOrders', dataWorkOrders);
        else {
            let filteredWorkOrders = [];
            for(let i in dataWorkOrders) {
                let dataWorkOrder = dataWorkOrders[i];
                if( (dataWorkOrder.status == selectedWoStatus || selectedWoStatus == 'All') && 
                    (dataWorkOrder.workTypeCategory == selectedWoType || selectedWoType == 'All') &&
                    (dataWorkOrder.faultType == selectedFaultType || selectedFaultType == 'All')
                ) filteredWorkOrders.push(dataWorkOrder);
            }
            component.set('v.filteredDataWorkOrders', filteredWorkOrders);
        }
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP264_DynamicListView >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP264_DynamicListView",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP264_DynamicListView >> Helper >> fireToggleSpinnerEvent >> End');
    },

    searchAccount : function(component) {
        console.log('TA_LCP264_DynamicListView >> Helper >> searchAccount >> Start');

        let searchAccount = component.get('c.searchAccount');
        searchAccount.setParam('accountNameLike', component.get('v.accountNameLike'));
        searchAccount.setCallback(this, function(response) {
            console.log('TA_LCP264_DynamicListView >> Helper >> searchAccountCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let result = JSON.parse(response.getReturnValue());
                component.set('v.columns', [
                    { label: $A.get("$Label.c.TA_AccountName"), fieldName: 'Name', type: 'text' },
                    { label: 'Id', fieldName: 'Id', type: 'text' }
                ]);

                let newData = [];
                result.map(res => newData.push({'Name' : res.Name, 'Id' : res.Id}));
                component.set('v.data', newData);

                if(component.get('v.custom').actionRow) {
                    let rowAction = component.get('v.custom').actionRow;
                    let tmpColumns = component.get('v.columns');
                    tmpColumns.unshift({
                        label: $A.get("$Label.c." + rowAction.label), 
                        type: 'button', 
                        initialWidth: 135,
                        typeAttributes: { label: $A.get("$Label.c.TA_List"), name: rowAction.method }
                    });
                    component.set('v.columns', tmpColumns);
                }
                component.set('v.selectedListViewId', null);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            this.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP264_DynamicListView >> Helper >> searchAccountCallback >> End');
        });
        this.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(searchAccount);
        console.log('TA_LCP264_DynamicListView >> Helper >> searchAccount >> End');
    }
})