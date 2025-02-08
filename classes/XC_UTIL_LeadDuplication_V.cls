/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 27/06/2019
* @description XC_UTIL_LeadDuplication - Util class for Lead Duplication process
*/
public without sharing class XC_UTIL_LeadDuplication_V {
    
    /**
    * @description checkEmailDocumentPhone
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param ld Lead
    * @param existingLd Lead 
    * @return XC_UTIL_LeadDuplication.CheckFirstStep
    */
    public static XC_UTIL_LeadDuplication.CheckFirstStep checkEmailDocumentPhone(Lead ld, Lead existingLd){
        XC_UTIL_LeadDuplication.CheckFirstStep checkFirst = new XC_UTIL_LeadDuplication.CheckFirstStep();
        String legalEntity;
        String docTypeNumber;
        String existingDocTypeNumber;
        List<XC_UTIL_LeadDuplication.CheckSingleFieldWrapper> checkSingleFieldWrapperList = new List<XC_UTIL_LeadDuplication.CheckSingleFieldWrapper>();
        
        if(!String.isBlank(ld.XC_DocumentType__c) && !String.isBlank(ld.XC_DocumentNumber__c)){
            docTypeNumber = ld.XC_DocumentType__c + ld.XC_DocumentNumber__c;
            existingDocTypeNumber = existingLd.XC_DocumentType__c + existingLd.XC_DocumentNumber__c;
        }

        checkSingleFieldWrapperList.add(new XC_UTIL_LeadDuplication.CheckSingleFieldWrapper(docTypeNumber, existingDocTypeNumber));
        checkFirst.checkDocument = checkField(new XC_UTIL_LeadDuplication.CheckSingleFieldWrapper(docTypeNumber, existingDocTypeNumber));

        if(XC_UTIL_Lead.isResidential(ld.recordTypeId)){
            system.debug('@@@ 2906 Lead Name: ' + ld.FirstName + ' ' + ld.LastName + ' Lead Phone: ' + ld.XC_PhonePrefix__c + ld.XC_LeadPhone__c + ' Lead Email: '+ ld.Email);
            String email;
            String existingEmail;
            String phone;
            String existingPhone;
            String namePhone;
            String existingNamePhone;

            if(!String.isBlank(ld.Email)){
                email = ld.Email;
                existingEmail = existingLd.Email;
            }
            
            if((!String.isBlank(ld.FirstName) && !String.isBlank(ld.LastName) && !String.isBlank(ld.XC_PhonePrefix__c) && !String.isBlank(ld.XC_LeadPhone__c))){
                phone = ld.XC_PhonePrefix__c + ld.XC_LeadPhone__c;
                namePhone = ld.FirstName + ld.LastName + ld.XC_PhonePrefix__c + ld.XC_LeadPhone__c;
                existingPhone = existingLd.XC_PhonePrefix__c + existingLd.XC_LeadPhone__c;
                existingNamePhone = existingLd.FirstName + existingLd.LastName + existingLd.XC_PhonePrefix__c + existingLd.XC_LeadPhone__c;
            }
            checkSingleFieldWrapperList.add(new XC_UTIL_LeadDuplication.CheckSingleFieldWrapper(email, existingEmail));
            checkSingleFieldWrapperList.add(new XC_UTIL_LeadDuplication.CheckSingleFieldWrapper(namePhone, existingNamePhone));
            
            checkFirst.checkEmail = checkField(new XC_UTIL_LeadDuplication.CheckSingleFieldWrapper(email, existingEmail));
            checkFirst.checkPhone = checkField(new XC_UTIL_LeadDuplication.CheckSingleFieldWrapper(phone, existingPhone));
        }
        checkFirst.checkEmailAndDocumentAndPhone = checkFields(checkSingleFieldWrapperList);
        // return checkFields(checkSingleFieldWrapperList); OLD VALUE
        return checkFirst;
    }

    /**
    * @description filterDuplicateLeadMap
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param listLeadInput List<Lead> 
    * @param mapDuplicateLeads Map<Id, Lead> 
    * @return List<Lead>
    */
    public static List<Lead> filterDuplicateLeadMap(List<Lead> listLeadInput, Map<Id, Lead> mapDuplicateLeads){
        List<Lead> leadDuplicatedList = new List<Lead>();
        for(Lead newLead: listLeadInput){
            for(Lead existingLd : mapDuplicateLeads.values()){
                if(existingLd.XC_ProductCategoryOfInterest__c == newLead.XC_ProductCategoryOfInterest__c || String.isEmpty(existingLd.XC_ProductCategoryOfInterest__c) ||String.isEmpty(newLead.XC_ProductCategoryOfInterest__c)  ){
                    leadDuplicatedList.add(existingLd);
                }
                if(existingLd.XC_ConcatenatedAddress__c== newLead.XC_ConcatenatedAddress__c|| existingLd.XC_ConcatenatedAddress__c == '|||||' || newLead.XC_ConcatenatedAddress__c == '|||||' ){
                    leadDuplicatedList.add(existingLd);
                }
            }
        }
        return leadDuplicatedList;
    }  

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 21/5/2020 
    * @param listLeadInput 
    * @param leadDuplicatedList 
    * @param finalStatus 
    * @return List<XC_LCC002_NewLead_W.InsertResultWrapper> 
    **/
    public static List<XC_LCC002_NewLead_W.InsertResultWrapper> checkErrorDuplicatesB2BG(List<Lead> listLeadInput, List<Lead> leadDuplicatedList, List<String> finalStatus){
        List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapperListToReturn = new List<XC_LCC002_NewLead_W.InsertResultWrapper>();
        XC_LCC002_NewLead_W.InsertResultWrapper wrapper = new XC_LCC002_NewLead_W.InsertResultWrapper(null);
        for(Lead ld : listLeadInput){
            if(finalStatus.contains(ld.Status)){
                continue;
            }
            for(Lead existingLd : leadDuplicatedList){ 
                XC_UTIL_LeadDuplication.UtilityWrapper utilWrapper = new XC_UTIL_LeadDuplication.UtilityWrapper();
                if(!String.isEmpty(ld.Company)
                    && ld.Company == existingLd.Company && ld.XC_ConcatenatedAddress__c == existingLd.XC_ConcatenatedAddress__c && ld.XC_ProductCategoryOfInterest__c == existingLd.XC_ProductCategoryOfInterest__c){
                    wrapper = XC_UTIL_LeadDuplication.duplicatedLead(wrapper, ld, existingLd);
                    wrapperListToReturn.add(wrapper); 
                } else if(!String.isEmpty(ld.XC_DocumentType__c) && !String.isEmpty(ld.XC_DocumentNumber__c) 
                    && ld.XC_DocumentType__c == existingLd.XC_DocumentType__c && ld.XC_DocumentNumber__c == existingLd.XC_DocumentNumber__c && ld.XC_ProductCategoryOfInterest__c == existingLd.XC_ProductCategoryOfInterest__c){
                    wrapper = XC_UTIL_LeadDuplication.duplicatedLead(wrapper, ld, existingLd); 
                    wrapperListToReturn.add(wrapper);
                }
            }
        }
        return wrapperListToReturn;
    }

    /** 
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 26/06/2019
    * @description Method to check if a Lead is a duplicate
    * @param listLeadInput - List<Lead>
    * @param leadDuplicatedList - List<Lead>
    * @param finalStatus List<String> 
    * @return List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapper List with result of duplicate matching
    */
    public static List<XC_LCC002_NewLead_W.InsertResultWrapper> checkErrorDuplicates(List<Lead> listLeadInput, List<Lead> leadDuplicatedList, List<String> finalStatus) { 
        List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapperListToReturn = new List<XC_LCC002_NewLead_W.InsertResultWrapper>();
        for(Lead ld : listLeadInput){
            if (finalStatus.contains(ld.Status)){
                continue;
            }
            // wrapper.success = true allora faccio l'insert/update 
            XC_LCC002_NewLead_W.InsertResultWrapper wrapper = new XC_LCC002_NewLead_W.InsertResultWrapper(null);
            for(Lead existingLd : leadDuplicatedList){ 
                XC_UTIL_LeadDuplication.UtilityWrapper utilWrapper = new XC_UTIL_LeadDuplication.UtilityWrapper();
                utilWrapper.wrapperListToReturn = wrapperListToReturn;
                utilWrapper.wrapper = wrapper;
                utilWrapper.existingLd = existingLd;
                utilWrapper.ld = ld;
                if(XC_UTIL_LeadDuplication.cycleOnExistingLead(utilWrapper)){
                    break;
                }
            }
            XC_UTIL_LeadDuplication_U.testCase(wrapper, wrapperListToReturn);
        } 
        return wrapperListToReturn;
    }

    /**
    * @description
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param checkSingleFieldWrapperList List<XC_UTIL_LeadDuplication.CheckSingleFieldWrapper> 
    * @return Boolean
    */
    public static Boolean checkFields(List<XC_UTIL_LeadDuplication.CheckSingleFieldWrapper> checkSingleFieldWrapperList){
        for (XC_UTIL_LeadDuplication.CheckSingleFieldWrapper wrp : checkSingleFieldWrapperList) {
            system.debug('@@@2706 wrp -->' + wrp);
            if (wrp.newField != null && wrp.newField == wrp.oldField) {
                return true;
            }
        }
        return false;
    }

    private static Boolean checkField(XC_UTIL_LeadDuplication.CheckSingleFieldWrapper checkSingleFieldWr){
        return (checkSingleFieldWr.newField != null && checkSingleFieldWr.newField == checkSingleFieldWr.oldField);
    }

    /**
    * @description
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param wrapper XC_LCC002_NewLead_W.InsertResultWrapper 
    * @param ld Lead 
    * @param existingLd Lead 
    */
    public static void manageScenarioWithExistingProduct(XC_LCC002_NewLead_W.InsertResultWrapper wrapper,  Lead ld, Lead existingLd){
        if(String.isEmpty(ld.XC_ProductCategoryOfInterest__c)){
            wrapper = XC_UTIL_LeadDuplication.duplicatedLead(wrapper, ld, existingLd);
            //anotherCheckOnAddress(wrapper, ld, existingLd);
        } else if(ld.XC_ProductCategoryOfInterest__c == existingLd.XC_ProductCategoryOfInterest__c &&  checkIfNewAddress(existingLd, ld)){
            wrapper = XC_UTIL_LeadDuplication.updateExistingLead(wrapper, ld, existingLd);
        } else if(existingLd.XC_ProductCategoryOfInterest__c != ld.XC_ProductCategoryOfInterest__c) {
            if((ld.XC_ProductCategoryOfInterest__c != existingLd.XC_ProductCategoryOfInterest__c/* && checkIfDifferentAddress(existingLd, ld)*/) ||
                (String.isEmpty(ld.XC_ProductCategoryOfInterest__c) && checkIfDifferentAddress(existingLd, ld))) {
                    wrapper.success = true; 
            } else {
                XC_UTIL_LeadDuplication.duplicatedLead(wrapper, ld, existingLd); 
            }
        } else {
            wrapper = XC_UTIL_LeadDuplication.duplicatedLead(wrapper, ld, existingLd);
        }
    }

    // METHOD DEPRACATED because the following cause: if I have more Leads with different products I cant say which one as to be updated when I insert a new Lead
    // without the product but with an address.
    /*private static void anotherCheckOnAddress(XC_LCC002_NewLead_W.InsertResultWrapper wrapper, Lead ld, Lead existingLd){
        if((existingLd.XC_ConcatenatedAddress__c == '|||||' ||  String.isEmpty(existingLd.XC_ConcatenatedAddress__c)) && (ld.XC_ConcatenatedAddress__c != '|||||')){
            wrapper = XC_UTIL_LeadDuplication.updateExistingLead(wrapper, ld, existingLd);
        } else {
            wrapper = XC_UTIL_LeadDuplication.duplicatedLead(wrapper, ld, existingLd);
        }
    } */

    private static Boolean checkIfNewAddress(Lead existingLd, Lead ld){
        return (existingLd.XC_ConcatenatedAddress__c== '|||||' && ld.XC_ConcatenatedAddress__c!=  '|||||');
    }

    private static Boolean checkIfDifferentAddress(Lead existingLd, Lead ld){
        return (existingLd.XC_ConcatenatedAddress__c!= '|||||' && ld.XC_ConcatenatedAddress__c!= '|||||' && existingLd.XC_ConcatenatedAddress__c!= ld.XC_ConcatenatedAddress__c);
    }
    
}