/**
* @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 20/05/2019
* @description XC_TR_Lead_U_CheckDuplicates – Util class for Lead for check duplicates
*/ 
 

public without sharing class XC_TR_Lead_U_CheckDuplicates {

    private final static Boolean DEBUGACTIVE = true; //XC_UTIL_Debug.isActive('XC_TR_Lead_U_CheckDuplicates');

    /** @description CheckFieldWrapper */
    /*private class CheckFieldWrapper {
        Set<String> setPrimaryKeys = new Set<String>();
        Set<String> setProductCategories = new Set<String>();
        Set<String> setAddresses = new Set<String>(); 
    } */

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to check lead duplicates 
    * @param listLeadInput - List<Lead>
    */
    public static void checkDuplicates(List<Lead> listLeadInput) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '<-- ENTER IN XC_TR_Lead_U_CheckDuplicates -->');
        checkingMassiveDML(listLeadInput);
        List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapperList = XC_UTIL_LeadDuplication.checkDuplicates(listLeadInput);
        for (XC_LCC002_NewLead_W.InsertResultWrapper wrp : wrapperList){
            if (wrp.leadToAddError != null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '<-- wrp.leadToAddError -->' + wrp.leadToAddError);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '<-- wrp.leadToUpdate -->' + wrp.leadToUpdate);
                if( (wrp.leadToUpdate.XC_DocumentNumber__c == wrp.leadToAddError.XC_DocumentNumber__c && !String.isBlank(wrp.leadToUpdate.XC_DocumentNumber__c) )
                    || (wrp.leadToUpdate.Email == wrp.leadToAddError.Email && !String.isBlank(wrp.leadToUpdate.Email))){ //FIX SS 20/08/19
                    wrp.leadToAddError.addError(wrp.errorMessage);
                }
            } 
        }
       

       /* CheckFieldWrapper checkFieldWrapper = populateCheckFieldWrapper(listLeadInput);
        Map<Id, Lead> mapLeadToCheck = new Map<Id, Lead>([
            SELECT Id, XC_PrimaryKey__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_ListOfLegalEntity__c, RecordTypeId
            FROM Lead
            WHERE XC_PrimaryKey__c IN :checkFieldWrapper.setPrimaryKeys
            AND XC_ProductCategoryOfInterest__c IN :checkFieldWrapper.setProductCategories
            AND XC_ConcatenatedAddress__c IN :checkFieldWrapper.setAddresses
        ]);

        if(mapLeadToCheck.isEmpty()){
            return;
        }
        checkErrorDuplicates(listLeadInput, mapLeadToCheck);*/
    }
    
    private static void checkingMassiveDML(List<Lead> listLeadInput){
        if(listLeadInput.size()>1){
            Set<Lead> leadToAddErrorSet = new Set<Lead>();
            for(Integer i = 0 ; i< listLeadInput.size(); i++){
                for(Integer j = i+1; j<=listLeadInput.size()-1; j++){
                    if(checkDuplication(listLeadInput[i],listLeadInput[j])){
                        leadToAddErrorSet.add(listLeadInput[j]);
                    }
                }
            }
            for(Lead ld : listLeadInput){
                if(leadToAddErrorSet.contains(ld)){
                    ld.addError(Label.XC_CL_Lead_LeadDuplicatedGeneric);
                }
            }
        }
    }

    private static Boolean checkDuplication(Lead previousLead, Lead actualLead){
        return ((previousLead.XC_DocumentType__c == actualLead.XC_DocumentType__c && previousLead.XC_DocumentNumber__c == actualLead.XC_DocumentNumber__c && !String.isEmpty(actualLead.XC_DocumentNumber__c))
                || (previousLead.FirstName == actualLead.FirstName && previousLead.LastName == actualLead.LastName && previousLead.XC_PhonePrefix__c == actualLead.XC_PhonePrefix__c && previousLead.XC_LeadPhone__c == actualLead.XC_LeadPhone__c && !String.isEmpty(actualLead.XC_LeadPhone__c))
                || (previousLead.Email == actualLead.Email && !String.isEmpty(actualLead.Email))
        );
    }
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to check lead duplicates on update
    * @param mapOld - Map<Id, sObject>()
    * @param mapNew - Map<Id, sObject>()
    */
    public static void checkDuplicatesOnUpdate(Map<Id,sObject> mapOld, Map<Id,sObject> mapNew) { 
        Map<Id, sObject> mapLeadResidential = new Map<Id, sObject>();
        Map<Id, sObject> mapLeadSoho = new Map<Id, sObject>();
        Map<Id, sObject> mapLeadCondominium = new Map<Id, sObject>();
 		XC_UTIL_Debug.debug(DEBUGACTIVE, '<-- ENTER IN check Duplicates On Update Method -->');
        List<Lead> listlead = (List<Lead>) mapNew.values();

        List<String> listFieldsToCheck = new List<String>{'XC_StreetType__c', 'XC_Address__c', 'XC_StreetNumber__c', 'XC_ZipCode__c', 'XC_City__c', 'XC_Province__c', 'XC_ProductCategoryOfInterest__c'};
        List<String> listFieldsToCheckResidential = new List<String>{'Email', 'FirstName', 'LastName', 'XC_PhonePrefix__c', 'XC_LeadPhone__c'};
        listFieldsToCheck.addAll(listFieldsToCheckResidential);
        List<String> listFieldsToCheckSohoAndCond = new List<String>{'XC_DocumentType__c', 'XC_DocumentNumber__c'};
        listFieldsToCheck.addAll(listFieldsToCheckSohoAndCond);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '<-- listFieldsToCheck -->' + listFieldsToCheck);
        List<Lead> listChanged = XC_UTIL_Sobject.getListChanged(listFieldsToCheck, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@ Leads Changed-->' + listChanged);
            checkDuplicates(listChanged);
        }
    } 

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to populate CheckFieldWrapper
    * @param listLeadInput - List<Lead>
    * @return CheckFieldWrapper
    */
 /*   private static CheckFieldWrapper populateCheckFieldWrapper(List<Lead> listLeadInput) { 
        CheckFieldWrapper wrapper = new CheckFieldWrapper();
        for(Lead ld : listLeadInput){
            if(XC_UTIL_Lead.isResidential(ld.recordTypeId)){
                if(!String.isBlank(ld.Email)){
                    ld.XC_PrimaryKey__c = ld.Email;
                } else {
                    ld.XC_PrimaryKey__c = String.join(new List<String>{ld.FirstName, ld.LastName, ld.XC_PhonePrefix__c, ld.XC_LeadPhone__c}, '|');
                }
            }
            else if(XC_UTIL_Lead.isSoho(ld.RecordTypeId) || XC_UTIL_Lead.isCondominium(ld.recordTypeId)){
                ld.XC_PrimaryKey__c = String.join(new List<String>{ld.XC_DocumentType__c, ld.XC_DocumentNumber__c}, '|');
            }
            List<String> addressFields = new List<String>{ld.XC_StreetType__c, ld.XC_Address__c, ld.XC_StreetNumber__c, ld.XC_ZipCode__c, ld.XC_City__c, ld.XC_Province__c};
            ld.XC_ConcatenatedAddress__c = String.join(addressFields, '|');
            wrapper.setPrimaryKeys.add(ld.XC_PrimaryKey__c);
            wrapper.setProductCategories.add(ld.XC_ProductCategoryOfInterest__c);
            wrapper.setAddresses.add(ld.XC_ConcatenatedAddress__c);
        }
        return wrapper;
    }*/

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to check if a Lead is a duplicate
    * @param listLeadInput - List<Lead>
    * @param mapLeadToCheck - Map<Id, Lead>
    */
 /*   private static void checkErrorDuplicates(List<Lead> listLeadInput, Map<Id, Lead> mapLeadToCheck) { 
        for(Lead ld : listLeadInput){ 
            Boolean duplicateFound = false; 
            for(Lead ldd : mapLeadToCheck.values()){
                if(ld.Id != ldd.Id) {
                    if(ld.XC_PrimaryKey__c == ldd.XC_PrimaryKey__c
                    && ld.XC_ConcatenatedAddress__c == ldd.XC_ConcatenatedAddress__c
                    && ld.XC_ProductCategoryOfInterest__c == ldd.XC_ProductCategoryOfInterest__c
                    && ld.RecordTypeId == ldd.RecordTypeId){
                        Boolean isDuplicate = checkLegalEntities(ld, ldd);
                        if(isDuplicate){
                            String keyForErrorMessage = getKeyForErrorMessage(ld);
                            ld.addError(Label.XC_CL_LeadAlreadyExists + ' ' + keyForErrorMessage);
                            duplicateFound = true; 
                            break;
                        }
                    } 
                }  
            }
        } 
    }*/

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 20/05/2019
    * @description Method to check Legal Entities by Input Lead and others
    * @param ld - Lead
    * @param ldd - Lead
    * @return Boolean
    */
   /* private static Boolean checkLegalEntities(Lead ld, Lead ldd){ 
        if(String.isBlank(ld.XC_ListOfLegalEntity__c) || String.isBlank(ldd.XC_ListOfLegalEntity__c)){
            return false; 
        }
        List<String> listLegalEntitiesNewLead = ld.XC_ListOfLegalEntity__c.split('|');
        List<String> listLegalEntitiesExistingLead = ldd.XC_ListOfLegalEntity__c.split('|'); 
 
        for(String le : listLegalEntitiesNewLead){
            if(listLegalEntitiesExistingLead.contains(le)){
                return true;
            }
        } 
        return false;
    }*/

    

    /*private static String getKeyForErrorMessage(Lead ld){
        String key = '';
        if(XC_UTIL_Lead.isResidential(ld.recordTypeId)){
            key = (!String.isBlank(ld.Email)) ? ld.Email : ld.XC_LeadPhone__c;
        } if(XC_UTIL_Lead.isSoho(ld.RecordTypeId) || XC_UTIL_Lead.isCondominium(ld.recordTypeId)){
            key = ld.XC_DocumentNumber__c;
        }
        return key;
    }*/

}