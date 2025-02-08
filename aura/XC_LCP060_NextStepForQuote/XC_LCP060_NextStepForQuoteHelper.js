({	 
    initEnvironment  : function(component,event,helper) {
        let action = component.get("c.isInCommunity");
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = a.getReturnValue();                
                if(result.isInCommunity){//NR2187 m.c.mohamed.ibrahim@accenture.com 5/26/22 - Added isInCommunity
                   component.set("v.isCommunity", result.isInCommunity);//NR2187 m.c.mohamed.ibrahim@accenture.com 5/26/22 - Added isInCommunity
                   helper.initSitePrefix(component,event,helper);
                   }
                else{
                   helper.checkPossibilityToCreate(component,event,helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    initSitePrefix  : function(component,event,helper) {
    let action = component.get("c.getVisualforceRelativeURL");
    action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = a.getReturnValue();
                if(result!==null){
                   component.set("v.sitePrefix", result);
                   console.log('URL='+result);
                   helper.checkPossibilityToCreate(component,event,helper);
                   }
            }
        });
        $A.enqueueAction(action);
    },

	checkPossibilityToCreate  : function(component,event,helper) {
        let recordId = component.get("v.recordId");
        let sitePrefix = component.get("v.sitePrefix");
        let isCommunity = component.get("v.isCommunity");
        if(isCommunity){
        	component.set('v.urlNextStepB2W', sitePrefix+'/apex/NE__NextStepPage?Id=' + recordId);
        }
        else{
        	component.set('v.urlNextStepB2W', '/apex/NE__NextStepPage?Id=' + recordId);  
        }
        
        let action = component.get("c.checkOrderCreation");
        action.setParams({ 'recordId' : recordId });
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = a.getReturnValue();
                if(result.success){
                    let spinner = component.find("mySpinner");
        			
        			setTimeout(function() {
                        $A.util.toggleClass(spinner, "slds-hide");
                    })
                    
                    if(isCommunity){
                        let url = component.get("v.urlNextStepB2W");
                        let urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({ "url": url });
                        urlEvent.fire();
                    }
                    else{
                        if(typeof sforce != 'undefined' && typeof sforce.one != 'undefined' && sforce.one !== null){
                            sforce.one.navigateToURL(url,true); 
                        }
                        else {
                            let urlB2W = component.get("v.urlNextStepB2W");
                            $A.get("e.force:closeQuickAction").fire();
                            window.open(urlB2W, "", "left=460,top=200,width=370,height=270,titlebar=0,toolbar=0,status=0,menubar=0,resizable=0,scrollbars=no");

							
                        }
                    }
                }else{
                    console.log('result error='+result.resultMessage);
                    helper.showToast(component, event, helper, result.resultMessage, 'error');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showNotice({
            "title": '',
            "message": message,
            "variant": type
        });
    }
})