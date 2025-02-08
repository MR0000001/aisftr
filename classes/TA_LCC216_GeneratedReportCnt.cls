public with sharing class TA_LCC216_GeneratedReportCnt {
    public TA_LCC216_GeneratedReportCnt() {

    }

    public class InfoBag {   

        @AuraEnabled
        public List<ContentDocument> contentDocumentList   {get;set;}
        }
    
        @AuraEnabled
        public static String init(String workOrderId, Boolean isRefresh) {
            System.debug('TA_LCC216_GeneratedReportCnt: init');
            System.debug('TA_LCC216_GeneratedReportCnt: workOrderId: ' + workOrderId);
            try {       
                InfoBag InfoBag = new InfoBag();  
                InfoBag.contentDocumentList = new List<ContentDocument>();
                /*String parameters = [SELECT TA_Parameters__c FROM WorkOrder WHERE ID =: workOrderId].TA_Parameters__c;
                Map<String,Object> paramMap = (Map<String,Object>) JSON.deserializeUntyped(parameters);
                if(paramMap.containsKey('quoteToAccept')){
                    String orderId = String.valueOf(paramMap.get('quoteToAccept'));     */
                    String orderId = [SELECT XC_Configuration__c FROM WorkOrder WHERE ID =: workOrderId].XC_Configuration__c;                                   
                                                  
                    List<ContentDocumentLink> docLink = [ SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :orderId]; 
                    List<String> contentDocumentIdList = new List<String>();
                    for(ContentDocumentLink cdl : docLink){
                        contentDocumentIdList.add(cdl.ContentDocumentId);
                    }                    
                    InfoBag.contentDocumentList = [SELECT Id, Title FROM ContentDocument  WHERE Id IN :contentDocumentIdList]; 
                    // start fix [ADC 15-02-2021] retry create doc
                    if(isRefresh){
                        Boolean createDoc = false;                   
                        List<NE__OrderItem__c> oiList = [SELECT Name,XC_CongaDynamicAPI__c
                                                        FROM NE__OrderItem__c 
                                                        WHERE NE__OrderId__c =: orderId];
                        for(NE__OrderItem__c oi : oiList){
                            if(!String.isBlank(oi.XC_CongaDynamicAPI__c)) {
                                createDoc = false;                                                      
                                break;
                            }                           
                            else createDoc = true;                        
                        }                    
                        if(createDoc) TA_LCC234_PaymentMethod.createDoc(orderId);
                    }                            
                    // end fix [ADC 15-02-2021] retry create doc
                    return JSON.serialize(infoBag);
                //}
                //return null;
    
            } catch(Exception e) {
                String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
                System.debug('[TA_LCC216_GeneratedReportCnt] init - EXCEPTION HANDLER: ' + errorMessage);
                TA_UTIL_LogManagement.createLog('TA_LCC216_GeneratedReportCnt', 'init', errorMessage, 0, errorMessage, null);
                return null;
            }
        }
 }