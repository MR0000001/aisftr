({
	doInit : function(component, event, helper) {
     	//var value = helper.getParameterByName(component , event, 'inContextOfRef');
        //var context = JSON.parse(window.atob(value));

        var pageRef = component.get("v.pageReference");
        if(pageRef!=null && pageRef!=undefined){
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        component.set("v.parentRecordId", addressableContext.attributes.recordId);
        }else{
            component.set("v.parentRecordId", component.get("v.recordId"));
        }
        //component.set("v.parentRecordId", context.attributes.recordId);
        console.log('@@@@ id:' + component.get("v.parentRecordId"));
		helper.getListConfCommercial(component, event, helper);

       
	},
    
    cancelDialog : function(component, helper) {
        /*
		var navigateEvent = $A.get("e.force:navigateToSObject");
    	navigateEvent.setParams({ 
        	"recordId": component.get('v.parentRecordId'), 
    		"slideDevName": "related"
    	});
    	navigateEvent.fire();
    	//window.location.reload(true);
    	var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });*/
        $A.get("e.force:closeQuickAction").fire();
        //window.location.reload(true);
    },
    
    callSaveComp : function(component, event, helper){
        component.set("v.spinner", true);
        console.log('@@@@ callSaveComp');
        var pageRef = component.get("v.pageReference");
        var idCommItem = component.get("v.idSelectConfComm");
        console.log('@@@@ callSaveComp - idCommItem:' + idCommItem);
        if(idCommItem!='--none--'){
            var woliId = component.get("v.parentRecordId");
            var wbeElement = component.get("v.wbeElement");
            var costCenter = component.get("v.costCenter");
             if(pageRef!=null && pageRef!=undefined){
                var evt = $A.get("e.force:navigateToComponent");
                console.log('@@@@ evt:' + evt);

                console.log('@@@@ woliId:' + woliId);
                evt.setParams({
                    componentDef  : "c:XC_LCP195_AddTechnicalItems" ,
                    componentAttributes : {
                       woliRecordId : woliId,
                       wbeElement : wbeElement,
                       costCenter : costCenter,
                       contestStartCI : false,
                       recordId : component.get("v.idSelectConfComm")
                    }

                });
                evt.fire();
                component.set("v.spinner", false);
            }
            else{
                component.set("v.spinner", true);
                $A.createComponent(
                    "c:XC_LCP195_AddTechnicalItems",
                    {
                        "woliRecordId": woliId,
                        "wbeElement": wbeElement,
                        "costCenter" : costCenter,
                        "contestStartCI" : false,
                        "recordId" : component.get("v.idSelectConfComm")
                    },
                    function(newInp, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = component.get("v.body1");
                            body.push(newInp);
                            component.set("v.body1", body);
                            component.set("v.manageCommunity", true);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                        }
                        else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                        component.set("v.spinner", false);
                    }
                );
            }
		}else{
		      component.set("v.spinner", false);
              var resultsToast = $A.get("e.force:showToast");
                 resultsToast.setParams({
                    "title": 'Add Order material',
                    "message": 'Choose related commercial item to add Material Order',
                    "duration": "8000",
                    "type": 'Error'
                 });
                 resultsToast.fire();
        }    
	},
    

    onPicklistChange: function(component, event, helper) {
        var idConfComm = event.getSource().get("v.value"); 
        console.log('@@@@ lstViewName;'+ idConfComm);
        component.set("v.idSelectConfComm", idConfComm)
      	if(idConfComm!='--none--') {
            component.set('v.disableSelect',false);
            helper.getotherParmCIC(component, event, helper);
        }
        else{
            component.set('v.disableSelect',true);
        }
        
           
        
            
    },

})