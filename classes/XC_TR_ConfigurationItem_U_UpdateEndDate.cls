/**
 * Created by dolombardi on 04/11/2021.
 */

public with sharing class XC_TR_ConfigurationItem_U_UpdateEndDate {
    public static void updateDate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
        List<String> fieldsToCheck = new List<String>{
                'NE__StartDate__c', 'XC_RecurringDuration__c', 'XC_Effective_Start_Date_Recurring__c'
        };
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck, mapOld, mapNew);
        List<NE__OrderItem__c> listChangedB2B = new List<NE__OrderItem__c>();
        for (NE__OrderItem__c ne : listChanged) {
            if (ne.XC_Segment__c != 'B2C') {
                listChangedB2B.add(ne);
            }
        }
        if (listChangedB2B.isEmpty()) {
            return;
        }
        XC_TR_ConfigurationItem_U_UpdateEndDate.addRecurringPeriod(listChangedB2B);

    }


    public static void addRecurringPeriod(List<NE__OrderItem__c> listChange){
        for(NE__OrderItem__c ne : listChange){
            //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022
            /*
            if(ne.NE__StartDate__c != null && ne.XC_RecurringDuration__c != null && ne.XC_NE_Type__c == 'InOrder'){
                ne.NE__EndDate__c = ne.NE__StartDate__c.addMonths(Integer.valueOf(ne.XC_RecurringDuration__c));
            }
            }*/
            if(ne.XC_Effective_Start_Date_Recurring__c != null && ne.XC_RecurringDuration__c != null && ne.XC_NE_Type__c == 'ChangeOrder'){
                ne.NE__EndDate__c = ne.XC_Effective_Start_Date_Recurring__c.addMonths(Integer.valueOf(ne.XC_RecurringDuration__c));

            }
        }

    }

}