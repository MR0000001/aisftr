/**
* @author Roberta Cossiga - rcossiga@deloitte.it & Marco Rosa - marco.rosa@nttdata.com
* @date Creation  02/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceResource_U_UserTerritory – Create the User Territory on the Root Territory of the Resource
*/

public without sharing class XC_TR_ServiceResource_U_UserTerritory {
    /**
     * @description Create User Territory
     * @param listNew
     */
    public static void checkAccountOnResources (List<ServiceResource> listNew) {
        List<ServiceResource> servResChecked = new List<ServiceResource>();
        for (Serviceresource servRes : listNew){
            if(!String.isBlank(servRes.XC_Account__c)){
                servResChecked.add(servRes);
            }
        }
        if(!servResChecked.isEmpty()){
            createUserTerritoryForRoot(servResChecked);
        }
    }


    /**
     * @description Create User Territory
     * @param listNew
     */
    public static void createUserTerritoryForRoot (List<ServiceResource> listNew){
        List<FSL__User_Territory__c> userTerritoryListToInsert = new List<FSL__User_Territory__c>();
        List<String> listAccount = XC_UTIL_SObject.getListFieldValues(listNew, 'XC_Account__c');
        List<ServiceTerritory> listRootTerritory = new List<ServiceTerritory>(
                                                        [SELECT Id, XC_AccountId__c, XC_IsRoot__c
                                                         FROM ServiceTerritory 
                                                         WHERE XC_AccountId__c IN :listAccount AND XC_IsRoot__c = TRUE]);
        Map<Id,Id> mapAccountTerritory = new Map<Id,Id>();
        for(ServiceTerritory st : listRootTerritory ){
            mapAccountTerritory.put(st.XC_AccountId__c, st.Id);
        }                              
        for(Serviceresource servRes : listNew){
            Id accountId = servRes.XC_Account__c;
            if(mapAccountTerritory.containsKey(accountId)){  
                FSL__User_Territory__c userTerritory = new FSL__User_Territory__c();
                userTerritory.FSL__ServiceTerritory__c = mapAccountTerritory.get(accountId);
                userTerritory.FSL__User__c = servRes.RelatedRecordId;
                userTerritoryListToInsert.add(userTerritory);
            }
        } 
        XC_UTIL_SObject.insertListRecords(userTerritoryListToInsert);
    }

}