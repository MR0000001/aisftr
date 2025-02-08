/**
* @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 26/06/2019
* @description XC_UTIL_LeadDuplication - Util class for Lead Duplication process
*/
public without sharing class XC_UTIL_LeadDuplication {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_LeadDuplication');
 
    private static List<String> finalStatus = new List<String>{Label.XC_CL_Lead_ClosedNotConverted, Label.XC_CL_Lead_ClosedConverted};
    /** @description CheckFieldWrapper */
    public class CheckFieldWrapper { 
        public Set<String> setEmail = new Set<String>();
        public Set<String> setPrefix = new Set<String>();
        public Set<String> setPhone = new Set<String>();
        public Set<String> setFirstName = new Set<String>();
        public Set<String> setLastName = new Set<String>();
        public Set<String> setDocumentType = new Set<String>();
        public Set<String> setDocumentNumber = new Set<String>();
        public Set<String> setPersonalDocumentType = new Set<String>();
        public Set<String> setPersonalDocumentNumber = new Set<String>();
        public Set<String> setProductCategories = new Set<String>();
        public Set<String> setAddresses = new Set<String>(); 
        public Set<String> setLegalEntity = new Set<String>(); 
        public Set<String> setCompany = new Set<String>(); 
        public Set<String> setId = new Set<String>();
    }
    private class KeyMessage {
        String key;
        String errorMessage;
    }
    
    /** @description CheckSingleFieldWrapper */
    public class CheckSingleFieldWrapper{
        public String newField;
        public String oldField;

        /**
        * @description CheckSingleFieldWrapper constructor
        * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
        * @param newField String
        * @param oldField String 
        */
        public CheckSingleFieldWrapper(String newField, String oldField){
            this.newField = newField;
            this.oldField = oldField;
        }
    }
    
    /** @description CheckFirstStep */
    public class CheckFirstStep{
        public Boolean checkEmail = false;
        public Boolean checkDocument  = false;
        public Boolean checkPhone  = false;
        public Boolean checkEmailAndDocumentAndPhone = false;
    }

    private class FirstCheckWrapper{
        CheckFirstStep checkFirst;
        XC_LCC002_NewLead_W.InsertResultWrapper wrapper;
        Lead ld;
        Lead existingLd;
    }
 
    /** @description UtilityWrapper */
    public class UtilityWrapper{
       public List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapperListToReturn;
       public XC_LCC002_NewLead_W.InsertResultWrapper wrapper;
       public Lead ld;
       public Lead existingLd;       
    }
    
    /** 
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 26/06/2019
    * @description Method to check lead duplicates 
    * @param listLeadInput - List<Lead>
    * @return List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapper List with result of duplicate matching
    */
    public static List<XC_LCC002_NewLead_W.InsertResultWrapper> checkDuplicates(List<Lead> listLeadInput) { 
        List<Lead> leadB2CList = new List<Lead>();
        List<Lead> leadB2BGList = new List<Lead>();
        CheckFieldWrapper checkFieldWrapper = new CheckFieldWrapper();
        for(Lead ld : listLeadInput){
            Lead leadInserted = (Lead) Lead.sObjectType.newSObject(/*recordTypeId*/ ld.RecordTypeId, /*loadDefaultValues*/ true);
            if(leadInserted.XC_Segment__c == 'B2C'){
                leadB2CList.add(ld);
            } else if(leadInserted.XC_Segment__c == 'B2B' || leadInserted.XC_Segment__c == 'B2G'){
                leadB2BGList.add(ld);
            }
        }
        if(!leadB2CList.isEmpty()){
            checkFieldWrapper = XC_UTIL_LeadDuplication_U.populateCheckFieldWrapper(leadB2CList);
        }else if(!leadB2BGList.isEmpty()){
            checkFieldWrapper = XC_UTIL_LeadDuplication_U.populateCheckFieldWrapperB2BG(leadB2BGList);
        }
        checkFieldWrapper.setId.add('');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@218 LEAD DUPLICATION PROCESS - Email ---> '+ checkFieldWrapper.setEmail);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@218 LEAD DUPLICATION PROCESS - Doc Number ---> '+ checkFieldWrapper.setDocumentNumber);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@218 LEAD DUPLICATION PROCESS - Phone ---> '+ checkFieldWrapper.setPhone);
        Map<Id, Lead> mapDuplicateLeads = new Map<Id, Lead>([
            SELECT Id, Email, Status, Phone, FirstName, LastName, XC_Channel__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_LeadPhone__c, XC_PhonePrefix__c, XC_ProductCategoryOfInterest__c, XC_ConcatenatedAddress__c, XC_MainLegalEntity__c, RecordTypeId,
                    XC_StreetType__c, XC_Address__c, XC_StreetNumber__c, XC_ZipCode__c, XC_City__c, XC_Province__c, Company
            FROM Lead
            WHERE 
            (
                (XC_DocumentType__c IN :checkFieldWrapper.setDocumentType
                AND XC_DocumentNumber__c IN :checkFieldWrapper.setDocumentNumber ) 
                OR Email IN :checkFieldWrapper.setEmail
                OR (FirstName IN :checkFieldWrapper.setFirstName
                AND LastName IN :checkFieldWrapper.setLastName
                AND XC_PhonePrefix__c IN :checkFieldWrapper.setPrefix
                AND XC_LeadPhone__c IN :checkFieldWrapper.setPhone)
                OR Company IN :checkFieldWrapper.setCompany 
            )             
            AND ID NOT IN :checkFieldWrapper.setId
            AND Status NOT IN :finalStatus
            AND XC_MainLegalEntity__c IN :checkFieldWrapper.setLegalEntity
            limit 10000
        ]);
 
        List<Lead> leadDuplicatedList = new List<Lead>();
        if(mapDuplicateLeads.isEmpty()){
            return new List<XC_LCC002_NewLead_W.InsertResultWrapper>();
        } else {
            leadDuplicatedList = XC_UTIL_LeadDuplication_V.filterDuplicateLeadMap(leadB2CList, mapDuplicateLeads);
        }

        if(!leadB2CList.isEmpty()){
            return XC_UTIL_LeadDuplication_V.checkErrorDuplicates(leadB2CList, leadDuplicatedList, finalStatus);
        } else if(!leadB2BGList.isEmpty()){
            return XC_UTIL_LeadDuplication_V.checkErrorDuplicatesB2BG(leadB2BGList, mapDuplicateLeads.values(), finalStatus);
        } else {
            return new List<XC_LCC002_NewLead_W.InsertResultWrapper>();
        }
    } 

    private static void ifFirstCheckTrue(FirstCheckWrapper firstCheckWrapper){
        CheckFirstStep checkFirst = firstCheckWrapper.checkFirst;
        XC_LCC002_NewLead_W.InsertResultWrapper wrapper = firstCheckWrapper.wrapper;
        Lead existingLd = FirstCheckWrapper.existingLd;
        Lead ld = FirstCheckWrapper.ld;
        if(onlyPhoneScenario(checkFirst, ld, existingLd)){
            wrapper.success = true;
        } else if(checkOnSecondaryKey(ld, existingLd)){ 
            //firstUpdateScenario(wrapper, existingLd, ld);  //--- FIX SA SS 03/12/2019 - ANOMALIA 1201
            wrapper = updateExistingLead(wrapper, ld, existingLd);
        } else {
            wrapper.success = false;
            KeyMessage keyForErrorMessage = populateKey(ld, existingLd);
            wrapper.leadToUpdate = existingLd; // FIX SS 29/08/19, before wrapper.leadToUpdate was empty
            wrapper.leadToAddError = ld;
            wrapper.errorMessage = Label.XC_CL_Lead_ErrorExists + keyForErrorMessage.key;                    
        }
    }  
    private static Boolean onlyPhoneScenario(CheckFirstStep checkFirst, Lead ld, Lead existingLd){
        return (checkFirst.checkPhone && checkOnDocumentEmail(ld, existingLd));
    }

    private static Boolean withExistingProductCategory(CheckFirstStep checkFirst, Lead existingLd){
        return (checkFirst.checkEmailAndDocumentAndPhone && !checkProductCategoryVoid(existingLd));
    }
    
    private static Boolean checkBreakCondition(XC_LCC002_NewLead_W.InsertResultWrapper wrapper){
        return !wrapper.success;
    }
    
    /**
    * @description cycleOnExistingLead
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param utilWrapper UtilityWrapper 
    * @return Boolean
    */
    public static Boolean cycleOnExistingLead(UtilityWrapper utilWrapper){
        List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapperListToReturn = utilWrapper.wrapperListToReturn;
        XC_LCC002_NewLead_W.InsertResultWrapper wrapper = utilWrapper.wrapper;
        Lead existingLd = utilWrapper.existingLd;
        Lead ld = utilWrapper.ld;
        
        Boolean breaking = false;
        CheckFirstStep checkFirst = XC_UTIL_LeadDuplication_V.checkEmailDocumentPhone(ld, existingLd);
        if (firstCheck(checkFirst, existingLd, ld)){
            FirstCheckWrapper firstCheckWrapper = new FirstCheckWrapper();
            firstCheckWrapper.checkFirst = checkFirst;
            firstCheckWrapper.wrapper = wrapper;
            firstCheckWrapper.existingLd = existingLd;
            firstCheckWrapper.ld = ld;
            ifFirstCheckTrue(firstCheckWrapper);
            wrapperListToReturn.add(wrapper);
            breaking = true;
        } else if(onlyPhoneScenario(checkFirst, ld, existingLd)){
            wrapper.success = true;
        } else if(withExistingProductCategory(checkFirst, existingLd) ) {
            XC_UTIL_LeadDuplication_V.manageScenarioWithExistingProduct(wrapper, ld, existingLd);
            wrapperListToReturn.add(wrapper);
            checkBreakCondition(wrapper);
        } else if(checkFirst.checkEmailAndDocumentAndPhone && !checkAddressVoid(existingLd)){
            manageScenarioWithAddress(wrapper, ld, existingLd);
            wrapperListToReturn.add(wrapper);
            checkBreakCondition(wrapper);
        } else if(checkFirst.checkEmailAndDocumentAndPhone){ 
            wrapperListToReturn.add(duplicatedLead(wrapper, ld, existingLd));
            checkBreakCondition(wrapper);
        } else {
            wrapper.success = true;
            System.debug('@@@ INSERT RECORD ' + wrapper);
            wrapperListToReturn.add(wrapper);
        }
        return breaking;
    }
     
    private static Boolean checkOnDocumentEmail(Lead ld, Lead existingLd){
        return ((!String.isBlank(ld.Email) && !String.isBlank(ld.XC_DocumentNumber__c) && ld.Email != existingLd.Email && ld.XC_DocumentNumber__c != existingLd.XC_DocumentNumber__c)
                ||(!String.isBlank(ld.Email) && ld.Email != existingLd.Email && String.isBlank(ld.XC_DocumentNumber__c) && String.isBlank(existingLd.XC_DocumentNumber__c))
                ||(!String.isBlank(ld.XC_DocumentNumber__c) && ld.XC_DocumentNumber__c != existingLd.XC_DocumentNumber__c && String.isBlank(ld.Email) && String.isBlank(existingLd.Email)));
                // FIX SS 19/8/19 BEFORE WAS: (ld.Email == existingLd.Email || ld.XC_DocumentNumber__c == existingLd.XC_DocumentNumber__c);
    }

    private static void manageScenarioWithAddress(XC_LCC002_NewLead_W.InsertResultWrapper wrapper,  Lead ld, Lead existingLd){
        if(ld.XC_ConcatenatedAddress__c== '|||||'){
            wrapper = duplicatedLead(wrapper, ld, existingLd);
            //anotherCheckOnProduct(wrapper, ld, existingLd);
        } else if(ld.XC_ConcatenatedAddress__c== existingLd.XC_ConcatenatedAddress__c&& String.isBlank(existingLd.XC_ProductCategoryOfInterest__c) && !String.isBlank(ld.XC_ProductCategoryOfInterest__c) && ld.XC_ProductCategoryOfInterest__c != existingLd.XC_ProductCategoryOfInterest__c){
            wrapper = updateExistingLead(wrapper, ld, existingLd);
        } else if(ld.XC_ConcatenatedAddress__c!= existingLd.XC_ConcatenatedAddress__c){
            wrapper.success = true; 
        } else {
            wrapper = duplicatedLead(wrapper, ld, existingLd);
        }
    }
    // METHOD DEPRACATED because the following cause: if I have more Leads with different address I cant say which one as to be updated when I insert a new Lead
    // without the address but with a product.
    /*private static void anotherCheckOnProduct(XC_LCC002_NewLead_W.InsertResultWrapper wrapper, Lead ld, Lead existingLd){
        if(String.isEmpty(existingLd.XC_ProductCategoryOfInterest__c) && !String.isEmpty(ld.XC_ProductCategoryOfInterest__c)){
            wrapper = updateExistingLead(wrapper, ld, existingLd);
        } else {
            wrapper = duplicatedLead(wrapper, ld, existingLd);
        }
    }*/

    // Fix SA SS 03/12/2019 - ANOMALIA 1201
    /*private static void firstUpdateScenario (XC_LCC002_NewLead_W.InsertResultWrapper wrapper, Lead existingLd, Lead ld){
        if(existingLd.Status == Label.XC_CL_Lead_AppointmentScheduling){
            wrapper.success = true;
        } else{  
            wrapper = updateExistingLead(wrapper, ld, existingLd);
        }
    }*/
    
    /**
    * @description updateExistingLead
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param wrapper XC_LCC002_NewLead_W.InsertResultWrapper 
    * @param ld Lead 
    * @param existingLd Lead 
    * @return XC_LCC002_NewLead_W.InsertResultWrapper
    */
    public static XC_LCC002_NewLead_W.InsertResultWrapper updateExistingLead(XC_LCC002_NewLead_W.InsertResultWrapper wrapper, Lead ld, Lead existingLd){
        wrapper.success = false;
        KeyMessage keyForErrorMessage = populateKey(ld, existingLd);
        wrapper.leadToUpdate = XC_UTIL_LeadDuplication_U.updateExistingLead(ld, existingLd);
        wrapper.leadToAddError = ld;
        wrapper.key = keyForErrorMessage.key;
        wrapper.errorMessage = keyForErrorMessage.errorMessage;
        wrapper.leadUpdated = true;
        return wrapper;
    }

    /**
    * @description duplicatedLead
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param wrapper XC_LCC002_NewLead_W.InsertResultWrapper 
    * @param ld Lead 
    * @param existingLd Lead 
    * @return XC_LCC002_NewLead_W.InsertResultWrapper
    */
    public static XC_LCC002_NewLead_W.InsertResultWrapper duplicatedLead(XC_LCC002_NewLead_W.InsertResultWrapper wrapper, Lead ld, Lead existingLd){
        wrapper.success = false;
        KeyMessage keyForErrorMessage = populateKey(ld, existingLd);
        wrapper.leadToUpdate = existingLd; // FIX SS 29/08/19, before wrapper.leadToUpdate was empty
        wrapper.leadToAddError = ld;
        wrapper.errorMessage = Label.XC_CL_Lead_ErrorExists + keyForErrorMessage.key; 
        return wrapper;
    }
    
    private static KeyMessage populateKey(Lead ld, Lead existingLd){
        KeyMessage wrapperKey = new KeyMessage();
        if(ld.XC_Channel__c == Label.XC_CL_Web){
            System.debug('@@@Lead Duplication -WEB Lead  case-lead.id: ' + existingLd.Id);
            wrapperKey.key = existingLd.Id;
            wrapperKey.errorMessage = Label.XC_CL_LeadAlreadyExists + ' ' + existingLd.Id;
        } else {
            wrapperKey.key = XC_UTIL_LeadDuplication_U.getKeyForErrorMessage(ld, existingLd);
            wrapperKey.errorMessage = Label.XC_CL_LeadAlreadyExists + ' ' + wrapperKey.key;
        }
        return wrapperKey;
    }

    private static Boolean firstCheck(CheckFirstStep checkFirst, Lead existingLd, Lead ld){
        return (checkFirst.checkEmailAndDocumentAndPhone && checkLegalEntity(ld, existingLd) && checkProductCategoryVoid(existingLd) && checkAddressVoid(existingLd));
    }
    
    private static Boolean checkLegalEntity(Lead ld, Lead existingLd){
        String legalEntity;
        String existingLegalEntity;
        List<CheckSingleFieldWrapper> checkSingleFieldWrapperList = new List<CheckSingleFieldWrapper>();

        if(!String.isBlank(ld.XC_MainLegalEntity__c)){
            legalEntity = ld.XC_MainLegalEntity__c;
            existingLegalEntity = existingLd.XC_MainLegalEntity__c;
        }

        checkSingleFieldWrapperList.add(new CheckSingleFieldWrapper(legalEntity, existingLegalEntity));
        return XC_UTIL_LeadDuplication_V.checkFields(checkSingleFieldWrapperList);
    }

    private static Boolean checkProductCategoryVoid(Lead ld){
        return (String.isBlank(ld.XC_ProductCategoryOfInterest__c));
    }

    private static Boolean checkAddressVoid(Lead ld){
        return (String.isBlank(ld.XC_ConcatenatedAddress__c) || ld.XC_ConcatenatedAddress__c== '|||||');
    }

    private static Boolean secondCheckOnProductCategory(Lead ld, Lead existingLd){
        return (String.isBlank(existingLd.XC_ProductCategoryOfInterest__c) || ld.XC_ProductCategoryOfInterest__c == existingLd.XC_ProductCategoryOfInterest__c);
    }

    private static Boolean secondCheckOnAddress(Lead ld, Lead existingLd){
        return (String.isBlank(existingLd.XC_ConcatenatedAddress__c) || existingLd.XC_ConcatenatedAddress__c== '|||||' || ld.XC_ConcatenatedAddress__c== existingLd.XC_ConcatenatedAddress__c);
    }

    private static Boolean checkOnSecondaryKey(Lead ld, Lead existingLd){
        return (!String.isBlank(ld.XC_ProductCategoryOfInterest__c) || ld.XC_ConcatenatedAddress__c!= '|||||');
    }
}