/**
*@author: francesco imperioli - fimperioli@deloitte.it
*@description : manage consent description for new gdpr management
*@history: 2019-12-11 creation
**/
public without sharing class XC_TR_LegalEntity_U_ManageDescription {

    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : manage consent description for new gdpr management - used in before insert
    *@history: 2019-12-11 creation
    **/
    public static void checkDescriptionOnConsent(List<XC_LegalEntityConsent__c> triggerNew){

        Map<String,XC_ConsentDescription__c> descrMap = generateDescriptionMap();
        System.Debug('CONSENT DESCRIPTION CHECK ' + descrMap);
        if(!descrMap.isEmpty()){
            for(XC_LegalEntityConsent__c cons : triggerNew){
                if(String.isNotBlank(cons.XC_LegalEntity__c) && String.isBlank(cons.XC_ConsentDescription__c) && descrMap.containsKey(cons.XC_LegalEntity__c)){
                    System.Debug('CONSENT DESCRIPTION FILL ' + descrMap.get(cons.XC_LegalEntity__c));
                    cons.XC_ConsentDescription__c = descrMap.get(cons.XC_LegalEntity__c).Id;
                    System.Debug('CONSENT DESCRIPTION FILL 2' + cons.XC_ConsentDescription__c);
                }
            }
        }
    }

    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : return le description mapping
    *@history: 2019-12-11 creation
    **/
    private static Map<String,XC_ConsentDescription__c> generateDescriptionMap(){

        Map<String,XC_ConsentDescription__c> leDescriptionMap = new Map<String,XC_ConsentDescription__c>();

        List<XC_ConsentDescription__c> parentDescriptions = [
        SELECT Id,XC_LegalEntity__c
        FROM XC_ConsentDescription__c 
        WHERE XC_ParentDescription__c = null AND XC_ConsentStatus__c = 'Active' ORDER BY CreatedDate DESC];

        if(!parentDescriptions.isEmpty()){
            for(XC_ConsentDescription__c descr : parentDescriptions){
                leDescriptionMap.put(descr.XC_LegalEntity__c,descr);
            }
        }
        return leDescriptionMap;
    }

}