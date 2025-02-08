({
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Contract Number', fieldName: 'ContractNumber', type: 'text' },
            {label: 'Adjustment Band', fieldName: 'XC_Adjustment_Band__c', type: 'text'},
            {label: 'Contract Start Date', fieldName: 'StartDate', type: 'date'},
            {label: 'Contract End Date', fieldName: 'EndDate', type: 'date'},
            {label: 'Account Name', fieldName: 'AccountName', type: 'text'},
            {label: 'Last Adjustment Date', fieldName: 'XC_LastAdjustmentDate__c', type: 'date'}
        ]);

        let action = component.get("c.initComponent");
        action.setCallback(this, function(response){
            var name = response.getState();
            var result = response.getReturnValue();
            component.set("v.showSpinner", false);
            if (name === "SUCCESS") {
                if(result.success){
                    var businessLines = [];
                    var legaliEntities = [];
                    var zones = [];
                    var priceBands = [];
                    var bl = JSON.parse(result.fieldName);
                    var le = JSON.parse(result.fieldName2);
                    var zone = JSON.parse(result.fieldName3);
                    var priceBand = JSON.parse(result.fieldName4);
                    for (var i = 0; i < bl.length; i++) {
                        businessLines.push({
                        value: bl[i],
                        label: bl[i]
                        });
                    }
                    for (var i = 0; i < le.length; i++) {
                        legaliEntities.push({
                        value: le[i],
                        label: le[i]
                        });
                    }
                    for (var i = 0; i < zone.length; i++) {
                        zones.push({
                        value: zone[i],
                        label: zone[i]
                        });
                    }
                    for (var i = 0; i < priceBand.length; i++) {
                        priceBands.push({
                        value: priceBand[i],
                        label: priceBand[i]
                        });
                    }
                    var symbols = [];
                    symbols.push({
                        value: "+",
                        label: "+"
                    });
                    symbols.push({
                        value: "-",
                        label: "-"
                    });
                    component.set('v.businessLines', businessLines);
                    component.set('v.legaliEntities', legaliEntities);
                    component.set('v.zones', zones);
                    component.set('v.priceBands', priceBands);
                    component.set('v.symbols', symbols);
                    component.set('v.businessLine','eCity');
                    component.set('v.legalEntity','EnelSole');
                    component.set("v.showSpinner" , false);
                } else {
                    console.log('result error='+result.resultMessage);
                    //helper.showToast(component, event, helper, result.resultMessage, 'error');
                }
            }
        });
        $A.enqueueAction(action);
	},

    handleSearch : function(component, event, helper) {
        let action = component.get("c.searchContracts");
        var map = new Object();
        map["priceBand"] = component.get("v.priceBand");
        map["contractZone"] = component.get("v.contractZone");
        map["businessLine"] = component.get("v.businessLine");
        map["legalEntity"] = component.get("v.legalEntity");

        action.setParams({
            "paramsMap": map
        });

        action.setCallback(this, function(response) {
            var name = response.getState();
            var result = response.getReturnValue();
            component.set("v.showSpinner", false);
            if (name === "SUCCESS") {
                if(result.success) {
                    var contracts = [];
                    var c = JSON.parse(result.fieldName);
                    for (var i = 0; i < c.length; i++) {
                        var row = c[i]; 
                        //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                        if (row.AccountId) { 
                            row.AccountName = row.Account.Name; 
                        } 
                        contracts.push(row);
                    }
                    component.set('v.orderItemIds', JSON.parse(result.fieldName3));
                    component.set('v.data', contracts);
                    component.set('v.assetIds', JSON.parse(result.fieldName2));
                    component.set("v.showSpinner" , false);
                    component.set('v.orderItemContractMap', JSON.parse(result.fieldName4));

                } else {
                    console.log('result error='+result.resultMessage);
                    helper.showToast(component, event, helper, result.resultMessage, 'error');
                }
            }
        });
        $A.enqueueAction(action);
	},

    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++) {
            setRows.push(selectedRows[i].Id);
        }
        component.set("v.selectedContracts", setRows);
        if($A.util.isEmpty(setRows)) {
            component.set("v.disableAdjustment", true);
        } else {
            component.set("v.disableAdjustment", false);
        }
    },

    handleAdjust : function (component, event) {
        let action = component.get("c.adjustFee");

        var map = new Object();
        map["percentage"] = component.get("v.percentage");
        map["symbol"] = component.get("v.symbol");
        map["orderItemIds"] = component.get("v.orderItemIds");
        map["assetIds"] = component.get("v.assetIds");
        map["selectedContracts"] = component.get("v.selectedContracts");
        map["orderItemContractMap"] = component.get("v.orderItemContractMap");
        
        action.setParams({
            "paramsMap": map
        });

        action.setCallback(this, function(response){
            
            var name = response.getState();
            var result = response.getReturnValue();
            component.set("v.showSpinner", false);
            if (name === "SUCCESS") {
                if(result.success) { 
                    this.showToast(component, $A.get("$Label.c.XC_ContractManagement_UpdatedSuccefully"), 'success');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    if(dismissActionPanel == undefined){
                        var urlString = window.location.href;
                        var baseURL = urlString.substring(0, urlString.indexOf("/lightning"));
                        window.location = baseURL +'/lightning/o/XC_ContractAmendment__c/list?filterName=Recent';
                    } else {
                        dismissActionPanel.fire();
                    }
                } else {
                    this.showToast(component, result.resultMessage, 'error');
                }
            } else {
                this.showToast(component, a.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(component, message, type) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        if(dismissActionPanel != undefined){
             component.find('notifLib').showToast({
                "title": message,
                "message": '',
                "variant": type
            });
        } else {
            alert(message);
        }
    }
})