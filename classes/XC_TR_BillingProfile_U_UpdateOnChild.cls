/**
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 13/05/2020
 * @description XC_TR_BillingProfile_U_UpdateOnChild – Trigger Util on NE__Billing_Profile__c to manage update on BillingProfileLineItem
*/ 
public without sharing class XC_TR_BillingProfile_U_UpdateOnChild {

    /** 
     * @description Manage status update to update child.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void manageStatusUpdate(List<NE__Billing_Profile__c> listNew, Map<Id,NE__Billing_Profile__c> mapOld, Map<Id,NE__Billing_Profile__c> mapNew){
        List<NE__Billing_Profile__c> listChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_Status__c'}, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            Map<String,List<NE__Billing_Profile__c>> dataGroups = checkChangesFromWaiting(mapOld, mapNew);
            if(!(dataGroups.get('Active').isEmpty()) || !(dataGroups.get('Refused').isEmpty())){
                List<XC_UTIL_Sobject.WrapperResult> updRes = transferStatusOnLastChild(dataGroups);
            }
        }
    }

    /** 
     * @description checkChangesFromWaiting -> groups obj by change status
     * @param mapOld the map old
     * @param mapNew the map new
     * @return data groups
     */
    private static Map<String,List<NE__Billing_Profile__c>> checkChangesFromWaiting(Map<Id,NE__Billing_Profile__c> mapOld, Map<Id,NE__Billing_Profile__c> mapNew){
        Map<String,List<NE__Billing_Profile__c>> dataGroups = new Map<String,List<NE__Billing_Profile__c>>();
        dataGroups.put('Active', new List<NE__Billing_Profile__c>());
        dataGroups.put('Refused', new List<NE__Billing_Profile__c>());
        for(NE__Billing_Profile__c billP : mapOld.values()){
            if(billP.XC_Status__c == 'Waiting External Activation'){
                if(mapNew.get(billP.Id).XC_Status__c == 'Active'){
                    dataGroups.get('Active').add(billP);
                }
                else if(mapNew.get(billP.Id).XC_Status__c == 'Refused'){
                    dataGroups.get('Refused').add(billP);
                }
            }
        }
        return dataGroups;
    }

    /** 
     * @description transferStatusOnLastChild
     * @param dataGroups
     * @return upd dml results
     */
    private static List<XC_UTIL_Sobject.WrapperResult> transferStatusOnLastChild(Map<String,List<NE__Billing_Profile__c>> dataGroups){
        Set<Id> parentsId = new Set<Id>();
        Set<Id> activeParentsId = new Set<Id>();
        Set<Id> refusedParentsId = new Set<Id>();
        if(!(dataGroups.get('Active').isEmpty())){
            activeParentsId = XC_UTIL_Sobject.getSetIds(dataGroups.get('Active'));
            parentsId.addAll(activeParentsId);
        }
        if(!(dataGroups.get('Refused').isEmpty())){
            refusedParentsId = XC_UTIL_Sobject.getSetIds(dataGroups.get('Refused'));
            parentsId.addAll(refusedParentsId);
        }
        List<XC_BillingProfileLineItem__c> childToUpd = getBPLIWaitingExternalActivation(parentsId);
        for(XC_BillingProfileLineItem__c bpli : childToUpd){
            if(activeParentsId.contains(bpli.XC_BillingProfile__c)){
                bpli.XC_Status__c = 'Active';
            }else if(refusedParentsId.contains(bpli.XC_BillingProfile__c)){
                bpli.XC_Status__c = 'Refused';
            }
        }

        return XC_UTIL_DML.updateRecords(childToUpd);
    }

    /** 
     * @description retrieve BPLI in 'Waiting External Activation' status
     * @param parentsId
     * @return List<XC_BillingProfileLineItem__c> result
     */
    private static List<XC_BillingProfileLineItem__c> getBPLIWaitingExternalActivation(Set<Id> parentsId){
        Map<Id,XC_BillingProfileLineItem__c> data = new Map<Id,XC_BillingProfileLineItem__c>([
            SELECT Id, XC_Status__c, XC_BillingProfile__c
              FROM XC_BillingProfileLineItem__c
             WHERE XC_Status__c = 'Waiting External Activation'
               AND XC_BillingProfile__c IN: parentsId
        ]);
        return data.values();
    }
}