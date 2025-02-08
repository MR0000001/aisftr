/**
 * The Class XC_REST_Lead_W.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 24/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse for Create/Update Lead
 **/

public without sharing class XC_REST_Lead_W {


    /**
     * The Class WrapperLeadRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperLeadRequest {
        
        /** The Lead. */
        public XC_UTIL_Lead.LeadRESTWrapper Lead = new XC_UTIL_Lead.LeadRESTWrapper();
    }	
    
    
	/**
	 * The Class WrapperLeadResponse.
     *
     * @description wrapper response of REST call
	 */
	public class WrapperLeadResponse {
		
		/** The Result. */
		public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
		
		/** The Lead. */
		public XC_UTIL_Lead.LeadRESTWrapper Lead;

        /** The Account. */
		public WrapperAccount Account;
	}


    /**
	 * The Class WrapperAccount.
     *
     * @description wrapper account for convert Lead
	 */
	public class WrapperAccount {
		
		/** The Account ID. */
		public String AccountID;
		
		/** The Contact ID. */
		public String ContactID;

        /** The Opportunity ID. */
		public String OpportunityID;
	} 


    /**
     * GenerateLeadFromWrapper.
     *
     * @param wrapper the wrapper
     * @param httpMethod the http method
     * @param existingLead the existing lead
     * @return the lead
     * @description generate Lead from wrapper
     */
	    public static Lead generateLeadFromWrapper(XC_UTIL_Lead.LeadRESTWrapper wrapper, String httpMethod, Lead existingLead, Map<String, String> mapHeader) {

        Date nieExpeditionDate = String.isNotBlank(wrapper.ReleaseDate) ? Date.valueOf(wrapper.ReleaseDate) : null;
        Date nieExpirationDate = String.isNotBlank(wrapper.ExpiryDate) ? Date.valueOf(wrapper.ExpiryDate) : null;
        Date birthdate = String.isNotBlank(wrapper.BirthDate) ? Date.valueOf(wrapper.BirthDate) : null; 
            if(wrapper.LeadType == 'B2B'){
                wrapper.Stream = 'B2B';
            } else if(wrapper.LeadType == 'B2G'){
                wrapper.Stream = 'B2G';
            }

        Map<String, Object> leadParametersMap = new Map<String, Object>{'Id' => wrapper.LeadID,
                                                                        'LastName' => wrapper.LastName,
                                                                        'FirstName' => wrapper.FirstName,
                                                                        'XC_PhonePrefix__c' => wrapper.PhonePrefix,
                                                                        'XC_LeadPhone__c' => wrapper.Phone, 
                                                                        'XC_MobilePrefix__c' => wrapper.MobilePrefix,
                                                                        'XC_LeadMobile__c' => wrapper.Mobile,
                                                                        'Email' => wrapper.PrimaryEmail,
                                                                        'XC_DocumentCountry__c' => wrapper.IdentityCountry,
                                                                        'XC_DocumentType__c' => wrapper.IdentityType,
                                                                        'XC_DocumentNumber__c' => wrapper.IdentityNumber,
                                                                        'XC_NIE_expedition_date__c' => nieExpeditionDate,
                                                                        'XC_NIE_expiration_date__c' => nieExpirationDate,
                                                                        'XC_Nationality__c' => wrapper.Nationality,
                                                                        'XC_Birthdate__c' => birthDate, 
                                                                        'XC_Channel__c' => wrapper.ReceivingChannel,
                                                                        'XC_LeadSource__c' => wrapper.Source,
                                                                        'XC_Preference_Language__c' => wrapper.PreferenceLanguage,
                                                                        'XC_ProductCategoryOfInterest__c' => wrapper.ProductCategoryOfInterest,
                                                                        'XC_HourToBeRecontacted__c' => wrapper.CommercialVisitPreferredTime,
                                                                        'XC_Notes__c' => wrapper.Notes,
                                                                        'XC_Product__c' => wrapper.ProductID,
                                                                        'XC_CampaignPlatform__c' => wrapper.CampaignPlatform,
                                                                        'XC_CampaignProduct__c' => wrapper.CampaignProduct,
                                                                        'XC_CampaignCode__c' => wrapper.CampaignCode,
                                                                        'XC_ConventionCode__c' => wrapper.ConventionCode,
                                                                        'XC_GenericZipCode__c' => wrapper.ZipCode,
                                                                        'XC_Segment__c' => wrapper.Stream,
                                                                        'XC_RequestType__c' => wrapper.RequestType,
                                                                        'XC_Salutation__c' => wrapper.Salutation,
                                                                        'XC_SectorOfTheCompany__c' => wrapper.CompanySectorLev1,
                                                                        'XC_SectorOfTheCompanySecondLevel__c' => wrapper.CompanySectorLev2,
                                                                        //'XC_UniqueId__c' => String.isNotBlank(mapHeader.get('X-UniqueID')) ? mapHeader.get('X-UniqueID') : null
                                                                        'XC_Ecid__c' => wrapper.ECID,
                                                                        'XC_Theatre__c' => wrapper.Theatre,
                                                                        'XC_SegmentOfCountry__c' => wrapper.SegmentOfCountry,
                                                                        'XC_SalesChannel__c' => wrapper.SalesChannel, 
                                                                        'XC_UserChannelName__c' => wrapper.UserChannelName,
                                                                        'XC_UserChannelCode__c' => wrapper.UserChannelCode,
                                                                        'XC_UserSubchannelCode__c' => wrapper.UserSubchannelCode,
                                                                        'XC_UserSubchannelName__c' => wrapper.UserSubchannelName,
                                                                        'XC_UserNumber__c' => wrapper.UserNumber,
                                                                        'XC_RegistrationLink__c' => wrapper.RegistrationLink,
																		'XC_LeadFormId__c' => wrapper.LeadFormID
                                                                        /*,
                                                                        'XC_GiveDataToThirdParties__c' => thirdParties/*,
                                                                        'XC_GiveDataTo__c' => (XC_UTIL_Integration.convertFromStringToBoolean(wrapper.GDPR.LegalEntity[0].GiveDataToLegalEntity)),
                                                                        'XC_MainLegalEntity__c' => wrapper.GDPR.LegalEntity[0].LegalEntity*/
                                                                        };
                                                                        // Missing RequestType
        if(mapHeader.get('ClientSystem') == 'CommoditySpainB2C'){
            leadParametersMap.put('XC_Channel__c', 'Commodity Partner');
            leadParametersMap.remove('XC_LeadSource__c');
        }          
        if(wrapper.Address != null) {
            leadParametersMap.put('XC_Category__c', wrapper.Address.Category);
            leadParametersMap.put('XC_StreetTypeText__c', wrapper.Address.StreetType); //(translatedMap != null) ? translatedMap.get(wrapper.Address.StreetType): wrapper.Address.StreetType);
            leadParametersMap.put('XC_Address__c', wrapper.Address.Address);
            leadParametersMap.put('XC_StreetNumber__c', wrapper.Address.StreetNumber);
            leadParametersMap.put('XC_ZipCode__c', wrapper.Address.ZipCode);
            leadParametersMap.put('XC_City__c', wrapper.Address.City);
            leadParametersMap.put('XC_Country__c', wrapper.Address.Country);
            leadParametersMap.put('Country__c', wrapper.Address.Country);
            leadParametersMap.put('XC_Stair__c', wrapper.Address.Stair);
            leadParametersMap.put('XC_Floor__c', wrapper.Address.Floor);
            leadParametersMap.put('XC_Municipality__c', wrapper.Address.MunicipalName);
            leadParametersMap.put('XC_Door__c', wrapper.Address.Door);
            leadParametersMap.put('XC_Province__c', wrapper.Address.Province);
            leadParametersMap.put('XC_DeliveryAddress__c', true);
            leadParametersMap.put('XC_BillingAddress__c', true);
            leadParametersMap.put('XC_InstallationAddress__c', true);
            leadParametersMap.put('XC_Region__c', wrapper.Address.Region);
        } else if(wrapper.GDPR!=null) {
            String country = XC_UTIL_Integration_U.getCountryFromLegalEntity(wrapper.GDPR.LegalEntity[0].LegalEntity);
            leadParametersMap.put('XC_Country__c', country);
            leadParametersMap.put('Country__c', country);
        }

        Lead ld = new Lead();
        for(String field : leadParametersMap.keySet()) {
            if(leadParametersMap.get(field) != null) {
                ld.put(field, leadParametersMap.get(field));
            }
        }

        populateOtherFieldsForLead(wrapper, httpMethod, ld);

        return ld;
    }


    /**
     * PopulateOtherFieldsForLead.
     *
     * @param wrapper the wrapper
     * @param httpMethod the http method
     * @param ld the lead
     * @description populate other Lead fields from wrapper
     */
    public static void populateOtherFieldsForLead(XC_UTIL_Lead.LeadRESTWrapper wrapper, String httpMethod, Lead ld) {
        
        if(wrapper.LeadType != null && httpMethod == 'POST') {
            Map<String, String> recordTypeMap = new Map<String, String>{'Residential' => 'XC_GLO_Lead_Residential',
                                                                        'Small Business' => 'XC_GLO_Lead_Soho',
                                                                        'Condominium' => 'XC_GLO_Lead_Condominium',
                                                                        'B2B' => 'XC_GLO_B2B',
                                                                        'B2G' => 'XC_GLO_B2G',
                                                                        'Global'=>'XC_Global'};
            ld.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(recordTypeMap.get(wrapper.LeadType)).getRecordTypeId();

            if(String.isBlank(wrapper.IdentityCountry)&&wrapper.GDPR!=null){
                String segment = ld.XC_Segment__c != null ? ld.XC_Segment__c : 'B2C';
                String leg = wrapper.GDPR.LegalEntity[0].LegalEntity;
                Map<Id,XC_CM_CountryLegalEntityAssociation__mdt> clMap = new Map<Id,XC_CM_CountryLegalEntityAssociation__mdt>([
                    SELECT Id, XC_Country__c
                    FROM XC_CM_CountryLegalEntityAssociation__mdt
                    WHERE XC_LegalEntity__c =: leg AND XC_Category__c =: segment
                ]);
                ld.XC_DocumentCountry__c = clMap.values()[0].XC_Country__c;
            }
    
            Map<String, Object> mapLeadWrapperB2B = new Map<String,Object>{
                'XC_PartnerEventCode__C' => wrapper.PartnerEventCode,
                'XC_PrivacyInfo__c' => wrapper.PrivacyInfo,
                'XC_Newsletter__c' => wrapper.Newsletter,
                'XC_Location__c' => wrapper.Location,
                'XC_AvailableSurface__c' => wrapper.AvailableSurface,
                'XC_AnnualBillingAmount__c' => wrapper.AnnualBillingAmount!=null?decimal.valueOf(wrapper.AnnualBillingAmount):null,
                'XC_AnnualEnergyConsumption__c' => wrapper.AnnualEnergyConsumption!=null?decimal.valueOf(wrapper.AnnualEnergyConsumption):null,
                'XC_Voltage__c' => wrapper.Voltage,
                'XC_ContractedPower__c' => wrapper.ContractedPower!=null?decimal.valueOf(wrapper.ContractedPower):null,
                'XC_WeeklyBehaviour__c' => wrapper.WeeklyBehaviour,
                'XC_NominalPower__c' => wrapper.NominalPower!=null?decimal.valueOf(wrapper.NominalPower):null,
                'XC_AvgProducibility__c' => wrapper.AvgProducibility!=null?decimal.valueOf(wrapper.AvgProducibility):null,
                'XC_CostSavings__c' => wrapper.CostSavings!=null?decimal.valueOf(wrapper.CostSavings):null,
                'XC_PaybackPeriod__c' => wrapper.PaybackPeriod!=null?decimal.valueOf(wrapper.PaybackPeriod):null,
                'XC_co2Avoidance__c' => wrapper.co2Avoidance!=null?decimal.valueOf(wrapper.co2Avoidance):null,
                'XC_PlantCost__c' => wrapper.PlantCost!=null?decimal.valueOf(wrapper.PlantCost):null,
                'XC_AutoconsumedEnergy__c' => wrapper.AutoconsumedEnergy!=null?decimal.valueOf(wrapper.AutoconsumedEnergy):null,
                'XC_ExchangedEnergy__c' => wrapper.ExchangedEnergy!=null?decimal.valueOf(wrapper.ExchangedEnergy):null,
                'XC_NumberofVehicles__c' => wrapper.NumberOfVehicles,
                'XC_VehicleType__c' => wrapper.VehicleType,
                'XC_ChargePoint__c' => wrapper.ChargePoint,
                'XC_RentingPeriod__c' => wrapper.RentingPeriod,
                'XC_VehicleMileage__c' => wrapper.VehicleMileage,
                'XC_DailyBehaviour__c' => wrapper.DailyBehaviour
            };

            for(String key : mapLeadWrapperB2B.keySet()){
                if(mapLeadWrapperB2B.get(key) != null){
                    ld.put(key, mapLeadWrapperB2B.get(key));
                }
            }
            
        }

        if(httpMethod == 'POST' && String.isNotBlank(wrapper.BusinessName)) {
            ld.Company = wrapper.BusinessName;
        } else if(httpMethod == 'POST') {
            ld.Company = wrapper.FirstName + ' ' + wrapper.LastName;
        }

        if(String.isNotBlank(ld.Company)) {
            ld.XC_CondominiumName__c = ld.Company;
        }

        populateDocumentFromIdentity(wrapper, ld);
    }


    /**
     * PopulateDocumentFromIdentity.
     *
     * @param wrapper the wrapper
     * @param ld the lead
     * @description populate Document field on Lead from Identity section
     */
     public static void populateDocumentFromIdentity(XC_UTIL_Lead.LeadRESTWrapper wrapper, Lead ld) {

        if(wrapper.Identity == null || wrapper.Identity.isEmpty()){
            return;
        } 

        Date nieExpeditionDate = String.isNotBlank(wrapper.Identity[0].ReleaseDate) ? Date.valueOf(wrapper.Identity[0].ReleaseDate) : null;
        Date nieExpirationDate = String.isNotBlank(wrapper.Identity[0].ExpiryDate) ? Date.valueOf(wrapper.Identity[0].ExpiryDate) : null;  

        if(wrapper.LeadType!='Small Business'){
            ld.XC_DocumentCountry__c = wrapper.Identity[0].Country;
            ld.XC_DocumentType__c = wrapper.Identity[0].IdentityType;
            ld.XC_DocumentNumber__c = wrapper.Identity[0].IdentityNumber;
            ld.XC_NIE_expedition_date__c = nieExpeditionDate; 
            ld.XC_NIE_expiration_date__c = nieExpirationDate;

        } else {
            ld.XC_CDocCountry__c = wrapper.Identity[0].Country; 
            ld.XC_CDocType__c = wrapper.Identity[0].IdentityType;
            ld.XC_CDocNumber__c = wrapper.Identity[0].IdentityNumber;
            ld.XC_ContacDocumentReleaseDate__c = nieExpeditionDate;
            ld.XC_ContactDocumentExpirationDate__c = nieExpirationDate; 
        }
        
    }


    /**
     * GenerateLegalEntityfromWrapper.
     *
     * @param legalEnWr the legal entity wrapper
     * @param individualId the individual id
     * @return the Legal Entity Consent
     * @description generate Legal Entity Consent from Wrapper
     */
    public static XC_LegalEntityConsent__c generateLegalEntityFromWrapper(XC_UTIL_Lead.LegalEntityWrapper legalEnWr, String individualId) {

        XC_LegalEntityConsent__c legalEntity = new XC_LegalEntityConsent__c();

        if(String.isNotBlank(legalEnWr.LegalEntityID)) {
            legalEntity.Id = legalEnWr.LegalEntityID;
        } else if(String.isNotBlank(individualId)) {
            legalEntity.XC_Individual__c = individualId;
        }

        legalEntity.XC_LegalEntity__c = legalEnWr.LegalEntity;
        legalEntity.XC_LeCountry__c	= XC_UTIL_Integration_U.getCountryFromLegalEntity(legalEnWr.LegalEntity);
        legalEntity.XC_GiveDataToNew__c = XC_UTIL_Integration_U.convertFromStringToPicklist(legalEnWr.GiveDataToLegalEntity);
        if(String.isNotBlank(legalEnWr.GiveDataForMarketing)) {
            legalEntity.XC_MarketingConsent__c = XC_UTIL_Integration_U.convertFromStringToPicklist(legalEnWr.GiveDataForMarketing);
        }
        if(String.isNotBlank(legalEnWr.GiveDataForProfiling)) {
            legalEntity.XC_ProfilingConsent__c = XC_UTIL_Integration_U.convertFromStringToPicklist(legalEnWr.GiveDataForProfiling);
        }
        if(legalEnWr.ConsentMarketingDate != null) {
            legalEntity.XC_CollectionDateMarketing__c = legalEnWr.ConsentMarketingDate;
        }
        if(legalEnWr.ConsentProfilingDate != null) {
            legalEntity.XC_CollectionDateProfiling__c = legalEnWr.ConsentProfilingDate;
        }
         if(String.isNotBlank(legalEnWr.GiveDataForNotCustomer)) {
             legalEntity.XC_NotCustomerConsent__c = (legalEnWr.GiveDataForNotCustomer == 'Y' || legalEnWr.GiveDataForNotCustomer == 'N') ? XC_UTIL_Integration_U.convertFromStringToPicklist(legalEnWr.GiveDataForNotCustomer) : legalEnWr.GiveDataForNotCustomer;
         }
         if(String.isNotBlank(legalEnWr.GiveDataForThirdProductMarketing)) {
             legalEntity.XC_ThirdProductsMarketingConsent__c = (legalEnWr.GiveDataForThirdProductMarketing == 'Y' || legalEnWr.GiveDataForThirdProductMarketing == 'N') ? XC_UTIL_Integration_U.convertFromStringToPicklist(legalEnWr.GiveDataForThirdProductMarketing) : legalEnWr.GiveDataForThirdProductMarketing;
         }
         if(String.isNotBlank(legalEnWr.VersionConsentNotCustomer)) {
             legalEntity.XC_NotCustomerConsentVersion__c = legalEnWr.VersionConsentNotCustomer;
         }
         if(legalEnWr.ConsentNotCustomerDate != null) {
             legalEntity.XC_CollectionDateNotCustomer__c = legalEnWr.ConsentNotCustomerDate;
         }
         if(String.isNotBlank(legalEnWr.VersionConsentThirdProductMarketing)) {
             legalEntity.XC_ThirdProductsMarketingConsentVersion__c = legalEnWr.VersionConsentThirdProductMarketing;
         }
         if(legalEnWr.ConsentThirdProductMarketingDate != null) {
             legalEntity.XC_CollectionDateThirdProductsMarketing__c = legalEnWr.ConsentThirdProductMarketingDate;
        }

     /*   Country
VersionConsentCompany
ConsentCompanyDate
VersionConsentMarketing
ConsentMarketingDate
VersionConsentForProfiling
ConsentProfilingDate*/

        
        Map<String, Object> mapLegalEn = new Map<String,Object>{
                                                                'XC_CompanyConsentVersion__c' => legalEnWr.VersionConsentCompany,
                                                                //'ConsentCompanyDate' => 
                                                                'XC_MarketingConsentVersion__c' => legalEnWr.VersionConsentMarketing,
                                                                'XC_ProfilingConsentVersion__c' => legalEnWr.VersionConsentForProfiling
                                                                //'' => legalEn.PreferredContactMethod;
                                                            };

        for(String key : mapLegalEn.keySet()){
            if(mapLegalEn.get(key) != null){
                legalEntity.put(key, mapLegalEn.get(key));
            }
        }

        return legalEntity;
    }


    /**
     * GenerateLegalEntityfromWrapper.
     *
     * @param legalEnWr the legal entity wrapper
     * @param individualId the individual id
     * @return the Legal Entity Consent
     * @description generate Legal Entity Consent from Wrapper
     */
    public static List<Map<String, Object>> generateLegalEntityForInsertLead(List<XC_UTIL_Lead.LegalEntityWrapper> legalEnList) {
        
        List<Map<String, Object>> consentList = new List<Map<String, Object>>();
        for(XC_UTIL_Lead.LegalEntityWrapper legalEn : legalEnList) {
            Map<String, Object> consent = new Map<String, Object>{'XC_LegalEntity__c' => legalEn.LegalEntity,
                                                                    'XC_GiveDataTo__c' => 'Yes',
                                                                    'XC_KeepMeUpdateOnProducts__c' => ((legalEn.GiveDataForMarketing == 'Y') ? 'Yes' : 'No'),
                                                                    'XC_GiveConsentToDataProcessing__c' => ((legalEn.GiveDataForProfiling == 'Y') ? 'Yes' : 'No'),
                                                                    'XC_LeCountry__c' => (XC_UTIL_Integration_U.getCountryFromLegalEntity(legalEn.LegalEntity)),
                                                                    'XC_CompanyConsentVersion__c' => legalEn.VersionConsentCompany,
                                                                    //'ConsentCompanyDate' => 
                                                                    'XC_MarketingConsentVersion__c' => legalEn.VersionConsentMarketing,
                                                                     'XC_ProfilingConsentVersion__c' => legalEn.VersionConsentForProfiling,
                                                                     //'' => legalEn.PreferredContactMethod;
                                                                     //API 2.22
                                                                     'XC_NotCustomerConsent__c' => legalEn.GiveDataForNotCustomer,
                                                                     'XC_ThirdProductsMarketingConsent__c' => legalEn.GiveDataForThirdProductMarketing,
                                                                     'XC_NotCustomerConsentVersion__c' => legalEn.VersionConsentNotCustomer,
                                                                     'XC_CollectionDateNotCustomer__c' => legalEn.ConsentNotCustomerDate,
                                                                     'XC_ThirdProductsMarketingConsentVersion__c' => legalEn.VersionConsentThirdProductMarketing,
                                                                     'XC_CollectionDateThirdProductsMarketing__c' => legalEn.ConsentThirdProductMarketingDate
                                                                    };
            if(legalEn.ConsentMarketingDate != null){
                consent.put('XC_CollectionDateMarketing__c',legalEn.ConsentMarketingDate);
            }
            if(legalEn.ConsentProfilingDate != null){
                consent.put('XC_CollectionDateProfiling__c',legalEn.ConsentProfilingDate);
            }
            consentList.add(consent);
        }

        return consentList;
    }


    /**
     * GenerateConsentsWrapper.
     *
     * @param legalEnList the legal entity list
     * @return the consents list
     * @description generate Legal Entity Consent from Wrapper
     */
    public static List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> generateConsentsWrapper(List<XC_UTIL_Lead.LegalEntityWrapper> legalEnList, String thirdPartyValue) {

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> consentList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        for(XC_UTIL_Lead.LegalEntityWrapper legalEn : legalEnList) {
            XC_LCC163_CreateConsents.GetLegalEntitiesResponse consent = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
            consent.legalEntity = legalEn.LegalEntity;
            consent.country = legalEn.country == null ? XC_UTIL_Integration_U.getCountryFromLegalEntity(legalEn.LegalEntity) : legalEn.country;
            consent.marketingValue = (legalEn.GiveDataForMarketing == 'Y') ? 'Yes' : 'No';
            consent.profilingValue = (legalEn.GiveDataForProfiling == 'Y') ? 'Yes' : 'No';
            consent.thirdPartyValue = thirdPartyValue;
            consent.consentsData.personalInfo.currentLE = consent.legalEntity;
            consent.consentsData.personalInfo.countryLE = consent.country;

            consent.consentsData.thirdPartiesConsent.consentVersion = legalEn.VersionConsentCompany;
            consent.consentsData.thirdPartiesConsent.ConsentCompanyDate = legalEn.ConsentCompanyDate;
        
            consent.consentsData.marketingConsent.consentVersion = legalEn.VersionConsentMarketing;
            consent.consentsData.marketingConsent.ConsentMarketingDate = legalEn.ConsentMarketingDate;

            consent.consentsData.profilingConsent.consentVersion = legalEn.VersionConsentForProfiling;
            consent.consentsData.profilingConsent.ConsentProfilingDate = legalEn.ConsentProfilingDate;

            //PreferredContactMethod;
            consentList.add(consent);
        }

        return consentList;
    }


    /**
     * GenerateDocumentFromWrapper.
     *
     * @param idWr the identity wrapper
     * @param leadId the lead Id
     * @return the Personal Document
     * @description generate Personal Document from Wrapper
     */
    /*public static XC_PersonalDocument__c generateDocumentFromWrapper(XC_UTIL_Account.IdentityIFWrapper idWr, Id leadId) {

        XC_PersonalDocument__c persDocument = new XC_PersonalDocument__c();
        if(String.isNotBlank(idWr.IdentityID)){            
            persDocument.Id = idWr.IdentityID;             
        }
        persDocument.XC_Lead__c = leadId;
        persDocument.XC_Country__c = idWr.Country;
        persDocument.XC_DocumentType__c = idWr.IdentityType;
        persDocument.XC_DocumentNumber__c = idWr.IdentityNumber;
        if(idWr.ReleaseDate != null) {
            persDocument.XC_ReleaseDate__c = Date.valueOf(idWr.ReleaseDate);
        }
        if(idWr.ExpiryDate != null) {
            persDocument.XC_ExpirationDate__c = Date.valueOf(idWr.ExpiryDate);
        }

        return persDocument;
    }*/


    /**
     * GeneratePosFromWrapper.
     *
     * @param posWr the pos wrapper
     * @param addressId the address Id
     * @return the Point of Service
     * @description generate a Point Of Service from wrapper
     */
    public static XC_PointOfService__c generatePosFromWrapper(XC_UTIL_Address.PoSWrapper posWr, Id addressId) {

        XC_PointOfService__c pos = new XC_PointOfService__c();

        if(String.isNotBlank(posWr.POSID)) {
            pos.Id = posWr.POSID;
        }
        if(String.isNotBlank(addressId)) {
            pos.XC_Address__c = addressId;
        }
        if(String.isNotBlank(posWr.POSType)) {
            pos.XC_Type__c = posWr.POSType;
        }
        if(String.isNotBlank(posWr.POS)) {
            pos.Name = posWr.POS;
        }
        
        return pos;
    }
}