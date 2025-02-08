/**
* The Class XC_LCC030_CancelOrder.
*
* @author Riccardo Cossu - riccardo.cossu@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  29/08/2018
* @date Modification 22/07/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @description XC_LCC030_CancelOrder - Controller for XC_LCP030_CancelOrder Component
*/
public without sharing class XC_LCC030_CancelOrder {

    /**
    * @description The Class resultWrapper.
    */
    public class resultWrapper {
        
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  result = '';
    }

    /**
    * @description Check status.
    * @param recordId the record id
    * @return the result wrapper
    */
    @AuraEnabled
    public static resultWrapper checkStatus(Id recordId){
        Boolean checkApproval = false;
        resultWrapper rWr = new resultWrapper ();

        Map<Id,NE__Order__c> neOrderListMap = new Map<Id,NE__Order__c>([SELECT ID, XC_Status__c 
        FROM NE__Order__c WHERE Id =: recordId]);
        List<NE__Order__c> neOrderList = neOrderListMap.values();

        Map<id,ProcessInstanceWorkitem> processInstanceWIListMap = new Map<Id,ProcessInstanceWorkitem>(
        [SELECT Id, ProcessInstance.TargetObjectId,ProcessInstance.Status
        FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recordId]);

        List<ProcessInstanceWorkitem> processInstanceWIList = processInstanceWIListMap.values();

        for(ProcessInstanceWorkitem pwi : processInstanceWIList){
            if(pwi.ProcessInstance.Status == Label.XC_CL_Approval_Pending) {
                rWr.success = false;
                rWr.result = Label.XC_CL_Order_CancelOrderErrorApproval;
                checkApproval = true;
            }
        }   

        if(!neOrderList.isEmpty()){
            if(!checkApproval && (neOrderList[0].XC_Status__c == Label.XC_CL_Configuration_OrderInProgress || neOrderList[0].XC_Status__c == Label.XC_CL_Configuration_OrderToBeValidated) ){                  
                rWr.success = true;
                rWr.result = '';
            }else if (!checkApproval){
                rWr.success = false;
                rWr.result  = Label.XC_CL_Configuration_ConfigurationNotClosable;
            }
        }
        return rWr;
    }

    /**
    * @description Order in cancelled.
    *
    * @param recordId the record id
    * @param cancType the canc type
    * @param reasonType the reason type
    * @return the result wrapper
    */
    @AuraEnabled
    public static resultWrapper orderInCancelled (Id recordId, String cancType, String reasonType){

        Boolean checkApproval = false;
        resultWrapper rWr = new resultWrapper ();
        rWr.success = false;
        rWr.result = '';

        Map<Id,NE__Order__c> neOrderListMap = new Map<Id,NE__Order__c>([SELECT Id, NE__OptyId__c, NE__OptyId__r.XC_LegalEntity__c, NE__OptyId__r.XC_Contact__c,
                                                                        NE__OptyId__r.XC_Contact__r.Email, NE__OptyId__r.XC_Contact__r.Name, NE__OptyId__r.XC_Contact__r.AccountId,
                                                                        NE__OptyId__r.XC_Contact__r.Phone, NE__OptyId__r.XC_Contact__r.XC_PhonePrefix__c, NE__OptyId__r.XC_Contact__r.XC_ContactPhone__c,           // Primary Phone of Contact
                                                                        NE__OptyId__r.XC_Contact__r.MobilePhone, NE__OptyId__r.XC_Contact__r.XC_MobilePrefix__c, NE__OptyId__r.XC_Contact__r.XC_ContactMobile__c,   // Secondary Phone of Contact
                                                                        NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c, XC_FinancialApproval__c, XC_Compliance_Approval__c,
                                                                        XC_Status__c, XC_Cancellation_Date__c, XC_Mode_of_cancellation__c
                                                                        FROM NE__Order__c WHERE Id =: recordId]);
        List<NE__Order__c> neOrderList = neOrderListMap.values();
    

        Map<Id,ProcessInstanceWorkitem> processInstanceWIListMap = new Map<Id,ProcessInstanceWorkitem>([SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status 
                                                                                                        FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recordId]);
        List<ProcessInstanceWorkitem> processInstanceWIList = processInstanceWIListMap.values();
        for(ProcessInstanceWorkitem pwi : processInstanceWIList){
            if(pwi.ProcessInstance.Status == Label.XC_CL_Approval_Pending) {
                rWr.success = false;
                rWr.result = Label.XC_CL_Order_CancelOrderErrorApproval;
                checkApproval = true;
            }
        }
    
        if(!neOrderList.isEmpty()){
            if(!checkApproval && (neOrderList[0].XC_Status__c == Label.XC_CL_Configuration_OrderInProgress || neOrderList[0].XC_Status__c == Label.XC_CL_Configuration_OrderToBeValidated) ){
                
                Id idOrd = neOrderList[0].Id;
                neOrderList[0].XC_Status__c = Label.XC_CL_Order_StatusCancelled;
                neOrderList[0].XC_Cancellation_Date__c = Date.today();
                neOrderList[0].XC_Mode_of_cancellation__c = 'Manual';
                neOrderList[0].XC_Type_of_cancellation__c = cancType;
                neOrderList[0].XC_Reason_of_cancellation__c = reasonType;

                //First - Call method B2W 
                NE.OrderSummaryButtonExtension.cancelButton(idOrd);

                //Second - XC Status
                XC_UTIL_Sobject.updateRecord(neOrderList[0]);

                rWr.success = true;
                rWr.result  = Label.XC_CL_OrderInCancelled;

                //Manage the notification to the Client because of the closed Order
                Map<String,Object> data = XC_TR_Conf_U_CheckCompliance1Status.createCustomInteractionInfo(neOrderList[0]);
                if(data != null) {
                    List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(new List<Map<String,Object>>{data});
                    system.debug('----------> results--->' + results);
                }

            }else if (!checkApproval){
                rWr.success = false;
                rWr.result  = Label.XC_CL_Configuration_ConfigurationNotClosable;
            }
        }

        System.debug(LoggingLevel.DEBUG,'--After Update--'+neOrderList);
        return rWr;
    }
}