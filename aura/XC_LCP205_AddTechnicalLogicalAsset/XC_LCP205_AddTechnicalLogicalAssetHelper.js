({
	initFunc2 : function(component, event, helper) {
        component.set('v.columns',  [
            {label: 'Name', fieldName: 'Name', type: 'String'},
            {label:'Serial Number',fieldName:'SerialNumber',type:'String'},
            {label: 'Technical Type', fieldName: 'TAM_AssetType__c', type: 'String'},
            {label: 'Root Asset', fieldName: 'RootAsset', type: 'String'},
            {label: 'Parent Asset', fieldName: 'Parent', type: 'String'}
        ]);
        component.set('v.columns2',  [
            {label: 'Name', fieldName: 'Name', type: 'String'},
            {label:'Serial Number',fieldName:'SerialNumber',type:'String'},
            {label: 'Technical Type', fieldName: 'TAM_AssetType__c', type: 'String'}
        ]);
        //DeAv 08.07.2022 - NR2330 START
        var action = component.get("c.showAllNetworks");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state=="SUCCESS"){
                if(response.getReturnValue() == true){
                    component.set('v.showAllNetwork', true);
                    helper.initFunc2Old(component, event, helper);                    
                }else{
                    helper.initFunc2Old(component, event, helper);
                }
            }
        })
        $A.enqueueAction(action);
    },
    initFunc2Old : function(component, event, helper){
        //DeAv 08.07.2022 - NR2330 END
        var action = component.get("c.retrieveLogicalAndTechnicalAsset");
	    action.setParams({
            'recordId' : component.get("v.recordId")            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                if(response.getReturnValue()){
                    var resultObj= JSON.parse(response.getReturnValue()); 
                    if (resultObj.result === 'OK'){
                        var listAsset =resultObj.techAssetList;
                        for (var i = 0; i < listAsset.length; i++){
                            var asset = listAsset[i];
                            if(asset.RootAsset.Name){
                                asset.RootAsset = asset.RootAsset.Name;
                            }
                            if(asset.Parent  && asset.Parent.Name){
                                asset.Parent = asset.Parent.Name;
                            }
                        }
                        console.log(listAsset);
                        component.set('v.data', listAsset);
                        component.set('v.data2', resultObj.logicalAssetList);
                        component.set('v.dataNetwork', resultObj.networkAssetList); //DeAv 07.07.2022 - NR2330
                        component.set('v.selectedRowsCount', listAsset.length);
                        component.set('v.businessLineValue', resultObj.caseBsnLine);
                        component.set('v.showCaseForceWorkOrder',resultObj.isForceWorkOrder);
                    }else{
                        console.log('errore - No address found');
                        this.toastError(component,resultObj.errorMessage);
                        var dismissActionPanel1=$A.get("e.force:closeQuickAction")
                        dismissActionPanel1.fire();
                        $A.get('e.force:refreshView').fire();
                
                    }
                }
            }
    })
   $A.enqueueAction(action);
    }, 
    filteredSearch : function(component, event, helper) {
        component.set ("v.selectedRows2", []);
        component.set ("v.selectedRows", []);
        var actionSearch = component.get("c.retrieveFilteredLogicalAndTechnicalAsset");
	    actionSearch.setParams({
            'recordId' : component.get("v.recordId"),
            'name' : component.get("v.filter")         
        });
        actionSearch.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                if(response.getReturnValue()){
                    var resultObj= JSON.parse(response.getReturnValue()); 
                    if (resultObj.result === 'OK'){
                        var listAsset =resultObj.techAssetList;
                        for (var i = 0; i < listAsset.length; i++){
                            var asset = listAsset[i];
                            if(asset.RootAsset.Name){
                                asset.RootAsset = asset.RootAsset.Name;
                            }
                            if(asset.Parent  && asset.Parent.Name){
                                asset.Parent = asset.Parent.Name;
                            }
                        }
                        console.log(listAsset);
                        component.set('v.data', listAsset);
                        component.set('v.data2', resultObj.logicalAssetList);
                        component.set('v.dataNetwork', resultObj.networkAssetList); //DeAv 07.07.2022 - NR2330
                        component.set('v.selectedRowsCount', listAsset.length);
                    }else{
                        console.log('errore - No address found');
                        this.toastError(component,resultObj.errorMessage);
                        var dismissActionPanel1=$A.get("e.force:closeQuickAction")
                        dismissActionPanel1.fire();
                        $A.get('e.force:refreshView').fire();
                
                    }
                }
            }
    })
   $A.enqueueAction(actionSearch);
    },
    initFunc : function(component, event, helper) {
        component.set('v.columns',  [
            {label: 'Name', fieldName: 'Name', type: 'String'},
            {label:'Serial Number',fieldName:'SerialNumber',type:'String'},
            {label: 'Technical Type', fieldName: 'TAM_AssetType__c', type: 'String'},
            //{label: 'Address', fieldName: 'XC_Address__c', type: 'Id'},
            {label: 'IsTechnical', fieldName: 'TAM_IsTechnical__c', type: 'Checkbox'},
            {label: 'IsLogical', fieldName: 'TAM_IsLogical__c', type: 'Checkbox'}
            //{label: 'ForceWorkOrrderGeneration' type:'Checkbox'}
           // {label: 'id', fieldName: 'id', type: 'Id'} 
        ]);
        var action = component.get("c.retrieveListAsset");
	    action.setParams({
            'recordId' : component.get("v.recordId")            
        });
        action.setCallback(this, function(response){
     var state = response.getState();
     if(state == "SUCCESS"){
         var str=response.getReturnValue();
         if(str){
          var result = [];
          result= JSON.parse(str); 
          // let addressSet=[];  
         // addressSet=result.keySet();
         //console.log(addressSet);
          var errorAddress=$A.get("$Label.c.XC_CL_CaseErrorMessage_MalfunctioningAddress"); 
          if (result['Ok']!=null){
          //var addressSet=response.getReturnValue().keySet();
          console.log(result['Ok']);
          var listAsset =result['Ok'];
          console.log(listAsset);
          component.set('v.data', listAsset);
          component.set('v.selectedRowsCount', listAsset.length);
           }else if(result[errorAddress]!=null){
                    console.log('errore - No address found');
                    this.toastError(component,errorAddress);
                    var dismissActionPanel1=$A.get("e.force:closeQuickAction")
                    dismissActionPanel1.fire();
                    $A.get('e.force:refreshView').fire();
                   /* var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Warning',
                        mode: 'sticky',
                        type:'error',
                        duration : 20,
                        message: 'Please set the address on the case'
                     
                    });*/
                }else if(result['No Asset found']!=null){
                    console.log('errore - No Asset found');
                    this.toastError(component,'No Asset found');
                    var dismissActionPanel2=$A.get("e.force:closeQuickAction")
                    dismissActionPanel2.fire();
                      $A.get('e.force:refreshView').fire();
                   /* var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Warning',
                        mode: 'sticky',
                        type:'error',
                        duration : 20,
                        message: 'There are not any Asset to be related'
                    
                    });*/
                }/*else if(result[caseClone]!=null){
                    console.log('The Case is cloned')
                    this.toastError(component,caseClone);
                    $A.get("e.force:closeQuickAction").fire();
                    var dismissActionPanel4=$A.get("e.force:closeQuickAction")
                    dismissActionPanel4.fire();
                    $A.get('e.force:refreshView').fire();
                }*/
         }
      }
    })
   $A.enqueueAction(action);
	},
      updateSubmit : function (component, event, helper){
        var dataTable ;
        var selectedRows = [];
        var subType = null;
        if(component.get("v.isLogical")  ){
            var dataTable = component.find('datatableIDLogicalAsset');
            selectedRows = dataTable.getSelectedRows(0);
        }//DeAv 08.07.2022 - NR2330 START
        else if(component.get("v.isNetwork")){
            var dataTable = component.find('datatableIDAllNetworks');
            selectedRows = dataTable.getSelectedRows(0);
        }
        //DeAv 08.07.2022 - NR2330 END
        else {
            var dataTable = component.find('datatableIDTechinicalAsset');
            selectedRows = dataTable.getSelectedRows(0);
        }

        if(component.find('SubType') ){
            if(component.get("v.choosenSubtype")== null || component.get("v.choosenSubtype")== '' ){
                this.toastError(component, $A.get("$Label.c.XC_CL_Case_InsertAssetSubtype"));
                return;
            }else{
                subType = component.get("v.choosenSubtype");
            }
        }  
        if(component.find("checkbox")){
            var checkCmp = component.find("checkbox");
            component.set("v.showCaseForceWorkOrder", checkCmp.get("v.value"));
        }
        

        var recordId = component.get("v.recordId");
        var ItemsToUpdate = [];
        var errorForceWorkOrderCreation=$A.get("$Label.c.XC_CL_CaseErrorMessage_TechnicalAsset");
        var woRelatedToThCase=$A.get("$Label.c.XC_CL_CaseErrorMessage_WoMal");
        var caseLinkedToaParent=$A.get("$Label.c.XC_CLCaseErroreMessage_CaselinkedtoParent");  
        for (var i = 0; i < selectedRows.length; i++){
             var selectedRowsToPass = selectedRows[i];
            var itemRows = {Id: selectedRowsToPass.Id};
            var itemID = itemRows.Id;
            ItemsToUpdate.push(itemRows);
             component.set("v.showSpinner", true);
             var action = component.get("c.caseUpdate");
            action.setParams({
                'recordId' : recordId,
                'assetId': itemID,
                'assetSubtype': subType,
                'forceWOCreation' : component.get("v.showForceWorkOrder")
            });
              action.setCallback(this, function(a){
                var state = a.getState();
                if (state === "SUCCESS"){
                    var res=a.getReturnValue();
                  //   $A.get("e.force:closeQuickAction").fire();
                      // $A.get('e.force:refreshView').fire();
                    if(res=='The Asset is just related to the Case'){
                        this.toastError(component,res);
                        var dismissActionPanel3=$A.get("e.force:closeQuickAction");
                        dismissActionPanel3.fire();
                         $A.get('e.force:refreshView').fire();
                       //  $A.get('e.force:refreshView').fire();
                        // window.location = "/lightning/r/Case/"+recordId+"/view";
                    }else if(res==errorForceWorkOrderCreation){
                         this.toastError(component,res);
                        var dismissActionPanel4=$A.get("e.force:closeQuickAction");
                        dismissActionPanel4.fire();
                       $A.get('e.force:refreshView').fire();
                      // window.location = "/lightning/r/Case/"+recordId+"/view";    
                    }else if(res!= recordId){
                        this.toastError(component,res);
                        var dismissActionPanel5=$A.get("e.force:closeQuickAction");
                       dismissActionPanel5.fire();
                      $A.get('e.force:refreshView').fire(); 
                       //window.location = "/lightning/r/Case/"+recordId+"/view"; 
                    }/*else if(res==caseLinkedToaParent){
                        this.toastError(component,res);
                        var dismissActionPanel6=$A.get("e.force:closeQuickAction");
                       dismissActionPanel6.fire();  
                       $A.get('e.force:refreshView').fire(); 
                    }*/
                    else{
                        console.log('res '+res);
                        this. ToastSuccess(component,'Operation successfull');
                        window.location = "/lightning/r/Case/"+res+"/view";    
                    }                
              }
                else{
                    $A.get("e.force:closeQuickAction").fire();
                    }
                component.set("v.showSpinner", false); 
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
         ToastSuccess : function(component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: message,
            messageTemplate: message,
            duration: '100',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
})