({
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Account Name', fieldName: 'AccountName', type: 'text' },
            {label: 'Contract Number', fieldName: 'ContractNumber', type: 'text'},
            {label: 'Contract Zone', fieldName: 'XC_Zone__c', type: 'text'},
            {label: 'Contract Start Date', fieldName: 'StartDate', type: 'date'},
            {label: 'Contract End Date', fieldName: 'EndDate', type: 'date', editable:true}
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
                    var bl = JSON.parse(result.fieldName);
                    var le = JSON.parse(result.fieldName2);
                    var zone = JSON.parse(result.fieldName3);
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
                    component.set('v.businessLines', businessLines);
                    component.set('v.legaliEntities', legaliEntities);
                    component.set('v.zones', zones);
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
        map["contractNumber"] = component.get("v.contractNumber");
        map["startDate"] = component.get("v.startDate");
		map["endDateMin"] = component.get("v.endDateMin"); //CR772-elisa.caldini@accenture.com-28.03.2022																																		
		map["endDate"] = component.get("v.endDate");
        map["contractZone"] = component.get("v.contractZone");
        map["businessLine"] = component.get("v.businessLine");
        map["legalEntity"] = component.get("v.legalEntity");

        action.setParams({
            "paramsMap": map
        });

        action.setCallback(this, function(response){
            
            var name = response.getState();
            component.set("v.showSpinner", false);
            var result = response.getReturnValue();
            if (name === "SUCCESS") {
                if(result.success) {
                    var contracts = [];
                    var assets = [];
                    var c = JSON.parse(result.fieldName);
                    var a = JSON.parse(result.fieldName2);
                    for (var i = 0; i < c.length; i++) {
                        var row = c[i]; 
                        //as data columns with relationship __r can not be displayed directly in data table, so generating dynamic columns 
                        if (row.AccountId) { 
                            row.AccountName = row.Account.Name; 
                        } 
                        contracts.push(row);
                    }
                    for (var i = 0; i < a.length; i++) {
                        assets.push(a[i]);
                    }
                    component.set('v.data', contracts);
                    component.set("v.showSpinner" , false);
                    component.set('v.orderItemIds', JSON.parse(result.fieldName3));
                    component.set('v.assetIds', JSON.parse(result.fieldName2));
                    component.set('v.orderItemContractMap', JSON.parse(result.fieldName4));
                } else {
                    console.log('result error='+result.resultMessage);
                    //helper.showToast(component, event, helper, result.resultMessage, 'error');
                    helper.showToast(component, result.resultMessage, 'error');
                }
            }
        });
        $A.enqueueAction(action);
	},

    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i].Id);
        }
        component.set("v.selectedContracts", setRows);  
        if($A.util.isEmpty(setRows)) {
            component.set("v.disableAdjustment", true);
        } else {
            component.set("v.disableAdjustment", false);
        } 
    },

    handleEditCell : function (component, event) {
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);

        var map = component.get("v.draftValueMap");
        console.log(component.get("v.draftValueMap"));
        map[draftValues[0].Id] = draftValues[0].EndDate;
        component.set("v.draftValueMap", map);
        console.log(component.get("v.draftValueMap"));
    },

    handleAdjust : function (component, event) {
        //let action = component.get("c.saveDates"); 
		let action = component.get("c.saveDatesD"); //FM CR772 changed method name																		  
        var draftValueMap = component.get("v.draftValueMap");

        var map = new Object();
        map["orderItemIds"] = component.get("v.orderItemIds");
        map["assetIds"] = component.get("v.assetIds");
        map["selectedContracts"] = component.get("v.selectedContracts");
        map["orderItemContractMap"] = component.get("v.orderItemContractMap");

        action.setParams({
            "draftValueMap": draftValueMap,
            "paramsMap" : map,
			"endDateMin" : component.get("v.endDateMin"),
            "endDateMax" : component.get("v.endDate")
        });//FM CR772 added new inputs 

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