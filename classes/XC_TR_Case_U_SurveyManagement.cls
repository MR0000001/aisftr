/*
* @author: Marco Ottaviano mottaviano@deloitte.it
* @date creation 22/10/2019
* @description: Class for Close The Loop feature of Survey Management called from XC_TR_CaseHandler class
*/

public without sharing class XC_TR_Case_U_SurveyManagement {

    /*
    * @author: Marco Ottaviano mottaviano@deloitte.it
    * @description Check if the case is a Case With SubCause = 'ATCL040 (Close the Loop) '
    * @param newLists -> List Of new Cases record
    */

   public static void linkCaseAndSurvey(List<Case> newLists) {
       Map<String,Case> caseSurveyMap = new Map<String,Case>();
       for(Case toInsertCase : newLists) {
           //TO DO Create Custom label for SubCause 
           if(toInsertCase.SubCause__c != null && toInsertCase.SubCause__c == 'ATCL040'  /* && toInsertCase.Reason ='' */ && String.isNotBlank(toInsertCase.XC_SurveyExID__c)) {
               caseSurveyMap.put(toInsertCase.XC_SurveyExID__c,toInsertCase);
           }
       }
        if(!caseSurveyMap.isEmpty()) {
            updateSurveyId(caseSurveyMap); //update function
        }
    }



     /*
    * @author: Marco Ottaviano mottaviano@deloitte.it
    * @description Check if the case is a Case With •	SubCause = 'ATCL040 (Close the Loop) '
    * @param caseSurveyMap -> List Of new Cases record
    */

    private static void updateSurveyId(Map<String,Case> caseSurveyMap) {

        Map<Id,XC_GetFeedbackResponse__c> mapSruveyResp = retrieveGetFeedbackResponseFromExtID(caseSurveyMap.keySet()); //new Map<Id,XC_GetFeedbackResponse__c>([SELECT Id,XC_SurveyId__c FROM XC_GetFeedbackResponse__c WHERE XC_SurveyId__c IN : caseSurveyMap.keySet()]);
        for(XC_GetFeedbackResponse__c surveyResp : mapSruveyResp.values()) {
            if(caseSurveyMap.containsKey(surveyResp.XC_SurveyId__c)) {
                Case toInsertCase = caseSurveyMap.get(surveyResp.XC_SurveyId__c);
                toInsertCase.XC_SurveyId__c = surveyResp.Id;
                caseSurveyMap.put(surveyResp.XC_SurveyId__c,toInsertCase);
            }
        }
    
    }


    /*
    * @author: Marco Ottaviano mottaviano@deloitte.it
    * @dateCreation 22/06/2020
    * @description' Close The Loop GetFeedBack. 
    * @param newLists -> List Of new Cases record
    * 
    */
    public static void afterInsertgetFeedBackCloseTheLoop(List<Case> newLists) {
        Map<String,String> caseSurveyMap = new Map<String,String>();
        for(Case toInsertCase : newLists) {
           if(String.isNotBlank(toInsertCase.XC_SurveyId__c)) {
               caseSurveyMap.put(toInsertCase.XC_SurveyId__c,toInsertCase.Id);
           }
        }

       if(!caseSurveyMap.isEmpty()) {
           Map<Id,XC_GetFeedbackResponse__c> mapGetFeedBackToUp=new Map<Id,XC_GetFeedbackResponse__c>([SELECT Id,XC_CaseCloseTheLoop__c FROM XC_GetFeedbackResponse__c WHERE Id IN : caseSurveyMap.keyset()]);
           for(String idgetFeedbackResp : caseSurveyMap.keySet()) {
                if(mapGetFeedBackToUp.containsKey(idgetFeedbackResp)) {
                    mapGetFeedBackToUp.get(idgetFeedbackResp).XC_CaseCloseTheLoop__c = caseSurveyMap.get(idgetFeedbackResp);
                }
           }
           

           XC_UTIL_Sobject.updateListRecords(mapGetFeedBackToUp.values());
       }
    }

    /*
    * @author: Monica Cutillo - mcutillo@deloitte.it
    * @dateCreation 29/07/2020
    * @description' On Case creation it set LE from the Contact of the XC_GetFeedbackResponse__c
    * @param newLists -> List Of new Cases record
    * 
    */
    public static void setLegalEntityFromSurveyContact(List<Case> newLists) {
        List<Case> caseToProcess = new List<Case>();
        for(Case caso : newLists){
            if(String.isNotBlank(caso.XC_SurveyExID__c)){
                caseToProcess.add(caso);
            }
        }
        if(caseToProcess.isEmpty()){
            return;
        }

        Set<String> surveyExIDs = XC_UTIL_Sobject.getSetIdsStringOnField(caseToProcess, 'XC_SurveyExID__c');
        Map<Id,XC_GetFeedbackResponse__c> feedbRespData = retrieveGetFeedbackResponseFromExtID(surveyExIDs);
        Map<String,XC_GetFeedbackResponse__c> feedbRespByExtID = new Map<String,XC_GetFeedbackResponse__c>();
        for(XC_GetFeedbackResponse__c getFR : feedbRespData.values()){
            feedbRespByExtID.put(getFR.XC_SurveyId__c, getFR);
        }

        for(Case caso : caseToProcess){
            if(feedbRespByExtID.get(caso.XC_SurveyExID__c) != null){
                caso.XC_LegalEntity__c = (feedbRespByExtID.get(caso.XC_SurveyExID__c)).XC_Contact__r.XC_MainLegalEntity__c;
            }
        }
    }

    /*
    * @description' Retrieve the XC_GetFeedbackResponse__c starting from the external ID XC_SurveyId__c
    * @param externalIds
    * @return query results
    */
    private static Map<Id,XC_GetFeedbackResponse__c> retrieveGetFeedbackResponseFromExtID(Set<String> externalIds) {
        return new Map<Id,XC_GetFeedbackResponse__c> ([
            SELECT Id, XC_SurveyId__c, XC_Contact__c, XC_Contact__r.XC_MainLegalEntity__c 
              FROM XC_GetFeedbackResponse__c
               WHERE XC_SurveyId__c IN : externalIds
        ]);
    }

    /*
    * @description' Retrieve the XC_GetFeedbackResponse__c starting from the external ID XC_SurveyId__c
    * @param mapOld
    * @param mapNew
    * @return query results
    */	
    public static void interactionForChangeMOP(Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        List<String> caseIdList = new List<String>();
        
        List<XC_Customer_Interaction__c> interactionList = new List<XC_Customer_Interaction__c>();
        for(Case cas : mapNew.values()){
            Boolean check = (cas.XC_Segment__c == 'B2B' && cas.Reason == 'XCMOT008' && cas.SubCause__c == 'ATCL014' && cas.AssetId != null && cas.Status == 'ESTA007' && cas.Status != mapOld.get(cas.id).Status);
            if(check){
                caseIdList.add(cas.Id);
            }
        }
        if(caseIdList.isEmpty()){
            return;
        }
        List<Case> caseInfo = [Select Status, Reason, AssetId, SubCause__c, Asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name, Asset.NE__CatalogItem__c, AccountId, ContactId, Contact.XC_Preferredlanguageofcontact__c, ContactEmail, XC_ContactName__c, XC_Segment__c, XC_LegalEntity__c from Case where id IN : caseIdList];
        for(Case c : caseInfo){
            if(c.Asset.NE__CatalogItem__c != null && c.Asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Monitoring And Verification'){
                interactionList.add(populateCustomerInteraction(c));
            }
        }
        insert interactionList;
    }
    
    public static XC_Customer_Interaction__c populateCustomerInteraction(Case c ){
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_ContactId__c = c.ContactId;
        ci.XC_AccountId__c = c.AccountId;
        ci.XC_Email__c = c.ContactEmail;
        ci.XC_Preferredlanguageofcontact__c = c.Contact.XC_Preferredlanguageofcontact__c;
        ci.XC_Channel__c =  'Email';
        ci.XC_Communication_Type__c = 'Change_MOP';
        ci.XC_LegalEntity__c = c.XC_LegalEntity__c;
        ci.XC_Segment__c = c.XC_Segment__c;
        ci.XC_CaseId__c = c.id;
        return ci;
    }
}