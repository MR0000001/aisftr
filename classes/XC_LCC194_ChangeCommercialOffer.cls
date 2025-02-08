/**
* @author: Marco Ottaviano - mottaviano@deloitte.it 
* @fileName XC_LCC194_ChangeCommercialOffer
* @date Creation Date: 16/06/2020
* @description Controller of LCP194_ChangeCommercialOffer (AuraDefinitionBundle)
* @testClass: 
*/


public without sharing class XC_LCC194_ChangeCommercialOffer {



    /**
    * @description retrieves order info to make the card available
    * @author Francesco Imperioli - fimperioli@deloitte.it | 24/6/2020 
    * @param configId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> getOrderInfo(String configId){
        Map<String,Object> result = new Map<String,Object>();
        NE__Order__c currentOrder = [SELECT XC_LegalEntity__c,XC_Status__c,RecordTypeAUX__c,XC_TechnicalProductOnly__c FROM NE__Order__c WHERE Id = :configId];

        result.put('status',currentOrder.XC_Status__c);
        result.put('legalEntity',currentOrder.XC_LegalEntity__c);
        result.put('rt',currentOrder.RecordTypeAUX__c);
        result.put('sessionId',UserInfo.getSessionId());
        result.put('isChangingOffer',!currentOrder.XC_TechnicalProductOnly__c);
        result.put('orderStatus',currentOrder.XC_Status__c);
        return result;
    }

    /*
    * @author Marco ottaviano - mottaviano@deloitte.it
    * @date Creation 16/06/2020
    * @date Modification dd/mm/yyyy
    * @description set flags on Order record in order to reopen the chart
    * @param configId
    * @return XC_UTIL_ResultWrapper
    */ 
   
    @AuraEnabled
    public static XC_UTIL_ResultWrapper changeCommercialOfferOnOrder(String configId,Boolean closed){

        SavePoint sp = DataBase.setSavePoint();

        XC_UTIL_ResultWrapper rew = new XC_UTIL_ResultWrapper();
        List<XC_UTIL_Sobject.WrapperResult> wResList = new List<XC_UTIL_Sobject.WrapperResult>();
        rew.success = false;
        rew.resultMessage = Label.XC_CL_OrderNotFound;
        
        try {

            Map<Id,NE__Order__c> configMap = new Map<Id, NE__Order__c>([SELECT Id, NE__OptyId__c, XC_TechnicalProductOnly__c,
                (SELECT Id,NE__Hidden_in_Cart__c FROM NE__Order_items__r) 
                FROM NE__Order__c WHERE Id =: configId]);

            if(!configMap.isEmpty()) {

                List<NE__OrderItem__c> orderItemToUp = configMap.values()[0].NE__Order_items__r;
                for(NE__OrderItem__c orderItem: orderItemToUp) {
                    orderItem.NE__Hidden_in_Cart__c = closed;
                }

                wResList.addAll(XC_UTIL_Sobject.updateListRecords(orderItemToUp));
                NE__Order__c orderToUpdate = configMap.values()[0];
                orderToUpdate.XC_TechnicalProductOnly__c= closed;
                wResList.add(XC_UTIL_Sobject.updateRecord(orderToUpdate));
                Map<Id,Opportunity> optyMap = new Map<Id,Opportunity>([SELECT Id,XC_TechnicalProductOnly__c FROM Opportunity WHERE Id =: orderToUpdate.NE__OptyId__c]);
               
                Opportunity optyUpdate = optyMap.values()[0];
                optyUpdate.XC_TechnicalProductOnly__c= closed;
                wResList.add(XC_UTIL_Sobject.updateRecord(optyUpdate));
            
                checkResultofAllDML(wResList,sp,rew);
            }
            
        } catch(Exception e) {
            Database.rollback(sp);
            rew.success = false;
            rew.resultMessage = e.getMessage();
            return rew;
        }

        return rew;
    }


    /*
    * @author Marco ottaviano - mottaviano@deloitte.it
    * @date Creation 16/06/2020
    * @date Modification dd/mm/yyyy
    * @description check the result of update DML
    * @param configId
    * @parm wResList
    * @param sp (SavePoint)
    * @param rew
    * @return void
    */ 
    @TestVisible
    private static void checkResultofAllDML(List<XC_UTIL_Sobject.WrapperResult> wResList, Savepoint sp, XC_UTIL_ResultWrapper rew) {
        for(XC_UTIL_Sobject.WrapperResult wrapperResult  : wResList) {
            if(!wrapperResult.success) {
                Database.rollback(sp);
                rew.success= false;
                rew.resultMessage = wrapperResult.errorMessage;
                rew.recordId = wrapperResult.recordId;
                return;
            } else {
                rew.success = true;
            }
        }
    }
}