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

                let username = component.get("v.username");

                var jsonObject = {
                    User: username,
                    Country: userInformation.country,
                    Company: userInformation.company,
                    Account_Id: userInformation.objectId
                }


                let jsonString = JSON.stringify(jsonObject)

                component.set("v.json", jsonString);
                console.log('@jsonString@: ' + jsonString);
                component.set("v.jsonFull", !userInformation.error);
                console.log('@error@'+ userInformation.error);
            } // Success state
        }); //Action

        console.log('@ACTION@:'+action);
        $A.enqueueAction(action);
    }

  
})