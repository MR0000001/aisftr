@isTest
public without sharing class XC_LWCC002_PartnerManagement_TEST {

    @TestSetup
    static void makeData(){
        UserRole ceo = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User usCEO = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND UserRoleId =: ceo.Id LIMIT 1];
        System.runAs(usCEO){
            Account acc = createAccount();
            insert acc;
            acc.IsPartner = true;
            update acc;
            Contact cont = createContact(acc);
            cont.XC_PhonePrefix__c = '+39';
            cont.XC_ContactPhone__c = '3384942921';
            insert cont;
            Account accSpain = createAccountSpain();
            insert accSpain;
            accSpain.IsPartner = true;
            update accSpain;
            Contact contSpain = createContactSpain(accSpain);
            insert contSpain;
        }
        List<XC_CS009_SettingPartnerManagement__c> listOfCs = new List<XC_CS009_SettingPartnerManagement__c>();
        XC_CS009_SettingPartnerManagement__c customSettingPartnerManagement = new XC_CS009_SettingPartnerManagement__c();
        customSettingPartnerManagement.Name = 'TestCS';
        customSettingPartnerManagement.XC_Role__c = 'User + Venditore';
        customSettingPartnerManagement.XC_ProfileName__c = 'XC_ITA_SalesAgentPartner';
        customSettingPartnerManagement.XC_RoleGroup__c = 'User';
        customSettingPartnerManagement.XC_PermissionSetList__c = 'FSL Resource Permissions;FSL Resource License;FSL Self Service Permissions';
        customSettingPartnerManagement.XC_ServiceResourceType__c = 'T';
        customSettingPartnerManagement.XC_ServiceResourceCapacityBased__c = false;
        customSettingPartnerManagement.XC_LegalEntity__c = 'EnelXItalia';
        customSettingPartnerManagement.XC_Country__c = 'Italy';
        customSettingPartnerManagement.XC_ServiceResourceManager__c = false;
        listOfCs.add(customSettingPartnerManagement);
        XC_CS009_SettingPartnerManagement__c customSettingPartnerManagementSpain = new XC_CS009_SettingPartnerManagement__c();
        customSettingPartnerManagementSpain.Name = 'TestCSSpain';
        customSettingPartnerManagementSpain.XC_Role__c = 'Tecnico/comercial';
        customSettingPartnerManagementSpain.XC_ProfileName__c = 'XC_ESP_SalesAgentPartner';
        customSettingPartnerManagementSpain.XC_RoleGroup__c = 'User';
        customSettingPartnerManagementSpain.XC_PermissionSetList__c = 'FSL Resource Permissions;FSL Resource License;FSL Self Service Permissions';
        customSettingPartnerManagementSpain.XC_ServiceResourceType__c = 'T';
        customSettingPartnerManagementSpain.XC_ServiceResourceCapacityBased__c = false;
        customSettingPartnerManagementSpain.XC_LegalEntity__c = 'EndesaX';
        customSettingPartnerManagementSpain.XC_Country__c = 'Spain';
        customSettingPartnerManagementSpain.XC_ServiceResourceManager__c = false;
        listOfCs.add(customSettingPartnerManagementSpain);
        insert listOfCs;
        XC_CS010_SettPartnerManagementSkillWT__c customSettingPartnerManagementWT = new XC_CS010_SettPartnerManagementSkillWT__c();
        customSettingPartnerManagementWT.Name = 'TestCSWT';
        customSettingPartnerManagementWT.XC_SkillToImport__c = 'Installazione - Caldaia';
        customSettingPartnerManagementWT.XC_WorktypeNameList__c = 'Delivery & Installation - Boiler';
        customSettingPartnerManagementWT.XC_Country__c = 'Italy';
        insert customSettingPartnerManagementWT;
        XC_CS010_SettPartnerManagementSkillWT__c customSettingPartnerManagementWTAirCond = new XC_CS010_SettPartnerManagementSkillWT__c();
        customSettingPartnerManagementWTAirCond.Name = 'TestCSWTAir';
        customSettingPartnerManagementWTAirCond.XC_SkillToImport__c = 'Installazione - Air Conditioning';
        customSettingPartnerManagementWTAirCond.XC_WorktypeNameList__c = 'Delivery & Installation - Air Conditioning';
        customSettingPartnerManagementWTAirCond.XC_Country__c = 'Italy';
        insert customSettingPartnerManagementWTAirCond;
        XC_CS016_SettPartnerManWhitelistedGroup__c customSettingWhitelist = new XC_CS016_SettPartnerManWhitelistedGroup__c();
        customSettingWhitelist.Name = 'TestWhitelist';
        customSettingWhitelist.XC_GroupDeveloperName__c = 'EnelXItalia_Partner_Abruzzo'; 
        customSettingWhitelist.XC_LegalEntity__c = 'EnelXItalia';
        insert customSettingWhitelist;
        List<WorkType> listOfWt = new List<WorkType>();
        WorkType wtdeliveryAndInstBoiler = XC_DF_WorkType.createWorkTypeWithName('Delivery & Installation','Delivery & Installation - Boiler');
        WorkType wtdeliveryAndInstAirCond = XC_DF_WorkType.createWorkTypeWithName('Delivery & Installation','Delivery & Installation - Air Conditioning');
        wtdeliveryAndInstAirCond.XC_LegalEntity__c = 'EnelXItalia';
        wtdeliveryAndInstAirCond.XC_Segment__c = 'B2C';
        wtdeliveryAndInstBoiler.XC_LegalEntity__c = 'EnelXItalia';
        wtdeliveryAndInstBoiler.XC_Segment__c = 'B2C';
        listOfWt.add(wtdeliveryAndInstAirCond);
        listOfWt.add(wtdeliveryAndInstBoiler);
        insert listOfWt;
    }

    private static User createUsers(){
        UserRole ceo = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User usCEO = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND UserRoleId =: ceo.Id LIMIT 1];
        List<Contact> conts = [SELECT Id, Country__c FROM Contact WHERE Country__c in ('Italy', 'Spain')];
        List<Account> accs = [SELECT Id, Name FROM Account WHERE XC_DocumentCountry__c = 'Italy'];
        List<User> userToInsertList = new List<User>();
        System.runAs(usCEO){
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'XC_ITA_SalesAgentPartner' LIMIT 1];
            for(Contact cont : conts){
                if(cont.Country__c == 'Italy'){
                    User usItaly = XC_DF_User.createUserAdmin();
                    usItaly.ProfileId = profile.Id;
                    usItaly.Country__c = 'Italy';
                    usItaly.CompanyP__c = 'Italy';
                    usItaly.ContactId = cont.Id;
                    usItaly.XC_LegalEntity__c = 'EnelXItalia';
                    userToInsertList.add(usItaly);
                } else {
                    User usSpain = XC_DF_User.createUserAdmin();
                    usSpain.ProfileId = profile.Id;
                    usSpain.Username = 'pablo1234@gmail.com';  
                    usSpain.Country__c = 'Spain';
                    usSpain.CompanyP__c = 'Spain';
                    usSpain.ContactId = cont.Id;
                    usSpain.XC_LegalEntity__c = 'EndesaX';
                    userToInsertList.add(usSpain);
                }
            }
            insert userToInsertList;
        }
        return usCEO;
    }

    private static Account createAccount(){
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
        accountToInsert.PrimaryEmail__c = 'test_partner' + (Math.random()*Math.random()) + '@email.com';
        accountToInsert.XC_DocumentCountry__c = 'Italy';
        accountToInsert.IdentityType__c='Partita Iva';
        accountToInsert.IdentityNumber__c= 'IT893478197';
        return accountToInsert;
    }

    private static Account createAccountSpain(){
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
        accountToInsert.PrimaryEmail__c = 'test_partner' + (Math.random()*Math.random()) + '@email.com';
        accountToInsert.XC_DocumentCountry__c = 'Spain';
        accountToInsert.IdentityType__c='Passport';
        accountToInsert.IdentityNumber__c= '3424324332';
        return accountToInsert;
    }

    private static String createContactMap(){
        Map<String, Object> mapContactField = new Map<String, Object>();
        mapContactField.put('FirstName', 'Test Cont Part');
        mapContactField.put('LastName', 'Test Cont Part');
        mapContactField.put('Email', 'test@partner.email.com');
        mapContactField.put('XC_GiveDataTo__c',true);
        mapContactField.put('XC_GiveDataToThirdParties__c',true);
        mapContactField.put('XC_PrimaryContact__c',true);
        mapContactField.put('XC_TypeOfContact__c', 'Administrator');
        mapContactField.put('XC_PhonePrefix__c','+39');
        mapContactField.put('XC_ContactPhone__c','2314123212');
        mapContactField.put('Country__c','Italy');
        mapContactField.put('XC_CountryLegalEntity__c','Italy');
        mapContactField.put('XC_ContactDocumentCountry__c','Italy');
        mapContactField.put('XC_DocumentType__c', 'CF');
        mapContactField.put('XC_MainLegalEntity__c', 'EnelXItalia');
        mapContactField.put('XC_ContactDocumentNumber__c', 'TSTTTC80A01C352Q');
        String contactToInsert = JSON.serialize(mapContactField);
        return contactToInsert;
    }

    private static Contact createContact (Account acc){
        Contact cont = new Contact();
        cont.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId();
        cont.FirstName = 'TestUser';
        cont.LastName = 'testUserProva';
        cont.Email = 'test@partner.email.com';
        cont.XC_GiveDataToNew__c = 'Yes';
        cont.XC_GiveDataToThirdParties__c = 'Yes';
        cont.XC_PrimaryContact__c = true;
        cont.XC_TypeOfContact__c = 'Administrator';
        cont.XC_PhonePrefix__c = '+39';
        cont.XC_ContactPhone__c = '2314123212';
        cont.Country__c = 'Italy';
        cont.XC_CountryLegalEntity__c = 'Italy';
        cont.XC_ContactDocumentCountry__c = 'Italy';
        cont.XC_ContactDocumentType__c = 'CF';
        cont.XC_MainLegalEntity__c = 'EnelXItalia';
        cont.XC_ContactDocumentNumber__c = 'TSTTTS80A01F591O';
        cont.AccountId = acc.Id;
        cont.XC_Preferredlanguageofcontact__c = 'Italian';
        cont.XC_Segment__c = 'B2C';
        cont.CurrencyIsoCode = 'EUR';
        cont.XC_isGuestContact__c = 'No';
        return cont;
    }

    private static Contact createContactSpain (Account acc){
        Contact cont = new Contact();
        cont.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId();
        cont.FirstName = 'Test lwc Part Spain';
        cont.LastName = 'Test lwc PartSpain';
        cont.Email = 'testSpain@partner.email.com';
        cont.XC_GiveDataToNew__c = 'Yes';
        cont.XC_GiveDataToThirdParties__c = 'Yes';
        cont.XC_PrimaryContact__c = true;
        cont.XC_TypeOfContact__c = 'Administrator';
        cont.XC_PhonePrefix__c = '+34';
        cont.XC_ContactPhone__c = '619901750';
        cont.Country__c = 'Spain';
        cont.XC_CountryLegalEntity__c = 'Spain';
        cont.XC_ContactDocumentCountry__c = 'Spain';
        cont.XC_ContactDocumentType__c = 'Passport';
        cont.XC_MainLegalEntity__c = 'EndesaX';
        cont.XC_ContactDocumentNumber__c = '342312132';
        cont.AccountId = acc.Id;
        cont.XC_Preferredlanguageofcontact__c = 'Spanish';
        cont.XC_Segment__c = 'B2C';
        cont.CurrencyIsoCode = 'EUR';
        cont.XC_isGuestContact__c = 'No';
        return cont;
    }

    @isTest
    static void testUtilityMethod (){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id FROM Account]);
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        XC_LWCC002_PartnerManagement.loadExistingContact(listOfAcc[0]);
        XC_LWCC002_PartnerManagement.retrieveContactInfo(listOfCont[0].Id);
        XC_LWCC002_PartnerManagement.checkIfUserNeedToBeCreated(listOfCont[0].Id);
        XC_LWCC002_PartnerManagement.getPickListValuesRole();
        XC_LWCC002_PartnerManagement.getPickListValues('Contact', 'XC_ContactDocumentCountry__c');
    }

    @isTest
    static void testCreateContact(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        String contactToInsert = createContactMap();
        XC_LWCC002_PartnerManagement.createContactAndPersonalDocument(contactToInsert, listOfAcc[0]);
    }

    @isTest
    static void enableAsPartnerTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id FROM Account]);
        XC_LWCC002_PartnerManagement.enableAsPartner(listOfAcc[0]);
    }

    @isTest
    static void retrieveAndDeleteContactTest(){
        createUsers();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        XC_LWCC002_PartnerManagement.retrieveAndDeleteContact(listOfCont[0].Id);
    }

    @isTest
    static void editContactTest(){
        createUsers();
        List<Contact> listOfCont = new List<Contact>([SELECT Id, XC_ContactDocumentNumber__c, XC_ContactDocumentType__c FROM Contact WHERE Country__c =: 'Italy']);
        XC_PersonalDocument__c docCont = new XC_PersonalDocument__c();
        docCont.XC_DocumentNumber__c = listOfCont[0].XC_ContactDocumentNumber__c;
        docCont.XC_DocumentType__c = listOfCont[0].XC_ContactDocumentType__c;
        docCont.XC_Contact__c = listOfCont[0].Id;
        docCont.XC_Country__c = 'Italy';
        insert docCont;
        listOfCont[0].FirstName = 'Test Partner Cont';
        listOfCont[0].LastName = 'Test Partner Cont';
        listOfCont[0].XC_ContactDocumentNumber__c = 'TSTTTP80A01C352D';
        listOfCont[0].XC_ContactDocumentType__c = 'CF';
        listOfCont[0].XC_ContactDocumentCountry__c = 'Italy';
        listOfCont[0].Email = 'testpartner1@email.com';
        String contactToUpdate = JSON.serialize(listOfCont[0]);
        XC_LWCC002_PartnerManagement.editContact(listOfCont[0].Id, contactToUpdate);
    }

    @isTest
    static void createUserTest(){
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        Test.startTest();
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        XC_LWCC002_PartnerManagement.UserWrapper usrWrap = XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
        Test.stopTest();
    }

    @isTest
    static void createUserTestSpain(){
        User usCEO = createUsers();
        List<Account> accs = new List<Account>([SELECT Id FROM Account WHERE XC_DocumentCountry__c = 'Spain']);
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Spain']);
        Test.startTest();
        List<User> listOfUser = new List<User>([SELECT Id FROM User WHERE XC_LegalEntity__c =: 'EndesaX' and isactive = true]);
        System.runAs(listOfUser[0]){
            Map<String, String> mapStringToUser = new Map<String, String>();
            List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ESP_SalesAgentPartner']);
            mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
            mapStringToUser.put('Role', 'Tecnico/comercial');
            mapStringToUser.put('SubChannel', '322');
            String userToInsert = JSON.serialize(mapStringToUser);
            XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
            XC_LWCC002_PartnerManagement.createServiceTerritory(accs[0]);
        }
        Test.stopTest();
    }

    @isTest
    static void createServiceTerritoryTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        OperatingHours oh = XC_DF_OperatingHours.createOperatingHours('Standard Hours ITA');
        insert oh;
        XC_LWCC002_PartnerManagement.createServiceTerritory(listOfAcc[0]);
    }

    @isTest
    static void findServiceResourceToInsertTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
        XC_LWCC002_PartnerManagement.findServiceResourceToInsert(listOfAcc[0]);
    }

    @isTest
    static void createServiceResourceTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account WHERE XC_DocumentCountry__c = 'Italy']);
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        Test.startTest();
        XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
        List<User> listOfUser = new List<User>([SELECT Id FROM User WHERE Profile.Name =: 'System Administrator' AND Country__c =: 'Italy' AND XC_LegalEntity__c =: 'EnelXItalia' and isactive = true]);
        User us = listOfUser[0];
        System.runAs(us){
            List<String> listOfServResourceName = XC_LWCC002_PartnerManagement.findServiceResourceToInsert(listOfAcc[0]);
            Map<String, String> mapNameServResRole = new Map<String, String>();
            List<Map<String, String>> listMapString = new List<Map<String, String>>();
            for(String name : listOfServResourceName){
                mapNameServResRole.put('key',name);
                mapNameServResRole.put('value','User + Venditore');
                listMapString.add(mapNameServResRole);
            }
            String mapServiceResourceRole = JSON.serialize(listMapString);
            XC_LWCC002_PartnerManagement.createServiceResource(listOfAcc[0], listOfServResourceName, mapServiceResourceRole);
        }
        Test.stopTest();
    }

    @isTest
    static void createServiceResourceTestSpain(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account WHERE XC_DocumentCountry__c = 'Spain']);
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Spain']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ESP_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'Tecnico/comercial');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        Test.startTest();
        XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
        List<User> listOfUser = new List<User>([SELECT Id FROM User WHERE Profile.Name =: 'System Administrator' AND Country__c =: 'Spain' AND XC_LegalEntity__c =: 'EndesaX' and isactive = true]);
        User us = listOfUser[0];
        System.runAs(us){
            List<String> listOfServResourceName = XC_LWCC002_PartnerManagement.findServiceResourceToInsert(listOfAcc[0]);
            Map<String, String> mapNameServResRole = new Map<String, String>();
            List<Map<String, String>> listMapString = new List<Map<String, String>>();
            for(String name : listOfServResourceName){
                mapNameServResRole.put('key',name);
                mapNameServResRole.put('value','Tecnico/comercial');
                listMapString.add(mapNameServResRole);
            }
            String mapServiceResourceRole = JSON.serialize(listMapString);
            XC_LWCC002_PartnerManagement.createServiceResource(listOfAcc[0], listOfServResourceName, mapServiceResourceRole);
        }
        Test.stopTest();
    }

    @isTest
    static void openNextStepTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
        XC_LWCC002_PartnerManagement.openNextStep(listOfAcc[0]);
    }

    @isTest
    static void createServiceTerritoryMemberToInsertTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        Test.startTest();
        XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
        Test.stopTest();
        List<User> listOfUser = new List<User>([SELECT Id FROM User WHERE Profile.Name =: 'System Administrator' AND Country__c =: 'Italy' AND XC_LegalEntity__c =: 'EnelXItalia' AND Isactive = true]);
        User us = listOfUser[0];
        System.runAs(us){
            OperatingHours oh = XC_DF_OperatingHours.createOperatingHours('Standard Hours ITA');
            insert oh;
            XC_LWCC002_PartnerManagement.createServiceTerritory(listOfAcc[0]);
            List<String> listOfServResourceName = XC_LWCC002_PartnerManagement.findServiceResourceToInsert(listOfAcc[0]);
            Map<String, String> mapNameServResRole = new Map<String, String>();
            List<Map<String, String>> listMapString = new List<Map<String, String>>();
            for(String name : listOfServResourceName){
                mapNameServResRole.put('key',name);
                mapNameServResRole.put('value','User + Venditore');
                listMapString.add(mapNameServResRole);
            }
            String mapServiceResourceRole = JSON.serialize(listMapString);
            XC_LWCC002_PartnerManagement.createServiceResource(listOfAcc[0], listOfServResourceName, mapServiceResourceRole);
            XC_LWCC002_PartnerManagement.createServiceTerritoryMemberToInsert(listOfAcc[0]);
        }
    }

    @isTest
    static void loadGroupOfPartnerTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        List<Group> listOfGroup = new List<Group>();
        Group groupPartner = new Group();
        groupPartner.Name = listOfAcc[0].Name;
        listOfGroup.add(groupPartner);
        Group groupEnelXItalia = new Group();
        groupEnelXItalia.Name = 'EnelXItalia Warehouse';
        listOfGroup.add(groupEnelXItalia);
        insert listOfGroup;
        List<String> listOfGroupSelected = new List<String>{'EnelXItalia Warehouse'};
        List<User> usIta = [SELECT Id FROM User WHERE XC_LegalEntity__c = 'EnelXItalia' AND Profile.Name = 'System Administrator' AND isActive = true];
        System.runAs(usIta[0]){
            XC_LWCC002_PartnerManagement.loadGroupOfPartner(listOfAcc[0]);
            XC_LWCC002_PartnerManagement.insertUserToGroupMember(listOfAcc[0], listOfGroupSelected);
        }
    }

    @isTest
    static void createResourceShare(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        List<User> listOfUser = new List<User>([SELECT Id FROM User WHERE Profile.Name =: 'System Administrator' AND Country__c =: 'Italy' AND XC_LegalEntity__c =: 'EnelXItalia' AND Isactive = true]);
        User us = listOfUser[0];
        System.runAs(us){
            OperatingHours oh = XC_DF_OperatingHours.createOperatingHours('Standard Hours ITA');
            insert oh;
            XC_LWCC002_PartnerManagement.createServiceTerritory(listOfAcc[0]);
            List<String> listOfServResourceName = XC_LWCC002_PartnerManagement.findServiceResourceToInsert(listOfAcc[0]);
            Map<String, String> mapNameServResRole = new Map<String, String>();
            List<Map<String, String>> listMapString = new List<Map<String, String>>();
            for(String name : listOfServResourceName){
                mapNameServResRole.put('key',name);
                mapNameServResRole.put('value','User + Venditore');
                listMapString.add(mapNameServResRole);
            }
            String mapServiceResourceRole = JSON.serialize(listMapString);
            XC_LWCC002_PartnerManagement.createServiceResource(listOfAcc[0], listOfServResourceName, mapServiceResourceRole);
            XC_LWCC002_PartnerManagement.checkAndCreateServiceResourceShare(listOfAcc[0]);
        }
    }

    @isTest
    static void loadValueAndServiceResourceForSkillManagementTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account WHERE XC_DocumentCountry__c = 'Italy']);
        List<Contact> listOfCont = new List<Contact>([SELECT Id, Name FROM Contact WHERE Country__c =: 'Italy']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        Test.startTest();
        XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
        Test.stopTest();
        List<User> listOfUser = new List<User>([SELECT Id FROM User WHERE Profile.Name =: 'System Administrator' AND Country__c =: 'Italy' AND XC_LegalEntity__c =: 'EnelXItalia' AND IsActive = true]);
        User us = listOfUser[0];
        System.runAs(us){
            OperatingHours oh = XC_DF_OperatingHours.createOperatingHours('Standard Hours ITA');
            insert oh;
            XC_LWCC002_PartnerManagement.createServiceTerritory(listOfAcc[0]);
            List<String> listOfServResourceName = XC_LWCC002_PartnerManagement.findServiceResourceToInsert(listOfAcc[0]);
            Map<String, String> mapNameServResRole = new Map<String, String>();
            List<Map<String, String>> listMapString = new List<Map<String, String>>();
            for(String name : listOfServResourceName){
                mapNameServResRole.put('key', name);
                mapNameServResRole.put('value','User + Venditore');
                listMapString.add(mapNameServResRole);
            }
            String mapServiceResourceRole = JSON.serialize(listMapString);
            XC_LWCC002_PartnerManagement.createServiceResource(listOfAcc[0], listOfServResourceName, mapServiceResourceRole);
            XC_LWCC002_PartnerManagement.loadValueAndServiceResourceForSkillManagement(listOfAcc[0]);
        }
    }

    @isTest
    static void createServiceResourceSkillTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        List<Contact> listOfCont = new List<Contact>([SELECT Id, Name, Account.Name FROM Contact WHERE Country__c =: 'Italy']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        List<User> listOfUser = new List<User>([SELECT Id FROM User WHERE Profile.Name =: 'System Administrator' AND Country__c =: 'Italy' AND XC_LegalEntity__c =: 'EnelXItalia' AND IsActive = true]);
        User us = listOfUser[0];
        System.runAs(us){
            OperatingHours oh = XC_DF_OperatingHours.createOperatingHours('Standard Hours ITA');
            insert oh;
            XC_LWCC002_PartnerManagement.createServiceTerritory(listOfAcc[0]);
            List<String> listOfServResourceName = XC_LWCC002_PartnerManagement.findServiceResourceToInsert(listOfAcc[0]);
            Map<String, String> mapNameServResRole = new Map<String, String>();
            List<Map<String, String>> listMapString = new List<Map<String, String>>();
            Map<String, String> mapNameServResWT = new Map<String, String>();
            List<Map<String, String>> listMapStringWT = new List<Map<String, String>>();
            for(String name : listOfServResourceName){
                mapNameServResRole.put('key', name);
                mapNameServResRole.put('value','User + Venditore');
                mapNameServResWT.put('key', name + ' - ' + listOfCont[0].Account.Name);
                mapNameServResWT.put('value','Installazione - Caldaia');
                listMapStringWT.add(mapNameServResWT);
                listMapString.add(mapNameServResRole);
            }
            Skill skillDeliveryInstallation = [SELECT Id FROM Skill WHERE DeveloperName = 'Delivery_Installation' LIMIT 1];
            List<SkillRequirement> listSkillRequirement= new List<SkillRequirement>(); 
            List<WorkType> listOfWt = [SELECT Id FROM WorkType];
            for(WorkType wt : listOfWt){
                SkillRequirement skillreq = new SkillRequirement();
                skillreq.SkillId = skillDeliveryInstallation.Id;
                skillreq.SkillLevel = 1;
                skillreq.RelatedRecordId = wt.Id;
                listSkillRequirement.add(skillreq);
            }
            insert listSkillRequirement;
            String mapServiceResourceRole = JSON.serialize(listMapString);
            String mapServiceResourceSkill = JSON.serialize(listMapStringWT);
            XC_LWCC002_PartnerManagement.NextStepWrapper nsw = XC_LWCC002_PartnerManagement.createServiceResource(listOfAcc[0], listOfServResourceName, mapServiceResourceRole);
            XC_LWCC002_PartnerManagement.createServiceResourceSkill(listOfAcc[0], mapServiceResourceSkill);
            if(listOfServResourceName.size() > 0){
                mapNameServResWT.put('key',listOfServResourceName[0]);
                mapNameServResWT.put('value','Installazione - Air Conditioning');
            }
            listMapStringWT.add(mapNameServResWT);
            mapServiceResourceSkill = JSON.serialize(listMapStringWT);
            XC_LWCC002_PartnerManagement.createServiceResourceSkill(listOfAcc[0], mapServiceResourceSkill);
        }
    }

    @isTest
    static void deleteUserFromFSLDefaultTest(){
        createUsers();
        List<Account> listOfAcc = new List<Account>([SELECT Id, Name FROM Account]);
        List<Group> listOfGroup = new List<Group>();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact WHERE Country__c =: 'Italy']);
        Map<String, String> mapStringToUser = new Map<String, String>();
        List<Profile> listOfProf = new List<Profile>([SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner']);
        mapStringToUser.put('XC_Receiving_Channel__c', 'Agency');
        mapStringToUser.put('Role', 'User + Venditore');
        mapStringToUser.put('SubChannel', '322');
        String userToInsert = JSON.serialize(mapStringToUser);
        Test.startTest();
        XC_LWCC002_PartnerManagement.createUser(userToInsert, listOfCont[0].Id);
        Test.stopTest();
        List<User> listOfUser = new List<User>([SELECT Id FROM User WHERE Profile.Name =: 'System Administrator' AND Country__c =: 'Italy' AND XC_LegalEntity__c =: 'EnelXItalia' AND IsActive = true]);
        User us = listOfUser[0];
        System.runAs(us){
            Group groupPartner = new Group();
            groupPartner.Name = listOfAcc[0].Name;
            listOfGroup.add(groupPartner);
            Group groupEnelXItalia = new Group();
            groupEnelXItalia.Name = 'FIELD_SERVICE_Defaul';
            listOfGroup.add(groupEnelXItalia);
            insert listOfGroup;
            List<String> listOfServResourceName = XC_LWCC002_PartnerManagement.findServiceResourceToInsert(listOfAcc[0]);
            Map<String, String> mapNameServResRole = new Map<String, String>();
            List<Map<String, String>> listMapString = new List<Map<String, String>>();
            for(String name : listOfServResourceName){
                mapNameServResRole.put('key',name);
                mapNameServResRole.put('value','User + Venditore');
                listMapString.add(mapNameServResRole);
            }
            String mapServiceResourceRole = JSON.serialize(listMapString);
            XC_LWCC002_PartnerManagement.createServiceResource(listOfAcc[0], listOfServResourceName, mapServiceResourceRole);
            XC_LWCC002_PartnerManagement.deleteUserFromFieldServiceDefault(listOfAcc[0]);
        }
    }

    @isTest
    static void testErrors(){
        XC_LWCC002_PartnerManagement.createServiceTerritoryMemberToInsert(new Account(Name = 'Test'));
    }
}