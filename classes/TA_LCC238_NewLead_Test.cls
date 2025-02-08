@isTest
private class TA_LCC238_NewLead_Test {
    
    @isTest
    private static void retrieveData() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        Id recordId = null;
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        String serializedWrapper = TA_LCC238_NewLead.retrieveData(recordId, recordTypeId); 
        Map<String, Object> mapWrapper = (Map<String, Object>) JSON.deserializeUntyped(serializedWrapper);
        System.assert(mapWrapper.get('recordTypeName') == 'XC_GLO_Lead_Residential');

        Id recordTypeIdSoho = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Soho').getRecordTypeId();
        String serializedWrapperSoho = TA_LCC238_NewLead.retrieveData(recordId, recordTypeIdSoho); 
        Map<String, Object> mapWrapperSoho = (Map<String, Object>) JSON.deserializeUntyped(serializedWrapperSoho);
        System.assert(mapWrapperSoho.get('recordTypeName') == 'XC_GLO_Lead_Soho');

        Id recordTypeIdCondominium = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Condominium').getRecordTypeId();
        String serializedWrapperCondominium = TA_LCC238_NewLead.retrieveData(recordId, recordTypeIdCondominium); 
        Map<String, Object> mapWrapperCondominium = (Map<String, Object>) JSON.deserializeUntyped(serializedWrapperCondominium);
        System.assert(mapWrapperCondominium.get('recordTypeName') == 'XC_GLO_Lead_Condominium');
        Test.stopTest();
    } 

    @isTest
    private static void isSystemAdmin(){
        Test.startTest();
        Boolean isSysAdmin = TA_LCC238_NewLead.isSystemAdmin();
        System.assertEquals(true, isSysAdmin);
        Test.stopTest();
    }

    @isTest
    private static void getChannelFromUser(){
        User u = new User(Id = UserInfo.getUserId());
        u.XC_Receiving_Channel__c = 'Web';
        update u;
        Test.startTest();
        XC_UTIL_ResultWrapper channelRes = TA_LCC238_NewLead.getChannelFromUser();
        System.assertEquals('Web', channelRes.fieldName);
        Test.stopTest();
    }

    
    @isTest
    private static void createEmptyeRecord(){
        Test.startTest(); 
        XC_LCC002_NewLead_W.InsertResultWrapper wrOk = TA_LCC238_NewLead.createRecord('');
        System.debug(wrOk);
        System.assertEquals(false, wrOk.success); 
        Test.stopTest(); 
    }

    @isTest
    private static void createRecordResidential(){
        Test.startTest(); 
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord(); 
        XC_ProductCategoryOfInterest__c productCategory = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        
        Map<String, Object> mapLeadFields = new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'XC_PhonePrefix__c' => '+39',
            'XC_LeadPhone__c' => '342767444',
            'XC_MobilePrefix__c' => '+39',
            'XC_LeadMobile__c' => '342767444',
            'Email' => 'te@tefhtheyr.it',
            'XC_Birthdate__c' => '01-01-1980',
            'XC_Preference_Language__c' => 'Italian',
            'XC_Nationality__c' => 'Italian',
            'XC_Notes__c' => null,
            'XC_DocumentCountry__c' => 'Spain',
            'XC_DocumentType__c' => 'Passport',
            'XC_DocumentNumber__c' => '22222522',
            'XC_NIE_expedition_date__c' => '2019-04-01',
            'XC_NIE_expiration_date__c' => '2099-07-31',
            'XC_AddressCountry__c' => 'Spain',
            'XC_StreetType__c' => 'Access',
            'XC_StreetNumber__c' => '2',
            'XC_Door__c' => '2',
            'XC_City__c' => 'test',
            'XC_AddressProvince__c' => 'Barcelona',
            'XC_Category__c' => 'Main house',
            'XC_Address__c' => 'test',
            'XC_Floor__c' => '2',
            'XC_Stair__c' => '2',
            'XC_Municipality__c' => 'test',
            'XC_PostalCode__c' => '2',
            'XC_InstallationAddress__c' => 'true',
            'XC_DeliveryAddress__c' => 'true',
            'XC_BillingAddress__c' => 'true',
            'XC_ProductCategoryOfInterest__c' => productCategory.Name,
            'XC_HourToBeRecontacted__c' => '',
            'XC_Channel__c' => 'Resellers',
            'XC_LeadSource__c' => '',
            //'XC_GDPRThirdPartiesRelated__c' => true,
            'Country__c' => 'SPAIN',
            'XC_Country__c' => 'Spain',
            'XC_Salutation__c' => 'Mr.',
            'XC_Note__c' => 'test note',
            'OwnerId' => UserInfo.getUserId()
        };

        Map<String, Object> mapAddressFields = new Map<String, Object>{
            'country' => 'Spain',
            'streetType' => 'Access',
            'address' => 'test',
            'streetNumber' => '2',
            'door' => '2',
            'postalCode' => '2',
            'stair' => '2',
            'floor' => '2',
            'city' => 'test',
            'province' => 'Barcelona',
            'category' => 'Main house',
            'municipality' => 'test',
            'installationAddress' => true,
            'deliveryAddress' => true,
            'billingAddress' => true,
            'validate' => true
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Yes',
            'XC_CompanyConsentVersion__c' => 'test v.2',
            'XC_GiveDataTo__c' => 'Yes'/* true,
            'XC_KeepMeUpdateOnProducts__c' => true,
            'XC_GiveConsentToDataProcessing__c' => true*/
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'Test';
        leWrapper.label = 'Test';
        leWrapper.legalEntity = 'Test';
        leWrapper.country = 'Test';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'Test';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapper.thPartiesMarketingValue = 'Test';
        leWrapper.notCustomerValue = 'Test';
        leWrapperList.add(leWrapper);
        
        Map<String, Object> mapLeadByComponent = new Map<String, Object>{
            'fieldMapStringLead' => JSON.serialize(mapLeadFields),
            'assignLead' => true,
            'recordTypeId' => recordTypeId,
            'existingLeadId' => null,
            'fullName' => null,
            'parentCaseId' => null, 
            'addressFields' => JSON.serialize(mapAddressFields),
            'socialPersonaId' => null,
            'robinsonCustomer' => true,
            'thirdPartiesCheck' => 'Yes',
            'thirdPartiesVersion' => 'test v.1',
            'consentsLE' =>  JSON.serialize(leConsents),
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapLeadString = JSON.serialize(mapLeadByComponent);
        
        XC_LCC002_NewLead_W.InsertResultWrapper wrOk = TA_LCC238_NewLead.createRecord(mapLeadString);
        System.debug(wrOk);
        System.assertNotEquals(null, wrOk); 
        Test.stopTest(); 
    }

    @isTest
    private static void createRecordSoho(){
        Test.startTest(); 
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Soho').getRecordTypeId();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord(); 
        XC_ProductCategoryOfInterest__c productCategory = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        
        Map<String, String> mapLeadFields = new Map<String, String>{
            'Company' => 'Test srl',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_DocumentType__c' => 'Passport',
            'XC_DocumentNumber__c' => 'TST1234567',
            'XC_NIE_expedition_date__c' => null,
            'XC_NIE_expiration_date__c' => null,
            'XC_Notes__c' => null,
            'FirstName' => 'Test Soho',
            'LastName' => 'Test Soho',
            'XC_PhonePrefix__c' => '',
            'XC_LeadPhone__c' => null,
            'XC_MobilePrefix__c' => '',
            'XC_LeadMobile__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_Nationality__c' => '',
            'Email' => 'testsoholead@test.it',
            'XC_ProductCategoryOfInterest__c' => productCategory.Name,
            'XC_HourToBeRecontacted__c' => '',
            'XC_Channel__c' => 'Resellers',
            'XC_LeadSource__c' => '',
            'OwnerId' => UserInfo.getUserId()
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Yes',
            'XC_CompanyConsentVersion__c' => 'test v.2'
            /*'XC_GiveDataTo__c' => true,
            'XC_KeepMeUpdateOnProducts__c' => true,
            'XC_GiveConsentToDataProcessing__c' => true*/
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'Test';
        leWrapper.label = 'Test';
        leWrapper.legalEntity = 'Test';
        leWrapper.country = 'Test';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'Test';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);

        Map<String, Object> mapLeadByComponent = new Map<String, Object>{
            'fieldMapStringLead' => JSON.serialize(mapLeadFields),
            'assignLead' => true,
            'recordTypeId' => recordTypeId,
            'existingLeadId' => null,
            'fullName' => null,
            'parentCaseId' => null, 
            'addressFields' => null,
            'socialPersonaId' => null,
            //'thirdPartiesCheck' => true,
            'robinsonCustomer' => true,
            'thirdPartiesCheck' => 'Yes',
            'thirdPartiesVersion' => 'test v.1',
            'consentsLE' =>  JSON.serialize(leConsents),
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapLeadString = JSON.serialize(mapLeadByComponent);
        
        XC_LCC002_NewLead_W.InsertResultWrapper wrOk = TA_LCC238_NewLead.createRecord(mapLeadString);
        System.debug(wrOk);
        System.assertEquals(false, wrOk.success); 
        Test.stopTest(); 
    }

    @isTest
    private static void createRecordCondominium(){
        Test.startTest(); 
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Condominium').getRecordTypeId();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord(); 
        XC_ProductCategoryOfInterest__c productCategory = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        
        Map<String, String> mapLeadFields = new Map<String, String>{
            'XC_CondominiumName__c' => 'test',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_DocumentType__c' => 'NIF',
            'XC_DocumentNumber__c' => 'Y9793296W',
            'XC_NIE_expedition_date__c' => '2019-04-01',
            'XC_NIE_expiration_date__c' => '2099-04-02',
            'XC_Notes__c' => null,
            'FirstName' => 'test',
            'LastName' => 'test',
            'XC_PhonePrefix__c' => '',
            'XC_LeadPhone__c' => null,
            'XC_MobilePrefix__c' => '',
            'XC_LeadMobile__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_Nationality__c' => '',
            'Email' => 'test@teshhhht.it',
            'XC_ProductCategoryOfInterest__c' => productCategory.Name,
            'XC_HourToBeRecontacted__c' => '',
            'XC_Channel__c' => 'Resellers',
            'XC_LeadSource__c' => '',
            'OwnerId' => UserInfo.getUserId()
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Yes',
            'XC_CompanyConsentVersion__c' => 'test v.2',
            'XC_GiveDataTo__c' => 'Yes'/*, 
            'XC_KeepMeUpdateOnProducts__c' => true,
            'XC_GiveConsentToDataProcessing__c' => true*/
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'Test';
        leWrapper.label = 'Test';
        leWrapper.legalEntity = 'Test';
        leWrapper.country = 'Test';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'Test';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);

        Map<String, Object> mapLeadByComponent = new Map<String, Object>{
            'fieldMapStringLead' => JSON.serialize(mapLeadFields),
            'assignLead' => true,
            'recordTypeId' => recordTypeId,
            'existingLeadId' => null,
            'fullName' => null,
            'parentCaseId' => null, 
            'addressFields' => null,
            'socialPersonaId' => null,
            //'thirdPartiesCheck' => true,
            'robinsonCustomer' => false,
            'thirdPartiesCheck' => 'No',
            'thirdPartiesVersion' => '',
            'consentsLE' =>  JSON.serialize(leConsents),
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapLeadString = JSON.serialize(mapLeadByComponent);
        
        XC_LCC002_NewLead_W.InsertResultWrapper wrOk = TA_LCC238_NewLead.createRecord(mapLeadString);
        System.debug(wrOk);
        System.assertNotEquals(null, wrOk); 
        Test.stopTest(); 
    }
    
    @isTest
    private static void createRecordCondominiumErr(){
        Test.startTest(); 

        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Condominium').getRecordTypeId();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord(); 
        XC_ProductCategoryOfInterest__c productCategory = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        
        Map<String, String> mapLeadFields = new Map<String, String>{
            'XC_CondominiumName__c' => 'test',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_DocumentType__c' => 'NIF',
            'XC_DocumentNumber__c' => 'Y9793296W',
            'XC_NIE_expedition_date__c' => '2019-04-01',
            'XC_NIE_expiration_date__c' => '2099-04-02',
            'XC_Notes__c' => null,
            'FirstName' => 'test',
            'LastName' => 'test',
            'XC_PhonePrefix__c' => '',
            'XC_LeadPhone__c' => null,
            'XC_MobilePrefix__c' => '',
            'XC_LeadMobile__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_Nationality__c' => '',
            'Email' => 'test@teshhhht.it',
            'XC_ProductCategoryOfInterest__c' => productCategory.Name,
            'XC_HourToBeRecontacted__c' => '',
            'XC_Channel__c' => 'Resellers',
            'XC_LeadSource__c' => '',
            'OwnerId' => UserInfo.getUserId()
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Yes',
            'XC_CompanyConsentVersion__c' => 'test v.2',
            'XC_GiveDataTo__c' => 'pp'/*, 
            'XC_KeepMeUpdateOnProducts__c' => true,
            'XC_GiveConsentToDataProcessing__c' => true*/
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'Test';
        leWrapper.label = 'Test';
        leWrapper.legalEntity = 'Test';
        leWrapper.country = 'Test';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'Test';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);

        Map<String, Object> mapLeadByComponent = new Map<String, Object>{
            'fieldMapStringLead' => JSON.serialize(mapLeadFields),
            'assignLead' => true,
            'recordTypeId' => recordTypeId,
            'existingLeadId' => null,
            'fullName' => null,
            'parentCaseId' => null, 
            'addressFields' => null,
            'socialPersonaId' => null,
            //'thirdPartiesCheck' => true,
            'robinsonCustomer' => false,
            'thirdPartiesCheck' => 'No',
            'thirdPartiesVersion' => '',
            'consentsLE' =>  JSON.serialize(leConsents),
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapLeadString = JSON.serialize(mapLeadByComponent);
        
        XC_LCC002_NewLead_W.InsertResultWrapper wrOk = TA_LCC238_NewLead.createRecord(mapLeadString);
        System.debug(wrOk);
        System.assertEquals(false, wrOk.success); 
        Test.stopTest(); 
    }

    @isTest
    private static void createRecordKoOnLE(){
        Test.startTest(); 

        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Condominium').getRecordTypeId();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord(); 
        XC_ProductCategoryOfInterest__c productCategory = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        
        Map<String, String> mapLeadFields = new Map<String, String>{
            'XC_CondominiumName__c' => 'test',
            'XC_DocumentCountry__c' => 'Spain',
            'XC_DocumentType__c' => 'NIE',
            'XC_DocumentNumber__c' => 'Y9793296W',
            'XC_NIE_expedition_date__c' => '2019-04-01',
            'XC_NIE_expiration_date__c' => '2099-04-02',
            'XC_Notes__c' => null,
            'FirstName' => 'test',
            'LastName' => 'test',
            'XC_PhonePrefix__c' => '',
            'XC_LeadPhone__c' => null,
            'XC_MobilePrefix__c' => '',
            'XC_LeadMobile__c' => null,
            'XC_Preference_Language__c' => '',
            'XC_Nationality__c' => '',
            'Email' => 'test@teshhhht.it',
            'XC_ProductCategoryOfInterest__c' => productCategory.Name,
            'XC_HourToBeRecontacted__c' => '',
            'XC_Channel__c' => 'Resellers',
            'XC_LeadSource__c' => '',
            'OwnerId' => UserInfo.getUserId()
        };

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            //'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Bad Value',
            'XC_CompanyConsentVersion__c' => 'test v.2'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'Test';
        leWrapper.label = 'Test';
        leWrapper.legalEntity = 'Test';
        leWrapper.country = 'Test';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'Test';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);

        Map<String, Object> mapLeadByComponent = new Map<String, Object>{
            'fieldMapStringLead' => JSON.serialize(mapLeadFields),
            'assignLead' => true,
            'recordTypeId' => recordTypeId,
            'existingLeadId' => null,
            'fullName' => null,
            'parentCaseId' => null, 
            'addressFields' => null,
            'socialPersonaId' => null,
            'robinsonCustomer' => false,
            'thirdPartiesCheck' => 'No',
            'thirdPartiesVersion' => '',
            'consentsLE' =>  JSON.serialize(leConsents),
            'consentsWrapper' => JSON.serialize(leWrapperList)
        }; 
        String mapLeadString = JSON.serialize(mapLeadByComponent);
        
        XC_LCC002_NewLead_W.InsertResultWrapper wrOk = TA_LCC238_NewLead.createRecord(mapLeadString);
        System.debug(wrOk);
        System.assertEquals(false, wrOk.success); 
        Test.stopTest(); 
    }

    @isTest
    private static void hasCommercialVisit(){
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord(); 
        XC_ProductCategoryOfInterest__c productCategory = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        
        Test.startTest(); 
        Boolean hasCommercialVisit = XC_LCC002_NewLead_U.hasCommercialVisit(productCategory.Name);
        //System.assertEquals(true, hasCommercialVisit); 
        Test.stopTest(); 
    }
    
    //Test Method for XC_LCC002_NewLead_U insertLegalEntityConsents
    @isTest
    private static void insertLegalEntityConsents(){
        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Yes',
            'XC_CompanyConsentVersion__c' => 'test v.2'
            /*'XC_GiveDataTo__c' => true,
            'XC_KeepMeUpdateOnProducts__c' => true,
            'XC_GiveConsentToDataProcessing__c' => true*/
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
        Individual i = new Individual(); 
        i.LastName = 'Test';
        insert i ; 
        String individualId  =  i.Id; 
        String consentsLE = JSON.serialize(leConsents); 
        Test.startTest();
        XC_UTIL_Sobject.WrapperResult result = XC_LCC002_NewLead_U.insertLegalEntityConsents(individualId, consentsLE);
        System.assert(result!=null); 
        Test.stopTest(); 
    }

    @isTest
    private static void callInsertRecord(){
        Test.startTest(); 
        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            //'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Bad Value',
            'XC_CompanyConsentVersion__c' => 'test v.2'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'Test';
        leWrapper.label = 'Test';
        leWrapper.legalEntity = 'Test';
        leWrapper.country = 'Test';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'Test';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);
        XC_LCC002_NewLead_W.LeadInputDataWrapper inputData = new XC_LCC002_NewLead_W.LeadInputDataWrapper();
        inputData.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        inputData.assignLead = true;
        inputData.robinsonCustomer = false;
        inputData.thirdPartiesCheckNew = 'No';
        inputData.thirdPartiesVersion = '';
        inputData.consentsLE = JSON.serialize(leConsents);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        XC_LCC002_NewLead_W.InsertResultWrapper outputWrapper = TA_LCC238_NewLead.insertRecord(XC_DF_Lead.createResidentialLead(), inputData);
        System.assertNotEquals(null, outputWrapper); 
        Test.stopTest(); 
    }

    @isTest
    private static void callUtilityMethods() {
        List<Lead> lead = XC_DF_Lead.createResidentialLeads(1);
        lead[0].XC_Category__c = 'Main house';
        lead[0].XC_StreetType__c = 'Access';
        lead[0].XC_StreetTypeText__c = 'Access';
        lead[0].XC_Address__c = 'Test';
        lead[0].XC_ZipCode__c = '28050';
        lead[0].XC_Province__c = 'Test';
        lead[0].XC_Municipality__c = 'Test';
        lead[0].XC_City__c = 'Test';
        lead[0].XC_StreetNumber__c = '5';
        lead[0].XC_Door__c = '5';
        lead[0].XC_Floor__c = '4';
        lead[0].XC_Stair__c = '5';
        lead[0].XC_Country__c = 'Spain';
        lead[0].XC_InstallationAddress__c = true;
        lead[0].XC_DeliveryAddress__c = true;
        lead[0].XC_BillingAddress__c = true;
        insert lead;
        Individual ind = new Individual(LastName = 'Test');
        insert ind;
        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Yes',
            'XC_CompanyConsentVersion__c' => 'test v.2',
            'XC_GiveDataTo__c' => 'pp'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;
        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'Test';
        leWrapper.label = 'Test';
        leWrapper.legalEntity = 'Test';
        leWrapper.country = 'Test';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'Test';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);

        Test.startTest();
        System.assertNotEquals(lead[0].Id, null);
        XC_UTIL_Sobject.WrapperResult wrRes =  XC_LCC002_NewLead_U.insertLegalEntityConsents(ind.Id, JSON.serialize(leConsents), lead[0]);
        XC_LCC002_NewLead_U.insertAddress(lead[0]);
        SocialPersona sp = new SocialPersona(
            Name = 'Test', 
            Provider = 'Facebook',
            ParentId = lead[0].Id
        );
        insert sp;
        XC_LCC002_NewLead_U.associateSocialPersonaWithLead(lead[0].Id, sp.Id);
        XC_LCC002_NewLead_W.LeadInputDataWrapper inputData = new XC_LCC002_NewLead_W.LeadInputDataWrapper();
        inputData.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        inputData.assignLead = true;
        inputData.robinsonCustomer = false;
        inputData.thirdPartiesCheckNew = 'No';
        inputData.thirdPartiesVersion = '';
        inputData.consentsLE = JSON.serialize(leConsents);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        XC_LCC002_NewLead_Related.saveSocialPersonaAndConsents(lead[0], inputData, Database.setSavepoint());
        XC_LCC002_NewLead_Related.updateIndividual(ind.Id, inputData);
        XC_LCC002_NewLead_Related.doRollback(new XC_UTIL_Sobject.WrapperResult(), Database.setSavepoint());
        Test.stopTest();
    }
    @isTest
    private static void populateWrapper2() {
        User sfmUser = XC_DF_User.createUserAdmin();
        sfmUser.Country__c = 'Argentina';
        Insert sfmUser;
        
        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;
        System.runAs(sfmUser){
            TA_LCC238_NewLead.retrieveData(l.id, recordTypeId);
        }
        
    }

    @isTest
    public static void convertLead_Test(){
        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;

        Test.startTest();
        XC_REST_Lead_W.WrapperLeadResponse response = TA_LCC238_NewLead.convertLead(l.Id);
        Test.stopTest();
    }

    @isTest
    public static void populateFields_Test(){
        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;

        Map<String,Object> fieldMap = new  Map<String,Object>();

        Test.startTest();
        TA_LCC238_NewLead.populateFields(l, fieldMap, '');
        Test.stopTest();
    }

    @isTest
    public static void checkDuplicatesAndInsertRecord_Test(){

        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;

        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            //'XC_LeCountry__c' => 'Spain',
            'XC_GiveDataToNew__c' => 'Bad Value',
            'XC_CompanyConsentVersion__c' => 'test v.2'
        };
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);

        XC_ConsentDescription__c consDescr = new XC_ConsentDescription__c(
            XC_ConsentVersion__c = '1',
            XC_LegalEntity__c = 'EndesaX',
            XC_Country__c = 'Spain',
            XC_ConsentStatus__c = 'Active',
            XC_DescriptionMarketing__c = 'Test',
            XC_DescriptionProfiling__c = 'Test',
            XC_DescriptionThirdParties__c = 'Test',
            XC_DescriptionGiveDataToLE__c = 'Test'
        );
        insert consDescr;

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'Test';
        leWrapper.label = 'Test';
        leWrapper.legalEntity = 'Test';
        leWrapper.country = 'Test';
        leWrapper.companyCode = 'Test';
        leWrapper.consentVersion = 'Test';
        leWrapper.thirdPartyLabel = 'Test';
        leWrapper.profilingLabel = 'Test';
        leWrapper.marketingLabel = 'Test';
        leWrapper.descriptionThirdParties = 'Test';
        leWrapper.descriptionProfiling = 'Test';
        leWrapper.descriptionMarketing = 'Test';
        leWrapper.descriptionGiveData = 'Test';
        leWrapper.marketingValue = 'Test';
        leWrapper.profilingValue = 'Test';
        leWrapper.thirdPartyValue = 'Test';
        leWrapper.legalEntityConsentId = 'Test';
        leWrapper.consentDescriptionLookup = consDescr.Id;
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);
        XC_LCC002_NewLead_W.LeadInputDataWrapper inputData = new XC_LCC002_NewLead_W.LeadInputDataWrapper();
        inputData.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        inputData.assignLead = true;
        inputData.robinsonCustomer = false;
        inputData.thirdPartiesCheckNew = 'No';
        inputData.thirdPartiesVersion = '';
        inputData.consentsLE = JSON.serialize(leConsents);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);

        Map<String,Object> fieldMap = new  Map<String,Object>();

        Test.startTest();
        XC_LCC002_NewLead_W.InsertResultWrapper response = TA_LCC238_NewLead.checkDuplicatesAndInsertRecord(l, inputData);
        Test.stopTest();
    }    

    @isTest
    public static void manageConvertLead_Test() {
        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;

        WorkOrder w = new WorkOrder();
        insert w;

        Test.startTest();
        XC_LCC002_NewLead_W.InsertResultWrapper insertResultWrapper1 = TA_LCC238_NewLead.manageConvertLead(l.Id, w.Id, true);
        XC_LCC002_NewLead_W.InsertResultWrapper insertResultWrapper2 = TA_LCC238_NewLead.manageConvertLead(l.Id, w.Id, false);
        XC_LCC002_NewLead_W.InsertResultWrapper insertResultWrapper3 = TA_LCC238_NewLead.manageConvertLead(l.Id, '', true);
        XC_LCC002_NewLead_W.InsertResultWrapper insertResultWrapper4 = TA_LCC238_NewLead.manageConvertLead(l.Id, '', false);
        Test.stopTest();
    }

    @isTest
    public static void createAssignedResource_Test() {
        
        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;
        
        List<Lead> leadList = new List<Lead>();
        leadList.add(l);

        XC_REST_Lead_W.WrapperLeadResponse wr = new XC_REST_Lead_W.WrapperLeadResponse();
        wr.Account = new XC_REST_Lead_W.WrapperAccount();

        User sfmUser = XC_DF_User.createUserAdmin();
        Insert sfmUser;

        ServiceResource sr = new ServiceResource();
        sr.RelatedRecordId = sfmUser.Id;
        sr.IsActive = true;
        sr.Name = 'Test Test';
        insert sr;

        
        System.runAs(sfmUser){
            List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1, 'Commercial Visit');

            Test.startTest();
            XC_LCC002_NewLead_W.InsertResultWrapper result1 = TA_LCC238_NewLead.createAssignedResource(saList[0].Id);
            XC_LCC002_NewLead_W.InsertResultWrapper result2 = TA_LCC238_NewLead.createAssignedResource('');
            Test.stopTest();
        }
        
    }

    @isTest
    public static void doRollback_Test() {
        
        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;

        Test.startTest();
        TA_LCC238_NewLead.doRollback(l.Id);
        TA_LCC238_NewLead.doRollback('');
        Test.stopTest();
    }

    @isTest
    public static void createDummy_Test() {
        
        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;
        
        List<Lead> leadList = new List<Lead>();
        leadList.add(l);

        XC_REST_Lead_W.WrapperLeadResponse wr = new XC_REST_Lead_W.WrapperLeadResponse();
        wr.Account = new XC_REST_Lead_W.WrapperAccount();

        User sfmUser = XC_DF_User.createUserAdmin();
        Insert sfmUser;

        ServiceResource sr = new ServiceResource();
        sr.RelatedRecordId = sfmUser.Id;
        sr.IsActive = true;
        sr.Name = 'Test Test';
        insert sr;

        try {
            Test.startTest();
            System.runAs(sfmUser){
                XC_UTIL_Sobject.WrapperResult result = TA_LCC238_NewLead.createDummyWorkOrder(leadList, l.Id, wr);
                TA_LCC238_NewLead.createDummyServiceAppointment(result);
            }
            Test.stopTest();
        } catch (Exception e) {
            Boolean expectedResult = (e != null) ? true : false;
            System.assertEquals(expectedResult, true);
        }        
    }

    @isTest
    public static void updateWorkOrderAndServiceAppointment_Test() {

        Lead l = XC_DF_Lead.createResidentialLead();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_ARG_Lead_SFM').getRecordTypeId();
        l.RecordTypeId = recordTypeId;
        l.XC_LeadSource__c = null;
        insert l;

        WorkOrder wo = new WorkOrder();
        wo.TA_Phase__c = 'Evaluation';
        wo.Status = 'In Progress';
        insert wo;

        XC_REST_Lead_W.WrapperLeadResponse convertLeadResponse = new XC_REST_Lead_W.WrapperLeadResponse();
        convertLeadResponse.Account = new XC_REST_Lead_W.WrapperAccount();

        Test.startTest();
        TA_LCC238_NewLead.updateWorkOrderAndServiceAppointment(wo.Id, l.Id, convertLeadResponse, false);
        TA_LCC238_NewLead.updateWorkOrderAndServiceAppointment(wo.Id, l.Id, convertLeadResponse, true);
        Test.stopTest();
    }

}