({
    init : function(component, event) {
		component.set("v.spinnerControl",true);
        this.getColumn(component,event);

        var recordId = component.get("v.recordId"); 
        var action = component.get("c.callStockAvailability");
        action.setParams({"recordId": recordId});
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                component.set("v.data", returnValue.sobjectList);
                component.set('v.spinnerControl', false);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set('v.spinnerControl', false);
                $A.get('e.force:closeQuickAction').fire();
            }
        });
    $A.enqueueAction(action);
    },

    getColumn : function(component, event){
        var column=[{label: $A.get("$Label.c.XC_CL_Name"), fieldName: 'Name', type: 'text'},
                    {label: $A.get("$Label.c.XC_CL_Description"), fieldName: 'NE__ProdName__c', type: 'String'},
                    {label: $A.get("$Label.c.XC_CL_DeliveryDate"), fieldName: 'NE__Delivery_Date__c', type: 'Date'}];
        component.set("v.columns", column);
    },

    updateSelectidRows:  function (component, event, helper) {
        component.set('v.spinnerControl', true);
        var selectedRows = component.get('v.Selected');
        var selectedRowsString = JSON.stringify(selectedRows);
        var action = component.get('c.updateDeliveryDates');
        action.setParams({"selectedStock": selectedRowsString});
        action.setCallback(this, function(response)  {
            if(response.getState() === 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.c.XC_CL_Success"),
                    type: 'success',
                    message:  $A.get("$Label.c.XC_CL_SelectedDataUpdated"),
                    mode: 'dismissible'
                });
                toastEvent.fire();
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
                component.set('v.spinnerControl', false);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.c.XC_CL_Warning"),
                    type: 'error',
                    message: $A.get('$Label.c.XC_CL_SelectedDataNotUpdated'),
                    mode: 'dismissible'
                });
                toastEvent.fire();
                $A.get('e.force:closeQuickAction').fire();
                component.set('v.spinnerControl', false);
            }
        });
        $A.enqueueAction(action);
    },

	cancel : function(component, event) {
		$A.get("e.force:closeQuickAction").fire();
	},

	sendEvent : function(component, event, helper) {
        helper.updateSelectidRows(component, event);
	},

	updateSelectedRowsHelper : function(component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
		component.set("v.Selected", selectedRows); 
		var a = component.get("v.Selected");  
		component.set("v.disabled", selectedRows.length == 0);	
	}
})