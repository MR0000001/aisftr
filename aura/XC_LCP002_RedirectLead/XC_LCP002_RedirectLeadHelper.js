({
    
    doInit : function(component, event,helper) {
        console.log('IN DO init');
        
        let myPageRef = component.get("v.pageReference"); 
        if(myPageRef){
            component.set("v.socialPersonaId", myPageRef.state.c__socialPersonaId);
        }
        
        let action2 = component.get("c.isMobileOrCommunityExperience");
        action2.setCallback(this, function(response) {
              let state = response.getState();
              let retValue = response.getReturnValue();
              if (state === "SUCCESS"){
                console.log('CIAO = '+retValue);
                  if(retValue==='isCommunity'){
                      component.set("v.isCommunity",true);
                  }
               }
                  }); 
          $A.enqueueAction(action2);
        
        if(component.get("v.pageReference") && component.get("v.pageReference").state) {
            var recordTypeId = component.get("v.pageReference").state.recordTypeId;  
            if(component.get("v.pageReference").state.ws){
                let url = component.get("v.pageReference").state.ws;
                console.log(url);
                if(url){
                    let s = url.split('/Case/')[1];
                    console.log(s);
                    if(s){
                        let caseId = s.split('/view')[0];
                        console.log(caseId);
                        component.set('v.parentRecordId', caseId);
                    }
                }
            }
            
        }
        if(recordTypeId) {
            component.set('v.recordTypeId', recordTypeId);
            console.log('recordTypeId->'+recordTypeId);
        }
        component.set('v.showComponent', true);  
    } 
})