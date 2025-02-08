/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @date listNew - 18/10/2019
    **/
public with sharing class XC_TR_ConsentDescription_CheckStatus {
    /**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List<XC_ConsentDescription__c>
    **/
    public static void existingRecord(List<XC_ConsentDescription__c> listNew){
        List<String> listStringCountry = new List<String>();
        List<String> listStringLegalEntity = new List<String>();
        for(XC_ConsentDescription__c cd: listNew){
            listStringCountry.add(cd.XC_Country__c);
            listStringLegalEntity.add(cd.XC_LegalEntity__c);
        }
        List<XC_ConsentDescription__c> listExisitingRecord = new List<XC_ConsentDescription__c>();
        listExisitingRecord = retriveRecord();
        checkExsisting(listExisitingRecord,listNew);

    }

    private static List<XC_ConsentDescription__c> retriveRecord(){
        List<XC_ConsentDescription__c> listExisitingRecord = new List<XC_ConsentDescription__c>();
        if(Schema.sObjectType.XC_ConsentDescription__c.isAccessible()){
            listExisitingRecord = [SELECT ID,XC_Country__c,XC_LegalEntity__c, XC_ConsentStatus__c FROM XC_ConsentDescription__c where XC_ConsentStatus__c = 'Active' /*WHERE XC_Country__c IN : listStringCountry AND XC_LegalEntity__c IN :listStringLegalEntity*/];
        }
        return listExisitingRecord;

    }

    private static void checkExsisting (List<XC_ConsentDescription__c> retriveRecord, List<XC_ConsentDescription__c> listNew){
        for(XC_ConsentDescription__c newRecord : listNew){
            for(XC_ConsentDescription__c retriveR : retriveRecord){
                if(retriveR.XC_ConsentStatus__c == 'Active' && newRecord.XC_ConsentStatus__c == 'Active'){
                    if(newRecord.XC_Country__c == retriveR.XC_Country__c && newRecord.XC_LegalEntity__c == retriveR.XC_LegalEntity__c){
                        newRecord.addError(Label.XC_CL_ActiveConsentDescriptionErr);
                    }
                }
            }
        }
    }
    /**
      * @author Donato Lombardi - dolombardi@deloitte.it
      * @description Method to retrieve a Map of Work Order -> List skills requested
      * @param mapNew - Map<Id,XC_ConsentDescription__c>
      * @param mapOld - Map<Id,XC_ConsentDescription__c>
     **/
    public static void checkStatusBeforeUpdate(Map<Id,XC_ConsentDescription__c> mapNew,Map<Id,XC_ConsentDescription__c> mapOld){
        List<XC_ConsentDescription__c> listRecordChange = new List<XC_ConsentDescription__c>();
        listRecordChange = checkIsChanged(mapNew,mapOld);
        List<XC_ConsentDescription__c> listRetriveRecord = new List<XC_ConsentDescription__c>();
        if(!listRecordChange.isEmpty()){
            listRetriveRecord= retriveRecord();
            if(!listRetriveRecord.isEmpty()){
                checkExsisting(listRetriveRecord,listRecordChange);
            }
        }


    }

    private static List<XC_ConsentDescription__c> checkIsChanged(Map<Id,XC_ConsentDescription__c> mapNew,Map<Id,XC_ConsentDescription__c> mapOld){
        List<XC_ConsentDescription__c> listRecordChange = new List<XC_ConsentDescription__c>();
        for(XC_ConsentDescription__c newR : mapNew.values()){
            for(XC_ConsentDescription__c oldR : mapOld.values()){
                if(newR.id == oldR.id){
                    XC_ConsentDescription__c description = checkField(newR,oldR);
                    if(description != null) {
                        listRecordChange.add(checkField(newR, oldR));
                    }
              }
            }
        }
        return listRecordChange;

    }

    private static XC_ConsentDescription__c checkField( XC_ConsentDescription__c newR, XC_ConsentDescription__c oldR){
        if(newR.XC_ConsentStatus__c == 'Active' && oldR.XC_ConsentStatus__c != newR.XC_ConsentStatus__c
                ||newR.XC_Country__c != oldR.XC_Country__c || newR.XC_LegalEntity__c != oldR.XC_LegalEntity__c ){
                return newR;
        }
        return null;
    }


 

}