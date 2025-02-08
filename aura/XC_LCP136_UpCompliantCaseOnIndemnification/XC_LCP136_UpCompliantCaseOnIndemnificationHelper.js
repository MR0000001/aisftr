({
    doInit : function(component,event,helper) {
        var action=component.get("c.getBillingInfo");
        console.log(" And record is: " + component.get("v.recordId"));

        action.setParams({
            "caseID": component.get("v.recordId")
        })
        //console.log("HERE");

        action.setCallback(this, function(a) {
            var state = a.getState();
            var result = a.getReturnValue();
            
            console.log("RESULT :"+JSON.stringify(result));
            if(state === 'SUCCESS') {
                
                console.log("QUERY:"+result.lookupString);

                let mystring=result.lookupString;
                let mapCase= result.mapfieldcase;
                //console.log("mystring"+mystring);
                var i;
                var newstring ='XC_BillingProfile__c IN (\''+ mystring[0] +'\'';
                for (i = 1; i < mystring.length; i++) { 
                    newstring += ',\''+mystring[i] +'\'';
                }
                newstring +=')';
                newstring += 'AND XC_Status__c = \''+ $A.get("$Label.c.XC_CL_Billing_Active") +'\'';
                newstring += 'AND XC_LegalEntity__c = \''+mapCase['XC_LegalEntity__c']+'\'';
                console.log("newstring"+newstring);
                component.set("v.lookupFilter",newstring);
                component.set("v.amount", mapCase['XC_Amount__c'] );
                component.set("v.indemnifReasonMap", result.resultPicklistMap);
                component.set("v.showSpinner",false);
                component.set("v.canshow",true);
                component.set("v.accountId", mapCase['AccountId']);
                component.set("v.automatic_refund", mapCase['XC_Automatic_Refund__c']);
                component.set("v.case_comments", mapCase['XC_Case_Comments__c']);
                component.set("v.indemnificationReason", mapCase['XC_IndemnificationReason__c']);
                component.set("v.BillingProfileLI", mapCase['XC_Billing_Profile_Line_Item__c']);
                component.set("v.approvalStatus", mapCase['XC_ApprovalStatus__c']);
                component.set("v.sentToZuora", mapCase['XC_SentToZuora__c']);
                component.set("v.sendStatus", mapCase['XC_SendStatus__c']);
                component.set("v.legalEntity", mapCase['XC_LegalEntity__c']);


                // check if it is necessary to set fields as read only
                if(!$A.util.isUndefinedOrNull(mapCase['XC_Amount__c']) && !$A.util.isUndefinedOrNull(mapCase['XC_IndemnificationReason__c']) 
                    && !$A.util.isUndefinedOrNull(mapCase['XC_Billing_Profile_Line_Item__c'])){
                        component.set("v.disableIndemnification", true);
                        component.set("v.disableAmount", true);
                        component.set("v.showAutomaticApproval", true);
                        component.set("v.disabledSend",false);
                }

                //console.log("HERE");
                
            } else {
                //console.log("ERROR");
            }
            
        });
        $A.enqueueAction(action);
    },


    updateCaseHelper: function(component,event,helper) {
        
        var action=component.get("c.updateComplaintCase");
        console.log(" And record is: " + component.get("v.recordId"));
        console.log("Billing Profile LI: "+component.get("v.BillingProfileLI"));

        let automaticApproval = component.get("v.automaticApproval");
        let approvalStatus;
        if(component.get("v.approvalStatus") != null){
            approvalStatus = component.get("v.approvalStatus");
        }else if(automaticApproval == 'Needed'){
            approvalStatus = 'Not Needed';
        }else if(automaticApproval == 'Not Needed'){
            approvalStatus = 'Needed'
        }

        
        let parInputlist={
            "XC_Billing_Profile_Line_Item__c": component.get("v.BillingProfileLI"),
            "XC_Case_Comments__c": component.get("v.case_comments"),
            "XC_IndemnificationReason__c": component.get("v.indemnificationReason"),
            "XC_Automatic_Refund__c": component.get("v.automatic_refund"),
            "XC_Amount__c": component.get("v.amount"),
            "XC_ApprovalStatus__c" : approvalStatus,
            "XC_SendStatus__c" : component.get("v.sendStatus"),
            "XC_SentToZuora__c" : component.get("v.sentToZuora"),
            "XC_LegalEntity__c" : component.get("v.legalEntity")
        };
        
        action.setParams({
            "jsonCaseUpdate": JSON.stringify(parInputlist),
            "caseID": component.get("v.recordId")
        })

        action.setCallback(this, function(a) {
            var state = a.getState();
            var result = a.getReturnValue();
            console.log('result success:'+ result.success);
            if(state ==='SUCCESS' && result.success === true) {
                console.log("ERROR");
                helper.showMessage(component,event,helper,'success','SUCCESS',result.resultMessage);
              
            } else {
                console.log("ERROR");
                helper.showMessage(component,event,helper,'error','ERROR',result.resultMessage);
            }
            $A.get("e.force:closeQuickAction").fire()
        });
        
        $A.enqueueAction(action);
    },    


    checkNotBlank: function(component,event,helper) {

        let indemnificationReason = component.get("v.indemnificationReason");
        let amount = component.get("v.amount");
        let billingProfile = component.get("v.BillingProfileLI");
        let disableIndemnification = component.get("v.disableIndemnification");

        // get amount
        if(indemnificationReason =='' || indemnificationReason == undefined){
            component.set("v.showAutomaticApproval", false);
            //component.set("v.amount", "" );
            component.set("v.disableAmount",true);
        }else if(disableIndemnification == false){
            helper.getAmount(component);
        }
 
        
        if(indemnificationReason =="" || indemnificationReason == undefined ||
            amount =="" || amount == undefined ||
            billingProfile =="" || billingProfile == undefined){
            component.set("v.disabledSend",true);
        }else{
            component.set("v.disabledSend",false);
        }
    },

    getAmount : function(component) {

        var action=component.get("c.getAmount");
        
        action.setParams({
            "indemnificationReason": component.get("v.indemnificationReason")
        })

        action.setCallback(this, function(a) {
            var state = a.getState();
            var result = a.getReturnValue();
            
            if(state === 'SUCCESS') {
                
                let mapCase = result.mapfieldcase;
                component.set("v.automaticApproval", mapCase['XC_AutomaticApproval__c']);
                component.set("v.showAutomaticApproval", true);
               
                if(mapCase['XC_Amount__c'] =='' ||mapCase['XC_Amount__c'] === undefined ){
                    let disableIndemnification = component.get("v.disableIndemnification");
                    if(disableIndemnification == true){
                        component.set("v.disableAmount",true);
                    }else{
                        component.set("v.disableAmount",false);
                    }
                    
                }else{
                    component.set("v.amount", mapCase['XC_Amount__c'] );
                    component.set("v.disableAmount",true);
                }  
            }
            
        });
        $A.enqueueAction(action);
    },


    goBack: function (component, event, helper) {
       /* if(component.get("v.isCommunity")){
            var windowRedirect = window.location.href;
            window.location.href = windowRedirect; 
        }else{*/
            //lancio evento per il close della finestra
            
            let ev = $A.get("e.c:XC_LCE015_ModalClosed");
            if(ev){
               ev.setParams({"modalName": $A.get("$Label.c.XC_CL_UpCompliantCaseClosedEvent")});        
               ev.fire();
            }
            let dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        //}
    },


    showMessage : function(component, event, helper, type, title, message) {
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": type
        });
        console.log("SHOW MESSAGE");
        helper.goBack(component, event, helper);
    },

    handleSecondaryButtonClick: function (component, event, helper) {
        component.set("v.showNewZuoraBilling", false);
        //$A.get('e.force:refreshView').fire();
    }

})