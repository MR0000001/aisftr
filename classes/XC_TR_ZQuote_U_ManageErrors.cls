/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
 * @date Creation 11/06/2019
 * @date Modification 28/10/2021 by Nicola Mariniello - nmariniello@deloitte.it
 * @description XC_TR_ZQuote_U_ManageErrors 
 */


public without sharing class XC_TR_ZQuote_U_ManageErrors {


    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description Method to populate WBE fields 
    * @param mapOld
    * @param mapNew
    */ 
    public static void manageErrors(Map<Id, Sobject> mapOld, Map<Id, Sobject> mapNew) {

        List<String> listFieldToCheck = new List<String>{'XC_Message__c'};
        List<zqu__Quote__c> listChanged = XC_UTIL_Sobject.getListChanged(listFieldToCheck,mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }

        Map<Id, List<XC_Provisioning_Step__c>> zquoteIdStepsMap = XC_TR_ZQuote_U_ManageSent.getStepsByZquote(listChanged);
        Map<Id, List<XC_ContractAmendment__c>> zquoteIdContractAmendsMap = XC_TR_ZQuote_U_ManageSent.getContractAmendsByZquote(listChanged);
        Map<Id, XC_Provisioning_Step__c> mapStepToUpdate = new Map<Id, XC_Provisioning_Step__c>();
        Map<Id, XC_ContractAmendment__c> mapContractAmendToUpdate = new Map<Id, XC_ContractAmendment__c>();
        for(zqu__Quote__c zquote : listChanged){
            if(!zquote.XC_IsPreviewQuote__c && !String.isBlank(zquote.XC_Message__c) && zquote.XC_IsSuccess__c == false && zquoteIdStepsMap.get(zquote.Id) != null) {
                manageStepsForErrorZquote(zquoteIdStepsMap.get(zquote.Id), zquote.XC_Message__c, mapStepToUpdate);
            }
            if (!zquote.XC_IsPreviewQuote__c && !String.isBlank(zquote.XC_Message__c) && zquote.XC_IsSuccess__c == false && zquoteIdContractAmendsMap.get(zquote.Id) != null) {
                manageContractAmendForErrorZquote(zquoteIdContractAmendsMap.get(zquote.Id), zquote.XC_Message__c, mapContractAmendToUpdate);
            }
        }
        XC_UTIL_Sobject.updateListRecords(mapStepToUpdate.values());
        XC_UTIL_Sobject.updateListRecords(mapContractAmendToUpdate.values());

        List<zqu__Quote__c> toBePreviewed = new List<zqu__Quote__c>();
        for(zqu__Quote__c zquote : (List<zqu__Quote__c>) mapNew.values()){
            if(zquote.XC_IsPreviewQuote__c && zquote.XC_IsSuccess__c == false){
                toBePreviewed.add(zquote);
            }
        }
        if(!toBePreviewed.isEmpty()){
            XC_TR_ZQuote_U_CallBillingPreviewWF.callZuoraBillingPreview(toBePreviewed);
        }
    }


    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description Method to manage Steps For Sent Zquote
    * @param stepList the step list
    * @param listStepToUpdate the step list to update
    */
    public static void manageStepsForErrorZquote(List<XC_Provisioning_Step__c> stepList, String errorMessage, Map<Id, XC_Provisioning_Step__c> mapStepToUpdate) {

        for(XC_Provisioning_Step__c step : stepList) {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.Id = step.Id;
            stepToUpdate.XC_ErrorMessage__c = errorMessage;
            if(step.XC_Status__c == 'In Progress') {
                stepToUpdate.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            } else {
                stepToUpdate.XC_ToBeAutocompleted__c = true;
            }
            mapStepToUpdate.put(stepToUpdate.Id, stepToUpdate);
        }
    }


    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description Method to manage Steps For Sent Zquote
    * @param stepList the step list
    * @param listStepToUpdate the step list to update
    */
    public static void manageContractAmendForErrorZquote(List<XC_ContractAmendment__c> contractAmendList, String errorMessage, Map<Id, XC_ContractAmendment__c> mapContractAmendToUpdate) {

        for(XC_ContractAmendment__c ca : contractAmendList) {

            XC_ContractAmendment__c caToUpdate = new XC_ContractAmendment__c();
            caToUpdate.Id = ca.Id;
            caToUpdate.XC_Status__c = 'Error';
            caToUpdate.XC_Error__c = 'Error in sending ZQuote to Zuora';
            caToUpdate.XC_ErrorDetail__c = errorMessage;

            mapContractAmendToUpdate.put(caToUpdate.id, caToUpdate);
        }
    }

}