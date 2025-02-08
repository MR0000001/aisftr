/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Contract_U_PopulateField – Class for populate Contract
*/
public without sharing class XC_TR_Contract_U_PopulateField {
    public static void manageInsertContract(List<Contract> listNew){
        Set<String> orderIdSet = XC_UTIL_Sobject.getSetIdsStringOnField(listNew, 'XC_Configurations__c');
        Map<Id,User> mapUser = new Map<Id,User>([Select Id, XC_LegalEntity__c FROM User where id= :UserInfo.getUserId()]);
        User runningUser;
        Boolean userRetrieved = false;
        if(!mapUser.values().isEmpty() ){
            runningUser = mapUser.values()[0];
            userRetrieved = true;
        }

        Map<Id,	NE__Order__c> mapIdOrder = retrieveInfoFromOrder(orderIdSet);

        for(Contract c : listNew ){
            if(c.XC_Configurations__c !=null) {
                c.XC_LegalEntity__c = String.isBlank(c.XC_LegalEntity__c) && mapIdOrder.containsKey(c.XC_Configurations__c) ?  mapIdOrder.get(c.XC_Configurations__c).XC_LegalEntity__c : c.XC_LegalEntity__c;
                c.XC_Segment__c = String.isBlank(c.XC_Segment__c) && mapIdOrder.containsKey(c.XC_Configurations__c) ? mapIdOrder.get(c.XC_Configurations__c).XC_Segment__c : c.XC_Segment__c;
            }
           

            if(String.isBlank(c.XC_LegalEntity__c) && userRetrieved) {
                c.XC_LegalEntity__c = runningUser.XC_LegalEntity__c;
            }
            c.XC_ContractAccount__c = c.AccountId;
        }
    }

    private static Map<Id,NE__Order__c> retrieveInfoFromOrder (Set<String> setOrderId) {
        Map<Id,	NE__Order__c> mapIdOrder = new Map<Id,NE__Order__c>();
        if(!setOrderId.isEmpty()) {
            mapIdOrder = new Map<Id,NE__Order__c>([SELECT Id,XC_LegalEntity__c,XC_Segment__c FROM NE__Order__c where ID IN : setOrderId]);
        }

        return mapIdOrder;
    }
}