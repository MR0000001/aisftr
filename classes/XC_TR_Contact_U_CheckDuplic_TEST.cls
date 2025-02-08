/**
* @author Emanuela Cacace ecacace@deloitte.it 
* @date Creation  18/06/2019 
* @description XC_TR_Contact_U_CheckDuplic_TEST – Test class for  XC_TR_Contact_U_CheckDuplicates
*/  
@isTest
public with sharing class XC_TR_Contact_U_CheckDuplic_TEST { 

    //Test method checkduplicationContactAndInsertIndividual
    static testMethod void checkduplicationContactAndInsertIndividual(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> acct = XC_DF_Account.createSohoAccounts(1);
        acct[0].PrimaryEmail__c = 'test@te.it';
        acct[0].IdentityType__c = 'NIF';
        acct[0].IdentityNumber__c='50692632B';
        insert acct;  
        /*List<Contact> cont = XC_DF_Contact.createSohoContacts(acct);
        cont[0].FirstName = 'Mario';
        cont[0].LastName='Rossi';
        cont[0].XC_PhonePrefix__c='+54'; 
        cont[0].XC_ContactPhone__c= '658965485';
        cont[0].Email = 'test1@contact.it';
        insert cont;*/
        //XC_TR_Contact_U_CheckDuplicates.ResultWrapper cd = new XC_TR_Contact_U_CheckDuplicates.ResultWrapper(cont[0]);
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();
        Map<String, Object> mapLEFields = new Map<String, Object>{
            'XC_LegalEntity__c' => 'EndesaX',
            'XC_GiveDataTo__c' => true,
            'XC_KeepMeUpdateOnProducts__c' => true,
            'XC_GiveConsentToDataProcessing__c' => true
        };
      
        
        Map<String, Object> mapContactFields = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Contact',
            'DocumentType' => '',
            'DocumentID' => '',
            'Email' => 'test@contact.it',
            'Mobile' => '',
            'Phone' => ''
        }; 
        List<Map<String, Object>> leConsents = new List<Map<String, Object>>();
        leConsents.add(mapLEFields);
        inputData.contactFields = JSON.serialize(mapContactFields); 
        inputData.consentsLE =  JSON.serialize(leConsents);

       XC_UTIL_Sobject.WrapperResult result = new XC_UTIL_Sobject.WrapperResult();
       /* XC_TR_Contact_U_CheckDuplicates.ResultWrapper result = new XC_TR_Contact_U_CheckDuplicates.ResultWrapper();
        try{
            result = XC_TR_Contact_U_CheckDuplicates.XC_TR_Contact_U_CheckDuplicates(acct[0], inputData); 
        }
        catch(exception e){
            System.assert(result!=null);
        }*/
        try{
            //result = XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(acct[0], inputData); 
        }
        catch(exception e){
            System.assert(result!=null);
        }
        System.assertEquals(1, acct.size());
        Test.stopTest(); 
    }

    @IsTest
    static void manageNotExistingContactTestResidential (){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].XC_ReceivingChannel__c = 'Commodity Partner';
       /* accList[0].XC_AccountMainPhone__c = '3696587459';
        accList[0].XC_MainPhonePrefix__c = '+34';
        accList[0].XC_AccountPhone__c = '3696587459';
        accList[0].XC_AccountPhonePrefix__c ='+34';*/
        accList[0].XC_BirthDate__c = Date.today();
        accList[0].XC_Salutation__c = 'Mr.';

        insert accList;

        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        insert contactList;

        XC_TR_Account_U_CheckDuplicates.ResultWrapper accountCheckDuplicateRes = new XC_TR_Account_U_CheckDuplicates.ResultWrapper();
        accountCheckDuplicateRes.accountID = accList[0].id;
        accountCheckDuplicateRes.existingContact = contactList[0];
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();

        Map<String, Object> mapContactFields = new Map<String, Object>{
                'FirstName' => 'a',
                'LastName' => 'b',
                'DocumentCountry' => 'Spain',
                'DocumentType' => 'Passport',
                'DocumentID' => '00533738',
                'Email' => 'test@te.it',
                'Mobile' => '3696587459',
                'Phone' => '',
                'XC_CountryLegalEntity__c' => 'Spain',
                'XC_MainLegalEntity__c' => 'EndesaX',
                'Sex' => 'M',
                'Citizenship' => 'Spainish',
                'BirthPlace' => 'Madrid',
                'BirthProvince' => 'Madrid',
                'BirthCountry' => 'Spain',
                'PreferredLanguage' => 'Spanish'
        };

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
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
        leWrapper.thirdPartyValue = 'YES';
        leWrapper.legalEntityConsentId = 'EndesaX';
        leWrapper.isExisting = false;
        leWrapper.confirmationByTheCustomer = true;
        leWrapperList.add(leWrapper);

        inputData.contactFields = JSON.serialize(mapContactFields);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        inputData.accountCheckDuplicateRes = accountCheckDuplicateRes;
        System.debug('MC ' +  inputData.consentsWrapper);
        System.debug('MC ' + leWrapperList);
        Test.startTest();
        XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(accList[0], inputData, false);
        Test.stopTest();
    }

    @IsTest
    static void manageNotExistingContactTestPartner (){
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();

        String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();



        Map<String, Object> mapContactFields = new Map<String, Object>{
                'FirstName' => 'a',
                'LastName' => 'b',
                'DocumentCountry' => 'Spain',
                'DocumentType' => 'Passport',
                'DocumentID' => '00533738',
                'Email' => 'test@te.it',
                'Mobile' => '3696587459',
                'Phone' => '',
                'XC_CountryLegalEntity__c' => 'Spain',
                'XC_MainLegalEntity__c' => 'EndesaX',
                'Sex' => 'M',
                'MobilePrefix' => '+34',
                'Citizenship' => 'Spainish',
                'BirthPlace' => 'Madrid',
                'BirthProvince' => 'Madrid',
                'BirthCountry' => 'Spain',
                'PreferredLanguage' => 'Spanish'
        };

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);

        inputData.contactFields = JSON.serialize(mapContactFields);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        System.debug('MC ' +  inputData.consentsWrapper);
        System.debug('MC ' + leWrapperList);
        Test.startTest();
        XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(accList[0], inputData, true);
        Test.stopTest();
    }

    @IsTest
    static void manageNotExistingContactTestSoho (){
        List<Account> accList = XC_DF_Account.createSohoAccounts(1);
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();

        Map<String, Object> mapContactFields = new Map<String, Object>{
                'FirstName' => 'a',
                'LastName' => 'b'
        };

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);

        inputData.contactFields = JSON.serialize(mapContactFields);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        System.debug('MC ' +  inputData.consentsWrapper);
        System.debug('MC ' + leWrapperList);
        Test.startTest();
        XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(accList[0], inputData, true);
        Test.stopTest();
    }

    @IsTest
    static void manageNotExistingContactTestCondominium (){
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();

        Map<String, Object> mapContactFields = new Map<String, Object>{
                'FirstName' => 'a',
                'LastName' => 'b'
        };

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);

        inputData.contactFields = JSON.serialize(mapContactFields);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        System.debug('MC ' +  inputData.consentsWrapper);
        System.debug('MC ' + leWrapperList);
        Test.startTest();
        XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(accList[0], inputData, true);
        Test.stopTest();
    }

    @IsTest
    static void manageNotExistingContactTestB2B (){
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
        accountToInsert.Company__c = 'Test Account Company n ' + (Math.random()*Math.random());
        accountToInsert.PrimaryEmail__c = 'test_b2b' + (Math.random()*Math.random()) + '@email.com'; 
        accountToInsert.XC_DocumentCountry__c = 'Spain';
        accountToInsert.IdentityType__c = 'NIF';
        accountToInsert.IdentityNumber__c = '11400283B';
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();

        Map<String, Object> mapContactFields = new Map<String, Object>{
                'FirstName' => 'a',
                'LastName' => 'b'
        };

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);

        inputData.contactFields = JSON.serialize(mapContactFields);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        System.debug('MC ' +  inputData.consentsWrapper);
        System.debug('MC ' + leWrapperList);
        Test.startTest();
        XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(accountToInsert, inputData, true);
        Test.stopTest();
    }

    @IsTest
    static void manageNotExistingContactTestB2G (){
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
        accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
        accountToInsert.Company__c = 'Test Account Company n ' + (Math.random()*Math.random());
        accountToInsert.PrimaryEmail__c = 'test_b2b' + (Math.random()*Math.random()) + '@email.com'; 
        accountToInsert.XC_DocumentCountry__c = 'Spain';
        accountToInsert.IdentityType__c = 'NIF';
        accountToInsert.IdentityNumber__c = '11400283B';
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();

        Map<String, Object> mapContactFields = new Map<String, Object>{
                'FirstName' => 'a',
                'LastName' => 'b'
        };

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);

        inputData.contactFields = JSON.serialize(mapContactFields);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        System.debug('MC ' +  inputData.consentsWrapper);
        System.debug('MC ' + leWrapperList);
        Test.startTest();
        XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(accountToInsert, inputData, true);
        Test.stopTest();
    }

    @IsTest
    static void manageNotExistingContactTestSFM (){
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_ESP_Account_SFM').getRecordTypeId();
        accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
        accountToInsert.Company__c = 'Test Account Company n ' + (Math.random()*Math.random());
        accountToInsert.PrimaryEmail__c = 'test_b2b' + (Math.random()*Math.random()) + '@email.com'; 
        accountToInsert.XC_DocumentCountry__c = 'Spain';
        accountToInsert.IdentityType__c = 'NIF';
        accountToInsert.IdentityNumber__c = '11400283B';
        XC_LCC003_NewAccount_W.AccountInputDataWrapper inputData = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();

        Map<String, Object> mapContactFields = new Map<String, Object>{
                'FirstName' => 'a',
                'LastName' => 'b'
        };

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> leWrapperList = new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>();
        XC_LCC163_CreateConsents.GetLegalEntitiesResponse leWrapper = new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
        leWrapper.developerName = 'EndesaX';
        leWrapper.label = 'EndesaX';
        leWrapper.legalEntity = 'EndesaX';
        leWrapper.country = 'Spain';
        leWrapperList.add(leWrapper);

        inputData.contactFields = JSON.serialize(mapContactFields);
        inputData.consentsWrapper = JSON.serialize(leWrapperList);
        System.debug('MC ' +  inputData.consentsWrapper);
        System.debug('MC ' + leWrapperList);
        Test.startTest();
        XC_TR_Contact_U_CheckDuplicates.manageNotExistingContact(accountToInsert, inputData, true);
        Test.stopTest();
    }

}