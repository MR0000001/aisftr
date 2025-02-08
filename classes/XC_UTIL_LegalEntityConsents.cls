/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 22/05/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_LegalEntityConsents – UTIL for Legal Entity Consents
*/
public without sharing class XC_UTIL_LegalEntityConsents {
 
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC003_NewAccount');
    
    /**
     * @description Create Legal Entity Consents
     * @param individualId the individual Id 
     * @param consentsLE legal entity consentsù
     * @return dml results
     * /
    public static XC_UTIL_Sobject.WrapperResult insertLegalEntityConsents(Id individualId, String consentsLE){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ NewLead > insertLegalEntityConsents -> IndividualId = '+ individualId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLE = '+ consentsLE);
        List<XC_UTIL_Sobject.WrapperResult> dmlResult = new List<XC_UTIL_Sobject.WrapperResult>();
        if(consentsLE!=null && !consentsLE.equals('null')){
            List<XC_LegalEntityConsent__c> consentsToInsert = new List<XC_LegalEntityConsent__c>();
            List<Object> consentsLEList = (List<Object>) JSON.deserializeUntyped(consentsLE);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsLEList = '+ consentsLEList);
            for(Object obj : consentsLEList){
			    Map<String,Object> item = (Map<String,Object>)obj;
                String legalEntity = (String)item.get('XC_LegalEntity__c');
                if(legalEntity==null || legalEntity==''){
                    continue;
                }
                XC_LegalEntityConsent__c newConsent = new XC_LegalEntityConsent__c();
                newConsent.XC_Individual__c = individualId;
                newConsent.XC_LegalEntity__c = legalEntity;
                newConsent.XC_GiveDataToNew__c =  String.valueOf(item.get('XC_GiveDataToNew__c'));
                newConsent.XC_UpdateAboutProducts__c =  String.valueOf(item.get('XC_UpdateAboutProducts__c'));
                newConsent.XC_ConsentToDataProcessing__c = String.valueOf(item.get('XC_ConsentToDataProcessing__c'));
                consentsToInsert.add(newConsent);
            }
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsToInsert3 = '+ consentsToInsert); 
            dmlResult = XC_UTIL_DML.insertRecords(consentsToInsert);
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ LE dmlResult List = '+ dmlResult);
        XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ insertLegalEntityConsents - result = '+ result);
        return result;
    }*/

    /**
     * @description update LEConsents for existinf Contact
     * @param existingContact the duplicate contact detected 
     * @param newAccount the account already insert
     * @param inputData the LEConsents
     * @return result wrapper
     * /
    public static XC_UTIL_Sobject.WrapperResult updateLegalConsents(Contact existingContact, Account newAccount,  XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ CALL XC_UTIL_LegalEntityConsents updateLegalConsents ');
        XC_UTIL_Sobject.WrapperResult legalResult = new XC_UTIL_Sobject.WrapperResult();
        legalResult.success = true;
        
        String currentIndividual = existingContact.IndividualId;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ currentIndividual = '+ currentIndividual);
        List<XC_LegalEntityConsent__c> exixtingLE = retrieveLegalEntityFromIndividual(currentIndividual);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ exixtingLE = '+ exixtingLE);

        List<String> leNames = new List<String>();
        for(XC_LegalEntityConsent__c le : exixtingLE){
            leNames.add(le.XC_LegalEntity__c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ leNames = '+ leNames);

        List<Map<String,Object>> consentsToInsert = new List<Map<String,Object>>();
        List<Object> newLEList = (List<Object>) JSON.deserializeUntyped(inputData.consentsLE);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ newLEList = '+ newLEList);
        for(Object obj : newLEList){
            Map<String,Object> item = (Map<String,Object>)obj;
            String legalEntity = (String)item.get('XC_LegalEntity__c');
            if(!leNames.contains(legalEntity)){
                consentsToInsert.add(item);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ consentsToInsert = '+ consentsToInsert);

        if(!consentsToInsert.isEmpty()){
            legalResult = insertLegalEntityConsents(currentIndividual, JSON.serialize(consentsToInsert));
        }

        return legalResult;
    }*/

    /**
     * @description Retrieve LegalEntity from IndividualId
     * @param individualId the individual Id
     * @return the List<XC_LegalEntityConsent__c> result
     * /
    private static List<XC_LegalEntityConsent__c> retrieveLegalEntityFromIndividual(String individualId){
        Map<Id,XC_LegalEntityConsent__c> leMap =  new Map<Id,XC_LegalEntityConsent__c>([SELECT Id, XC_LegalEntity__c FROM XC_LegalEntityConsent__c WHERE XC_Individual__c =: individualId ]);
        return leMap.values();
    }*/
    
    /**
     * @description checkAvailableConsentForContact
     * @param newAccount the newAccount
     * @param contact the contact
     * @param inputData
     */
   public static void checkAvailableConsentForContact(Account newAccount, Contact contact, XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in checkAvailableConsentForContact con inputData = '+inputData);
        List<String> availableConsents = new List<String>();
        if(newAccount.XC_GiveDataTo_JuicenetLimited__c){
            availableConsents.add(Label.XC_CL_JuicenetLimited);
        }if(newAccount.XC_GiveDataTo_EndesaX__c){ 
              availableConsents.add(Label.XC_CL_EndesaX);
        }if(newAccount.XC_GiveDataTo_EnelXMobilitySpain__c){ 
            availableConsents.add(Label.XC_CL_LegalEntity_EnelXMobilitySpain);
        }if(newAccount.XC_GiveDataTo_EnelXMobilityUK__c){ 
            availableConsents.add(Label.XC_CL_LegalEntity_EnelXMobilityUK);
        }
        if(newAccount.Id!=contact.AccountId){ // caso Secondary Contact
            List<Object> consentsLEList = (List<Object>) JSON.deserializeUntyped(inputData.consentsLE);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'consentsLEList3 ='+consentsLEList);
            List<Map<String,Object>> approvedLE = new List<Map<String,Object>>();
            for(Object obj : consentsLEList){
                Map<String,Object> item = (Map<String,Object>)obj;
                String legalEntity = (String)item.get('XC_LegalEntity__c');
                if(availableConsents.contains(legalEntity)){
                    approvedLE.add(item);
                }
            }
            inputData.consentsLE = JSON.serialize(approvedLE);
        }
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com - Monica Cutillo monica.cutillo@nttdata.com
    * @date Creation 05/07/2019
    * @description Method to check available LegalEntity for Secondary Contact
    * @param listNew - List<XC_LegalEntityConsent__c>
    * @return result wrapper mapped with Contact Id
    */
    public static Map<Id,XC_UTIL_ResultWrapper> checkAvailableLegalEntityOnSecContact(List<XC_LegalEntityConsent__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START checkAvailable LegalEntity On SecContact');
        Map<Id,XC_UTIL_ResultWrapper> result = new Map<Id,XC_UTIL_ResultWrapper>();
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        Map<Id,XC_LegalEntityConsent__c> individualIdToLegalEnt = new Map<Id,XC_LegalEntityConsent__c>();
        for(XC_LegalEntityConsent__c legalEn : listNew){
            individualIdToLegalEnt.put(legalEn.XC_Individual__c,legalEn);
        }

        Map<Id,Individual> individualMap = new Map<Id,Individual>([SELECT Id, (SELECT Id,AccountId, XC_PrimaryContact__c FROM Contacts 
                                                                WHERE XC_PrimaryContact__c = false LIMIT 1 )
                                                                FROM Individual WHERE Id IN : individualIdToLegalEnt.keySet()]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ individualMap = '+individualMap);

        Set<Id> accountsId = new Set<Id>();
        Map<Id,Id> indiAccMapping = new Map<Id,Id>();
        for(Individual ind : individualMap.values()){
            if(!ind.Contacts.isEmpty()){ // Trovato Individual di un contatto secondario quindi vado a cercare il primario sull'account
                accountsId.add(ind.Contacts[0].AccountId);
                indiAccMapping.put(ind.Id,ind.Contacts[0].AccountId);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ accountsId = '+accountsId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ indiAccMapping = '+indiAccMapping);

        //cerco tutti i primary contact
        Map<Id,Account> accMap =  new Map<Id,Account>([SELECT Id, (SELECT Id, AccountId, XC_PrimaryContact__c,IndividualId FROM Contacts 
                                                                    WHERE XC_PrimaryContact__c = true LIMIT 1) 
                                                       FROM Account WHERE Id IN: accountsId]);
    
        List<Contact> primaryContacts = new List<Contact>();
        for(Account acc : accMap.values()){
            if(!acc.Contacts.isEmpty()){
                primaryContacts.addAll(acc.Contacts);
            }
        }
        Map<Id,List<String>> primaryLegalListNames = checkAllConsentsOfPrimary(primaryContacts);
        return prepareResultLEAvailabilityForLE(listNew, indiAccMapping, primaryLegalListNames);
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com - Monica Cutillo monica.cutillo@nttdata.com
    * @date Creation 09/07/2019
    * @description Method to check available LegalEntity for Secondary Contact
    * @param listNew - List<XC_LegalEntityConsent__c>
    * @param indiAccMapping - Map<Id,Id> IndividualId -> AccountId
    * @param primaryLegalListNames - Map<Id,List<String>>
    * @return result wrapper mapped with LE Id
    */
    private static Map<Id,XC_UTIL_ResultWrapper> prepareResultLEAvailabilityForLE(List<XC_LegalEntityConsent__c> listNew, Map<Id,Id> indiAccMapping, Map<Id,List<String>> primaryLegalListNames){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START prepare Result For Legal Entity  Availability');
        Map<Id,XC_UTIL_ResultWrapper> result = new Map<Id,XC_UTIL_ResultWrapper>();
        XC_UTIL_ResultWrapper rw;
        for(XC_LegalEntityConsent__c le : listNew){
            Id accIdKey = indiAccMapping.get(le.XC_IndividualId__c);
            List<String> primaryLE = primaryLegalListNames.get(accIdKey);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ le.XC_IndividualId__c = '+le.XC_IndividualId__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ accIdKey = '+accIdKey);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ primaryLE = '+primaryLE);
            if(primaryLE != null && !primaryLE.isEmpty()){
                if(!primaryLE.contains(le.XC_LegalEntity__c)){
                    rw = new XC_UTIL_ResultWrapper();
                    rw.resultMessage = Label.XC_CL_LENotAvailable;
                }else {
                    rw = new XC_UTIL_ResultWrapper();
                    rw.success = true;
                }
                result.put(le.Id, rw);
            }
        }
        return result;
    }


    /** 
    * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com - Monica Cutillo monica.cutillo@nttdata.com
    * @date Creation 05/07/2019
    * @description Method to check All Consents Of Primary Contact
    * @param contacts - Contact
    * @return consents names list mapping with account id
    */
    public static Map<Id,List<String>> checkAllConsentsOfPrimary(List<Contact> contacts){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START checkAllConsentsOfPrimary - contacts = '+contacts);
        List<XC_LegalEntityConsent__c> legalList;
        Map<Id,Contact> indiMap = new Map<Id,Contact>();
        for(Contact c : contacts){
            indiMap.put(c.IndividualId, c);
        }

        Map<Id,List<String>> result = new Map<Id,List<String>>();
        List<String> primaryLegalListNames;
        List<Individual> individualList = new List<Individual>([SELECT Id, (SELECT Id, XC_LegalEntity__c FROM Legal_Entity_Consents__r) 
                                                                FROM Individual WHERE Id IN: indiMap.keySet() ]);

        Contact contact;
        for(Individual indi : individualList){
            if(indi.Legal_Entity_Consents__r.isEmpty()){
                continue;
            }
            primaryLegalListNames = new List<String>();
            legalList = indi.Legal_Entity_Consents__r;
            for(XC_LegalEntityConsent__c legalEn : legalList ){
                primaryLegalListNames.add(legalEn.XC_LegalEntity__c);
            }
            contact = indiMap.get(indi.Id);
            result.put(contact.AccountId, primaryLegalListNames);
        }
        return result;
    }
}