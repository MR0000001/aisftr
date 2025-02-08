/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
* @date Creation 28/06/2019
* @description XC_LCC122_LeadConversion_U – Util class for Controller for component XC_LCP122_LeadConversion
*/

public without sharing class XC_LCC122_LeadConversion_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC122_LeadConversion_U');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 28/06/2019
    * @description Method to check if it is possible to convert 
    * @param lead - Lead
    * @param listWorkOrder - List<WorkOrder>  
    * @return CheckResultWrapper
    */
    public static XC_LCC122_LeadConversion.CheckResultWrapper validateForLeadConversion(Lead lead, List<WorkOrder> listWorkOrder) {
        XC_LCC122_LeadConversion.CheckResultWrapper resultWrapper = new XC_LCC122_LeadConversion.CheckResultWrapper();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Validation for Lead ---> ' + lead);

        // Check for Status (B2B/B2G): 
        List<String> listCountryToSkip = new List<String>{'Chile', 'Colombia'};
        Boolean checkSegment = (lead.XC_Segment__c == 'B2B' || lead.XC_Segment__c == 'B2G');
        Boolean checkStatus = (lead.Status == Label.XC_CL_Lead_CustomerContacted);
        Boolean checkCountry = (String.isNotBlank(lead.XC_Country__c) && !listCountryToSkip.contains(lead.XC_Country__c));
        Boolean checkDocument = (String.isBlank(lead.XC_DocumentType__c) && String.isBlank(lead.XC_DocumentNumber__c));
        if(checkSegment && checkStatus && checkCountry && checkDocument && !lead.XC_LeadRecordType__c.contains('SFM')) {
            resultWrapper.errorMessage = Label.XC_CL_ErrorStatusLead;
            resultWrapper.isErrorValidation = true;
            return resultWrapper;
        }

        if(!Schema.sObjectType.Contact.isAccessible()){
            return resultWrapper;
        }
        else if(lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Soho || lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Condominium) {
            String labelContactSoho = Label.XC_CL_Contact_Soho;
            String labelContactCondominium = Label.XC_CL_Contact_Condominium;
            String emailLead = lead.Email;
            String query = 'SELECT Id FROM Contact WHERE (Email <> null AND Email = :emailLead) AND ';
            if(lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Soho) {
                query = query + ' RecordType.DeveloperName <> :labelContactSoho';
            } else {
                query = query + ' RecordType.DeveloperName <> :labelContactCondominium';
            }
            List<Contact> listContact = Database.query(query);
            if(!listContact.isEmpty()) {
                resultWrapper.errorMessage = Label.XC_CL_LeadConvert_Another_Contact;
                resultWrapper.isErrorValidation = true;
                return resultWrapper;
            }
        }

        Boolean isB2B = lead.XC_Segment__c=='B2B' || lead.XC_Segment__c=='B2G';
        String labelLeadResidential = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Lead_Residential).getRecordTypeId();
        if(!isB2B && lead.RecordTypeId != labelLeadResidential && (String.isBlank(lead.XC_CDocType__c) || String.isBlank(lead.XC_CDocNumber__c) || String.isBlank(lead.XC_CDocCountry__c))) {
            resultWrapper.errorMessage = Label.XC_CL_LeadConvert_DocumentContactMissing;
            resultWrapper.isErrorValidation = true;
            return resultWrapper;
        }
        if(XC_LCC122_LeadConversion_Z.checkLeadStatus(lead) && !lead.XC_LeadRecordType__c.contains('SFM')) {
            resultWrapper.isErrorValidation = true;
            resultWrapper.errorMessage = lead.XC_CommercialVisitRequired__c ?
                    Label.XC_CL_LeadConvert_Check_Lead_CommercialVisitRequired_True : Label.XC_CL_LeadConvert_Check_Lead_CommercialVisitRequired_False;
            return resultWrapper;
        }
        validateForOpportunity(lead, resultWrapper, listWorkOrder);
        validateWorkOrderLink(lead, resultWrapper, listWorkOrder);
        return resultWrapper;

    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 12/07/2019
    * @description Method to recalculate Individual for Existing Contact
    * @param ld - Lead
    * @param contact - Contact
    */
    public static void calculateIndividualForExistingContact(Lead ld, Contact contact) {
        List<XC_LegalEntityConsent__c> listLegalEntityLead = XC_UTIL_AccountDuplication_U.getConsents(ld.IndividualId);
        List<XC_LegalEntityConsent__c> listLegalEntityContact = XC_UTIL_AccountDuplication_U.getConsents(contact.IndividualId);
        List<XC_LegalEntityConsent__c> listLegalEntityToInsert = new List<XC_LegalEntityConsent__c>();

        for(XC_LegalEntityConsent__c legalEntityLead : listLegalEntityLead) {
            Boolean legalEntityFound = false;
            for(XC_LegalEntityConsent__c legalEntityContact : listLegalEntityContact) {
                if(legalEntityContact.XC_LegalEntity__c == legalEntityLead.XC_LegalEntity__c) {
                    legalEntityFound = true;
                    break;
                }
            }

            if(!legalEntityFound) {
                XC_LegalEntityConsent__c legalEntityToInsert = new XC_LegalEntityConsent__c();
                legalEntityToInsert.XC_Individual__c = contact.IndividualId;
                legalEntityToInsert.XC_LegalEntity__c = legalEntityLead.XC_LegalEntity__c;
                //legalEntityToInsert.XC_GiveDataTo__c = legalEntityLead.XC_GiveDataTo__c;
                legalEntityToInsert.XC_IndividualLegalEntity__c = legalEntityLead.XC_IndividualLegalEntity__c;
                legalEntityToInsert.XC_IndividualId__c = legalEntityLead.XC_IndividualId__c;
                legalEntityToInsert.XC_LeCountry__c = legalEntityLead.XC_LeCountry__c;
                legalEntityToInsert.XC_GiveDataToNew__c = legalEntityLead.XC_GiveDataToNew__c;
                legalEntityToInsert.XC_UpdateAboutProducts__c = legalEntityLead.XC_UpdateAboutProducts__c;
                legalEntityToInsert.XC_ConsentToDataProcessing__c = legalEntityLead.XC_ConsentToDataProcessing__c;
                legalEntityToInsert.XC_CompanyConsentVersion__c = legalEntityLead.XC_CompanyConsentVersion__c;
                legalEntityToInsert.XC_MarketingConsentVersion__c = legalEntityLead.XC_MarketingConsentVersion__c;
                legalEntityToInsert.XC_ProfilingConsentVersion__c = legalEntityLead.XC_ProfilingConsentVersion__c;
                legalEntityToInsert.XC_NotCustomerConsentVersion__c = legalEntityLead.XC_MarketingConsentVersion__c;
                legalEntityToInsert.XC_ThirdProductsMarketingConsentVersion__c = legalEntityLead.XC_ProfilingConsentVersion__c;
                listLegalEntityToInsert.add(legalEntityToInsert);
            }

        }

        XC_UTIL_Sobject.insertListRecords(listLegalEntityToInsert);
        ld.IndividualId = null;
        XC_UTIL_Sobject.updateRecord(ld);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 08/07/2019
    * @description Method to recalculate Individual
    * @param ld - Lead
    * @param contact - Contact
    */
    public static void calculateIndividual(Lead ld, Contact contact) {
        String individualId = ld.IndividualId;
        ld.IndividualId = null;
        XC_UTIL_Sobject.updateRecord(ld);
        contact.IndividualId = individualId;
        XC_UTIL_Sobject.updateRecord(contact);

        Account accountToUpdate = new Account(Id = contact.AccountId);
        List<XC_LegalEntityConsent__c> legalEntityList = XC_UTIL_AccountDuplication_U.getConsents(individualId);
        for(XC_LegalEntityConsent__c legalEnt : legalEntityList) {
            if(legalEnt.XC_GiveDataToNew__c == 'Yes') {
                String field = 'XC_GiveDataTo_' + legalEnt.XC_LegalEntity__c + '__c';
                accountToUpdate.put(field.replaceAll( '\\s+', ''), true);
            }
        }
        XC_UTIL_Sobject.updateRecord(accountToUpdate);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 08/07/2019 
    * @description Method to populate Legal Entity to Contact
    * @param contact - Contact
    * @param individualId - String
    */
    public static void populateLegalEntityContact(Contact contact, String individualId) {
        List<Individual> listLegalEntity = new List<Individual>([
                SELECT Id, XC_GiveDataToThirdParties__c,
                (SELECT XC_GiveDataToNew__c
                FROM Legal_Entity_Consents__r
                WHERE XC_LegalEntity__c = :contact.XC_MainLegalEntity__c)
                FROM Individual
                WHERE Id = :individualId
        ]);
        if(!listLegalEntity.isEmpty() && !listLegalEntity[0].Legal_Entity_Consents__r.isEmpty()) {
            contact.XC_GiveDataToNew__c = listLegalEntity[0].Legal_Entity_Consents__r[0].XC_GiveDataToNew__c;
        }

        List<XC_CM_CountryLegalEntityAssociation__mdt> listCM = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
                SELECT XC_Country__c
                FROM XC_CM_CountryLegalEntityAssociation__mdt
                WHERE XC_LegalEntity__c = :contact.XC_MainLegalEntity__c
        ]);
        if(!listCM.isEmpty()){
            contact.XC_CountryLegalEntity__c = listCM[0].XC_Country__c.toUpperCase();
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 08/07/2019
    * @description Method to link WorkOrder to Account and Contact
    * @param resultWrapper - ConversionResultWrapper
    * @param createOpportunity - Boolean
    * @param listLinkedWorkOrders - List<WorkOrder> 
    */
    public static void populateWorkOrder(XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper, Boolean createOpportunity, List<WorkOrder> listLinkedWorkOrders) {
        List<WorkOrder> listWoToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : listLinkedWorkOrders) {
            wo.XC_Lead__c = null;
            wo.AccountId = resultWrapper.account.Id;
            wo.ContactId = resultWrapper.contact.Id;
            if(createOpportunity) {
                wo.XC_Opportunity__c = resultWrapper.opportunity.Id;
            }
            listWoToUpdate.add(wo);
        }
        XC_UTIL_Sobject.updateListRecords(listWoToUpdate);
    }

    /**
    * @author Valeria Martino - valeria.martino@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 03/07/2019
    * @description Method to create address for Account
    * @param lead - Lead
    * @param contact - Contact 
    */
    public static void checkAddressForAccount(Lead lead, Contact contact) {
        List<Account> listAccount = new List<Account>([SELECT Id, (SELECT Id FROM Addresses__r) FROM Account WHERE Id = :contact.AccountId]);
        Boolean addressFound = false;
        for(XC_Address__c address : listAccount[0].Addresses__r) {
            if(address.Id == lead.XC_LeadAddress__c) {
                addressFound = true;
                break;
            }
        }
        if(!addressFound) {
            XC_Address__c address = new XC_Address__c();
            address.id = lead.XC_LeadAddress__c;
            address.XC_Lead__c = null;
            address.XC_Account__c = listAccount[0].Id;
            XC_UTIL_sObject.updateRecord(address);
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 28/06/2019
    * @description Method to check if it is possible to convert Lead
    * @param lead - Lead
    * @param resultWrapper - CheckResultWrapper
    * @param listWorkOrder - List<WorkOrder>
    */
    public static void validateWorkOrderLink(Lead lead, XC_LCC122_LeadConversion.CheckResultWrapper resultWrapper, List<WorkOrder> listWorkOrder) {
        for(WorkOrder workOrder : listWorkOrder) {
            if(workOrder.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit && !String.isBlank(workOrder.XC_Address__c)) {
                if(workOrder.AccountId != lead.ConvertedAccountId || workOrder.ContactId != lead.ConvertedContactId || workOrder.XC_Opportunity__c != lead.ConvertedOpportunityId) {
                    resultWrapper.errorMessage = Label.XC_CL_Lead_ErrorWorkOrderNotLinked;
                    resultWrapper.isErrorValidation = true;
                    break;
                }
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 28/06/2019
    * @description Method to check for Opportunity 
    * @param lead - Lead
    * @param resultWrapper - XC_LCC122_LeadConversion.CheckResultWrapper
    * @param listWorkOrder - List<WorkOrder>
    */
    public static void validateForOpportunity(Lead lead, XC_LCC122_LeadConversion.CheckResultWrapper resultWrapper, List<WorkOrder> listWorkOrder) {
        if(!Schema.sObjectType.XC_ProductCategoryOfInterest__c.isAccessible()){
            return;
        }

        if(String.isBlank(lead.XC_ProductCategoryOfInterest__c)) {
            resultWrapper.canCreateOpportunity = false;
        }
        else {
            XC_ProductCategoryOfInterest__c prodCategory = [SELECT XC_CommercialVisit__c FROM XC_ProductCategoryOfInterest__c WHERE Name = :lead.XC_ProductCategoryOfInterest__c LIMIT 1];
            if(prodCategory.XC_CommercialVisit__c == true && String.isBlank(lead.XC_LeadAddress__c)) {
                resultWrapper.canCreateOpportunity = false;
                resultWrapper.addressBlank = true;
            }
        }

        for(WorkOrder workOrder : listWorkOrder) {
            if(workOrder.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit && workOrder.XC_Check_Final_Status__c == false){
                resultWrapper.mustCreateOpportunity = true;
                break;
            }
        }
    }

}