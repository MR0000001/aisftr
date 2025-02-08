({
	doInit : function(component, event, helper) {
		helper.setGridColumns(component, 'v.gridColumns');
		helper.setGridData(component, 'v.gridData');
	},
    
    setGridColumns: function (component, attributeName) {
        let columns = [	
                        { label: $A.get('$Label.c.XC_CL_Node'), fieldName: 'nodeName', type: 'String', initialWidth: 150},
                        { label: $A.get('$Label.c.XC_CL_Name'), fieldName: 'link', type: 'url', 
                        typeAttributes: { target: '_self', label: { fieldName: 'name' } }, initialWidth: 250},
						// label: $A.get('$Label.c.XC_CL_Type'), fieldName: 'catalogName', type: 'String' },
						//{ label: $A.get('$Label.c.XC_CL_Type'), fieldName: 'productSubtype', type: 'String', initialWidth: 100 },
						{ label: $A.get('$Label.c.XC_CL_State'), fieldName: 'status', type: 'String', initialWidth: 100 },
						{ label: $A.get('$Label.c.XC_CL_StartDate'), fieldName: 'startDate', type: 'String', initialWidth: 100 },
						{ label: $A.get('$Label.c.XC_CL_EndDate'), fieldName: 'endDate', type: 'String', initialWidth: 100  },
						{ label: $A.get('$Label.c.XC_CL_Address'), fieldName: 'addressName', type: 'String', initialWidth: 400  }
						//{ label: $A.get('$Label.c.XC_CL_Installation_Date'), fieldName: 'installDate', type: 'Date' },
						/*{ label: $A.get('$Label.c.XC_CL_ContractLineItem'), fieldName: 'contractLineItemLink', type: 'url', 
                        typeAttributes: { target: '_self', label: { fieldName: 'contractLineItemName' } } },*/
						//{ label: $A.get('$Label.c.XC_CL_BundleConfiguration'), fieldName: 'bundleConfigurationLink', type: 'url', 
                          //typeAttributes: { target: '_self', label: { fieldName: 'bundleConfigurationName' } } } 
                    ];

        component.set(attributeName, columns);
    },
    
    setGridData: function (component, attributeName){
        let recordId = component.get("v.recordId");
        let assetTreeType = component.get("v.assetTreeType");
        let actionAssetTree;
        if(assetTreeType==="Services"){
            actionAssetTree = component.get('c.getTreeAssetServices');
        }else if(assetTreeType==="Products"){
            actionAssetTree = component.get('c.getTreeAssetProducts');
        }
        if(actionAssetTree===null){
            return;
        }

        console.log("actionAssetTree = " + actionAssetTree);
        console.log("recordId = " + recordId);
        actionAssetTree.setParams({
            recordId: recordId
        });
        actionAssetTree.setCallback(this, function (response) {
            let state = response.getState();
            if (state = "SUCCESS") {
                console.log('actionAssetTree callback = ' + response.getReturnValue());
                component.set(attributeName, response.getReturnValue());
            } else {
                console.log("error on actionAssetTree");
            }
        });
        $A.enqueueAction(actionAssetTree)
    }
})