/**
* @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 27/06/2019
* @description XC_UTIL_AccountDuplication - Util class for Account Duplication process
*/
public without sharing class XC_UTIL_AccountDuplication_U {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_AccountDuplication_U');
    
    /** 
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 26/06/2019
    * @description Method to populate XC_UTIL_AccountDuplication_W.CheckFieldWrapper
    * @param listContactInput - List<Account>
    * @return XC_UTIL_AccountDuplication_W.CheckFieldWrapper
    */
    public static XC_UTIL_AccountDuplication_W.CheckFieldWrapper populateCheckFieldWrapper(List<Contact> listContactInput) { 
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper wrapper = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
        for(Contact cnt : listContactInput){

            if(!String.isBlank(cnt.Email)){
                wrapper.setEmail.add(cnt.Email);
            }
            
            if(!String.isBlank(cnt.Account.IdentityType__c) && !String.isBlank(cnt.Account.IdentityNumber__c)){
                wrapper.setDocumentType.add(cnt.Account.IdentityType__c);
                wrapper.setDocumentNumber.add(cnt.Account.IdentityNumber__c); 
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Document for account: ' + wrapper.setDocumentNumber);
            if(!String.isBlank(cnt.XC_MainLegalEntity__c)){
                wrapper.setLegalEntity.add(cnt.XC_MainLegalEntity__c);
            }
            if (cnt.Id != null){
                wrapper.setId.add(cnt.Id);
            }
            
            if (cnt.IndividualId != null){
                wrapper.setIndividualId.add(cnt.IndividualId);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Wrapper result for populateCheckFieldWrapper: ' + wrapper);
        return wrapper;
    }

    /** 
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 28/06/2019
    * @description Method to populate XC_UTIL_AccountDuplication_W.CheckFieldWrapper.mapConsent
    * @param idString - id of individual record
    * @return XC_UTIL_AccountDuplication_W.CheckFieldWrapper 
    */
    public static List<XC_LegalEntityConsent__c> getConsents(String idString){ 
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper wrapper = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
        wrapper.setIndividualId.add(idString);
        wrapper = XC_UTIL_AccountDuplication_V.getConsents(wrapper);
        if (wrapper.mapConsent.isEmpty()){
            return new List<XC_LegalEntityConsent__c>();
        }
        return wrapper.mapConsent.values()[0];
    }
    
    /** 
    * @author Andrea Bravaccino andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 01/07/2019
    * @description Method to check duplicate Account
    * @param accountToCheckList - account to Insert 
    * @param contactWrapperList - Contact needed for check duplicate
    * @return List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> 
    */
    public static List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> checkErrorDuplicates(List<Account> accountToCheckList, List<XC_UTIL_AccountDuplication_W.ContactWrapper> contactWrapperList){
        List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper> wrapperListToReturn = new List<XC_UTIL_AccountDuplication_W.CheckAccountWrapper>();
        for (Account acc : accountToCheckList) {
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ For Account: ' + acc);
            for (XC_UTIL_AccountDuplication_W.ContactWrapper conWrapper : contactWrapperList){
                Contact existingContact = conWrapper.contact;
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ ... and Contact: ' + existingContact);
                if (existingContact.Account.XC_isGuestUser__c != acc.XC_isGuestUser__c){
                    continue;
                }
                
                if (checkSingleAccountDuplicatedFirstStep(acc, existingContact)){ // TORNA TRUE SE SONO UGUALI
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Contact exists for account');
                    XC_UTIL_AccountDuplication_W.CheckAccountWrapper wrapper = new XC_UTIL_AccountDuplication_W.CheckAccountWrapper();
                    wrapper.existingAccountForPrimaryContact = acc;
                    wrapper = XC_UTIL_AccountDuplication.getWrapperForExistingContact(existingContact, wrapper);
                    if(checkConsentForSecondStep(acc, conWrapper.listConsent)){ // TORNA TRUE SE TROVA UN DUPLICATO
                        Boolean isPrimary = existingContact.XC_PrimaryContact__c;
                        wrapper.success = !XC_TR_Account_U_CheckDuplicates.startFromTrigger && checkSameRT(existingContact, acc) ? !isPrimary : false;
                        wrapper.successConsent = false;
                    }else {
                        wrapper.success = false;
                        wrapper.successConsent = true;
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Wrapper for checkErrorDuplicates: ' + wrapper);

                    String key = '';
                    if(conWrapper.contact.XC_ContactDocumentNumber__c != null && acc.IdentityNumber__c != null && conWrapper.contact.XC_ContactDocumentNumber__c == acc.IdentityNumber__c) {
                        key = acc.IdentityType__c + ' - ' + acc.IdentityNumber__c;
                    } else {
                        key = acc.PrimaryEmail__c;
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ ... with key: ' + key);

                    wrapper.errorMessage = Label.XC_CL_ActiveAccountExists + ' ' + key;
                    wrapperListToReturn.add(wrapper);
                    break;
                }
            }    
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'wrapperListToReturn ' + wrapperListToReturn);
        return wrapperListToReturn;
    }

    private static Boolean checkSameRT(Contact con, Account acc){
        return ((con.XC_RecordTypeDeveloperName__c.toLowerCase().contains('soho') && XC_UTIL_Account.isSoho(acc.RecordTypeId)) ||
                (con.XC_RecordTypeDeveloperName__c.toLowerCase().contains('residential') && XC_UTIL_Account.isResidential(acc.RecordTypeId)) ||
                (con.XC_RecordTypeDeveloperName__c.toLowerCase().contains('condominium') && XC_UTIL_Account.isCondominium(acc.RecordTypeId)));
    }

    private static Boolean checkConsentForSecondStep(Account acc, List<XC_LegalEntityConsent__c> cntConsent){
        if (cntConsent != null){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Legal entity consent: ' + cntConsent);
            for(XC_LegalEntityConsent__c cnt : cntConsent){
                if(cnt.XC_LegalEntity__c != null && acc.get('XC_GiveDataTo_' + cnt.XC_LegalEntity__c + '__c') == true){
                    return true;
                }
            }
        }else {
            return true;
        }
        return false;
    }

    private static Boolean checkSingleAccountDuplicatedFirstStep(Account acc, Contact cnt){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ For Account: ' + acc);
        List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper> checkSingleFieldWrapperList = new List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper>();
        
        if(XC_UTIL_Account.isResidential(acc.recordTypeId)){
            String email;
            String existingEmail;

            if(!String.isBlank(acc.PrimaryEmail__c)){
                email = acc.PrimaryEmail__c;
                existingEmail = cnt.Account.PrimaryEmail__c;
                checkSingleFieldWrapperList.add(new XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper(email, existingEmail));
                
                existingEmail = cnt.Email;
                checkSingleFieldWrapperList.add(new XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper(email, existingEmail));
            }
            
            if (acc.XC_isGuestUser__c){
                return checkFields(checkSingleFieldWrapperList);
            }
        }
        checkSingleFieldWrapperList = checkDocuments(checkSingleFieldWrapperList, acc, cnt);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Return for: ' + checkSingleFieldWrapperList);
        return checkFields(checkSingleFieldWrapperList);
    }    

    private static List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper> checkDocuments(List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper> checkSingleFieldWrapperList, Account acc, Contact cnt){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ check document ' + acc.IdentityType__c + acc.IdentityNumber__c);
        if (checkDocumentsCondition(acc, cnt)){
                if(!String.isBlank(acc.IdentityType__c) && !String.isBlank(acc.IdentityNumber__c)){
                    String docTypeNumberCountry = acc.IdentityType__c + acc.IdentityNumber__c;
                    String existingDocTypeNumberCountry = cnt.Account.IdentityType__c + cnt.Account.IdentityNumber__c;
                    checkSingleFieldWrapperList.add(new XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper(docTypeNumberCountry, existingDocTypeNumberCountry));
                    for(XC_PersonalDocument__c pd : cnt.Personal_Documents__r){
                        docTypeNumberCountry = acc.IdentityType__c + acc.IdentityNumber__c;
                        existingDocTypeNumberCountry = pd.XC_DocumentType__c + pd.XC_DocumentNumber__c;
                        checkSingleFieldWrapperList.add(new XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper(docTypeNumberCountry, existingDocTypeNumberCountry));
                    }
                }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Return result for checkDocuments: ' + checkSingleFieldWrapperList);
        return checkSingleFieldWrapperList;
    }

    private static Boolean checkDocumentsCondition(Account acc, Contact cnt){
        return (cnt.Account.RecordTypeId == acc.RecordTypeId || (XC_UTIL_Account.isSoho(acc.RecordTypeId) && !XC_UTIL_Account.isSoho(cnt.Account.RecordTypeId) ) );
    }

    /**
    * @description checkFields
    * @author Andrea Bravaccino andrea.bravaccino@nttdata.com | 21/8/2019
    * @param checkSingleFieldWrapperList List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper> 
    * @return Boolean
    */
    public static Boolean checkFields(List<XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper> checkSingleFieldWrapperList){
        for (XC_UTIL_AccountDuplication_W.CheckSingleFieldWrapper wrp : checkSingleFieldWrapperList) {
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@acc wrp -->' + wrp);
            if (wrp.newField != null && wrp.newField == wrp.oldField) {
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@acc CASO CHECK TRUE');
                return true;
            }
        }
        return false;
    }
}