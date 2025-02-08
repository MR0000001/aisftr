({
    closeModal:function (component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/lightning"));
        window.location = baseURL +'/lightning/o/XC_ContractAmendment__c/list?filterName=Recent';
        /*
        var homeEvent = $A.get("e.force:navigateToURL");
        homeEvent.setParams({
            "url": "https://enelx-uat--exuat.lightning.force.com/lightning/o/XC_ContractAmendment__c/list?filterName=Recent"
        });
        homeEvent.fire();
        */
    },
    
	//Go to previously modal
    backButtonClick: function(component,event,helper){
        //Implement the function of back button. For each modal I disable the current one and enable the previously
        if (component.get("v.showLCP263")){
            component.set("v.showLCP263", false);    
            component.set("v.showLCP260", true);
        }else if(component.get("v.showLCP256")){
            component.set("v.showLCP256", false);    
            component.set("v.showLCP263", true);
        }else if(component.get("v.showLCP257")){
            component.set("v.showLCP257", false);    
            component.set("v.showLCP263", true);
        }else if(component.get("v.showLCP258")){
            component.set("v.showLCP258", false);    
            component.set("v.showLCP260", true);
        }

    },
})