({
	initFunc : function(component, event, helper) {
        component.set('v.columns',  [
            {label: 'Name', fieldName: 'Name', type: 'String'}
            
           // {label: 'id', fieldName: 'id', type: 'Id'}
            
        ]);
        var action = component.get("c.projectTemplateList");
	    action.setParams({
            'recordId' : component.get("v.recordId")        
            
        });
    action.setCallback(this, function(response){
     var state = response.getState();
    if (state == "SUCCESS"){
      var listOrder = response.getReturnValue();
      console.log(listOrder);
      component.set('v.data', listOrder);
      component.set('v.selectedRowsCount', listOrder.length);
       }else{
                console.log('errore');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    mode: 'sticky',
                    type:'error',
                    duration : 20,
                    message: 'There are not found Project Templates'
                });
                
            }
  
    })
  $A.enqueueAction(action);
 },
    updateSubmit : function (component, event, helper){
        var dataTable = component.find('datatableID');
        var selectedRows = dataTable.getSelectedRows(0);
        var recordId = component.get("v.recordId");
        var ItemsToUpdate = [];
        var errorOnTaskReminder=$A.get("$Label.c.XC_CL_MaintenanceReminderTask");
        var lackOfProject=$A.get("$Label.c.XC_CL_MaintenanceLackofProject");
        var replanTask=$A.get("$Label.c.XC_CL_ReplanTask");
        var contractExpired=$A.get("$Label.c.XC_CL_ContractExpired");
        for (var i = 0; i < selectedRows.length; i++){
             var selectedRowsToPass = selectedRows[i];
            var itemRows = {Id: selectedRowsToPass.Id};
            var itemID = itemRows.Id;
            ItemsToUpdate.push(itemRows);
             var action = component.get("c.createProject");
            action.setParams({
                'recordId' : recordId,
                'projTempldateId': itemID
            });
              action.setCallback(this, function(a){
                var state = a.getState();
                if (state === "SUCCESS"){
                    var res=a.getReturnValue();
                  //   $A.get("e.force:closeQuickAction").fire();
                      // $A.get('e.force:refreshView').fire();
                   /* if(res=='A project is just related to this Project Task'){
                        this.toastError(component,res);
                        $A.get("e.force:closeQuickAction").fire();
                    }*/if(res==errorOnTaskReminder){
                         this.toastError(component,res);
                        $A.get("e.force:closeQuickAction").fire();
                    }else if(res==lackOfProject){
                        this.toastError(component,res);
                        $A.get("e.force:closeQuickAction").fire(); 
                    }else if(res==replanTask){
                        this.toastError(component,res);
                        $A.get("e.force:closeQuickAction").fire();
                    }else if(res==contractExpired){
                        this.toastError(component,res);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else{
                      window.location = "/lightning/r/project_cloud__Project__c/"+res+"/view";    
                    }                
              }
                else{
                    $A.get("e.force:closeQuickAction").fire();
                    }
               
            });
            $A.enqueueAction(action);
                 
        }
    },
     toastError : function(component,message){
            console.log('success');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error!',
                message: message,
                messageTemplate: message,
                duration: '100',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
             
        },
})