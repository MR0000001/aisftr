/**
    @description giic_MergePurchaseOrderHelper - Helper JavaScript
    @date Mod 07/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
*/

({  
    
    paginate : function(component) {
        let wlist = component.get("v.pMasterWrapperlist");
        component.set("v.pWrapperlist", wlist);
        if(wlist.length > component.get("v.pageSize")){
            let subWrapperlist = [];
            for(let i=0; i<component.get("v.pageSize"); i++){
                subWrapperlist.push(wlist[i]);
            }
            component.set("v.pWrapperlist", subWrapperlist);
        }
    },
    
    getDraftPOdata : function(component) {
        component.set('v.spinnerControl', true);
        var wareHouses;
        var suppliername;
        var action = component.get("c.fetchPOdata");
        action.setParams({
            suppKey: suppliername,
            whkey: wareHouses,
            clusters: component.get('v.filterCluster')
        });
        action.setCallback(this, function(resp) {
            var state=resp.getState();
            if(state === "SUCCESS"){         
                let resultValues = resp.getReturnValue().lstPORecords;  
                let mapCodeRows = resp.getReturnValue().mapCodeRows;  
                component.set('v.mapRowNumber', mapCodeRows);
                let mapColors = new Map();
                resultValues.forEach(element => {
                    let codeCluster = element.codeCluster;
                    if(mapColors.has(codeCluster)) {
                        element.cluster = 'background-color: ' + mapColors.get(codeCluster) + ' !important;';
                    } else {
                        let newColor = '#'+(0x1000000+Math.random()*0xffffff).toString(16).substr(1,6);
                        mapColors.set(codeCluster, newColor);
                        element.cluster = 'background-color: ' + newColor + ' !important;';
                    }
                }); 
                component.set("v.pMasterWrapperlist", resultValues);
                component.set("v.masterlistSize", component.get("v.pMasterWrapperlist").length);
                component.set("v.startPosn",0);
                var listWrap=component.get("v.pMasterWrapperlist");
                component.set("v.pageSize",listWrap[0].pageSize);
                component.set("v.endPosn",component.get("v.pageSize")-1);
                this.paginate(component);
            }
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);
    },
    
    searchDraftPOdata: function(component) {
        var wareHouses = component.get("v.selItem.text");
        var suppliername = component.get("v.suppliername.text");
        if ($A.util.isEmpty(suppliername) && $A.util.isEmpty(wareHouses)) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: "sticky",
                title: "Error!",
                message: "Please Enter one of the Search Criteria",
                type: "error"
            });
            toastEvent.fire();
            $A.get("e.force:refreshView").fire();
        } 
        else {
            component.set('v.spinnerControl', true);
            var action = component.get("c.fetchPOdata");
            action.setParams({
                suppKey: suppliername,
                whkey: wareHouses,
                clusters: component.get('v.filterCluster')
            });
            action.setCallback(this, function(resp) {
                var state = resp.getState();
                if (state == "SUCCESS") {
                    var result = resp.getReturnValue().lstPORecords;    
                    let mapCodeRows = resp.getReturnValue().mapCodeRows;  
                    component.set('v.mapRowNumber', mapCodeRows);
                    let mapColors = new Map();
                    result.forEach(element => {
                        let codeCluster = element.codeCluster;
                        if(mapColors.has(codeCluster)) {
                            element.cluster = 'background-color: ' + mapColors.get(codeCluster) + ' !important;';
                        } else {
                            let newColor = '#'+(0x1000000+Math.random()*0xffffff).toString(16).substr(1,6);
                            mapColors.set(codeCluster, newColor);
                            element.cluster = 'background-color: ' + newColor + ' !important;';
                        }
                    }); 

                    if (!$A.util.isEmpty(result) && !$A.util.isUndefined(result)) {
                        component.set("v.pMasterWrapperlist", result);
                        component.set("v.masterlistSize", component.get("v.pMasterWrapperlist").length);
                        component.set("v.startPosn",0);
                        component.set("v.endPosn",component.get("v.pageSize")-1);
                        this.paginate(component);
                        component.set("v.isButtonActive", true);
                    } else {
                        component.set("v.pWrapperlist", result);
                        component.set("v.paginationList", null);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: "sticky",
                            title: "Error!",
                            message: "No Records Found",
                            type: "error"
                        });
                        toastEvent.fire();
                        var delay=2000; //2 seconds
                        setTimeout(function() {
                            $A.get("e.force:refreshView").fire();
                        }, delay);
                    }
                } else if (state == "ERROR") {
                    alert("Error in calling server side action");
                }
                component.set('v.spinnerControl', false);
            });
            //adds the server-side action to the queue
            $A.enqueueAction(action);
        }
    },
    
    mergePOdata: function(component,event,helper) {
        component.set('v.spinnerControl', true);
        // var draftpo = component.get("v.pWrapperlist");
        var draftpo = component.get("v.pMasterWrapperlist");
        var selectedrecords = [];
        for(var i=0;i<draftpo.length;i++) {
            if(draftpo[i].isSelected) {
                selectedrecords.push(draftpo[i]);
            }
        }	        
        if(!$A.util.isEmpty(selectedrecords) && !$A.util.isUndefined(selectedrecords)) {
            if(selectedrecords.length <2) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: "sticky",
                    title: "Error!",
                    message: 'Please Select at least 2 records',
                    type: "error"
                });
                toastEvent.fire();  
                component.set('v.spinnerControl', false);
            } else if (selectedrecords.length > 200) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: "sticky",
                    title: "Error!",
                    message: 'Records selected should be less than 200',
                    type: "error"
                });
                toastEvent.fire();
                component.set('v.spinnerControl', false);
            } else {
                var action = component.get("c.mergePOData");
                var mergeRecords = JSON.stringify(selectedrecords);
                action.setParams({
                    mergeRecords: mergeRecords
                });
                action.setCallback(this, function(a) {
                    //get the response state
                    var state = a.getState();
                    let retValue = a.getReturnValue();
                    if(state === "SUCCESS" && retValue.success) {
                        var Id = retValue.recordId;
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": Id
                         });
                        navEvt.fire();
                        //$A.get("e.force:refreshView").fire();
                    } else if (state == "ERROR") {
                        var errors = a.getError();
                        var fmsg = errors[0].message;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: "sticky",
                            title: "Error!",
                            message: fmsg,
                            type: "error"
                        });
                        toastEvent.fire();
                        var delay=2000; //2 seconds
                        setTimeout(function() {
                            $A.get("e.force:refreshView").fire();
                        }, delay);
                    } else {
                        helper.showToast(component, event, helper, 'Warning: '+retValue.resultMessage, 'error' );
                    }
                    component.set('v.spinnerControl', false);
                });
                //adds the server-side action to the queue
                $A.enqueueAction(action);
            }
        } else {   
            component.set("v.isButtonActive", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: "sticky",
                title: "Error!",
                message: 'Please select records for Merge',
                type: "error"
            });
            toastEvent.fire(); 
            component.set('v.spinnerControl', false);
        }
    },     

    next: function(component) {
        var wlist = component.get("v.pMasterWrapperlist");
        var endPosn = component.get("v.endPosn");
        var startPosn = component.get("v.startPosn");
        var subWrapperlist = [];
        for(var i=0; i<component.get("v.pageSize"); i++){
            endPosn++;
            if(wlist.length > endPosn) {
                subWrapperlist.push(wlist[endPosn]);
            }
            startPosn++;
        }
        component.set("v.pWrapperlist",subWrapperlist);
        component.set("v.startPosn",startPosn);
        component.set("v.endPosn",endPosn);
    },

    previous: function(component) {
        var wlist = component.get("v.pMasterWrapperlist");
        var startPosn = component.get("v.startPosn");
        var endPosn = component.get("v.endPosn");
        var subWrapperlist = [];
        var pageSize = component.get("v.pageSize");
        startPosn -= pageSize;
        if(startPosn > -1){
            for(var i=0; i<pageSize; i++){
                if(startPosn > -1){
                    subWrapperlist.push(wlist[startPosn]);
                    startPosn++;
                    endPosn--;
                }
            }
            startPosn -= pageSize;
            component.set("v.pWrapperlist",subWrapperlist);
            component.set("v.startPosn",startPosn);
            component.set("v.endPosn",endPosn);
        }
    },

    First: function(component) {
        var wlist = component.get("v.pMasterWrapperlist");
        var startPosn = component.get("v.startPosn");
        var endPosn = component.get("v.endPosn");
        var subWrapperlist = [];
        var pageSize = component.get("v.pageSize");
        startPosn=0;
        if(startPosn > -1) {
            for(var i=0; i<pageSize; i++){
                if(startPosn > -1){
                    subWrapperlist.push(wlist[startPosn]);
                    startPosn++;
                }
            }
            startPosn=0;
            endPosn=pageSize-1;
            component.set("v.pWrapperlist",subWrapperlist);
            component.set("v.startPosn",startPosn);
            component.set("v.endPosn",endPosn);
        }
    },

    Last: function(component) {
        var wlist = component.get("v.pMasterWrapperlist");
        var startPosn = component.get("v.startPosn");
        var endPosn = component.get("v.endPosn");
        var subWrapperlist = [];
        var pageSize = component.get("v.pageSize");
        var l=wlist.length;
        var po=l-(l%pageSize);
        if((l%pageSize)!=0) {
            startPosn=po;
        } else{
            startPosn=po-pageSize;
        }
        endPosn=l-1;
        if(startPosn <=endPosn ){
            for(var i=startPosn; i<=endPosn; i++){
                subWrapperlist.push(wlist[i]);
            }
            component.set("v.pWrapperlist",subWrapperlist);
            component.set("v.startPosn",startPosn);
            component.set("v.endPosn",endPosn);
        }
    },
    
    sortMethod: function(component,helper,field,Wrapfield) {
        var sortAsc = component.get("v.sortAsc");
        var sortField = component.get("v.sortField");
        var oRes = component.get("v.pMasterWrapperlist");
        component.set("v.selectedTabsoft", field);
        component.set('v.sortField',field);   
        var currentDir = component.get("v.arrowDirection");        
        if (currentDir == 'arrowdown') {            
            component.set("v.arrowDirection", 'arrowup');            
            component.set("v.sortAsc", false);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.sortAsc", true);
        }         
        sortAsc = sortField != field || !sortAsc;            
        oRes.sort(function(a,b) {      
            if(field.includes("__r")) {
                var forSort = $A.util.isUndefined(a[Wrapfield]["gii__ShipTo__r"]["Name"]) || $A.util.isEmpty(a[Wrapfield]["gii__ShipTo__r"]["Name"]) ? '' : a[Wrapfield]["gii__ShipTo__r"]["Name"];
                var tosort = $A.util.isUndefined(b[Wrapfield]["gii__ShipTo__r"]["Name"]) || $A.util.isEmpty(b[Wrapfield]["gii__ShipTo__r"]["Name"]) ? '' : b[Wrapfield]["gii__ShipTo__r"]["Name"];            
            }      
            else {
                var forSort = $A.util.isUndefined(a[Wrapfield][field]) || $A.util.isEmpty(a[Wrapfield][field]) ? '' : a[Wrapfield][field];
                var tosort = $A.util.isUndefined(b[Wrapfield][field]) || $A.util.isEmpty(b[Wrapfield][field]) ? '' : b[Wrapfield][field];              
            }   
            var t1 = forSort == tosort ,
                t2 = (!forSort && tosort) || (forSort < tosort);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.pMasterWrapperlist", oRes);
        var startPosn = component.get("v.startPosn");
        var endPosn = component.get("v.endPosn");
        var pageSize = component.get("v.pageSize");
        startPosn=0;
        endPosn=pageSize-1;
        component.set("v.startPosn", startPosn);
        component.set("v.endPosn", endPosn);
        this.paginate(component);
    },
    
    refreshPOdata: function(component) {
        $A.get("e.force:refreshView").fire();
        //adds the server-side action to the queue
        //$A.enqueueAction(action);
    },
    
    SelectAll: function(component) {  
        component.set('v.spinnerControl', true);
        let tabledataExisting = component.get("v.pMasterWrapperlist");
        if(component.find("selectall").get("v.checked") == true) {
            tabledataExisting.forEach(function(element){
                element.isSelected = true;
            });
        }
        else{
            tabledataExisting.forEach(function(element){
                element.isSelected = false;
            });
        }
        component.set("v.pWrapperlist", tabledataExisting);
        component.set("v.isButtonActive", true);
        component.set("v.masterlistSize", component.get("v.pWrapperlist").length);
        component.set("v.startPosn",0);
        component.set("v.endPosn",component.get("v.pageSize")-1);
        this.paginate(component);
        component.set('v.isButtonActiveMergeCluster', false);
        component.set('v.showConfirmMerge', false);
        component.set('v.countClusterElements', '--');
        component.set('v.listClusterSelected', new Array());
        component.set('v.spinnerControl', false);
    },

    navigatetoListView : function (component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "gii__PurchaseOrder__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "mode": "sticky",
            "title": message,
            "message": '',
            "variant": type
        });
    },
    
    handleShowNotice : function(component, event, helper, message) {
        component.find('notifLib').showNotice({
            "variant": "error",
            "header": message,
            "message": ""
        });
    },

    mergeCluster: function(component, event, helper){
        component.set('v.showConfirmMerge', true);
    },

    onFilterCluster: function(component, event, helper){
        component.set('v.showConfirmMerge', false);
        component.set('v.isButtonActiveMergeCluster', false);
        component.set('v.isButtonActive', false);
        component.set('v.countClusterElements', '--');
        component.set('v.listClusterSelected', new Array());
        let buttonPressed = 'All';//event.getSource().getLocalId();
        let buttonAll = component.find('canSelectAll');
        let buttonWarehouse = component.find('canSelectWarehouse');
        let buttonSupplier = component.find('canSelectSupplier');
        let buttonPricebook = component.find('canSelectPricebook');
        let existingFilters = component.get('v.filterCluster');
        let newFilter = '';
        switch (buttonPressed) {
            case 'canSelectWarehouse':
                if(existingFilters == 'All' || existingFilters == '' || existingFilters == null || existingFilters == undefined) {
                    $A.util.removeClass(buttonAll, 'buttonSelect');
                    $A.util.addClass(buttonAll, 'buttonDeselect');
                    $A.util.removeClass(buttonWarehouse, 'buttonDeselect');
                    $A.util.addClass(buttonWarehouse, 'buttonSelect');
                    component.set('v.filterCluster', 'wh');
                    break;
                }
                newFilter = existingFilters+',wh';
                if(newFilter.split(',').length==3) {
                    $A.util.removeClass(buttonAll, 'buttonDeselect');
                    $A.util.addClass(buttonAll, 'buttonSelect');
                    $A.util.removeClass(buttonWarehouse, 'buttonSelect');
                    $A.util.addClass(buttonWarehouse, 'buttonDeselect');
                    $A.util.removeClass(buttonSupplier, 'buttonSelect');
                    $A.util.addClass(buttonSupplier, 'buttonDeselect');
                    $A.util.removeClass(buttonPricebook, 'buttonSelect');
                    $A.util.addClass(buttonPricebook, 'buttonDeselect');
                    component.set('v.filterCluster', 'All');
                } else {
                    $A.util.removeClass(buttonAll, 'buttonSelect');
                    $A.util.addClass(buttonAll, 'buttonDeselect');
                    $A.util.removeClass(buttonWarehouse, 'buttonDeselect');
                    $A.util.addClass(buttonWarehouse, 'buttonSelect');
                    component.set('v.filterCluster', newFilter);
                }
                break;
            case 'canSelectSupplier':
                if(existingFilters == 'All' || existingFilters == '' || existingFilters == null || existingFilters == undefined) {
                    $A.util.removeClass(buttonAll, 'buttonSelect');
                    $A.util.addClass(buttonAll, 'buttonDeselect');
                    $A.util.removeClass(buttonSupplier, 'buttonDeselect');
                    $A.util.addClass(buttonSupplier, 'buttonSelect');
                    component.set('v.filterCluster', 'supplier');
                    break;
                } 
                newFilter = existingFilters+',supplier';
                if(newFilter.split(',').length==3) {
                    $A.util.removeClass(buttonAll, 'buttonDeselect');
                    $A.util.addClass(buttonAll, 'buttonSelect');
                    $A.util.removeClass(buttonWarehouse, 'buttonSelect');
                    $A.util.addClass(buttonWarehouse, 'buttonDeselect');
                    $A.util.removeClass(buttonSupplier, 'buttonSelect');
                    $A.util.addClass(buttonSupplier, 'buttonDeselect');
                    $A.util.removeClass(buttonPricebook, 'buttonSelect');
                    $A.util.addClass(buttonPricebook, 'buttonDeselect');
                    component.set('v.filterCluster', 'All');
                } else {
                    $A.util.removeClass(buttonAll, 'buttonSelect');
                    $A.util.addClass(buttonAll, 'buttonDeselect');
                    $A.util.removeClass(buttonSupplier, 'buttonDeselect');
                    $A.util.addClass(buttonSupplier, 'buttonSelect');
                    component.set('v.filterCluster', newFilter);
                }
                break;
            case 'canSelectPricebook':
                if(existingFilters == 'All' || existingFilters == '' || existingFilters == null || existingFilters == undefined) {
                    component.set('v.filterCluster', 'pricebook');
                    $A.util.removeClass(buttonAll, 'buttonSelect');
                    $A.util.addClass(buttonAll, 'buttonDeselect');
                    $A.util.removeClass(buttonPricebook, 'buttonDeselect');
                    $A.util.addClass(buttonPricebook, 'buttonSelect');
                    break;
                } 
                newFilter = existingFilters+',pricebook';
                if(newFilter.split(',').length==3) {
                    $A.util.removeClass(buttonAll, 'buttonDeselect');
                    $A.util.addClass(buttonAll, 'buttonSelect');
                    $A.util.removeClass(buttonWarehouse, 'buttonSelect');
                    $A.util.addClass(buttonWarehouse, 'buttonDeselect');
                    $A.util.removeClass(buttonSupplier, 'buttonSelect');
                    $A.util.addClass(buttonSupplier, 'buttonDeselect');
                    $A.util.removeClass(buttonPricebook, 'buttonSelect');
                    $A.util.addClass(buttonPricebook, 'buttonDeselect');
                    component.set('v.filterCluster', 'All');
                } else {
                    $A.util.removeClass(buttonAll, 'buttonSelect');
                    $A.util.addClass(buttonAll, 'buttonDeselect');
                    $A.util.removeClass(buttonPricebook, 'buttonDeselect');
                    $A.util.addClass(buttonPricebook, 'buttonSelect');
                    component.set('v.filterCluster', newFilter);
                }
                break;
            case 'canSelectAll':
                $A.util.removeClass(buttonAll, 'buttonDeselect');
                $A.util.addClass(buttonAll, 'buttonSelect');
                $A.util.removeClass(buttonWarehouse, 'buttonSelect');
                $A.util.addClass(buttonWarehouse, 'buttonDeselect');
                $A.util.removeClass(buttonSupplier, 'buttonSelect');
                $A.util.addClass(buttonSupplier, 'buttonDeselect');
                $A.util.removeClass(buttonPricebook, 'buttonSelect');
                $A.util.addClass(buttonPricebook, 'buttonDeselect');
                component.set('v.filterCluster', 'All');
                break;
            default:
                break;
        }
    },

    onCheckRow: function(component, event, helper){
        let listRowsSeleted = component.get('v.listClusterSelected');
        var selected = event.getSource().get("v.checked"); 
        var rowSelected = event.getSource().get("v.name"); 
        if(!selected) {
            if(listRowsSeleted.includes(rowSelected)) {
                const index = listRowsSeleted.indexOf(rowSelected);
                if(index > -1) {
                    listRowsSeleted.splice(index, 1);
                }
            }
        } else {
            listRowsSeleted.push(rowSelected);
        }
        component.set('v.listClusterSelected', listRowsSeleted);

        // For Merge Selected:
        if(listRowsSeleted.length > 0) {
            component.set("v.isButtonActive", true);
        } else {
            component.set("v.isButtonActive", false);
        }

        // For Merge Cluster
        if(listRowsSeleted.length == 0 || !listRowsSeleted.every((val, i, arr) => val === arr[0])) {
            component.set('v.isButtonActiveMergeCluster', false);
            component.set('v.countClusterElements', '--');
            component.set('v.showConfirmMerge', false);
        }
        else {
            component.set('v.isButtonActiveMergeCluster', true);
            let mapCountRows = component.get('v.mapRowNumber');
            if(mapCountRows.hasOwnProperty(listRowsSeleted[0])) {
                component.set('v.countClusterElements', mapCountRows[listRowsSeleted[0]].toString());
            }
        } 
    },

    goMergeOperation: function(component,event,helper){
        component.set('v.spinnerControl', true);
        let listElements = component.get('v.listClusterSelected');
        let mapRowNumber = component.get('v.mapRowNumber');
        if(!mapRowNumber.hasOwnProperty(listElements[0]) || mapRowNumber[listElements[0]] == 1 || mapRowNumber[listElements[0]] > 200) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: "sticky",
                title: "Error!",
                message: "You can merge clusters with more than one element and less than 200",
                type: "error"
            });
            toastEvent.fire();
            component.set('v.spinnerControl', false);
            return;
        }

        let draftpo = component.get("v.pMasterWrapperlist");
        let selectedrecords = [];
        for(let i=0; i<draftpo.length; i++) {
            if(draftpo[i].codeCluster == listElements[0]) {
                selectedrecords.push(draftpo[i]);
            }
            if(mapRowNumber[listElements[0]] == selectedrecords.length) {
                break;
            }
        }	        
        if(!$A.util.isEmpty(selectedrecords) && !$A.util.isUndefined(selectedrecords)) {
            let action = component.get("c.mergePOData");
            let mergeRecords = JSON.stringify(selectedrecords);
            action.setParams({
                mergeRecords: mergeRecords
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                let retValue = a.getReturnValue();
                if(state === "SUCCESS" && retValue.success) {
                    let Id = retValue.recordId;
                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": Id
                        });
                    navEvt.fire();
                } else if (state == "ERROR") {
                    let errors = a.getError();
                    let fmsg = errors[0].message;
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: "sticky",
                        title: "Error!",
                        message: fmsg,
                        type: "error"
                    });
                    toastEvent.fire();
                } else {
                    helper.showToast(component, event, helper, 'Warning: '+retValue.resultMessage, 'error' );
                }
                component.set('v.spinnerControl', false);
            });
            $A.enqueueAction(action);
        } else {   
            component.set("v.isButtonActive", false);
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: "sticky",
                title: "Error!",
                message: 'Please select records for Merge',
                type: "error"
            });
            toastEvent.fire(); 
            component.set('v.spinnerControl', false);
        }
    },
    
})