/**
* The Class XC_LCC139_QuoteDetails
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 05/08/2019
* @date Modification 16/12/2019 - Domenico Del Prete - domenico.delprete@nttdata.com
* @description controller for XC_LCP139_QuoteDetails component
*/

public without sharing class XC_LCC139_QuoteDetails {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC139_QuoteDetails');

    
    /**
    * @description 
    * @author Domenico Del Prete - domenico.delprete@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param caseId 
    * @return XC_UTIL_ResultWrapper 
    **/
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper retrieveQuoteId(String caseId){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        Map<String,Object> quoteValueMap = new Map<String,Object>();
        List<Case> listOfCase = new List<Case>([
            SELECT Id, XC_WorkOrder__c 
            FROM Case 
            WHERE Id =:caseId AND XC_WorkOrder__r.Status = :Label.XC_CL_WorkOrder_Completed AND RecordType.Name = 'XC_ESP_Information_Case'
        ]);
        

        if(!listOfCase.isEmpty() && listOfCase[0].XC_WorkOrder__c !=null) {
            Case cs = listOfCase[0];
            List<Opportunity> listOfOpp = new List<Opportunity>([
                SELECT Id, Name, 
                    (SELECT Id, Name, RecordType.DeveloperName, NE__One_Time_Fee_Total__c,NE__Recurring_Charge_Total__c, NE__TotalRecurringFrequency__c, XC_Status__c 
                    FROM NE__Orders__r 
                    WHERE (RecordType.DeveloperName = 'Quote' AND  XC_Status__c = 'Accepted') OR (RecordType.DeveloperName = 'Order' AND  XC_Status__c = 'In provisioning'))
                FROM Opportunity 
                WHERE XC_WorkOrder__c  =: cs.XC_WorkOrder__c]); 

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Found opportunity -> ' + listOfOpp);
            Double tempPrice = 0;
            Integer frequencyNumb = 0;
            String frequency;
            Map<String, Integer> mapOfValue = new Map<String, Integer>();
            mapOfValue.put('Monthly', 1);
            mapOfValue.put('Bi-Monthly', 2);
            mapOfValue.put('Quarterly', 3);
            mapOfValue.put('Four-Monthly', 4);
            mapOfValue.put('Semiannual', 6);
            mapOfValue.put('Annual', 12);

            for(Opportunity opp : listOfOpp){ 
                for(NE__Order__c order : opp.NE__Orders__r){
                    tempPrice += order.NE__One_Time_Fee_Total__c + order.NE__Recurring_Charge_Total__c;
                    if(!String.isBlank(order.NE__TotalRecurringFrequency__c) && mapOfValue.get(order.NE__TotalRecurringFrequency__c) >= frequencyNumb){
                        frequencyNumb = mapOfValue.get(order.NE__TotalRecurringFrequency__c);
                        frequency = order.NE__TotalRecurringFrequency__c;
                    }
                }
            }
            if(!String.isBlank(frequency)){
                quoteValueMap.put('priceTotal' , tempPrice);
                quoteValueMap.put('recurringFrequencyTotal' , frequency);
                String values = JSON.serialize(quoteValueMap);
                resWrapper.objectInfo = values;
                resWrapper.success = true;
                return resWrapper;
            }

            /*if(!opp.NE__Orders__r.isEmpty()){
                resWrapper.success = true;
                resWrapper.recordId = opp.NE__Orders__r[0].Id;
                quoteValueMap.put('quoteNumber' , opp.NE__Orders__r[0].Name);
                quoteValueMap.put('opportunityName' , opp.Name);
                quoteValueMap.put('recordType' , opp.NE__Orders__r[0].RecordType.DeveloperName);
                quoteValueMap.put('oneTime' , opp.NE__Orders__r[0].NE__One_Time_Fee_Total__c);
                quoteValueMap.put('recurringCharge' , opp.NE__Orders__r[0].NE__Recurring_Charge_Total__c);
                quoteValueMap.put('recurringFrequency' , opp.NE__Orders__r[0].NE__TotalRecurringFrequency__c);
                quoteValueMap.put('status' , opp.NE__Orders__r[0].XC_Status__c);
                String values = JSON.serialize(quoteValueMap);
                resWrapper.objectInfo = values;

                return resWrapper; 
            }*/                                                                     
        }
        return resWrapper; 
    }

}