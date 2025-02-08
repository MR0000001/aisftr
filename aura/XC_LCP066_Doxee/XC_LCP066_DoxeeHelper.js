({
	doInit : function(component, event, helper) {
		let action = component.get("c.fetchUser");

        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log('@state@'+state);

            if (state === "SUCCESS") {
                let storeResponse = response.getReturnValue();
                let userInformation = JSON.parse(storeResponse.objectInfo);
                let objectParentId;  //GLOVIA DDT
                if(storeResponse.success){
                    component.set("v.username",userInformation.userName);
                    component.set("v.objectType",userInformation.objectType);
                    objectParentId = userInformation.parentId; //GLOVIA DDT
                }
                console.log(`userInformation: ${userInformation}`)

                component.set("v.userInfo", storeResponse);
                component.set("v.userInfo.Company", storeResponse.Company__c);
                let recordId = component.get("v.recordId");
                let typeOfObject = component.get("v.objectType") + "_Id";
                let username = component.get("v.username");

                const newTypeOfObject = helper.getTypeOfObject(typeOfObject)
                const objectParent = helper.getObjectParent(typeOfObject)

                var jsonObject = {
                    User: username,
                    Country: userInformation.country,
                    Company: userInformation.company
                }
                jsonObject[newTypeOfObject] = recordId
                if (userInformation.dossier) {
                    jsonObject.dossier = userInformation.dossier
                }
                if (userInformation.AdditionalInfo) {
                    jsonObject.AdditionalInfo = userInformation.AdditionalInfo
                }
                // DDT Glovia add parent to Json to retrieve document Parent
                //if(objectParentId !== '' && objectParent) jsonObject[objectParent] = objectParentId

                let jsonString = JSON.stringify(jsonObject)
                if (userInformation.dossier) jsonString.replace('business_id','business-id');

                component.set("v.json", jsonString);
                console.log('@jsonString@: ' + jsonString);
                component.set("v.jsonFull", !userInformation.error);
                console.log('@error@'+ userInformation.error);
            } // Success state
        }); //Action

        console.log('@ACTION@:'+action);
        $A.enqueueAction(action);
    },

    getTypeOfObject: function(typeOfObject) {
        const objectMap = {
            NE__Order__c_Id : 'Configuration_Id',
            NE__OrderItem__c_Id : 'Configuration_item_Id',
            WorkOrder_Id : 'Workorder_Id',
            WorkOrderLineItem_Id : 'Workorder_lineitem_Id',
            NE__Billing_Profile__c_Id : 'Billing_profile_Id',
            gii__PurchaseOrder__c_Id : 'Purchase_order_Id',
            gii__PurchaseOrderReceipt__c_Id : 'PurchaseOrder_receipt_Id',
            gii__TransferOrder__c_Id : 'Transfer_order_Id',
            gii__ReturntoSupplier__c_Id : 'Return_to_vendor_Id',
            gii__Shipment__c_Id : 'Shipment_Id',
            project_cloud__Project__c_Id : 'Project_Id',
            project_cloud__Project_Task__c_Id :'Projecttask_Id',
            XC_B2BG_QualityCheck__c_Id : 'Quality_check_Id',
            XC_FormCase__c_Id :'FormCase_Id' //NR2357
        }
        if(objectMap[typeOfObject] === undefined) {
            return typeOfObject
        }
        return objectMap[typeOfObject]
    },

    getObjectParent: function(typeOfObject) {
        const objectMap = {
            gii__PurchaseOrderReceipt__c_Id : 'Purchase_order_Id',
            gii__ReturntoSupplier__c_Id : 'PurchaseOrder_receipt_Id',
            gii__Shipment__c_Id : 'Transfer_order_Id'
        }
        if(objectMap[typeOfObject] === undefined) {
            return typeOfObject
        }
        return objectMap[typeOfObject]
    }
})