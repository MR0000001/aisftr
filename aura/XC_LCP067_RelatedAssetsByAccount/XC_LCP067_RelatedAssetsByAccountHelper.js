({
	doInit: function (component, event, helper) {
		let recordId = component.get("v.recordId");
		component.set('v.product', $A.get('$Label.c.XC_CL_AssetType_Product'));
		component.set('v.service', $A.get('$Label.c.XC_CL_AssetType_Service'));
		component.set('v.coverage', $A.get('$Label.c.XC_CL_AssetType_Coverage'));

		//vb Lista asset Tipos
		/*var actionAsset = component.get('c.getAssetCoverage');
		console.log("recordId " + recordId);
		actionAsset.setParams({
			recordId: recordId
		});
		actionAsset.setCallback(this, function (response) {
			var state = response.getState();
			if (state = "SUCCESS") {
				console.log('asset callback' + response.getReturnValue());
				component.set('v.data', response.getReturnValue());
			}else{
				console.log("error " );
			}
		});
		$A.enqueueAction(actionAsset);

		helper.setGridColumns(component,'v.columns');//MCutillo 2019-01-18*/
		
		//vb Lista asset Productos 
		/*var actionAsset = component.get('c.getAssetProduct');
		console.log("recordId " + recordId);
		actionAsset.setParams({
			recordId: recordId
		});
		actionAsset.setCallback(this, function (response) {
			var state = response.getState();
			if (state = "SUCCESS") {
				console.log('asset2 callback' + response.getReturnValue());
				component.set('v.data2', response.getReturnValue());
			} else {
				console.log("error ");
			}
		});
		$A.enqueueAction(actionAsset);*/

		helper.setGridColumns(component,'v.columns2');//MCutillo 2019-01-18
	},
    
    //MCutillo 2019-01-18
    setGridColumns: function (component, attributeName) {
        let columns = [	{ label: $A.get('$Label.c.XC_CL_Name'), fieldName: 'link', type: 'url', typeAttributes: { target: '_self', label: { fieldName: 'name' } }, fixedWidth: 350},
						{ label: $A.get('$Label.c.XC_CL_Type'), fieldName: 'catalogName', type: 'String' },
						{ label: $A.get('$Label.c.XC_CL_State'), fieldName: 'status', type: 'String' },
						{ label: $A.get('$Label.c.XC_CL_Installation_Date'), fieldName: 'installDate', type: 'Date' },
						{ label: $A.get('$Label.c.XC_CL_ContractLineItem'), fieldName: 'contractLineItemLink', type: 'url', typeAttributes: { target: '_self', label: { fieldName: 'contractLineItemName' } } },
						{ label: $A.get('$Label.c.XC_CL_BundleConfiguration'), fieldName: 'bundleConfigurationLink', type: 'url', typeAttributes: { label: { target: '_self', fieldName: 'bundleConfigurationName' } } } ];

		component.set(attributeName, columns);
    },
})