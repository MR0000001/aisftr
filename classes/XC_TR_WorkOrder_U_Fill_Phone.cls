/**
 * Created by dolombardi on 29/09/2021.
 */

public with sharing class XC_TR_WorkOrder_U_Fill_Phone {
    public static void updatePhoneByContact(List<WorkOrder> listNew){
        Set<Id> setContact = new Set<Id>();
        for(WorkOrder wo : listNew){
            if(String.isNotBlank(wo.ContactId)){
                setContact.add(wo.ContactId);
            }
        }
        if(setContact.isEmpty()){
            return ;
        }
        Map<Id,Contact> mapContact = new Map<Id,Contact>([SELECT ID, Phone FROM Contact WHERE ID IN:setContact]);
        for(WorkOrder wo :listNew){
            if(mapContact.get(wo.ContactId)!= null){
                wo.XC_CustomerPhone__c = mapContact.get(wo.ContactId).Phone;
            }
        }

    }

}