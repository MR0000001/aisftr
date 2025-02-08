public class XC_LCC_CreateOppFromServiceAppointment {
    public class ResultWrapper{
         @AuraEnabled
         public String objectType;
         @AuraEnabled
         public String accountId;
          @AuraEnabled
         public Boolean success;
          @AuraEnabled
         public String resultMessage;
            @AuraEnabled
         public String caseId;
            @AuraEnabled
         public String workOrderId;
     }
     
     
     @AuraEnabled
     public static ResultWrapper getCurrentServiceAppointment(String recordId) {
         ResultWrapper resultWr = new ResultWrapper();
         resultWr.objectType = XC_UTIL_Sobject_U_Retrieve.getObjectType(recordId);
         if(resultWr.objectType == 'ServiceAppointment') {
             System.debug('@@ServiceAppointment' + resultWr.objectType);
             List<ServiceAppointment> sapplist = XC_UTIL_Sobject.selectAllFields(recordId);
            // List<Account> accountlist = XC_UTIL_Sobject.selectAllFields(sapplist[0].AccountId);
             List<WorkOrder> listWorkOrder = XC_UTIL_Sobject.selectAllFields(sapplist[0].ParentRecordId);
             List<Case> Caselist = XC_UTIL_Sobject.selectAllFields(listWorkOrder[0].CaseId);
             if(!'Quotation Request Accepted'.equalsIgnoreCase(sapplist[0].XC_QuotationRequestOutcome__c)){
                  resultWr.success = false; resultWr.resultMessage = 'ErrorServiceAppQuota'; return resultWr;
             }else if(!('eCity'.equalsIgnoreCase(Caselist[0].XC_BusinessLine__c) && 'Italy'.equalsIgnoreCase(listWorkOrder[0].XC_Country__c) && ('B2G'.equalsIgnoreCase(listWorkOrder[0].XC_Segment__c) || 'B2B'.equalsIgnoreCase(listWorkOrder[0].XC_Segment__c)))){
                  resultWr.success = false; resultWr.resultMessage = 'ErrorServiceAppOpp'; return resultWr;
                 }else{
                  resultWr.caseId =Caselist[0].id;
                  resultWr.accountId= sapplist[0].AccountId;
                  resultWr.workOrderId=listWorkOrder[0].id;           
             }
         }
                   
      return resultWr;
    }
  
 }