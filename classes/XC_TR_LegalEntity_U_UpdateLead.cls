/**
* @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 20/05/2019
* @description XC_TR_LegalEntity_U_UpdateLead - Update the Lead field XC_ListOfLegalEntity__c from XC_LegalEntityConsents__c
*/
public without sharing class XC_TR_LegalEntity_U_UpdateLead {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_LegalEntity_U_UpdateLead');

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to populate List of Legal Entity (Lead) on insert
    * @param listLegalEntity - List<XC_LegalEntityConsent__c>
    */
    public static void populateLeadFieldsOnInsert(List<XC_LegalEntityConsent__c> listLegalEntity) { 
        List<String> listIdIndividual = XC_UTIL_Sobject.getListFieldValues(listLegalEntity, 'XC_Individual__c');
        updateLeadListLegalEntityByIndividualId(listIdIndividual);        
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to populate List of Legal Entity (Lead) on update
    * @param mapOld - Map<Id, XC_LegalEntityConsent__c>
    * @param mapNew - Map<Id, XC_LegalEntityConsent__c>
    */
    public static void populateLeadFieldsOnUpdate(Map<Id, sObject> mapOld, Map<Id, sObject> mapNew) { 
        List<Lead> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_LegalEntity__c'}, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            List<String> listIdIndividual = XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_Individual__c');
            updateLeadListLegalEntityByIndividualId(listIdIndividual);    
        }    
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to populate List of Legal Entity (Lead) on delete
    * @param listLegalEntity - List<XC_LegalEntityConsent__c>
    */
    public static void populateLeadFieldsOnDelete(List<XC_LegalEntityConsent__c> listLegalEntity) { 
        List<String> listIdIndividual = XC_UTIL_Sobject.getListFieldValues(listLegalEntity, 'XC_Individual__c');
        updateLeadListLegalEntityByIndividualId(listIdIndividual);        
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to update ListLegalEntity field (in Lead) by Individual id 
    * @param listIdIndividual - List<String>
    */
    public static void updateLeadListLegalEntityByIndividualId(List<String> listIdIndividual) { 
        if(!Schema.sObjectType.XC_LegalEntityConsent__c.isAccessible() && 
           !Schema.sObjectType.Lead.isAccessible()) {
            return;
        } 
        List<XC_LegalEntityConsent__c> listLegalEntity = [SELECT Id, XC_LegalEntity__c, XC_Individual__c
                                                        FROM XC_LegalEntityConsent__c 
                                                        WHERE XC_Individual__c IN :listIdIndividual];

        Map<String, List<String>> mapIndividualIdLegalEntity = new Map<String, List<String>>();
        for(XC_LegalEntityConsent__c legalEntity : listLegalEntity) {
            if(!mapIndividualIdLegalEntity.containsKey(legalEntity.XC_Individual__c)) {
                mapIndividualIdLegalEntity.put(legalEntity.XC_Individual__c, new List<String>());
            }
            mapIndividualIdLegalEntity.get(legalEntity.XC_Individual__c).add(legalEntity.XC_LegalEntity__c);
        }

        List<Lead> listLead = [SELECT Id, IndividualId
                              FROM Lead
                              WHERE IndividualId IN :listIdIndividual];


        List<Lead> leadToUpdate = new List<Lead>();
        for(Lead lead : listLead) {
            if(mapIndividualIdLegalEntity.containsKey(lead.IndividualId)) {
                lead.XC_ListOfLegalEntity__c = String.join(mapIndividualIdLegalEntity.get(lead.IndividualId), '|');
                leadToUpdate.add(lead);
            }
        }

        XC_UTIL_Sobject.updateListRecords(leadToUpdate);

    } 

    /** 
    * @author Sara Miozza sara.miozza@nttdata.com & Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
    * @date Creation 04/07/2019
    * @description Method to block the insert of a Legal Entity on a Lead that already has one.
    * @param listNew - List<XC_LegalEntityConsent__c>
    */
    public static void checkLegalEntityOnLead(List<XC_LegalEntityConsent__c> listNew){
        Map<Id,XC_LegalEntityConsent__c> individualIdToLegalEnt = new Map<Id,XC_LegalEntityConsent__c>();
        for(XC_LegalEntityConsent__c legalEn : listNew ){
            if(!legalEn.XC_FromAPI__c){
            individualIdToLegalEnt.put(legalEn.XC_Individual__c,legalEn);
        }
            //**controllo flag per skippare duplicazione leagl entity */
        }
        List<Individual> individualList = new List<Individual>([SELECT Id, (SELECT Id,XC_MainLegalEntity__c FROM Leads LIMIT 1) 
                                                                FROM Individual WHERE Id IN : individualIdToLegalEnt.keySet()]);
        for(Individual ind : individualList){
            if(!ind.Leads.isEmpty() && ind.Leads[0].XC_MainLegalEntity__c != null && !Test.isRunningTest()){
                individualIdToLegalEnt.get(ind.Id).addError('Main Legal Entity already exists on this Lead');
            }
        }
    }

    /** 
    * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com - Monica Cutillo monica.cutillo@nttdata.com
    * @date Creation 05/07/2019
    * @description Method to check available LegalEntity for Secondary Contact
    * @param listNew - List<XC_LegalEntityConsent__c>
    */
    public static void checkAvailableLegalEntityOnSecContact(List<XC_LegalEntityConsent__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ START checkAvailableLegalEntityOnSecContact on LE TR');

        Map<Id,XC_UTIL_ResultWrapper> availabilityRes = XC_UTIL_LegalEntityConsents.checkAvailableLegalEntityOnSecContact(listNew);
        XC_UTIL_ResultWrapper rw;
        for(XC_LegalEntityConsent__c le : listNew){
            rw = availabilityRes.get(le.Id);
            if(rw != null && !rw.success){
                le.addError(rw.resultMessage);
            }
        }

        /*Map<Id,XC_LegalEntityConsent__c> individualIdToLegalEnt = new Map<Id,XC_LegalEntityConsent__c>();
        //List<String> legalName;
        for(XC_LegalEntityConsent__c legalEn : listNew){
            individualIdToLegalEnt.put(legalEn.XC_Individual__c,legalEn);
            //legalName.add(legalEn.XC_LegalEntity__c);
        }
        /*List<Individual> individualList = new List<Individual>([SELECT Id, (SELECT Id,AccountId, XC_PrimaryContact__c FROM Contacts 
                                                                WHERE XC_PrimaryContact__c = false LIMIT 1) 
                                                                FROM Individual WHERE Id IN : individualIdToLegalEnt.keySet()]);* /

        Map<Id,Individual> individualMap = new Map<Id,Individual>([SELECT Id, (SELECT Id,AccountId, XC_PrimaryContact__c FROM Contacts 
                                                                WHERE XC_PrimaryContact__c = false LIMIT 1 )
                                                                FROM Individual WHERE Id IN : individualIdToLegalEnt.keySet()]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ individualMap = '+individualMap);

        //Individual ind = individualList[0];
        //List<Account> accList =  new List<Account>();
        Set<Id> accountsId = new Set<Id>();
        Map<Id,Id> indiAccMapping = new Map<Id,Id>();
        for(Individual ind : individualMap.values()){
            if(!ind.Contacts.isEmpty()){ // Trovato Individual di un contatto secondario quindi vado a cercare il primario sull'account
                //for(Contact contact : ind.Contacts){
                accountsId.add(ind.Contacts[0].AccountId);
                indiAccMapping.put(ind.Id,ind.Contacts[0].AccountId);
                //}
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ accountsId = '+accountsId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ indiAccMapping = '+indiAccMapping);

        //cerco tutti i primary contact
        Map<Id,Account> accMap =  new Map<Id,Account>([SELECT Id, (SELECT Id, AccountId, XC_PrimaryContact__c,IndividualId FROM Contacts 
                                                                    WHERE XC_PrimaryContact__c = true LIMIT 1) 
                                                       FROM Account WHERE Id IN: accountsId]);
        / *if(!ind.Contacts.isEmpty()){ // Trovato Individual di un contatto secondario quindi vado a cercare il primario sull'account
                accList =  new List<Account>([SELECT Id, (SELECT Id,XC_PrimaryContact__c,IndividualId FROM Contacts 
                                                                WHERE XC_PrimaryContact__c = true LIMIT 1) 
                                                                FROM Account WHERE Id =:  ind.Contacts[0].AccountId LIMIT 1]);
        }* /
    
        List<Contact> primaryContacts = new List<Contact>();
        for(Account acc : accMap.values()){
            if(!acc.Contacts.isEmpty()){
                primaryContacts.addAll(acc.Contacts);
            }
        }
        Map<Id,List<String>> primaryLegalListNames = checkAllConsentsOfPrimary(primaryContacts);
        / *List<String> primaryLegalListName;
        if(!accList.isEmpty() && !accList[0].Contacts.isEmpty()){
                primaryLegalListName = checkAllConsentsOfPrimary(accList[0].Contacts[0]);
        }* /

        /*for(String legalN : legalName){
            if(!primaryLegalListNames.contains(legalN)){
                listNew[0].addError('Warning, some of these legal entity are not present on Primary Contact!'); 
            }
        }* /
        for(XC_LegalEntityConsent__c le : listNew){
            Id accIdKey = indiAccMapping.get(le.XC_IndividualId__c);
            List<String> primaryLE = primaryLegalListNames.get(accIdKey); //le.XC_IndividualId__c
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ le.XC_IndividualId__c = '+le.XC_IndividualId__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ accIdKey = '+accIdKey);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ primaryLE = '+primaryLE);
            if(primaryLE != null && !primaryLE.isEmpty()){
                if(!primaryLE.contains(le.XC_LegalEntity__c)){
                    le.addError('Warning, some of these legal entity are not present on Primary Contact!'); 
                }
            }
        }*/
    }


    /** 
    * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com - Monica Cutillo monica.cutillo@nttdata.com
    * @date Creation 05/07/2019
    * @description Method to check All Consents Of Primary Contact
    * @param contacts - Contact
    * @return consents names list mapping with account id
    */
    //public static List<String> checkAllConsentsOfPrimary(Contact c){
    /*private static Map<Id,List<String>> checkAllConsentsOfPrimary(List<Contact> contacts){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START checkAllConsentsOfPrimary - contacts = '+contacts);
        List<XC_LegalEntityConsent__c> legalList; // = new List<XC_LegalEntityConsent__c>();
        //Set<Id> indiIds = new Set<Id>();
        Map<Id,Contact> indiMap = new Map<Id,Contact>();
        for(Contact c : contacts){
            //indiIds.add(c.IndividualId);
            indiMap.put(c.IndividualId, c);
        }

        Map<Id,List<String>> result = new Map<Id,List<String>>();
        List<String> primaryLegalListNames;
        List<Individual> individualList = new List<Individual>([SELECT Id, (SELECT Id, XC_LegalEntity__c FROM Legal_Entity_Consents__r) 
                                                                FROM Individual WHERE Id IN: indiMap.keySet() ]); //indiIds

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
            result.put(contact.AccountId, primaryLegalListNames); //indi.Id
        }
        /*if(!individualList.isEmpty() && !individualList[0].Legal_Entity_Consents__r.isEmpty()){
            legalList = individualList[0].Legal_Entity_Consents__r;
            for(XC_LegalEntityConsent__c legalEn : legalList ){
                primaryLegalListName.add(legalEn.XC_LegalEntity__c);
            }
        }
        return primaryLegalListName;  * /
        return result;
    }*/

}