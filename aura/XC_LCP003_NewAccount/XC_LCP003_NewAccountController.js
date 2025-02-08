({
    init : function(component, event, helper) {
        helper.doInit(component, event, helper);
        helper.isSpain(component);
    },
    
    onSubmit : function(component, event, helper) {
        helper.onSubmitHelper(component, event, helper);
    }, 
    
    assignLeadChecked : function(component, event, helper) {
        helper.assignLeadCheckedHelper(component, event);
    },
    checkIfNIE : function(component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue != 'undefined' && selectedOptionValue==='NIE'){
            component.set("v.showReleaseDate", true);
        }else{
            component.set("v.showReleaseDate", false);
        }
    },
    
    handleComponentEvent :  function(component, event, helper) {
        console.log('ricevuto');
        let map = event.getParam("address");
        console.log('ricevuta mappa '+JSON.stringify(map));
        let withoutValidate = event.getParam("withoutValidate");
        component.set("v.withoutValidate",withoutValidate);
        let mandatoryFields = event.getParam("checkValue");
        component.set("v.addressMandatoryFields", mandatoryFields);
        
        component.set("v.addressFromEvent", map);
        //component.set("v.checkValue", checkedValue);
        component.set("v.changeIcon", true);

    },
    
    handleLEConsentsEvent :  function(component, event, helper) {
        let relatedObject = event.getParam("relatedObject");
        if(relatedObject === 'Account'){
            let consentsLE = event.getParam("consentsLE");
            let robinsonCustomer = event.getParam("robinsonCustomer");
            let thirdPartiesCheck = event.getParam("thirdPartiesCheck");
            let thirdPartiesVersion = event.getParam("thirdPartiesVersion");
            component.set("v.consentsLE", consentsLE);
            component.set("v.robinsonCustomer", robinsonCustomer);
            component.set("v.thirdPartiesCheck", thirdPartiesCheck);
            component.set("v.thirdPartiesVersion", thirdPartiesVersion);
        }
    },
    
    handleLEConsentsEventNEW :  function(component, event, helper) {
        let relatedObject = event.getParam("relatedObject");
        if(relatedObject === 'Account'){
            let consentsLE = event.getParam("consentsLE");
            let robinsonCustomer = event.getParam("robinsonCustomer");
            let thirdPartiesCheck = event.getParam("thirdPartiesCheck");
            let thirdPartiesVersion = event.getParam("thirdPartiesVersion");
            component.set("v.consentsLE", consentsLE);
            component.set("v.robinsonCustomer", robinsonCustomer);
            component.set("v.thirdPartiesCheck", thirdPartiesCheck);
            component.set("v.thirdPartiesVersion", thirdPartiesVersion);
        }
    },
    
    setAddressOpenable : function(component, event, helper) {
        console.log('catturato');
        let alwaysSet = event.getParam("alreadyPush"); 
        component.set("v.insertAddressClicked", true);
        component.set("v.alreadyPush", alwaysSet);
    },

    
    redirectToExistingAcc : function(component, event, helper) {
        helper.redirectToExistingAccHelper(component, event, helper);
    },
    
    goBack : function(component, event, helper) { 
        helper.goBack(component, event);
        
    },
    /*changePickVal : function(component, event, helper) {
        helper.changePickVal(component, event);
    },*/
    
    goBackInCommunity : function(component, event, helper) {
        let windowRedirect = window.location.href;
        window.location.href = windowRedirect;    
    }, 
    
    openInsert : function(component, event, helper) {
        component.set("v.insertAddressClicked", false);
        helper.openInsert(component, event, helper);
        
    }, 
    
    goOnExistingAccount : function(component, event, helper) {
        let existingAccId = component.get('v.existingAccId');
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": existingAccId,
            "slideDevName": "related"
        }); 
        navEvt.fire();
    },

    setAddressOn : function(component, event, helper) {
        let checkbox = component.get("v.showAddress");
        if(checkbox){
             component.set("v.showAddress", false);
        }else{
             component.set("v.showAddress", true);
        }
    },
    setDocOn : function(component, event, helper) {
        let checkbox = component.get("v.showDocument");
        
        if(checkbox){
             var identityN =  component.find("IdentityNumber__c").get("v.value");
             component.set("v.numberAppoggio", identityN);
             //var exDate =  component.find("XC_NIE_expiration_date__c").get("v.value");
             var exDate = component.get("v.expDate");
             component.set("v.exDateAppoggio", exDate);
             if(component.find("XC_NIE_expedition_date__c") != 'undefined' && component.find("IdentityType__c")==='NIE'){
                 //var rDate =  component.find("XC_NIE_expiration_date__c").get("v.value");
                 var rDate = component.get("v.expDate");
                 component.set("v.rDateAppoggio", rDate);
             }
             component.set("v.showDocument", false);
        }else{
            
             component.set("v.showDocument", true);
             component.find("IdentityNumber__c").set("v.value",  component.get("v.numberAppoggio") );
             //component.find("XC_NIE_expiration_date__c").set("v.value",  component.get("v.exDateAppoggio") );
             component.set("v.expDate", component.get("v.exDateAppoggio"));
             if(component.find("XC_NIE_expedition_date__c") != 'undefined' && component.find("IdentityType__c")==='NIE'){
             component.find("XC_NIE_expedition_date__c").set("v.value",  component.get("v.rDateAppoggio") );
                
            }
            
        }
    }, 

     handleSaveConsentsEvent: function (component, event, helper) { //dpalamides
             let relatedObject = event.getParam("consentsWrapper");
             component.set("v.saveConsentsWrapper",relatedObject);
             console.log("consentsEvent:"+JSON.stringify(relatedObject));
     },

     //fimperioli
     handleSohoTypeChange : function(component,event,helper){
        console.log("changevalevent on sohotype : " + event.getSource().get("v.value"));
        helper.handleSohoType(component,event,helper);

     },
     changeConfirmationByTheCustomer : function(component, event, helper) {
         let boolVal = !component.get("v.confirmationByTheCustomer");
         component.set("v.confirmationByTheCustomer",boolVal);
         component.set("v.accountRecord.XC_ConfirmationByCustomer__c",boolVal);
         //let cmpTarget = component.find('confirmationByCutomerCheck');
         //$A.util.removeClass(cmpTarget, 'slds-has-error ');

     }
})