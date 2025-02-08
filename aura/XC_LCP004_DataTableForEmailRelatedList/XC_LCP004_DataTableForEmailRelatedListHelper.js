({
    getData : function(component, event) {
        
        component.set('v.columns', [
            { label: $A.get("$Label.c.XC_CL_Subject"), fieldName: 'Subject', type: 'String'},
            { label: $A.get("$Label.c.XC_CL_FromAddress"), fieldName: 'FromAddress', type: 'Email'},
            { label: $A.get("$Label.c.XC_CL_ToAddress"), fieldName: 'ToAddress', type: 'Email'},
            { label: $A.get("$Label.c.XC_CL_MessageDate"), fieldName: 'MessageDate', type: 'Date'},           
            { label: $A.get("$Label.c.XC_CL_Status"), fieldName: 'Status', type: 'String'},
            { label: $A.get("$Label.c.XC_CL_OpenEmail"), fieldName: 'Headers', type: 'url', typeAttributes: { label: { fieldName: 'Headers' }, target: 'Headers' }},
            { label: $A.get("$Label.c.XC_CL_Attachment"), fieldName: 'XC_Has_Attachment__c', type: 'Checkbox'}
        ]);
        var action = component.get("c.dataQuery");
        action.setParams({"recordId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retValue = response.getReturnValue();
                var i;
                if(retValue.length != 0) {
                    for(i=0; i < retValue.length;i++){
                        console.log("@@@ message " + retValue[i]);

                        var messDate=retValue[i].MessageDate;
                        var day=messDate.slice(8,10);
                        var month=messDate.slice(5,7);
                        var year=messDate.slice(0,4);
                        var hours=messDate.slice(11,13);
                        var minutes=messDate.slice(14,16);
                        var newDate=day + '/' + month + '/' + year + ' ' + hours + ':' +minutes;
                        retValue[i].MessageDate=newDate;
                          var attach =retValue[i].XC_Has_Attachment__c;
                          console.log("@@@ attach " + retValue[i].XC_Has_Attachment__c);
                          if(attach){
                            retValue[i].XC_Has_Attachment__c='SI';
                          } else{
                           retValue[i].XC_Has_Attachment__c='NO'; 
                        }
                    }  
                    for(i=0; i < retValue.length;i++){
                        if(retValue[i].ToAddress != 'xc_es_enelxsupport@t-2467zechvc9sok4i7jodeaaya9nhpz3qgruqjauavnwwueh6ll.1w-nu3eam.cs105.apex.sandbox.salesforce.com') {
                            retValue[i].Status = 'Inviata';
                        }
                        else{
                            retValue[i].Status = 'Ricevuta';
                        }
                        
                    }          
                } 
                
                component.set('v.data', response.getReturnValue());
            }   
        }); 
        $A.enqueueAction(action);
    }

})