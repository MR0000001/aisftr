({
    doInit : function(component, event, helper) { 
        let accountType = component.get("v.accountType"); 
        if(accountType === 'XC_GLO_Account_Condominium' ||
            accountType === 'XC_GLO_Account_Soho' || accountType === 'XC_GLO_B2B' || accountType === 'XC_GLO_B2G' || accountType.includes('SFM')){
            component.set('v.showLanguage', true);
        }else{
            component.set('v.showLanguage', false);
        }
        if(accountType.includes('SFM')){
            component.set('v.showDocumentType', false);
        }
        let action = component.get("c.retrieveLanguagePicklist");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = JSON.parse(response.getReturnValue());
                console.log('****reslt****',result);
                component.set('v.languageOptions', result.languageTypes);
                
            }
        });
        $A.enqueueAction(action);  

        component.set("v.newSection.DocumentCountry", component.get("v.userCountry"));
        console.log(component.get("v.userCountry"));
        if(component.get("v.userCountry") == 'Spain') {
            component.set("v.newSection.PhonePrefix", '+34');
            component.set("v.newSection.MobilePrefix", '+34');
            // component.set("v.setDependent",true);
        }else if(component.get("v.userCountry") == 'Colombia'){
            component.set("v.newSection.PhonePrefix", '+57');
            component.set("v.newSection.MobilePrefix", '+57');
        }else if(component.get("v.userCountry") == 'Chile'){
           
            component.set("v.newSection.PhonePrefix", '+56');
            component.set("v.newSection.MobilePrefix", '+56');
        }

        if (accountType === 'XC_GLO_Account_Soho') {
            let requiredField = component.get("v.requiredField");
            requiredField.DocumentCountry = true;
            requiredField.DocumentType = true;
            requiredField.DocumentID = true;
            component.set("v.requiredField", requiredField);
        }

        if((accountType === 'XC_GLO_B2B' || accountType === 'XC_GLO_B2G') && component.get("v.userCountry") != 'Chile' && component.get("v.userCountry") != 'Colombia'){
            let requiredField = component.get("v.requiredField");
            requiredField.Email = true;
            component.set("v.requiredField", requiredField);
        }
        let actualDocCountry = component.get("v.newSection.DocumentCountry");
       /* if (accountType === 'XC_GLO_Account_Soho') {
            component.set('v.newSection.DocumentType','Passport');
        }*/

        
        console.log('@@@ actualDocCountry -> ', actualDocCountry);
        if((actualDocCountry != 'undefined' && actualDocCountry!='')||accountType.includes('SFM')) {
            component.set("v.docCountryOK", false);  
        }
    },

    retrieveDefaultDocumentTypeHelper: function(component,event,helper) {
        let action = component.get("c.retrieveDefaultDocumentType");
        let actualDocCountry = component.get("v.newSection.DocumentCountry");

        if (typeof(actualDocCountry) === 'undefined') {
            component.set("v.docCountryOK", true);
            return;
        }

        if (component.get("v.accountType") !='XC_GLO_Account_Soho') {
            return;
        }
        

        action.setParams({
            "defaultDependetDocumentCountry": component.get("v.newSection.DocumentCountry")
        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = JSON.parse(response.getReturnValue());
                console.log('****reslt DT****', result);
                let documetType = result.defaultDocumentType;
                if(documetType!= null) {

                    component.set('v.newSection.DocumentType', documetType);
                    component.set("v.docCountryOK", false); 
                } else {
                    component.set("v.docCountryOK", true);
                }

            }
        });

        $A.enqueueAction(action);
        
    }
    
})