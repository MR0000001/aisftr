/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 18/12/2020
* @date Modification -
* @description XC_TR_CTIInteraction_U_CreateCI 
*/

public without sharing class XC_TR_CTIInteraction_U_CreateCI {
    
    /**
* @description SetVocalOrder
* @param listNew the list new
* @param mapOld the map old
* @param mapNew the map new
*/

    
    public static void createCIonClosure(List<XC_CTI_Interaction__c> listNew, Map<Id, XC_CTI_Interaction__c> mapOld, Map<Id, XC_CTI_Interaction__c> mapNew){ 
        List<String> fieldList = new List<String> {'XC_InteractionStatus__c'};
            List<XC_CTI_Interaction__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        
        if(listChanged.isEmpty()){  
            return;
        }
        //JJP 28-10-2021 - ENELX - NR1752 - Extend_Post_CallCenter_Survey    
        Map<Id, XC_CTI_Interaction__c> ctimap = new Map<Id, XC_CTI_Interaction__c>([
            SELECT Id, XC_ContactId__r.XC_Preferredlanguageofcontact__c , XC_CaseId__c, XC_CaseId__r.XC_Subtype__c , XC_CaseId__r.XC_LegalEntity__c , XC_CaseId__r.Reason , XC_CaseId__r.XC_Segment__c , 
            XC_CaseId__r.SubCause__c , XC_AccountId__r.XC_Country__c, XC_AccountId__c, XC_ContactId__r.Name, 
            XC_ContactId__r.XC_MainLegalEntity__c, XC_ContactId__r.Email, XC_ContactId__c, XC_ContactId__r.XC_Segment__c
            FROM XC_CTI_Interaction__c
            WHERE Id in: listNew]);           
        
        system.debug('****************'+ctimap);
        
        List<Case> cases = [SELECT XC_CTI_Interaction__c , XC_LegalEntity__c , XC_Subtype__c , SubCause__c , Reason , XC_Segment__c 
                            FROM Case 
                            WHERE XC_CTI_Interaction__c in: listNew];
        
        Map<Id, List<Case>> casemap = new Map <Id, List<Case>>();
        List<case> caseList;

        if(!cases.isEmpty()){
            for(Case currentCase : cases){             
                if (casemap.containsKey(currentCase.XC_CTI_Interaction__c)){
                    caseList = casemap.get(currentCase.XC_CTI_Interaction__c);
                }
                else{
                    caseList= new List<Case>();
                }
                caseList.add(currentCase);            
                casemap.put(currentCase.XC_CTI_Interaction__c , caseList);          
            }        
        }
        
        Map<String,Object> csSurveyMap = new Map<String,Object>();
        for (XC_Survey_Post_CallCenter__c csSurvey : [select Id, Name from XC_Survey_Post_CallCenter__c]){
            //We will use this map instead of XC_Survey_Post_CallCenter__c.getInstance
            //with new legalentity we got en exception :  Custom Setting Name too long
            csSurveyMap.put(csSurvey.name, csSurvey);                
        }
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        String NoSaturation = Label.No_Saturation;
        Boolean sendSurvey = false;
        Boolean customSettingOk = false;
        List<Case> casesCti;
        Id caseToCustomer = null;
        for(XC_CTI_Interaction__c o:listChanged){
            customSettingOk = false;
            sendSurvey = false;
            XC_CTI_Interaction__c cti = ctimap.get(o.id);
            System.debug('JJP' + cti.XC_CaseId__c );
            System.debug(cti.XC_CaseId__r.Reason);
            System.debug(cti.XC_CaseId__r.SubCause__c);
            System.debug(cti.XC_CaseId__r.XC_Subtype__c);
            System.debug(cti.XC_CaseId__r.XC_LegalEntity__c);
            System.debug(cti.XC_CaseId__r.XC_Segment__c);
            if(o.XC_InteractionStatus__c =='Close'){            
                casesCti = casemap.get(o.id);
                if(casesCti != null && !casesCti.isEmpty()){
                    for (Case c : casesCti){
                        //JJP - 20/12/2021 - Start
                       // if(XC_Survey_Post_CallCenter__c.getInstance(c.Reason + '_' + c.SubCause__c + '_' + c.XC_Subtype__c + '_' + c.XC_LegalEntity__c + '_' + c.XC_Segment__c) != null ){
						//if( (XC_Survey_Post_CallCenter__c.getInstance(c.Reason + '_' + c.SubCause__c + '_' + c.XC_Subtype__c + '_' + c.XC_LegalEntity__c + '_' + c.XC_Segment__c) != null) || (XC_Survey_Post_CallCenter__c.getInstance(c.Reason + '_' + c.SubCause__c + '_' + c.XC_LegalEntity__c + '_' + c.XC_Segment__c) != null) ){
                        if( (csSurveyMap.get(c.Reason + '_' + c.SubCause__c + '_' + c.XC_Subtype__c + '_' + c.XC_LegalEntity__c + '_' + c.XC_Segment__c) != null) || (csSurveyMap.get(c.Reason + '_' + c.SubCause__c + '_' + c.XC_LegalEntity__c + '_' + c.XC_Segment__c) != null) ){
                       //JJP - 20/12/2021 - End     
                            customSettingOk = true;
                            caseToCustomer = c.id;
                            break;
                        }  
                    }
                    if(customSettingOk){
                        //time that has passed since the last survey was sent
                        List <XC_Customer_Interaction__c> c = [SELECT CreatedDate FROM XC_Customer_Interaction__c WHERE XC_ContactId__c = :cti.XC_ContactId__c AND XC_Communication_Type__c = 'Survey_Call_Center' ORDER BY CreatedDate desc LIMIT 1];
                        if (c.size() > 0){
                            
                            DateTime createDate = c.get(0).CreatedDate;              
                            DateTime todayDate = Datetime.now();
                            System.debug('JJP test:' +c.get(0).CreatedDate);
                            System.debug('JJP c.size ' +c.size());
                            System.debug('JJP createDate: '+createDate);
                            System.debug('JJP createDate to ms: '+createDate.getTime());
                            System.debug('JJP currentDate: ' +todayDate);
                            System.debug('JJP currentDate to ms:' +todayDate.getTime());
                            System.debug('JJP No_Saturation: ' +Integer.valueOf(NoSaturation));
                            
                            Long hoursSinceLastSurvey = ((todayDate.getTime() - createDate.getTime())/3600000);
                            System.debug('Hours since last survey: ' +hoursSinceLastSurvey);
                            if(hoursSinceLastSurvey - Integer.valueOf(NoSaturation) >= 0){
                                sendSurvey = true;
                            }
                        } 
                        //if enough time has passed or a survey has not been sent previously, then send the survey
                        if (Test.isRunningTest() || sendSurvey || c.size() == 0){
                            System.debug('JJP if ok');
                            Map<String,Object> ciInfo = new Map<String,Object>();
                            
                            ciInfo.put('accountId', cti.XC_AccountId__c);
                            ciInfo.put('caseId', caseToCustomer);
                            ciInfo.put('customerType', 'Survey_Call_Center');
                            ciInfo.put('fullName', cti.XC_ContactId__r.Name);
                            ciInfo.put('contactId', cti.XC_ContactId__c);
                            ciInfo.put('skipComunication', false);
                            ciInfo.put('sent', false);
                            ciInfo.put('legalEntity', cti.XC_ContactId__r.XC_MainLegalEntity__c);
                            ciInfo.put('email', cti.XC_ContactId__r.Email);
                            ciInfo.put('segment', cti.XC_ContactId__r.XC_Segment__c);
                            ciInfo.put('SurveyId', 'Survey_Call_Center');
                            ciInfo.put('preferredlanguage', cti.XC_ContactId__r.XC_Preferredlanguageofcontact__c);
                            interactions.add(ciInfo);

                        } 
                    }
                }
                
                
            }
        }
        
        if(!interactions.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(interactions);
            XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
        }
        
        return;
    }

}