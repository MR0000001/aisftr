({  
    
    doInit : function(component, event) {   
            
        var recordId = component.get("v.recordId");    
        var action = component.get("c.checkStatus"); 
        action.setParams({"recordId": recordId});  
        action.setCallback(this, function(a) {   
            var result = a.getReturnValue();        
            if(!result.success) {      
                console.log("####fallimento####");
                component.set("v.showModal", true);             
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'error',
                    mode: 'dismissible',
                    duration : 20,
                    message: result.result
                });
                toastEvent.fire();             
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();              
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();          
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    cancelOrder : function(component, event) {   
        
        component.set("v.spinnerControl",true); 
        console.log("####cancelorderfunction####");
        var cancType = component.find("cancType").get("v.value");
        var reasonType = component.find("reasonType").get("v.value");
        var recordId = component.get("v.recordId");    
        var action = component.get("c.orderInCancelled"); 
        console.log(cancType);
        console.log(reasonType);
        console.log(recordId);
        console.log(action);
        action.setParams({
            "recordId": recordId,
            "cancType" :cancType,
            "reasonType" :reasonType
        });  
        action.setCallback(this, function(a) {   
            var result = a.getReturnValue();		
            if(result.success) { 
                console.log("####successo####");
                component.set("v.showModal", true);    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'success',
                    mode: 'dismissible',
                    duration : 20,
                    message: result.result
                });
                toastEvent.fire();      
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();   
            } else {      
                console.log("####fallimento####");
                component.set("v.showModal", true);             
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'error',
                    mode: 'dismissible',
                    duration : 20,
                    message: result.result
                });
                toastEvent.fire();             
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();              
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();          
            }
        });
        $A.enqueueAction(action);
    },
    
    Cancelled : function(component, event) { 
        $A.get("e.force:closeQuickAction").fire();
    },
    
    buttAct: function(component,event) {            
        let button = component.find('saveButt');
        
        var pickValue = component.find("cancType").get("v.value");
        var reasType = component.find("reasonType").get("v.value");
        
        if(pickValue!=='' && reasType != '') { 
            button.set('v.disabled',false);
        }
        
        if(pickValue=='' || reasType == '') { 
            button.set('v.disabled',true);
        }
    }
    
})