({
	getParameterByName: function(component, event, name) {
        name= name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    getListConfCommercial : function (component, event, name){
    	var action = component.get("c.getCommercialItemList");
        var woliId = component.get("v.parentRecordId");
        console.log('@@@@ getListConfCommercial:' + woliId);
        action.setParams({
            'woliId':woliId
		})
     	
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@ getListConfCommercial - state:' + state);
            console.log('@@@ a.getReturnValue():' + response.getReturnValue());
            
            if (state === "SUCCESS") {
            var prods = response.getReturnValue();
          		if(response.getReturnValue()!='' && response.getReturnValue()!=null && response.getReturnValue().length > 0) {
                    component.set("v.selectConfComm", true);
                   
                	component.set("v.confItemCommercial", response.getReturnValue());
                }else if(response.getReturnValue()!=null && response.getReturnValue().length == 0){
                    //alert('Vuoto');
                    this.openLCP195(component, event, name);
                }else{
                     
                    var resultsToast = $A.get("e.force:showToast");
                			resultsToast.setParams({
                    		"title":$A.get('$Label.c.XC_CL_Error'),
                    		"message": $A.get('$Label.c.XC_CL_NoAddProductForWOLI'),
                        	"duration": "4000",
                        	"type": 'Error'
                		});
                       resultsToast.fire();
                       $A.get("e.force:closeQuickAction").fire();
                        /*var workspaceAPI = component.find("workspace");
                           workspaceAPI.getFocusedTabInfo().then(function(response) {
                               var focusedTabId = response.tabId;
                               workspaceAPI.closeTab({tabId: focusedTabId});
                           })
                           .catch(function(error) {
                               console.log(error);
                           });*/
                      
                }    
            }    
        });
        $A.enqueueAction(action);
	},
    
     getotherParmCIC : function (component, event, name){
        console.log('@@@@ getotherParmCIC');
        var action = component.get("c.getParamToGlovia");
        var idConfComm = component.get("v.idSelectConfComm"); 
        action.setParams({
            'confItemComm':idConfComm
		})
     	console.log('@@@@ getotherParmCIC2');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue().result;
            console.log('@@@@ getotherParmCIC3');
            console.log('@@@ onPicklistChange - state:' + state);
            console.log('@@@ onPicklistChange - a.getReturnValue().result:' + res);
            console.log('@@@ onPicklistChange - a.getReturnValue().wbe:' + response.getReturnValue().wbeElement);
            console.log('@@@ onPicklistChange - a.getReturnValue().costcenter:' + response.getReturnValue().costCenter);
            
            if (state === "SUCCESS") { 
                if(response.getReturnValue().result == true) {
                    component.set("v.selectConfComm", true);
                	component.set("v.wbeElement", response.getReturnValue().wbeElement);
                    component.set("v.costCenter", response.getReturnValue().costCenter);
                }else{
                	component.set("v.selectConfComm", false);
                    var resultsToast = $A.get("e.force:showToast");
                			resultsToast.setParams({
                    		"title": response.getReturnValue().titleMessage,
                    		"message": response.getReturnValue().message,
                        	"duration": "8000",
                        	"type": response.getReturnValue().typeMessage
                		});
                       resultsToast.fire();
                       
                }
            }
        });
        $A.enqueueAction(action);      
          
     },
     openLCP195 : function(component, event, helper){
             console.log('@@@@ openLCP195');
             var pageRef = component.get("v.pageReference");
             var idCommItem = component.get("v.idSelectConfComm");
             console.log('@@@@ callSaveComp - idCommItem:' + idCommItem);

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
                 }
                 else{
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
                         }
                     );
                 }

     	}
})