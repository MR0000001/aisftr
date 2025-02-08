/**
 * @File Name          : XC_TR_QueuedRequest_U_CompleteReq.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 16/6/2020, 13:05:41
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_TR_QueuedRequest_U_CompleteReq {

    /**
    * @description change status of the request in completed when all steps are executed
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param mapNew 
    * @param mapOld 
    * @return void 
    **/
    public static void setCompleteRequest(Map<Id,XC_QueuedRequest__c> mapNew,Map<Id,XC_QueuedRequest__c> mapOld){
        
        List<XC_QueuedRequest__c> requestsToProcess = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_QueuedRequestCompletedSteps__c'},mapOld,mapNew);
        for(XC_QueuedRequest__c qr : requestsToProcess){
            if(qr.XC_QueuedRequestCompletedSteps__c==qr.XC_QueuedRequestSteps__c){
                qr.XC_Status__c = 'Completed';
            }
        }

    }

    /**
    * @description set the status of the request in error in case one the child steps fails
    * @author Francesco Imperioli - fimperioli@deloitte.it | 16/6/2020 
    * @param mapNew 
    * @param mapOld 
    * @return void 
    **/
    public static void setRequestError(Map<Id,XC_QueuedRequest__c> mapNew,Map<Id,XC_QueuedRequest__c> mapOld){

        List<XC_QueuedRequest__c> requestsToProcess = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_QueuedRequestKOSteps__c'},mapOld,mapNew);
        for(XC_QueuedRequest__c qr : requestsToProcess){
            if(qr.XC_Status__c != 'In Error' && qr.XC_QueuedRequestKOSteps__c>0){
                qr.XC_Status__c = 'In Error';
            }
        }
    }


    /**
    * @description restore the status of the request in "In Progress" if XC_QueuedRequestKOSteps__c is equal to zero
    * @author Luisana Rocco - lrocco@deloitte.it | 23/04/2020 
    * @param mapNew 
    * @param mapOld 
    * @return void 
    **/
    public static void setRequestInProgress(Map<Id,XC_QueuedRequest__c> mapNew,Map<Id,XC_QueuedRequest__c> mapOld){

        List<XC_QueuedRequest__c> requestsToProcess = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_QueuedRequestKOSteps__c'},mapOld,mapNew);
        if(!requestsToProcess.isEmpty()){
            for(XC_QueuedRequest__c qr : requestsToProcess){
                if(qr.XC_Status__c == 'In Error' && qr.XC_QueuedRequestKOSteps__c == 0 && qr.XC_QueuedRequestCompletedSteps__c != qr.XC_QueuedRequestSteps__c){
                    qr.XC_Status__c = 'In Progress';
                }
            }
        }
       
    }
    
    /**
    * @description Populate Template Name field of Queued Request before Insert
    * @author Angelos Kosintzis - akosintzis@deloitte.gr | 11/12/2021 
    * @param listNew 
    * @return void 
    **/
	public static void PopulateTemplateName(List<XC_QueuedRequest__c> listNew){
        list <XC_CM_QueuedRequestTemplate__mdt> templates = [select Id, DeveloperName, XC_TemplateName__c, XC_Type__c, XC_ClientSystems__c from XC_CM_QueuedRequestTemplate__mdt];
        for(XC_QueuedRequest__c queuedReq : listNew){
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(queuedReq.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            for(XC_CM_QueuedRequestTemplate__mdt template : templates){
                list <String> ClientSystems = template.XC_ClientSystems__c.split(';');
                if (ClientSystems.contains(queuedReq.XC_ClientSystem__c) && fullQRReqBody.Order.OrderType == template.XC_Type__c){
                    queuedReq.XC_TemplateName__c = template.XC_TemplateName__c;
                    break;
                }
            }
        }
    }

}