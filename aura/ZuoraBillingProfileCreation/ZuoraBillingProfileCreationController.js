({
	doInit : function(component, event, helper) {

		helper.init(component, event, helper);
	},
    create :  function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.retriveContactsForZuora(component, event, helper, '');
    },
    showDocumentSection :  function(component, event, helper) {
          component.set("v.showDocument", true);
          component.set("v.showSpinner", true);
          setTimeout(function(){
                          helper.checkValue(component, event, helper);
                      }, 1200);

    },

    closeModal : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var res = component.get("v.fromOrderComponent");
        if(res) {
             var b = true;
  			 var cmpEvent = $A.get("e.c:XC_LCE016_RefreshView");
        	 cmpEvent.setParams({
             "refreshView" : b
        	});
             cmpEvent.fire();
             workspaceAPI.getFocusedTabInfo().then(function(response) {
			 var focusedTabId = response.tabId;
			 workspaceAPI.closeTab({tabId: focusedTabId});

       })

        }else{
            helper.closeModalZuora(component,event,helper);
            //$A.get("e.force:closeQuickAction").fire();
        }

	},

    invoiceDeliveryPreferencesChange : function(component, event,helper){

        var selectedValues =  component.get("v.boolCheck");
        console.log('selectedValues INIZIO ='+selectedValues);

        if(!selectedValues){
            console.log('entrato in include');
            component.set("v.valueCheck","Print");
            component.set("v.boolCheck",true);
        }

        else {

             component.set("v.valueCheck","Email");
             component.set("v.boolCheck",false);
        }

         console.log('selectedValues FINE=' + component.get("v.boolCheck"));
    },

    checkPayment : function(component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue != 'undefined' && selectedOptionValue!='' && selectedOptionValue==='Commodity Bill'){
             //helper.checkPayment(component, event, helper);
            if((component.get("v.recordTypeName")==='XC_GLO_Account_Soho' || component.get("v.recordTypeName")==='XC_GLO_Account_Condominium') && //!component.get("v.isB2BLE")){
                component.get("v.getContractBy") === 'IdentityDoc'){
                helper.getB2CCommodityContract(component,event,helper);
            }

        }else{
            helper.checkValue(component, event, helper);
        }
    },

    onCheckTax : function(component, event, helper) {
        var isChecked = component.get('v.taxExemptStatus');
        if(isChecked!=null && isChecked!='undefined'){
            var newVal = isChecked == "false" ? "true" : "false";
            component.set("v.taxExemptStatus",newVal);
        }
        helper.checkValue(component, event, helper);
    },

    checkValue : function(component, event, helper) {
        helper.checkValue(component, event, helper);
    },

    onChooseCommodityPOS : function(component, event, helper) {
        var typeRetrive = component.get('v.getContractBy');
        if( typeRetrive== 'AccountDocAndPOD'){
            //helper.onChooseCommodityPOSAndAccountDoc(component, event, helper);
        }else if(typeRetrive== 'POS'){
            helper.onChooseCommodityPOS(component, event, helper);
        }
    },

    /*commodityPosChanged : function(component, event, helper) {
        helper.commodityPosChanged(component, event, helper);
    },*/

    updateAccount: function(component, event, helper){
        var doxeeSelectedLanguage = component.find("comboboxdoxee").get("v.value");
        //alert('selectedValues -->'+doxeeSelectedLanguage);
        if( doxeeSelectedLanguage != null && doxeeSelectedLanguage != undefined){
            var mapValues = {PreferredLanguage__c: doxeeSelectedLanguage};

            helper.updateAccount(component, event, helper,JSON.stringify(mapValues));

        }
        helper.checkValue(component, event, helper);
    },

    retrieveContractAndCups: function(component, event, helper){
        component.set("v.showStrikeModal",true);
        helper.retrieveCupsAndContract(component, event, helper);
    },

    setLegalEntity: function(component, event, helper){
        var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue != 'undefined' && selectedOptionValue!=''){
            component.set("v.valueMap.legal", selectedOptionValue);
        }
        helper.checkValue(component, event, helper);
    },

    updateSelectedText : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        selectedRows = selectedRows[0];
        helper.populateAllField(component, event, helper, selectedRows) ;

    },
    /*findContract : function(component, event, helper) {
        var contractValue = component.get("v.contractValue");
        if(contractValue!=''){
    		component.set("v.valueMap.contractId", contractValue);
        }
    },*/
    handlePrimaryButtonClick : function(component, event, helper) {
        component.set("v.showStrikeModal",false);
    },

    retrieveCupsId : function(component, event, helper) {
        //if(component.get("v.isB2BLE")){
        if(component.get("v.valueMap.payment") === 'Commodity Bill' && component.get("v.getContractBy") === 'POS' ){
            helper.retrieveCups(component, event, helper);
        }else if(component.get("v.valueMap.payment") === 'Commodity Bill' &&  component.get("v.getContractBy") === 'AccountDocAndPOD'){
            helper.retrieveCupsByDocAndPOS(component, event, helper);
        }
    },

    onChangePayTerm : function(component,event,helper){
        let selectedPayTerm = event.getParam("value");
        if(selectedPayTerm){
            component.set("v.paymentTerm",selectedPayTerm);
        }
    },
    checkContact: function(component, event, helper){
        helper.retrieveLegalEntities(component, event, helper);
        if(component.get("v.invoiceDelValue") == 'Email'){
            var actionCheckContact = component.get("c.checkContactEmail");
            var contactId = component.get(" v.valueMap.soldContact ");
            actionCheckContact.setParams({
                "contactId": contactId
            }); 
            actionCheckContact.setCallback(this, function (response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS" && !res ) {
                    var toastEvent = $A.get("e.force:showToast");
                    var title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                    var message = $A.get("$Label.c.XC_CL_BillingProfile_ContactWithoutEmail");
                    toastEvent.setParams({
                        "title": title,
                        "message": message,
                        "type": 'error'
                    });
                	toastEvent.fire();
                    component.set("v.disabledSubmit", true);
                    component.set("v.validInvoiceChannel", false);
                }else{
                    //component.set("v.disabledSubmit", false);
                    component.set("v.validInvoiceChannel", true);
                    helper.checkValue(component, event, helper);
                }
            });

            $A.enqueueAction(actionCheckContact);
        }else {
            //component.set("v.disabledSubmit", false);
            helper.checkValue(component, event, helper);
        }
    },

    checkCommodity: function(component,event,helper){
        //if(!component.get('v.isB2BLE')){
        if(component.get("v.getContractBy") === 'IdentityDoc' && component.get('v.valueMap.payment')==='Commodity Bill'){
            helper.getB2CCommodityContract(component,event,helper);
        }
        //}
    },

    onChooseCommodityContract : function(component,event,helper){
        helper.onChooseCommodityContract(component,event,helper);
    },

    checkExternalFinancing : function(component,event,helper){
        if(component.get("v.institutePickVal")){
            if(component.get("v.institutePickVal") === 'Other'){
                component.set("v.showOtherExtFinancing",true);
            }else{
                component.set("v.showOtherExtFinancing",false);
            }
        }
        helper.checkValue(component,event,helper);
    }
})