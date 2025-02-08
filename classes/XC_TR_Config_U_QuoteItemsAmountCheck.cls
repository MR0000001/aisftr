public without sharing class XC_TR_Config_U_QuoteItemsAmountCheck {
    public static void checkNotifiedQuoteItemsAmount(Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        //quote id set to query related configuration items
        Set<Id> quoteSet = new Set<Id>();

        //quote record type id
        //String quoteRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        String quoteRecType = Schema.getGlobalDescribe().get('NE__Order__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();

        //filter configurations that have changed status
        List<NE__Order__c> listStatusChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Status__c'}, mapOld, mapNew);

        //PERFORMANCE IMPROVEMENT - JUNE 2022 - GDB
        if(listStatusChanged.isEmpty()){
            return;
        }
        
        Set<Id> oppIdSet = XC_UTIL_Sobject.getSetIdsOnField(listStatusChanged,'NE__OptyId__c');

        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,XC_BusinessLine__c FROM Opportunity WHERE Id IN: oppIdSet]);

        system.debug('DIM ' + listStatusChanged.size());

        for(NE__Order__c q : listStatusChanged){
            if(q.XC_Status__c != 'Rejected' &&
               mapOld.get(q.Id).XC_Status__c == 'Draft' &&
               q.RecordTypeId == quoteRecType &&
               (q.XC_Segment__c == 'B2G' || q.XC_Segment__c == 'B2B') &&
               oppMap.get(q.NE__OptyId__c).XC_BusinessLine__c == 'eCity'){
                    quoteSet.add(q.Id);
               }
        }

        if(quoteSet.size()>0){

                       Map<Id,NE__Order__c> quotesWithItems = new Map<Id,NE__Order__c>([SELECT Id,
                                                                              (SELECT XC_BillingModel__c,NE__OneTimeFeeOv__c,NE__RecurringChargeOv__c FROM NE__Order_Items__r 
                                                                              where XC_ParentCommercialItem__c=null) 
                                                                              FROM NE__Order__c 
                                                                              WHERE Id IN : quoteSet AND NE__OptyId__r.XC_BusinessLine__c = 'eCity']);


            for(NE__Order__c q : quotesWithItems.values()){

                //the list with all chlidren config items for the current quote
                List<NE__OrderItem__c> configItems = q.NE__Order_Items__r;

                //true: all items with not Capex model have amount 0
                //false: there is at least 1 item of not Capex model with amount > 0, or there are no items of not capex model to give an error
                Boolean isAmountZero = true;
                //counter for configuration items with billing model != capex
                Integer nonCapexModelItems = 0;

                for(NE__OrderItem__c item: configItems){
                    if(item.XC_BillingModel__c != 'Capex'){
                        nonCapexModelItems+=1;
                        if(item.NE__OneTimeFeeOv__c > 0 || item.NE__RecurringChargeOv__c > 0){
                            isAmountZero = false;
                            break;
                        }
                    }  
                }

                //in case there are no items with billing model != capex, do not give error
                if(nonCapexModelItems == 0){
                    isAmountZero = false;
                }

                //if there are items with non capex billing model and the total amount in all of them is 0, give an error
                if(isAmountZero){
                    mapNew.get(q.Id).addError(System.Label.XC_CL_Configuration_CapexBillingModelError);
                }
            }
        }
    }
}