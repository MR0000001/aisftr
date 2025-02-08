({

    /*
     * This finction defined column header
     * and calls getProduct2 helper method for column data
     * editable:'true' will make the column editable
     * */
    doInit: function (component, event, helper) {
        helper.retrieveContract(component, event, helper);
        helper.defaultSAPContratto(component, event, helper);


        //From Community
        component.set('v.columns', [{
                label: 'Nome Comune',
                fieldName: 'AccountName',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Provincia ',
                fieldName: 'AddressProvince',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Contratto passivo SFA',
                fieldName: 'ContractNumber',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Nome Rete',
                fieldName: 'Name',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Telefono',
                fieldName: 'AvailablePhone',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Email',
                fieldName: 'AvailableEmail',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Data Schedulazione',
                fieldName: 'ChangeDate',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Nuovo Contratto',
                fieldName: 'NewPartnerContract',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Nuovo Tel',
                fieldName: 'NewAvailablePhone',
                type: 'text',
                initialWidth: 150
            },
            {
                label: 'Nuova Email',
                fieldName: 'NewAvailableEmail',
                type: 'text',
                initialWidth: 150
            }


        ]);
    },
    getAsset: function (component, event, helper) {
        
        console.log('@@inside getAsset');
        if (component.find("Cerca").get("v.disabled")) {
            component.find("Data di Avvicendamento").set("v.disabled", false);
            
        } else {
            component.find("Data di Avvicendamento").set("v.disabled", true);
            component.find("Nuovo Contratto").set("v.disabled",false);
            component.find("Nuovo Numero di telefono").set("v.disabled", false);
            component.find("Nuova Email").set("v.disabled", false);
            component.find("flagForSchedulaId").set("v.disabled", false);
            component.find("flagForAnnullaSchedulazione").set("v.disabled", false);
            component.find("flagForRimuoviContratto").set("v.disabled", false);
        }
        helper.populateNuovoContratto(component, event, helper);
        helper.retrieveAsset(component, event, helper);
        component.set("v.isModalOpen", true);
     },
    
    onFieldKeyUp: function (component, event, helper) {
        var fieldValue = component.get("v.fieldValue");
        if(((component.find("Nuova Email").get("v.value").length != 0) || (component.find("Nuovo Numero di telefono").get("v.value").length != 0) || (component.find("Nuovo Contratto").get("v.value").length != 0)) && ((component.get("v.selected")).length != 0)){
            component.find("conferma").set("v.disabled", false);    
        }
        else{
            component.find("conferma").set("v.disabled", true);
        } 
        if(fieldValue.length >= 3){
            helper.populateNuovoContratto(component, event, helper);
            component.set("v.isDisabled",false);
        }else{
            component.set("v.isDisabled",true);
        }
    
    },
    onOptSelection: function (component, event, helper) {
        var contrattoValues = component.get("v.contrattoValues");
        var inputVal = contrattoValues[event.currentTarget.dataset.record].XC_ContractSAP__c;
        console.log('@@ value =>'+ inputVal);
        component.set("v.fieldValue",inputVal);
        component.set("v.isDisabled",true);
    },

    getAnnullaSchedula: function (component, event, helper) {

        if(component.find("flagForAnnullaSchedulazione").get("v.checked")){
            component.set("v.isSchedulaDisabled",true);
            component.set("v.isRimuoviDisabled",true);
            component.set("v.selectCheckbox",'AnnullaSchedulazione');
            if((component.get("v.selected")).length != 0){
                component.find("conferma").set("v.disabled", false);
            }
        }else {
            component.set("v.isSchedulaDisabled",false);
            component.set("v.isRimuoviDisabled",false);
            component.set("v.selectCheckbox","");
            component.find("conferma").set("v.disabled", true);
        }

        if ((!(component.find("Nuovo Contratto").get("v.disabled"))) && (!(component.find("Nuovo Numero di telefono").get("v.disabled"))) && (!(component.find("Nuova Email").get("v.disabled")))) {
            component.find("Nuovo Contratto").set("v.disabled",true);
            component.find("Nuovo Numero di telefono").set("v.disabled",true);
            component.find("Nuova Email").set("v.disabled", true);    
        } else {
            component.find("Nuovo Contratto").set("v.disabled",false);
            component.find("Nuovo Numero di telefono").set("v.disabled", false);
            component.find("Nuova Email").set("v.disabled", false);
            component.find("Nuovo Contratto").set("v.value","");
            component.find("Nuovo Numero di telefono").set("v.value","");
            component.find("Nuova Email").set("v.value","");       
        }
        

       
    },
    
    onRowSelection: function (component, event, helper) {
        let selectedRows = event.getParam('selectedRows');
        component.set("v.selected", selectedRows);
        var selected = component.get("v.selected");
        console.log('@@selected =>' + selected.Id);
        console.log('@@selectedRows =>' + JSON.stringify(selectedRows));
        console.log('@@s: =>' + selectedRows);
        //showConferma(component, event, helper);
        if(selectedRows.length == 0){
            component.find("conferma").set("v.disabled", true);    
        }
        else{
            if(((component.find("Nuova Email").get("v.value").length != 0) || (component.find("Nuovo Numero di telefono").get("v.value").length != 0) || (component.find("Nuovo Contratto").get("v.value").length != 0) ) || (component.find("flagForRimuoviContratto").get("v.checked")) || (component.find("flagForAnnullaSchedulazione").get("v.checked"))){
            component.find("conferma").set("v.disabled", false);    
        }
        }
           },
    
    showConferma: function (component, event, helper) {
         if(((component.find("Nuova Email").get("v.value").length != 0) || (component.find("Nuovo Numero di telefono").get("v.value").length != 0) || (component.find("Nuovo Contratto").get("v.value").length != 0)) && ((component.get("v.selected")).length != 0)){
            component.find("conferma").set("v.disabled", false);    
        }
        else{
            component.find("conferma").set("v.disabled", true);
        } 
    },
    
    getSchedula: function (component, event, helper) {
        if (component.find("Data di Avvicendamento").get("v.disabled")) {
            component.find("Data di Avvicendamento").set("v.disabled", false);
        } else {
            component.find("Data di Avvicendamento").set("v.disabled", true);
            component.find("Data di Avvicendamento").set("v.value","");
        }
        if(component.find("flagForSchedulaId").get("v.checked")){
            component.set("v.isAnnullaDisabled",true);
            component.set("v.isRimuoviDisabled",true);
            component.set("v.selectCheckbox",'Schedula');
        }else {
            component.set("v.isAnnullaDisabled",false);
            component.set("v.isRimuoviDisabled",false);
            component.set("v.selectCheckbox","");
        }
         
    },
    activeCerca: function (component, event, helper) {
        if (component.find("Contratto").get("v.value").length != 0) {
            component.find("Cerca").set("v.disabled", false);
        }
        else{
            console.log('@length'+component.find("Contratto").get("v.value").length);
            component.find("Data di Avvicendamento").set("v.disabled", true);
            component.find("Nuovo Contratto").set("v.disabled",true);
            component.find("Nuovo Numero di telefono").set("v.disabled", true);
            component.find("Nuova Email").set("v.disabled", true);
            component.find("flagForSchedulaId").set("v.disabled", true);
            component.find("flagForAnnullaSchedulazione").set("v.disabled", true);
            component.find("flagForRimuoviContratto").set("v.disabled", true);
            component.find("Cerca").set("v.disabled", true);
        }
    },
    clickConferma: function (component, event, helper) {
 
     

        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var fordate = component.find("Data di Avvicendamento").get("v.value");
        if(fordate == null)
           fordate = "";
        console.log('@@@' + fordate);
        if ((fordate !== "" && fordate <= today ) ||(fordate.length === 0  && (component.find("flagForSchedulaId").get("v.checked")))) {
            component.find('notifLib').showToast({
                "variant": "Error",
                "title": "Error!",
                "message": "È necessario inserire una data avvicendamento maggiore della data odierna"              
            })
        }
        
                else{
            console.log('@@inside clickConferma');
            helper.retrieveClickConferma(component, event, helper);
        }
       
    },
    getRimuoviContratto: function (component, event, helper) {

        if(component.find("flagForRimuoviContratto").get("v.checked")){
            component.set("v.isSchedulaDisabled",true);
            component.set("v.isAnnullaDisabled",true);
            component.set("v.selectCheckbox",'RimuoviContratto');
            if((component.get("v.selected")).length != 0){
                component.find("conferma").set("v.disabled", false);
            }
        }else {
            component.set("v.isSchedulaDisabled",false);
            component.set("v.isAnnullaDisabled",false);
            component.set("v.selectCheckbox","");
            component.find("conferma").set("v.disabled", true);
        }


        if ((!(component.find("Nuovo Contratto").get("v.disabled"))) && (!(component.find("Nuovo Numero di telefono").get("v.disabled"))) && (!(component.find("Nuova Email").get("v.disabled")))) {
            component.find("Nuovo Contratto").set("v.disabled",true);
            component.find("Nuovo Numero di telefono").set("v.disabled",true);
            component.find("Nuova Email").set("v.disabled", true);  
            component.find("Nuovo Contratto").set("v.value","");
            component.find("Nuovo Numero di telefono").set("v.value","");
            component.find("Nuova Email").set("v.value","");
        } else {
            component.find("Nuovo Contratto").set("v.disabled",false);
            component.find("Nuovo Numero di telefono").set("v.disabled", false);
            component.find("Nuova Email").set("v.disabled", false);
            component.find("Nuovo Contratto").set("v.value","");
            component.find("Nuovo Numero di telefono").set("v.value","");
            component.find("Nuova Email").set("v.value","");       
        }
    },

})