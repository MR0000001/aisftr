({
	createSOGlovia : function(component,event, helper ) {
		component.set("v.spinner", true);
        console.log('@@@@ spinner:' + component.get("v.spinner"));
        var action = component.get("c.getAllProductRequired");
        var woliId =  component.get("v.recordId");

        action.setParams({
            'workOrderLineItemId' : woliId

		});

        action.setCallback(this,function(response){
            var state = response.getState();
            let storeResponse = response.getReturnValue();
            console.log('@@@ createSOSOLIGlovia state:' + state);
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
               if(storeResponse.success){
                   console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                   resultsToast.setParams({
                    	"title": "Success",
                    	"message": "Goods Issue successfully executed",
                        "duration": "4000",
                        "type": "success",
                	});
                	// Update the UI: close panel, show toast, refresh account page
               }
               else{
                    console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                      resultsToast.setParams({
                        "title": "Error",
                        "message": storeResponse.resultMessage,
                        "duration": "4000",
                        "type": "error"
                    });
               }
            }else{
                	resultsToast.setParams({
                    	"title": 'Send order Material',
                    	"message": 'Order Material send failed!!',
                        "duration": "4000",
                        "type": 'Error',
                	});
            }
            resultsToast.fire();
            // Update the UI: close panel, show toast, refresh account page
            helper.fireRefreshEvt(component,'true');

            //$A.get("e.force:refreshView").fire();
        });
        var requestInitiatedTime = new Date().getTime();
        //component.set("v.spinner", false);
        $A.enqueueAction(action);
	},

    getCommercialItem : function(component,event, helper ) {

        console.log('@@@@ getCommercialItem:');
        var action = component.get("c.getCommercialItemList");
        var woliId =  component.get("v.recordId");

        action.setParams({
            'woliId' : woliId

		});

        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('@@@ product2 state:' + state);
            if (state === "SUCCESS") {
                console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                if(response.getReturnValue()!=''){
                   component.set("v.commercialCI", response.getReturnValue());
                   component.set("v.isOpen", true);
                }


            }
        });
        var requestInitiatedTime = new Date().getTime();
        //component.set("v.spinner", false);
        $A.enqueueAction(action);
	},
	fireRefreshEvt : function(component,refresh) {
        console.log('TA_LCP248_GoodIssueExecution >> Helper >> fireRefreshEvt >> Start');
        let fireRefreshEvt = $A.get("e.c:TA_LCE224_Refresh");
        fireRefreshEvt.setParam('action','refresh intervention');
        var params={};
        params.showComponentLabel = 'showComponentGoodIssue';
        params.refresh = refresh;
        fireRefreshEvt.setParam('params',params);
        fireRefreshEvt.fire();
        console.log('TA_LCP243_CreateRecordModal >> Helper >> fireRefreshEvt >> End');
    },

})