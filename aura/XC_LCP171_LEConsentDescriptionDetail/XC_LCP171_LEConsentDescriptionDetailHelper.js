/**
    *@author Francesco Imperioli - fimperioli@deloitte.it
    *@date 13/5/2020
    *@Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 27/10/2020
    *@description XC_LCP171_LEConsentDescriptionDetailHelper - Helper Javascript for component LCP171
*/

({
    doInit : function(component,event,helper) {
        // let descriptionId = component.get("v.leRecord.XC_ConsentDescription__c");
        let objectName = component.get("v.sObjectName");
        if(objectName=="XC_LegalEntityConsent__c") {
            component.set("v.isLegalEntityConsentObj",true);
            helper.initFromLeConsentRecord(component,event,helper);
        }
    },

    initFromLeConsentRecord : function(component,event,helper) {
        let recordId = component.get("v.recordId");
        let initAction = component.get("c.getConsentsDescriptionInfo");
        initAction.setParams({
            leConsentId : recordId
        });
        initAction.setCallback(this,function(response) {
            if(response.getState() === "SUCCESS") {
                let result = response.getReturnValue();
                if(result.length > 0) {
                    result.forEach(element => {
                        let nameLabel = element.helpText;
                        // C'è un errore di Salesforce: quando si sistemerà bisognerà renderlo dinamico (eliminare lo switch/case):
                        switch(nameLabel) {
                            case "XC_CL_Consents_Profiling":
                                element.helpText = $A.get("$Label.c.XC_CL_Consents_Profiling");
                                break;
                            case "XC_CL_NotCustomerConsens":
                                element.helpText = $A.get("$Label.c.XC_CL_NotCustomerConsens");
                                break;
                            case "XC_CL_Consents_Marketing":
                                element.helpText = $A.get("$Label.c.XC_CL_Consents_Marketing");
                                break;
                            case "XC_CL_Consents_ThirdParty":
                                element.helpText = $A.get("$Label.c.XC_CL_Consents_ThirdParty");
                                break;
                            case "XC_CL_ThirdProductsMarketing":
                                element.helpText = $A.get("$Label.c.XC_CL_ThirdProductsMarketing");
                                break;
                            default:
                                element.helpText = "Error";
                                break;
                        }
                    });
                }
                component.set("v.fieldsList", result);
                component.set("v.urlConsens", result[0].urlConsens);
                helper.initFromIndividual(component,event,helper);
            } else{
                let errorMsg = response.getError()[0].message;
                console.log("@@@ ERROR ON INIT LCP171::: " + errorMsg);
            }
        });
        $A.enqueueAction(initAction);
    },

    initFromIndividual : function(component,event,helper){
        let initAction = component.get("c.getConsentDescriptionInfoIndividual");
        let descrId = component.get("v.leRecord.XC_ConsentDescription__c");
        initAction.setParams({
            descriptionId : descrId
        });
        initAction.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let resultObj = JSON.parse(response.getReturnValue());
                if(resultObj.length > 0) {
                    resultObj.forEach(element => {
                        let nameLabel = element.helpText;
                        // C'è un errore di Salesforce: quando si sistemerà bisognerà renderlo dinamico (eliminare lo switch/case):
                        switch(nameLabel) {
                            case "XC_CL_Consents_Profiling":
                                element.helpText = $A.get("$Label.c.XC_CL_Consents_Profiling");
                                break;
                            case "XC_CL_NotCustomerConsens":
                                element.helpText = $A.get("$Label.c.XC_CL_NotCustomerConsens");
                                break;
                            case "XC_CL_Consents_Marketing":
                                element.helpText = $A.get("$Label.c.XC_CL_Consents_Marketing");
                                break;
                            case "XC_CL_Consents_ThirdParty":
                                element.helpText = $A.get("$Label.c.XC_CL_Consents_ThirdParty");
                                break;
                            case "XC_CL_ThirdProductsMarketing":
                                element.helpText = $A.get("$Label.c.XC_CL_ThirdProductsMarketing");
                                break;
                            default:
                                element.helpText = "Error";
                                break;
                        }
                    });
                }
                component.set("v.individualField",resultObj);
                let objectName = component.get("v.sObjectName");                
                if(objectName=="XC_LegalEntityConsent__c") {
                    component.set("v.isLegalEntityConsentObj",true);
                }
            } else{
                let errorMsg = response.getError()[0].message;
                console.log("@@@ ERROR ON INIT LCP171:::INDIVIDUAL" + errorMsg);
            }
        });
        $A.enqueueAction(initAction);
    }

})