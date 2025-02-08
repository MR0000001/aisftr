/**
 * @File Name          : XC_TR_QueuedRequest_U_ManageSteps.cls
 * @Description        : 
 * @Author             : Luisana Rocco - lrocco@deloitte.it
 * @Group              : 
 * @Last Modified By   : Luisana Rocco - lrocco@deloitte.it
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/5/2021   Luisana Rocco - lrocco@deloitte.it     Initial Version
**/
public without sharing class XC_TR_QueuedRequest_U_ManageSteps {

    /**
    * @description method to close Get Asset step of the QR Parent if all QR Child are Completed
    * @author Luisana Rocco - lrocco@deloitte.it | 11-05-2021 
    * @param mapNew 
    * @param mapOld 
    **/
    public static void closeWatingStepOnQRUpdate(Map<Id,XC_QueuedRequest__c> mapNew,Map<Id,XC_QueuedRequest__c> mapOld){

        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_QueuedRequest__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);

        if(!listChanged.isEmpty()){

            Map<Id, List<XC_QueuedRequest__c>> parentChildMap = new Map<Id, List<XC_QueuedRequest__c>>();
            for(XC_QueuedRequest__c qr : listChanged){
                if(!String.isBlank(qr.XC_ParentQueuedRequest__c) && (qr.XC_Status__c == Label.XC_CL_Completed || qr.XC_Status__c == 'In Error')){
                    parentChildMap.put(qr.XC_ParentQueuedRequest__c, new List<XC_QueuedRequest__c>());
                }
            }

            if(!parentChildMap.KeySet().isEmpty()){
                manageQRStepToUpdate(parentChildMap);
            } 
        }
      
    }


    /**
    * @description method to filter queued request step to be updated
    * @author Luisana Rocco - lrocco@deloitte.it | 11-05-2021 
    * @param parentChildMap
    **/
    private static void manageQRStepToUpdate(Map<Id, List<XC_QueuedRequest__c>> parentChildMap){

        Map<Id, XC_QueuedRequest__c> qrMap = new Map<Id, XC_QueuedRequest__c>([SELECT XC_Status__c, XC_ParentQueuedRequest__c,
                                                                              (SELECT Id, XC_Status__c, XC_ExecutionResponse__c, XC_QueuedRequest__c, XC_StepSequence__c  FROM QueuedRequestSteps__r WHERE XC_StepLabel__c =: 'Get Asset' OR XC_StepLabel__c =: 'Update Payment Method') 
                                                                              FROM XC_QueuedRequest__c WHERE XC_ParentQueuedRequest__c IN: parentChildMap.keySet()  OR Id IN: parentChildMap.keySet()]);

        // identify parent child relationship
        manageRelationship(parentChildMap, qrMap);

        Set<Id> parentQRToProcess = new Set<Id>();
        List<XC_QueuedRequestStep__c> qrsToCompleteList = new List<XC_QueuedRequestStep__c>();
        Map<String,Object> utilMap = new Map<String,Object>();
        Set<XC_QueuedRequestStep__c> completedKOSteps = new Set<XC_QueuedRequestStep__c>();
        for(Id qrParentId : parentChildMap.keySet()){
            if(parentChildMap.get(qrParentId) != null && !parentChildMap.get(qrParentId).isEmpty()){
                Boolean completeStep = checkIfIsToComplete(parentChildMap.get(qrParentId), utilMap);
                if(completeStep && !qrMap.get(qrParentId).QueuedRequestSteps__r.isEmpty()){
                    String callbackMessage = (String)utilMap.get('callbackMessage');
                    Boolean hasKoQRChild = (Boolean)utilMap.get('hasKoQRChild');
                    XC_QueuedRequestStep__c qrsToComplete = qrMap.get(qrParentId).QueuedRequestSteps__r[0];
                    qrsToComplete.XC_Status__c = (hasKoQRChild) ? Label.XC_CL_Step_CompletedKO : Label.XC_CL_Completed_Ok;
                    qrsToComplete.XC_ExecutionResponse__c = (hasKoQRChild) ? '' : 'Operation Completed Successfully. ' + callbackMessage;
                    qrsToCompleteList.add(qrsToComplete);

                    if(qrsToComplete.XC_Status__c == Label.XC_CL_Step_CompletedKO){
                        completedKOSteps.add(qrsToComplete);
                    }
                }
            }
        }

        if(!qrsToCompleteList.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(qrsToCompleteList);
        }

        if(!completedKOSteps.isEmpty()){
            XC_UTIL_QueuedRequestStep.skipNotCallbackSteps(new List<XC_QueuedRequestStep__c>(completedKOSteps));
        }
    }


    /**
    * @description method to create a map of QR Parent and QR child relationship
    * @author Luisana Rocco - lrocco@deloitte.it | 11-05-2021 
    * @param parentChildMap 
    * @param qrMap 
    **/
    private Static void manageRelationship(Map<Id, List<XC_QueuedRequest__c>> parentChildMap, Map<Id, XC_QueuedRequest__c> qrMap){
       
        for(XC_QueuedRequest__c qr : qrMap.values()){
            if(!String.isBlank(qr.XC_ParentQueuedRequest__c)){ 
                parentChildMap.get(qr.XC_ParentQueuedRequest__c).add(qr);

            }
        }

        /*for(XC_QueuedRequest__c qr : qrMap.values()){

            if(String.isBlank(qr.XC_ParentQueuedRequest__c)){ 
                if(!parentChildMap.containsKey(qr.Id)){
                    parentChildMap.put(qr.id, new List<XC_QueuedRequest__c>()); 
                }
            }else{  
                if(!parentChildMap.containsKey(qr.XC_ParentQueuedRequest__c)){
                    List<XC_QueuedRequest__c> childList = new List<XC_QueuedRequest__c>{qr};
                    parentChildMap.put(qr.XC_ParentQueuedRequest__c, childList);
                }else{
                    
                }
            }
        }
        return parentChildMap; */
    }


    /**
    * @description method to check if all QR child related to an QR Parent are in Completed status
    * @author Luisana Rocco - lrocco@deloitte.it | 11-05-2021 
    * @param childQRList 
    * @return Boolean
    **/
    private static Boolean checkIfIsToComplete(List<XC_QueuedRequest__c> childQRList, Map<String, Object> utilMap){

        String callbackMessage = '';
        Boolean hasKoQRChild = false;
        Boolean completeStep = true;
        for(XC_QueuedRequest__c childQR: childQRList){
            if(childQR.XC_Status__c != Label.XC_CL_Completed && childQR.XC_Status__c != 'In Error'){
                completeStep = false;
                break;
            }
            if(!childQR.QueuedRequestSteps__r.isEmpty() && childQR.QueuedRequestSteps__r[0].XC_Status__c == Label.XC_CL_Step_Skipped){ // To retrieve case number created by updatePaymentMethod step
                callbackMessage = childQR.QueuedRequestSteps__r[0].XC_ExecutionResponse__c;
            }
            if(childQR.XC_Status__c == 'In Error'){
                hasKoQRChild = true;
            }
        }
        utilMap.put('hasKoQRChild', hasKoQRChild);
        utilMap.put('callbackMessage', callbackMessage);
        return completeStep;
    }

}