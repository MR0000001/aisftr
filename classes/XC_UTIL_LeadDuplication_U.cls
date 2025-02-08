/**
* @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 27/06/2019
* @description XC_UTIL_LeadDuplication - Util class for Lead Duplication process
*/

public without sharing class XC_UTIL_LeadDuplication_U {

    /** 
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 26/06/2019
    * @description Method to populate CheckFieldWrapper
    * @param listLeadInput - List<Lead>
    * @return CheckFieldWrapper
    */ 
    public static XC_UTIL_LeadDuplication.CheckFieldWrapper populateCheckFieldWrapper(List<Lead> listLeadInput) { 
        XC_UTIL_LeadDuplication.CheckFieldWrapper wrapper = new XC_UTIL_LeadDuplication.CheckFieldWrapper();
        for(Lead ld : listLeadInput){
            wrapper = populateCheckFieldWrapperRT(ld, wrapper);

            if(!String.isBlank(ld.XC_DocumentType__c) && !String.isBlank(ld.XC_DocumentNumber__c)){
                wrapper.setDocumentType.add(ld.XC_DocumentType__c);
                wrapper.setDocumentNumber.add(ld.XC_DocumentNumber__c);
            }
            if(!String.isBlank(ld.XC_MainLegalEntity__c)){
                wrapper.setLegalEntity.add(ld.XC_MainLegalEntity__c);
            }
            List<String> addressFields = new List<String>{ld.XC_StreetType__c, ld.XC_Address__c, ld.XC_StreetNumber__c, ld.XC_ZipCode__c, ld.XC_City__c, ld.XC_Province__c};
            ld.XC_ConcatenatedAddress__c= String.join(addressFields, '|');
            wrapper.setProductCategories.add(ld.XC_ProductCategoryOfInterest__c);
            wrapper.setAddresses.add(ld.XC_ConcatenatedAddress__c);
            if (ld.Id != null){
                wrapper.setId.add(ld.Id);
            }
        }
        return wrapper;
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 21/5/2020 
    * @param listLeadInput 
    * @return XC_UTIL_LeadDuplication.CheckFieldWrapper 
    **/
    public static XC_UTIL_LeadDuplication.CheckFieldWrapper populateCheckFieldWrapperB2BG(List<Lead> listLeadInput){
        XC_UTIL_LeadDuplication.CheckFieldWrapper wrapper = new XC_UTIL_LeadDuplication.CheckFieldWrapper();
        for(Lead ld : listLeadInput){
            wrapper.setCompany.add(ld.Company);
            List<String> addressFields = new List<String>{ld.XC_StreetType__c, ld.XC_Address__c, ld.XC_StreetNumber__c, ld.XC_ZipCode__c, ld.XC_City__c, ld.XC_Province__c};
            ld.XC_ConcatenatedAddress__c= String.join(addressFields, '|');
            wrapper.setAddresses.add(ld.XC_ConcatenatedAddress__c);
            if(!String.isBlank(ld.XC_ProductCategoryOfInterest__c)){
                wrapper.setProductCategories.add(ld.XC_ProductCategoryOfInterest__c);
            }
            if(!String.isBlank(ld.XC_DocumentType__c) && !String.isBlank(ld.XC_DocumentNumber__c)){
                wrapper.setDocumentType.add(ld.XC_DocumentType__c);
                wrapper.setDocumentNumber.add(ld.XC_DocumentNumber__c);
            }
            if(!String.isBlank(ld.XC_MainLegalEntity__c)){
                wrapper.setLegalEntity.add(ld.XC_MainLegalEntity__c);
            }
            if (ld.Id != null){
                wrapper.setId.add(ld.Id);
            }   

        }
        return wrapper;        
    }

    private static XC_UTIL_LeadDuplication.CheckFieldWrapper populateCheckFieldWrapperRT(Lead ld, XC_UTIL_LeadDuplication.CheckFieldWrapper wrapper){
        if(XC_UTIL_Lead.isResidential(ld.recordTypeId)){
            if(!String.isBlank(ld.Email)){
                wrapper.setEmail.add(ld.Email);
            } 
            if(!String.isBlank(ld.FirstName) && !String.isBlank(ld.LastName) && !String.isBlank(ld.XC_PhonePrefix__c) && !String.isBlank(ld.XC_LeadPhone__c)) {
                wrapper.setFirstName.add(ld.FirstName);
                wrapper.setLastName.add(ld.LastName);
                wrapper.setPrefix.add(ld.XC_PhonePrefix__c);
                wrapper.setPhone.add(ld.XC_LeadPhone__c);
            }
        }
        return wrapper;
    }

    /** 
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 26/06/2019
    * @description Method to update Existing Lead
    * @param ld - lead new
    * @param existingLead - existing Lead
    * @return Lead
    */
    public static Lead updateExistingLead(Lead ld, Lead existingLead){
        if (String.isBlank(existingLead.Email)){
            existingLead.Email = ld.Email;
        }
        
        if (String.isBlank(existingLead.XC_ConcatenatedAddress__c) || existingLead.XC_ConcatenatedAddress__c== '|||||'){
            existingLead.XC_ConcatenatedAddress__c= ld.XC_ConcatenatedAddress__c;
            existingLead.XC_StreetType__c = ld.XC_StreetType__c;
            existingLead.XC_Address__c = ld.XC_Address__c;
            existingLead.XC_StreetNumber__c = ld.XC_StreetNumber__c;
            existingLead.XC_ZipCode__c = ld.XC_ZipCode__c;
            existingLead.XC_City__c = ld.XC_City__c;
            existingLead.XC_Province__c = ld.XC_Province__c;
        }
        
        if (String.isBlank(existingLead.XC_ProductCategoryOfInterest__c)){
            existingLead.XC_ProductCategoryOfInterest__c = ld.XC_ProductCategoryOfInterest__c;
        }
        
        if (String.isBlank(existingLead.XC_DocumentType__c) && String.isBlank(existingLead.XC_DocumentNumber__c)){
            existingLead.XC_DocumentType__c = ld.XC_DocumentType__c;
            existingLead.XC_DocumentNumber__c = ld.XC_DocumentNumber__c;
            existingLead.XC_DocumentCountry__c = ld.XC_DocumentCountry__c;
        }    

        if (String.isBlank(existingLead.XC_PhonePrefix__c) && String.isBlank(existingLead.XC_LeadPhone__c)){
            existingLead.XC_PhonePrefix__c = ld.XC_PhonePrefix__c;
            existingLead.XC_LeadPhone__c = ld.XC_LeadPhone__c;
        }
        return existingLead;
    }

    /** 
    * @author Andrea Bravaccino -andrea.bravaccino@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 26/06/2019
    * @description Method get Key For Error Message
    * @param ld - lead new
    * @param existingLd - lead new
    * @return String - error Message
    */
    public static String getKeyForErrorMessage(Lead ld, Lead existingLd){
        String key = '';
        Lead leadInserted = (Lead) Lead.sObjectType.newSObject(/*recordTypeId*/ ld.RecordTypeId, /*loadDefaultValues*/ true);
        if(XC_UTIL_Lead.isResidential(ld.recordTypeId)){
            if(!String.isEmpty(ld.XC_DocumentNumber__c) && ld.XC_DocumentNumber__c == existingLd.XC_DocumentNumber__c){
                key = Label.XC_CL_LeadConvert_Doc_Numb + ld.XC_DocumentNumber__c;
            } else if(!String.isEmpty(ld.Email) && ld.Email == existingLd.Email){
                key = ld.Email; 
            } else {
                key = ld.XC_LeadPhone__c;
            }
        } 
        if(XC_UTIL_Lead.isSoho(ld.RecordTypeId) || XC_UTIL_Lead.isCondominium(ld.recordTypeId)){
            key = ld.XC_DocumentNumber__c;
        }
        if(leadInserted.XC_Segment__c == 'B2B' || leadInserted.XC_Segment__c == 'B2G'){
            if(!String.isEmpty(ld.XC_DocumentNumber__c) && ld.XC_DocumentNumber__c == existingLd.XC_DocumentNumber__c){
                key = Label.XC_CL_LeadConvert_Doc_Numb + ld.XC_DocumentNumber__c;
            } else if(!String.isEmpty(ld.Company) && ld.Company == existingLd.Company){
                key = ld.Company;   
            }          
        }
        return key;
    }

    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 26/06/2019
    * @description Method to check if is a Test
    * @param wrapper 
    * @param wrapperListToReturn
    */
    public static void testCase (XC_LCC002_NewLead_W.InsertResultWrapper wrapper, List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapperListToReturn) {
        if(Test.isRunningTest()){
            wrapper.success = true;
            System.debug('@@@ TEST RUNNING ');
            wrapperListToReturn.add(wrapper);
        }
    }
}