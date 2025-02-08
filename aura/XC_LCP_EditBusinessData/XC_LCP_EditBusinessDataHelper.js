({
    retrieveAsset: function (component, event, helper) {
        component.set("v.spinner", true);
        let action = component.get("c.queryAsset");
        action.setParams({
            recordId: component.get("v.recordId"),
            Contract: component.find("Contratto").get("v.value")

        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            let res = response.getReturnValue();
            if (state === "SUCCESS") {
                //component.set("v.data", res);
                let currentData = [];
                for(var i=0; i<res.resultAsset.length;i++ ){
                    var row = res.resultAsset[i];
                    console.log('@row'+JSON.stringify(row));
                    let rowData = {};
                    if(row.Name != null){
                        rowData.Name = row.Name;
                    } 
                    if(row.Account && row.Account.Name){
                        rowData.AccountName = row.Account.Name;
                    }  
                    rowData.AvailablePhone = row.TAM_AvailablePhone__c;
                    rowData.AvailableEmail = row.TAM_AvailableEmail__c;
                    if(row.XC_Address__c && row.XC_Address__r.XC_AddressProvince__c){
                        rowData.AddressProvince = row.XC_Address__r.XC_AddressProvince__c;
                    }
                    if(row.TAM_PartnerContract__c && row.TAM_PartnerContract__r.ContractNumber){
                        rowData.ContractNumber = row.TAM_PartnerContract__r.ContractNumber;
                    }
                   
                    rowData.Id = row.Id ;
                    console.log('@resultAssetExt'+JSON.stringify(res.resultAssetExt));
                    for(var x=0; x<res.resultAssetExt.length;x++ ){
                        if(res.resultAssetExt[x].XC_Asset__c === row.Id){
                            var row1 = res.resultAssetExt[x];
                            console.log('@row1'+JSON.stringify(row1));
                            rowData.ChangeDate = row1.XC_ChangeDate__c ;
                            rowData.NewAvailablePhone = row1.XC_NewTAMAvailablePhone__c ;
                            rowData.NewAvailableEmail = row1.XC_NewTAMAvailableEmail__c ;
                            if(row1.XC_NewTAMPartnerContract__c && row1.XC_NewTAMPartnerContract__r.XC_ContractSAP__c){
                                rowData.NewPartnerContract = row1.XC_NewTAMPartnerContract__r.XC_ContractSAP__c;
                            }
                        }
                    }
                    currentData.push(rowData);
                }
                component.set("v.data",currentData);
                if(currentData.length == 0){
                    component.find('notifLib').showToast({
                        "variant": "Error",
                        "mode": "Sticky",
                        "title": "Error!",
                        "message": "Nessuna rete collegata al contratto specificato"            
                    })

                }
            }

           component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },

    retrieveContract: function (component, event, helper) {
        let action = component.get("c.checkContract");
        action.setParams({
            Contract: component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            let res = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log('@@' + res);
                if (!(res)) {
                    component.find('notifLib').showToast({
                        "variant": "Error",
                        "message": "Errore. La Legal Entity del contratto non è compatibile con questa funzionalità"
                    })
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();

                }


            }

        });

        $A.enqueueAction(action);
    },

    retrieveClickConferma: function (component, event, helper) {
        
        let action = component.get("c.selectConferma");
        console.log('@@inside retrieveClickConferma');
        console.log('@1 =>' + component.find("Nuovo Contratto").get("v.value"));
        var selected = component.get("v.selected");
        var DatadiAvvicendamento;
        if (!(component.find("Data di Avvicendamento").get("v.disabled"))) {
            DatadiAvvicendamento = component.find("Data di Avvicendamento").get("v.value");
        } else {
            DatadiAvvicendamento = null;
        }
        component.set("v.spinner", true);
        console.log('@2=>');
        action.setParams({
            newPartnerContract: component.find("Nuovo Contratto").get("v.value"),
            newAvailablePhone: component.find("Nuovo Numero di telefono").get("v.value"),
            newAvailableEmail: component.find("Nuova Email").get("v.value"),
            //newchangeDate : component.find("Data di Avvicendamento").get("v.value"),
            newchangeDate: DatadiAvvicendamento,
            SelectedRows: selected,
            CheckBox: component.get("v.selectCheckbox")
        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            let res = response.getReturnValue();
            if (state === "SUCCESS") {  
                this.retrieveAsset(component, event, helper)
                if((component.find("Nuova Email").get("v.value").length != 0) || (component.find("Nuovo Numero di telefono").get("v.value").length != 0) || (component.find("Nuovo Contratto").get("v.value").length != 0)){
                 component.find('notifLib').showToast({
                        "variant": "Success",
                        "title": "Success!",
                        "message": "Modifica effettuata correttamente"
                 })}
   
                    //dismissActionPanel.fire();

                //helper.showDetailedToast(component, '', res, "error", "5000");
                //$A.get("e.force:closeQuickAction").fire();

            }
            else{
                if(response.getError()[0].message === 'already scheduled'){
                    component.find('notifLib').showToast({
                        "variant": "Error",
                        "title": "Error!",
                        "message": "E' stato selezionato uno o più asset su cui è già attiva una schedulazione. Annullare la schedulazione attualmente in corso e riprogrammare le modifiche"              
                    })
                }
                //[START R1.2 CR762 12.07.2022 vaibhav.c.anand@accenture.com]
                else if(response.getError()[0].message === 'missing fields'){
                    component.find('notifLib').showToast({
                        "variant": "Error",
                        "title": "Error!",
                        "message": "É necessario specificare i seguenti campi sull'Asset: Contratto Partner, Telefono reperibile, Email reperibile"              
                    })
                }
                //[END R1.2 CR762 12.07.2022 vaibhav.c.anand@accenture.com]
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    populateNuovoContratto: function (component, event, helper) {
        console.log('@@inside populateNuovoContratto=>'+component.find("Contratto").get("v.value"));
        let action = component.get("c.getAccountContracts");
        action.setParams({
            recordId : component.get("v.recordId"),
            contractSAP: component.get("v.fieldValue")
            //contractSAP: component.find("Contratto").get("v.value")
        })
        action.setCallback(this, function (response) {
                let state = response.getState();
                let res = response.getReturnValue();
                if (state === "SUCCESS") {
                    if ((res)) {
                        console.log('@@SUCcess =>' + JSON.stringify(res));
                        component.set("v.contrattoValues",res);
                    }
                }
        })
        $A.enqueueAction(action);
    },
    
     defaultSAPContratto: function (component, event, helper) {
        let action = component.get("c.getSAPContract");
      action.setParams({
            Contract: component.get("v.recordId")
        })
      action.setCallback(this, function (response) {
                let state = response.getState();
                let res = response.getReturnValue();
                if (state === "SUCCESS") {
                    
                        console.log('@@SUCcess =>' + res);
                    if(res.XC_ContractSAP__c !== ""){
                        component.set("v.defaultContratto",res.XC_ContractSAP__c);
                        component.find("Cerca").set("v.disabled", false);
                    }
                        
      
                }
        });
		$A.enqueueAction(action);
}

})