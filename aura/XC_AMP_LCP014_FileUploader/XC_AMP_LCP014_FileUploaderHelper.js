({
    manageFileUpload : function(component,event,helper) {
        let files = event.getParam("files");
        console.log(' FILES UPLOADED ' + JSON.stringify(files));

        let action = component.get("c.uploadFile");
        let paramsObj = {
            "fileInfo" : files[0],
            "opportunityId" : component.get("v.recordId")
        }

        component.set("v.fileLoaded",true);
        component.set("v.fileName",files[0].name);

        action.setParams({"paramsMap" : paramsObj});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result=response.getReturnValue();
                if(result.success){
                    console.log('SUCCESS UPLOAD ON DOXEE');
                    let evtData = {
                        type : "FILE_UPLOAD",
                        /*success : true,*/
                        sectionName: "fileUpload",
                        isSectionValid : true
                    }
                    component.set('v.notSelected', false);
                    helper.fireAMPEvent(component,evtData);
                }else{
                    helper.showToast(component,'Error',result.errorMsg,'error');
                    console.log('ERROR ON SEND TO DOXEE ' + result.errorMsg);
                }
            }else{
                console.log('ERROR ON SEND TO DOXEE ' + JSON.stringify(response.getError()[0]));
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(component,title,message,type){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "mode": "pester",
            "variant": type
        });
    },

    fireAMPEvent : function(component,eventData) {
        let ev = component.getEvent("XC_AMP_LCE001_AMPCommunicationEvent");
        ev.setParam("data",eventData);
        ev.fire();
    }

})