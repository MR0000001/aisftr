public without sharing class XC_LWCC002_PartnerManagement {
    /** @description WrapperResult */
    public class ContactWrapper{ 
        @AuraEnabled
        public Contact contactInserted = new Contact();
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String errorMessage = '';
    } 

    public class AccountWrapper{ 
        @AuraEnabled
        public Account accountUpdated = new Account();
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String errorMessage = '';
    } 

    public class UserWrapper{ 
        @AuraEnabled
        public User userCreated = new User();
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String errorMessage = '';
        @AuraEnabled 
        public Boolean showUsernameBox = false;
    }
    public class NextStepWrapper{ 
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String errorMessage = '';
        @AuraEnabled
        public List<ServiceResource> listOfServiceResource = new List<ServiceResource>();
    } 


    public class SkillServiceResourceWrapper{ 
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String errorMessage = '';
        @AuraEnabled
        public List<ServiceResource> listOfServiceResource = new List<ServiceResource>();
        @AuraEnabled
        public List<String> allSkill = new List<String>();
        @AuraEnabled
        public Map<String, List<String>> mapServiceResourceToSkills = new Map<String, List<String>>();
        @AuraEnabled
        public Boolean skipStep = false;
    } 

    public class GroupWrapper{
        @AuraEnabled
        public List<String> toAddGroups;
        @AuraEnabled
        public List<String> addedGroups;
    
        public GroupWrapper(Set<String> toAdd, Set<String> added){
            this.toAddGroups = new List<String>(toAdd);
            this.addedGroups = new List<String>(added);
        }
    }


    @AuraEnabled(cacheable=true)

    public static List <Map< String, String >> getPickListValues(String objApiName, String fieldName) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
        Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map < String, String > values = new Map < String, String > {
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            options.add(values);
        }
        return options;
    }

    @AuraEnabled
    public static ContactWrapper createContactAndPersonalDocument(String contactToInsert, Account accountFound) {
        ContactWrapper wrap = new ContactWrapper();
        Map<String, Object> mapContactField = (Map<String, Object>)JSON.deserializeUntyped(contactToInsert);
        Contact conToInsert =  populateContactField(mapContactField, accountFound);
        List<Contact> listOfContact = new List<Contact>([SELECT Id FROM Contact WHERE XC_ContactDocumentNumber__c =: conToInsert.XC_ContactDocumentNumber__c]);
        if(!listOfContact.isEmpty()){
            wrap.success = false;
            wrap.errorMessage = Label.XC_CL_PartnerManagement_ContactAlreadyExists;
            return wrap;
        }
        XC_UTIL_Sobject.WrapperResult wrapContact = XC_UTIL_Sobject.insertRecord(conToInsert);
        if(!wrapContact.success){
            wrap.success = wrapContact.success;
            wrap.errorMessage = wrapContact.errorMessage;
            return wrap;
        }
        if(conToInsert.XC_PrimaryContact__c){
            Account accountToUpdatePrimaryCont = new Account (Id = accountFound.Id, XC_ESP_Account_PrimaryContact__c = conToInsert.Id);
            XC_UTIL_Sobject.updateRecord(accountToUpdatePrimaryCont);
        }
        wrap.contactInserted = conToInsert;
        wrap.success = true;
        return wrap;
    }

    public static Contact populateContactField(Map<String, Object> mapContactField, Account account){
        Contact contactToInsert = new Contact();
        String recordTypeIdContact = '';
        recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId();
        contactToInsert.RecordTypeId = recordTypeIdContact;
        contactToInsert.FirstName = (String)mapContactField.get('FirstName');
        contactToInsert.LastName = (String)mapContactField.get('LastName');
        contactToInsert.Email = (String)mapContactField.get('Email');
        contactToInsert.XC_TypeOfContact__c = (String)mapContactField.get('XC_TypeOfContact__c');
        contactToInsert.XC_PhonePrefix__c = (String)mapContactField.get('XC_PhonePrefix__c');
        contactToInsert.XC_ContactPhone__c = (String)mapContactField.get('XC_ContactPhone__c');
        contactToInsert.Country__c = (String)mapContactField.get('XC_ContactDocumentCountry__c');
        contactToInsert.XC_CountryLegalEntity__c = (String)mapContactField.get('XC_ContactDocumentCountry__c');
        contactToInsert.XC_ContactDocumentType__c = (String)mapContactField.get('XC_DocumentType__c');
        contactToInsert.XC_ContactDocumentCountry__c = (String)mapContactField.get('XC_ContactDocumentCountry__c');
        contactToInsert.XC_ContactDocumentNumber__c = (String)mapContactField.get('XC_ContactDocumentNumber__c');
        Boolean giveDataToNewBoolean =(Boolean)mapContactField.get('XC_GiveDataTo__c');
        giveDataToNewBoolean = giveDataToNewBoolean == null ? false : true;
        contactToInsert.XC_GiveDataToNew__c = giveDataToNewBoolean ? 'Yes' : 'No';
        Boolean giveDataToThirdPartiesBoolean = (Boolean)mapContactField.get('XC_GiveDataToThirdParties__c');
        giveDataToThirdPartiesBoolean = giveDataToThirdPartiesBoolean == null ? false : true; 
        contactToInsert.XC_GiveDataToThirdParties__c = giveDataToThirdPartiesBoolean ? 'Yes' : 'No';
        contactToInsert.XC_MainLegalEntity__c = (String)mapContactField.get('XC_MainLegalEntity__c');
        contactToInsert.XC_PrimaryContact__c = (Boolean)mapContactField.get('XC_PrimaryContact__c') == null ? false : (Boolean)mapContactField.get('XC_PrimaryContact__c');
        contactToInsert.XC_Segment__c = 'B2C';
        contactToInsert.CurrencyIsoCode = 'EUR';
        contactToInsert.XC_isGuestContact__c = 'No';
        contactToInsert.AccountId = account.Id;
        contactToInsert.XC_Preferredlanguageofcontact__c = 'Italian';
        return contactToInsert;
        
    }

    @AuraEnabled
    public static List<Contact> loadExistingContact (Account accountFound){
        List<Contact> listOfContact = new List<Contact>();
        listOfContact = [SELECT Id, RecordTypeId, FirstName, LastName, Email, XC_TypeOfContact__c, XC_PhonePrefix__c, XC_ContactPhone__c, Country__c, XC_CountryLegalEntity__c, XC_ContactDocumentType__c, XC_ContactDocumentCountry__c, XC_ContactDocumentNumber__c, XC_GiveDataToNew__c, XC_GiveDataToThirdParties__c, XC_MainLegalEntity__c, XC_PrimaryContact__c, XC_Segment__c, CurrencyIsoCode, XC_isGuestContact__c, AccountId, XC_Preferredlanguageofcontact__c, (SELECT id, XC_Receiving_Channel__c, Username, XC_SubChannel__c FROM Users) FROM Contact WHERE AccountId =: accountFound.Id ORDER BY CreatedDate desc];
        return listOfContact;
    }

    @AuraEnabled
    public static AccountWrapper enableAsPartner(Account accountFound){
        AccountWrapper wrap = new AccountWrapper();
        List<User> listOfUser = new List<User>([SELECT Id, XC_LegalEntity__c FROM User WHERE Id =: UserInfo.getUserId()]);
        List<Contact> listOfContact = new List<Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE XC_PrimaryContact__c =: true AND AccountId =: accountFound.Id]);
        Account accountToUpdate = new Account(Id = accountFound.Id);
        accountToUpdate.XC_PartnerType__c = 'Field Service';
        accountToUpdate.IsPartner = true;
        if(listOfUser[0].XC_LegalEntity__c.equals('EndesaX')){
            accountToUpdate.XC_GiveDataTo_EndesaX__c = true;
        }else if (listOfUser[0].XC_LegalEntity__c.equals('EnelXItalia')){
            accountToUpdate.XC_GiveDataTo_EnelXItalia__c = true;
        }
        if(!listOfContact.isEmpty()){
            accountToUpdate.XC_ESP_Account_PrimaryContact__c = listOfContact[0].Id;
        }
        XC_UTIL_Sobject.WrapperResult wrapAccount = XC_UTIL_Sobject.updateRecord(accountToUpdate);
        if(!wrapAccount.success){
            wrap.success = wrapAccount.success;
            wrap.errorMessage = wrapAccount.errorMessage;
            return wrap;
        }
        wrap.success = true;
        wrap.accountUpdated = accountToUpdate;
        return wrap;
    }

    @AuraEnabled
    public static ContactWrapper retrieveAndDeleteContact(String contactToSearchId){
        ContactWrapper wrap = new ContactWrapper();
        List<Contact> listOfContact = new List<Contact>([SELECT Id FROM Contact WHERE Id =: contactToSearchId]);      
        XC_UTIL_Sobject.WrapperResult wrapContact = XC_UTIL_SObject.deleteRecord(listOfContact[0]);
        if(!wrapContact.success){
            wrap.success = wrapContact.success;
            wrap.errorMessage = wrapContact.errorMessage;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static Contact retrieveContactInfo(String contactToSearchId){
        List<Contact> listOfContact = new List<Contact>([SELECT Id, FirstName, LastName, Email, XC_TypeOfContact__c, XC_PhonePrefix__c, XC_ContactPhone__c, XC_ContactDocumentCountry__c, XC_ContactDocumentNumber__c, XC_ContactDocumentType__c, XC_PrimaryContact__c, XC_GiveDataToNew__c, XC_GiveDataToThirdParties__c, XC_MainLegalEntity__c FROM Contact WHERE Id =: contactToSearchId]);     
        return listOfContact[0];
    }

    @AuraEnabled
    public static ContactWrapper editContact(String contactToUpdateId, String contactToUpdate){
        ContactWrapper wrap = new ContactWrapper();
        Contact contactToUpdateOb = (Contact)JSON.deserialize(contactToUpdate, Contact.class);
        contactToUpdateOb.Id = contactToUpdateId;
        List<Contact> listOfContPreUpdate = new List<Contact>([SELECT Id, XC_ContactDocumentNumber__c, XC_ContactDocumentType__c, XC_ContactDocumentCountry__c FROM Contact WHERE Id =: contactToUpdateId]);
        XC_UTIL_Sobject.WrapperResult wrapContact = XC_UTIL_Sobject.updateRecord(contactToUpdateOb);
        if(!wrapContact.success){
            wrap.success = wrapContact.success;
            wrap.errorMessage = wrapContact.errorMessage;
            return wrap;
        }
        if(contactToUpdateOb.XC_ContactDocumentNumber__c != null){
            List<XC_PersonalDocument__c> listOfDocument = new List<XC_PersonalDocument__c> ([SELECT Id, XC_DocumentNumber__c, XC_DocumentType__c, XC_Country__c FROM XC_PersonalDocument__c WHERE XC_Contact__c =: contactToUpdateOb.Id AND XC_DocumentNumber__c =: listOfContPreUpdate[0].XC_ContactDocumentNumber__c]);
            if(!listOfDocument.isEmpty()){
                listOfDocument[0].XC_DocumentNumber__c = contactToUpdateOb.XC_ContactDocumentNumber__c;
                if(contactToUpdateOb.XC_ContactDocumentType__c != null){
                    listOfDocument[0].XC_DocumentType__c = contactToUpdateOb.XC_ContactDocumentType__c;
                }
                if(contactToUpdateOb.XC_ContactDocumentCountry__c != null){
                    listOfDocument[0].XC_Country__c = contactToUpdateOb.XC_ContactDocumentCountry__c;
                }
                XC_UTIL_Sobject.WrapperResult wrapPersonalDocument = XC_UTIL_Sobject.updateRecord(listOfDocument[0]);
                if(!wrapPersonalDocument.success){
                    wrap.success = wrapPersonalDocument.success;
                    wrap.errorMessage = wrapPersonalDocument.errorMessage;
                    return wrap;
                }
            }
        }
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static UserWrapper checkIfUserNeedToBeCreated(String contactId){
        UserWrapper wrap = new UserWrapper();
        List<User> listofUser = new List<User>([SELECT Id FROM User WHERE ContactId =: contactId]);
        if(!listofUser.isEmpty()){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_UserAlreadyExists;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static List <Map<String, String>> getPickListValuesRole(){
        List <Map<String, String>> listOfMapLabelValueRoleUser = new List <Map<String, String>>();
      
        List<User> listOfUser = new List<User>([SELECT Id, XC_LegalEntity__c, Country__c FROM User WHERE Id =: UserInfo.getUserId()]);
        User runningUser = listOfUser[0];
        List<XC_CS009_SettingPartnerManagement__c> listOfCustomSetting = new List<XC_CS009_SettingPartnerManagement__c>([SELECT Id, XC_Role__c FROM XC_CS009_SettingPartnerManagement__c WHERE XC_LegalEntity__c =: runningUser.XC_LegalEntity__c AND XC_Country__c =: runningUser.Country__c]);
        for(XC_CS009_SettingPartnerManagement__c cs : listOfCustomSetting){
            Map <String,String > values = new Map <String,String> {
                'label' => cs.XC_Role__c,
                'value' => cs.XC_Role__c
            };
            listOfMapLabelValueRoleUser.add(values);
        }
        return listOfMapLabelValueRoleUser;
    }

    @AuraEnabled
    public static UserWrapper createUser(String userToInsert, String contactIdForUser){
        UserWrapper wrap = new UserWrapper();
        String countryRunningUser = '';
        List<Contact> listOfContactRelatedToUser = new List<Contact>([SELECT Id, Email, FirstName, LastName, XC_ContactDocumentNumber__c, XC_ContactPhone__c, AccountId FROM Contact WHERE Id =: contactIdForUser]);
        if(listOfContactRelatedToUser.isEmpty()){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoContactFound;
            return wrap;
        }
        Map<String, String> mapUserRecevingChannelRole = (Map<String,String>) JSON.deserialize(userToInsert, Map<String, String>.class);
        List<User> listOfUser = new List<User>([SELECT Id, XC_LegalEntity__c, CompanyP__c, Country__c FROM User WHERE Id =: UserInfo.getUserId()]);
        List<XC_CM_LegalEntity_Configuration__mdt> listOfOrgId = new List<XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_LegalEntity__c, XC_Stream__c,  XC_OrgName__c, XC_OrgId__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: listOfUser[0].XC_LegalEntity__c AND XC_Stream__c = 'B2C' AND XC_OrgId__c =: UserInfo.getOrganizationId()]);
        List<XC_CS009_SettingPartnerManagement__c> listOfCustomSetting = new List<XC_CS009_SettingPartnerManagement__c>([SELECT Id, XC_Role__c, XC_ProfileName__c, XC_RoleGroup__c, XC_PermissionSetList__c FROM XC_CS009_SettingPartnerManagement__c WHERE XC_LegalEntity__c =: listOfUser[0].XC_LegalEntity__c AND XC_Country__c =: listOfUser[0].Country__c AND XC_Role__c =: mapUserRecevingChannelRole.get('Role')]);
        User userToInsertObj = new User ();
        String orgNameEmail = calculateOrgName (listOfOrgId[0]);
        if(listOfUser[0].Country__c == null ){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoCountryOnUser;
            return wrap;
        }
        if(listOfUser[0].Country__c.toLowerCase().equals('spain')){
            countryRunningUser = 'Spain';
        }else if (listOfUser[0].Country__c.toLowerCase().equals('italy')){
            countryRunningUser = 'Italy';
        }
        if(String.isBlank(listOfContactRelatedToUser[0].Email)){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_EmailNotPopulated;
            return wrap;
        }
        userToInsertObj = populateUser (listOfContactRelatedToUser[0], orgNameEmail, mapUserRecevingChannelRole, listOfUser[0],  countryRunningUser, listOfCustomSetting);
        List<User> listOfExistingUser = new List<User>();
        if(userToInsertObj.UserName != null && userToInsertObj.UserName != ''){
            listOfExistingUser = [SELECT Id FROM User WHERE Username =: userToInsertObj.UserName];
        }
        if(!listOfExistingUser.isEmpty()){
            wrap.showUsernameBox = true;
            wrap.errorMessage = 'Another User with this Username already exist, please select a different username for this user';
            return wrap;
        }
        XC_UTIL_Sobject.WrapperResult wrapUser = XC_UTIL_Sobject.insertRecord(userToInsertObj);
        if(!wrapUser.success){
            wrap.success = wrapUser.success;
            wrap.errorMessage = wrapUser.errorMessage;
            return wrap;
        }
        if(listOfCustomSetting.isEmpty()){
            return wrap;
        }
        List<UserRole> listOfUserRole = new List<UserRole> ([SELECT Id, Name FROM UserRole WHERE PortalAccountId =: listOfContactRelatedToUser[0].AccountId]);
        userToInsertObj.UserRoleId =  findUserRole(listOfUserRole, listOfCustomSetting[0].XC_RoleGroup__c);
        wrapUser = XC_UTIL_Sobject.updateRecord(userToInsertObj);
        if(!wrapUser.success){
            wrap.success = wrapUser.success;
            wrap.errorMessage = wrapUser.errorMessage;
            return wrap;
        }
        List<PermissionSet> listOfPermissionSet = new List<PermissionSet>();
        List<String> permissionSetListFromCustomSetting = listOfCustomSetting[0].XC_PermissionSetList__c.split(';');
        if(countryRunningUser.equals('Italy')){
            listOfPermissionSet = [SELECT Id FROM PermissionSet WHERE Label IN: permissionSetListFromCustomSetting];
        }else if(countryRunningUser.equals('Spain')){
            listOfPermissionSet = [SELECT Id FROM PermissionSet WHERE Label IN: permissionSetListFromCustomSetting];
        }
        List<PermissionSetAssignment> listOfPermissionSetAssignment = new List<PermissionSetAssignment>();
        for(PermissionSet permSet : listOfPermissionSet){
            PermissionSetAssignment permSetAssignment = new PermissionSetAssignment();
            permSetAssignment.AssigneeId = userToInsertObj.Id;
            permSetAssignment.PermissionSetId = permSet.Id;
            listOfPermissionSetAssignment.add(permSetAssignment);
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapPermissionSetList = XC_UTIL_Sobject.insertListRecords(listOfPermissionSetAssignment);
        if(!XC_UTIL_Sobject.checkDMLResults(wrapPermissionSetList)){
            wrap.success = wrapPermissionSetList[0].success;
            wrap.errorMessage = wrapPermissionSetList[0].errorMessage;
            return wrap;
        }
        wrap.success = true;
        wrap.userCreated = userToInsertObj;
        return wrap;
    }

    private static String calculateOrgName (XC_CM_LegalEntity_Configuration__mdt metaDataOfOrg){
        String orgNameEmail = '';
        if(metaDataOfOrg.XC_OrgName__c != null && metaDataOfOrg.XC_OrgName__c.toLowerCase().contains('dev')){
            orgNameEmail = '@exdevhub.com';
        }else if (metaDataOfOrg.XC_OrgName__c != null && metaDataOfOrg.XC_OrgName__c.toLowerCase().contains('uat')){
            orgNameEmail = '@exuat.com';
        }else if (metaDataOfOrg.XC_OrgName__c != null && metaDataOfOrg.XC_OrgName__c.toLowerCase().contains('prod')){
            orgNameEmail = '@exprod.com';
        }
        return orgNameEmail;
    }

    private static User populateUser (Contact contactRelated, String orgNameEmail, Map<String, String> mapReceivingChannelAndRole, User runningUser, String countryRunningUser,  List<XC_CS009_SettingPartnerManagement__c> listOfCustomSetting){
        User userToInsert = new User();
        userToInsert.UserName = mapReceivingChannelAndRole.get('Username') != null ? mapReceivingChannelAndRole.get('Username') : contactRelated.Email.substringBefore('@') + orgNameEmail; 
        userToInsert.FirstName = contactRelated.FirstName;
        userToInsert.LastName = contactRelated.LastName;
        userToInsert.XC_Document_Number__c = contactRelated.XC_ContactDocumentNumber__c;
        userToInsert.MobilePhone = contactRelated.XC_ContactPhone__c;
        userToInsert.Email = contactRelated.Email;
        userToInsert.Alias = contactRelated.FirstName.subString(0,1) + contactRelated.LastName.subString(0,3);
        userToInsert.ContactId = contactRelated.Id;
        userToInsert.XC_AccountId__c = contactRelated.AccountId;
        userToInsert.TimeZoneSidKey = 'Europe/Rome';
        if(countryRunningUser.equals('Italy')){
            List<Profile> listOfProfile = new List<Profile>();
            if(listOfCustomSetting.isEmpty()){
                listOfProfile = [SELECT Id FROM Profile WHERE Name =: 'XC_ITA_SalesAgentPartner'];
            }else{
                 listOfProfile = [SELECT Id FROM Profile WHERE Name =: listOfCustomSetting[0].XC_ProfileName__c];
            }
            userToInsert.LocaleSidKey  = 'it_IT';
            userToInsert.LanguageLocaleKey  = 'it';
            userToInsert.CompanyP__c  = 'Italy';
            userToInsert.Country__c  = 'Italy';
            userToInsert.Company__c  = 'Italy';
            userToInsert.XC_LegalEntity__c  = runningUser.XC_LegalEntity__c;
            userToInsert.XC_LegalEntities__c  = runningUser.XC_LegalEntity__c;
            //userToInsert.UserRoleId =  findUserRole(listOfUserRole, listOfCustomSetting[0].XC_RoleGroup__c);
            userToInsert.ProfileId = !listOfProfile.isEmpty() ? listOfProfile[0].Id : ''; 
        } else if (countryRunningUser.equals('Spain')){
            List<Profile> listOfProfile = new List<Profile>();
            if(listOfCustomSetting.isEmpty()){
                listOfProfile = [SELECT Id FROM Profile WHERE Name =: 'XC_ESP_SalesAgentPartner'];
            }else{
                 listOfProfile = [SELECT Id FROM Profile WHERE Name =: listOfCustomSetting[0].XC_ProfileName__c];
            }
            userToInsert.LocaleSidKey  = 'es_ES';
            userToInsert.LanguageLocaleKey  = 'es';
            userToInsert.CompanyP__c  = 'Spain';
            userToInsert.Country__c  = 'Spain';
            userToInsert.Company__c  = 'Spain';
            userToInsert.XC_LegalEntity__c  = runningUser.XC_LegalEntity__c;
            userToInsert.XC_LegalEntities__c  = runningUser.XC_LegalEntity__c;
            //userToInsert.UserRoleId =   findUserRole(listOfUserRole, listOfCustomSetting[0].XC_RoleGroup__c);
            userToInsert.ProfileId = !listOfProfile.isEmpty() ? listOfProfile[0].Id : ''; 
        }
        userToInsert.DefaultCurrencyIsoCode  = 'EUR';
        userToInsert.CurrencyIsoCode  = 'EUR';
        userToInsert.XC_Businessline__c  = 'e-Home';
        userToInsert.IsActive  = true;
        userToInsert.EmailEncodingKey  = 'ISO-8859-1';
        userToInsert.XC_Receiving_Channel__c  = mapReceivingChannelAndRole.get('XC_Receiving_Channel__c');
        userToInsert.XC_X_Customer_User__c  = true;
        userToInsert.ReceivesAdminInfoEmails  = true;
        userToInsert.UserPreferencesDisableLikeEmail = true;
        userToInsert.UserPreferencesSortFeedByComment = true;
        userToInsert.UserPreferencesShowTitleToExternalUsers = true;
        userToInsert.UserPreferencesLightningExperiencePreferred = true;
        userToInsert.UserPreferencesHideSfxWelcomeMat = true;
        userToInsert.XC_EnabledToSkip__c = false;
        userToInsert.XC_SubChannel__c = mapReceivingChannelAndRole.get('SubChannel');
        return userToInsert;
    }

    private static String findUserRole (List<UserRole> listOfUserRole, String role){
        String userRoleId = '';
        for(UserRole usRole : listOfUserRole){
            if(usRole.Name.contains(role)){
                userRoleId = usRole.Id;
                break;
            }
        }
        return userRoleId;
    }

    @AuraEnabled
    public static NextStepWrapper createServiceTerritory (Account accountFound){
        NextStepWrapper wrap = new NextStepWrapper();
        if(accountFound == null || String.isBlank(accountFound.Id)){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoAccountFound;
            return wrap;
        }
        List<ServiceTerritory> listOfServiceTerritory = new List<ServiceTerritory>([SELECT Id FROM ServiceTerritory WHERE XC_AccountId__c =: accountFound.Id]);
        if(!listOfServiceTerritory.isEmpty()){
            wrap.success = true;
            return wrap;
        }
        List<User> listOfUser = new List<User>([SELECT Id, XC_LegalEntity__c, CompanyP__c, Country__c FROM User WHERE Id =: UserInfo.getUserId()]);
        String operatingHours = '';
        String country = '';
        if(!listOfUser.isEmpty()){   
            if(listOfUser[0].Country__c.toLowerCase().equals('spain')){
                List<OperatingHours> listOfOperatingHours = new List<OperatingHours>([
                    SELECT Id FROM OperatingHours WHERE Name =: 'HORARIO MANUEL RUIZ'
                ]);
                if(listOfOperatingHours.isEmpty()){
                    wrap.success = false;
                    wrap.errorMessage = Label.XC_CL_PartnerManagement_NoOperatingHoursESP;
                    return wrap;
                }
                operatingHours = listOfOperatingHours[0].Id;
                country = 'Spain';
            } else if (listOfUser[0].Country__c.toLowerCase().equals('italy')){
                List<OperatingHours> listOfOperatingHours = new List<OperatingHours>([
                    SELECT Id FROM OperatingHours WHERE Name =: 'Standard Hours ITA'
                ]);
                if(listOfOperatingHours.isEmpty()){
                    wrap.success = false;
                    wrap.errorMessage = Label.XC_CL_PartnerManagement_NoOperatingHoursITA;
                    return wrap;
                }
                operatingHours = listOfOperatingHours[0].Id;
                country = 'Italy';
            }
        }
        ServiceTerritory serviceTerritoryToInsert = new ServiceTerritory();
        serviceTerritoryToInsert.Name = accountFound.Name;
        serviceTerritoryToInsert.OperatingHoursId = operatingHours;
        serviceTerritoryToInsert.XC_AccountId__c = accountFound.Id;
        serviceTerritoryToInsert.isActive = true;
        serviceTerritoryToInsert.XC_Country__c = country;
        Savepoint sp = Database.setSavepoint();
        XC_UTIL_Sobject.WrapperResult wrapServiceTerritory = XC_UTIL_Sobject.insertRecord(serviceTerritoryToInsert);
        if(!wrapServiceTerritory.success){
            Database.rollback(sp);
            wrap.success = wrapServiceTerritory.success;
            wrap.errorMessage = wrapServiceTerritory.errorMessage;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static List<String> findServiceResourceToInsert (Account accountFound){
        List<String> listOfServiceResourceNameToInsert = new List<String>();
        Map<Id,Contact> mapIdContact = new Map<Id,Contact>([SELECT Id, Name, (SELECT Id, IsActive FROM Users) FROM Contact WHERE AccountId =: accountFound.Id]);
        if(mapIdContact.isEmpty()){
            return listOfServiceResourceNameToInsert;
        }
        for(Contact cont : mapIdContact.values()){
            Boolean userFound = false;
            for(User us : cont.Users){
                userFound = true;
                if(!us.isActive){
                    mapIdContact.remove(cont.Id);
                }
            }
            if(!userFound){
                mapIdContact.remove(cont.Id);
            }
        }
        List<User> listOfUserContactSearched = new List<User>([SELECT Id, IsActive, ContactId FROM User WHERE ContactId IN : mapIdContact.keySet()]);
        for(User us : listOfUserContactSearched){
            if(!us.IsActive){
                mapIdContact.remove(us.ContactId);
            }
        }
        if(mapIdContact.isEmpty()){
            return listOfServiceResourceNameToInsert;
        }
        Map<Id, ServiceResource> mapIdServiceResourceAlreadyExist = new Map<Id,ServiceResource>([SELECT Id, XC_Contact__c FROM ServiceResource WHERE XC_Contact__c IN: mapIdContact.keySet() AND isActive =: true]);
        for(ServiceResource servResource : mapIdServiceResourceAlreadyExist.values()){  
            if(mapIdContact.get(servResource.XC_Contact__c) != null){
                mapIdContact.remove(servResource.XC_Contact__c);
            }
        }
        for(Contact cont : mapIdContact.values()){
            listOfServiceResourceNameToInsert.add(cont.Name);
        }
        return listOfServiceResourceNameToInsert; 
    }

    @AuraEnabled
    public static NextStepWrapper createServiceResource (Account accountFound, List<String> listOfServiceResourceName, String mapServiceResourceRole){
        NextStepWrapper wrap = new NextStepWrapper();
        if(mapServiceResourceRole == null){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoServiceResourceToInsert;
            return wrap;
        }
        List<Map<String,String>> deserializedList = (List<Map<String,String>>)JSON.deserialize(mapServiceResourceRole, List<Map<String,String>>.class);
        Map<String, String> serviceResourceNameRoleMap = new Map<String, String>();
        for(Map<String,String> newMap : deserializedList){
            serviceResourceNameRoleMap.put(newMap.get('key'), newMap.get('value'));
        }
        List<User> listOfUser = new List<User>([SELECT Id, XC_LegalEntity__c, Country__c FROM User WHERE Id =: UserInfo.getUserId()]);
        User runningUser = listOfUser[0];
        List<Contact> listOfContact = new List<Contact>([SELECT Id, XC_ContactDocumentNumber__c, XC_ContactDocumentType__c, AccountId, Account.Name, Name,(SELECT Id, Name, XC_LegalEntity__c FROM Users ) FROM Contact WHERE Name IN: listOfServiceResourceName AND AccountId =: accountFound.Id]);
        List<ServiceResource> listOfServiceResource = new List<ServiceResource>();
        listOfServiceResource = populateServiceResource(listOfContact, runningUser, serviceResourceNameRoleMap);
        if (listOfServiceResource.isEmpty()){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoServiceResourceToInsert;
            return wrap;
        }
        Savepoint sp = Database.setSavepoint();
        List<XC_UTIL_Sobject.WrapperResult> wrapServiceResourceList = XC_UTIL_Sobject.insertListRecords(listOfServiceResource);
        if(!XC_UTIL_Sobject.checkDMLResults(wrapServiceResourceList)){
            Database.rollback(sp);
            wrap.success = wrapServiceResourceList[0].success;
            wrap.errorMessage = wrapServiceResourceList[0].errorMessage;
            return wrap;
        }
        wrap.success = true;
        wrap.listOfServiceResource = listOfServiceResource;
        return wrap;
    }

    public static List<ServiceResource> populateServiceResource(List<Contact> listOfContact, User runningUser, Map<String, String> serviceResourceNameRoleMap){
        List<ServiceResource> listOfServiceResource = new List<ServiceResource>();
        List<XC_CS009_SettingPartnerManagement__c> listOfCustomSetting = new List<XC_CS009_SettingPartnerManagement__c>([SELECT Id, XC_Role__c, XC_ServiceResourceType__c, XC_ServiceResourceCapacityBased__c, XC_ServiceResourceManager__c FROM XC_CS009_SettingPartnerManagement__c WHERE XC_LegalEntity__c =: runningUser.XC_LegalEntity__c AND XC_Country__c =: runningUser.Country__c AND XC_Role__c IN: serviceResourceNameRoleMap.values()]);
        Map<String, XC_CS009_SettingPartnerManagement__c> mapRoleCustomSetting = new Map<String, XC_CS009_SettingPartnerManagement__c>();
        for(XC_CS009_SettingPartnerManagement__c cs : listOfCustomSetting){
            mapRoleCustomSetting.put(cs.XC_Role__c, cs);
        }
        for(Contact con : listOfContact){
            ServiceResource servResource = new ServiceResource();
            String role = serviceResourceNameRoleMap.get(con.Name);
            servResource.Name = con.Users[0].Name + ' - ' + con.Account.Name;
            servResource.RelatedRecordId = con.Users[0].Id;
            servResource.XC_Contact__c  = con.Id;
            servResource.AccountId = con.AccountId;
            servResource.XC_Account__c = con.AccountId;
            servResource.IsActive = true;
            if(runningUser.Country__c.toLowerCase().equals('italy')){
                servResource.ResourceType = mapRoleCustomSetting.get(role).XC_ServiceResourceType__c;
                servResource.IsCapacityBased = mapRoleCustomSetting.get(role).XC_ServiceResourceCapacityBased__c;
                servResource.XC_IsManager__c = mapRoleCustomSetting.get(role).XC_ServiceResourceManager__c;
                servResource.XC_Country__c = 'Italy';
                servResource.XC_LegalEntity__c = runningUser.XC_LegalEntity__c;
            }else if (runningUser.Country__c.toLowerCase().equals('spain')){
                servResource.ResourceType = mapRoleCustomSetting.get(role).XC_ServiceResourceType__c;
                servResource.IsCapacityBased = mapRoleCustomSetting.get(role).XC_ServiceResourceCapacityBased__c;
                servResource.XC_IsManager__c = mapRoleCustomSetting.get(role).XC_ServiceResourceManager__c;
                servResource.XC_Country__c = 'Spain';
                servResource.XC_LegalEntity__c = runningUser.XC_LegalEntity__c;
            }
            servResource.IsOptimizationCapable = false;
            servResource.XC_DocumentId__c = con.XC_ContactDocumentNumber__c;
            servResource.XC_DocumentType__c = con.XC_ContactDocumentType__c;
            servResource.XC_Freelance__c = false;
            servResource.XC_AutomaticDeactivation__c = false;
            servResource.XC_WorkingForEndesa__c = true;
            listOfServiceResource.add(servResource);
        }
        return listOfServiceResource;
    }

    @AuraEnabled
    public static NextStepWrapper  openNextStep(Account accountFound){
        NextStepWrapper wrap = new NextStepWrapper();
        List<Contact> listOfContactFromPartner = new List<Contact>([SELECT Id, (SELECT Id, IsActive FROM Users) FROM Contact WHERE AccountId =: accountFound.Id]);
        Boolean contactWithUser = false;
        for(Contact cont : listOfContactFromPartner){
            for(User us : cont.Users){
                if(us.isActive){
                    contactWithUser =  true;
                }
            } 
        }
        if(!contactWithUser){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoUsersConfigured;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }


    @AuraEnabled
    public static NextStepWrapper  createServiceTerritoryMemberToInsert(Account accountFound){
        NextStepWrapper wrap = new NextStepWrapper();
        List<ServiceTerritory> listOfServiceTerritory = new List<ServiceTerritory>([SELECT Id, OperatingHoursId FROM ServiceTerritory WHERE XC_AccountId__c =: accountFound.Id]);
        if(listOfServiceTerritory.isEmpty()){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoServiceTerritoryFound;
            return wrap;
        }
        ServiceTerritory servTerritory = listOfServiceTerritory[0];
        List<ServiceTerritoryMember> listOfServiceTerritoryMemberWithResource = new List<ServiceTerritoryMember>([SELECT Id, ServiceResourceId FROM ServiceTerritoryMember WHERE ServiceTerritoryId =: servTerritory.Id ]);
        Map<Id, ServiceResource> mapIdServiceResource = new Map<Id, ServiceResource>([SELECT Id, XC_Country__c FROM ServiceResource WHERE AccountId =: accountFound.Id AND IsActive =: true]);
        for(ServiceTerritoryMember servTerrMemb : listOfServiceTerritoryMemberWithResource){
            if(mapIdServiceResource.containsKey(servTerrMemb.ServiceResourceId)){
                mapIdServiceResource.remove(servTerrMemb.ServiceResourceId);
            }
        }
        List<ServiceTerritoryMember> listOfServiceTerritoryMember = new List<ServiceTerritoryMember>();
        for(ServiceResource servRes : mapIdServiceResource.values()){
            ServiceTerritoryMember servTerMember = new ServiceTerritoryMember();
            servTerMember.ServiceResourceId = servRes.Id;
            servTerMember.ServiceTerritoryId = servTerritory.Id;
            servTerMember.TerritoryType = 'P';
            servTerMember.EffectiveStartDate = Datetime.newInstance(2020,01,01);
            servTerMember.OperatingHoursId = servTerritory.OperatingHoursId;
            servTerMember.XC_Country__c = servRes.XC_Country__c;
            listOfServiceTerritoryMember.add(servTerMember);
        }   
        List<XC_UTIL_Sobject.WrapperResult> wrapServiceTerritoryMemberList = XC_UTIL_Sobject.insertListRecords(listOfServiceTerritoryMember);
        if(!XC_UTIL_Sobject.checkDMLResults(wrapServiceTerritoryMemberList)){
            wrap.success = wrapServiceTerritoryMemberList[0].success;
            wrap.errorMessage = wrapServiceTerritoryMemberList[0].errorMessage;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static GroupWrapper loadGroupOfPartner(Account accountFound){
        List<Group> listGroupOfPartner = new List<Group>([SELECT Id FROM Group WHERE Name =: accountFound.Name]);
        List<User> listOfUser = new List<User>([SELECT Id, XC_LegalEntity__c FROM User WHERE Id =: UserInfo.getUserId()]);
        String legalEntityToSearch = listOfUser[0].XC_LegalEntity__c;
        List<XC_CS016_SettPartnerManWhitelistedGroup__c> candidateGroupsCS = new List<XC_CS016_SettPartnerManWhitelistedGroup__c>([SELECT XC_GroupDeveloperName__c FROM XC_CS016_SettPartnerManWhitelistedGroup__c WHERE XC_LegalEntity__c = :legalEntityToSearch]);
        Set<String> candidateGroupsDevNames = new Set<String>();
        for(XC_CS016_SettPartnerManWhitelistedGroup__c cs : candidateGroupsCS){
            if(!String.isBlank(cs.XC_GroupDeveloperName__c)){
                List<String> whitelist = cs.XC_GroupDeveloperName__c.split(';');
                candidateGroupsDevNames.addAll(whitelist);
            }
        }
        Set<String> candidateGroupsNames = new Set<String>();
        for(Group g : [SELECT Id, Name FROM Group WHERE Developername in: candidateGroupsDevNames]){
            candidateGroupsNames.add(g.Name);
        }
        List<GroupMember> listGroupPartnerShare = new List<GroupMember>([SELECT Id, Group.Developername, Group.Name FROM GroupMember WHERE GroupId IN (SELECT Id from Group WHERE Developername in: candidateGroupsDevNames) AND UserOrGroupId =: listGroupOfPartner[0].Id]);
        Set<String> alreadyAssociatedGroupsDevNames = new Set<String>();
        for(GroupMember gm : listGroupPartnerShare){
            alreadyAssociatedGroupsDevNames.add(gm.Group.Name);
        }
        return new GroupWrapper(candidateGroupsNames, alreadyAssociatedGroupsDevNames);
    }

    @AuraEnabled
    public static NextStepWrapper insertUserToGroupMember(Account accountFound, List<String> selectedGroup){
        NextStepWrapper wrap = new NextStepWrapper();
        if(selectedGroup.isEmpty()){
            wrap.success = true;
            return wrap; 
        }
        List<Group> listGroupToSearch = new List<Group>([SELECT Id, Name FROM Group WHERE Name IN: selectedGroup]);
        List<Group> listGroupOfPartner = new List<Group>([SELECT Id FROM Group WHERE Name =: accountFound.Name]);
        List<GroupMember> listGroupMemberToInsert = new List<GroupMember>();
        for(Group groupToAdd : listGroupToSearch){
            GroupMember groupMember = new GroupMember();
            groupMember.GroupId = groupToAdd.Id;
            groupMember.UserOrGroupId = listGroupOfPartner[0].Id;
            listGroupMemberToInsert.add(groupMember);
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapGroupMemberList = XC_UTIL_Sobject.insertListRecords(listGroupMemberToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(wrapGroupMemberList)){
            wrap.success = wrapGroupMemberList[0].success;
            wrap.errorMessage = wrapGroupMemberList[0].errorMessage;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static NextStepWrapper checkAndCreateServiceResourceShare (Account accountFound){
        NextStepWrapper wrap = new NextStepWrapper();
        Map<Id,ServiceResource> mapIdServiceResource = new Map<Id, ServiceResource>([SELECT Id FROM ServiceResource WHERE AccountId =: accountFound.Id AND IsActive =: true]);
        if(mapIdServiceResource.isEmpty()){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoServiceResourcesFound;
            return wrap;
        }
        List<Group> listGroupOfPartner = new List<Group>([SELECT Id FROM Group WHERE Name =: accountFound.Name]);
        List<ServiceResourceShare> listOfServiceResourceShare = new List<ServiceResourceShare>([SELECT Id, ParentId FROM ServiceResourceShare WHERE UserOrGroupId =: listGroupOfPartner[0].Id]);
        List<ServiceResource> listOfServiceResourceToShare = new List<ServiceResource>();
        Map<Id,ServiceResourceShare> mapServiceResourceServiceResourceShare = new Map<Id, ServiceResourceShare>();
        List<ServiceResourceShare> listOfServiceResourceShareToInsert = new List<ServiceResourceShare>();
        if(listOfServiceResourceShare.isEmpty()){
            listOfServiceResourceToShare = mapIdServiceResource.values();
        }else {
            for(ServiceResourceShare servResourceShare : listOfServiceResourceShare){
                mapServiceResourceServiceResourceShare.put(servResourceShare.ParentId, servResourceShare);
            }
            for(ServiceResource servResource : mapIdServiceResource.values()){
                if( mapServiceResourceServiceResourceShare.get(servResource.Id) != null){
                    mapIdServiceResource.remove(servResource.Id);
                }
            }
            listOfServiceResourceToShare = mapIdServiceResource.values();
        }
        for(ServiceResource servResource : listOfServiceResourceToShare){
            ServiceResourceShare servResourceShare = new ServiceResourceShare();
            servResourceShare.ParentId = servResource.Id;
            servResourceShare.UserOrGroupId = listGroupOfPartner[0].Id;
            servResourceShare.AccessLevel = 'Edit';
            servResourceShare.RowCause = 'Manual';
            listOfServiceResourceShareToInsert.add(servResourceShare);
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapServiceResourceShareList = XC_UTIL_Sobject.insertListRecords(listOfServiceResourceShareToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(wrapServiceResourceShareList)){
            wrap.success = wrapServiceResourceShareList[0].success;
            wrap.errorMessage = wrapServiceResourceShareList[0].errorMessage;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static SkillServiceResourceWrapper loadValueAndServiceResourceForSkillManagement(Account accountFound){
        SkillServiceResourceWrapper wrap = new SkillServiceResourceWrapper();
        List<User> listOfUser = new List<User>([SELECT Id, XC_LegalEntity__c, Country__c FROM User WHERE Id =: UserInfo.getUserId()]);
        if(listOfUser[0].Country__c.toLowerCase().equals('spain')){
            wrap.success = true;
            wrap.skipStep = true;
            return wrap;
        }
        List<ServiceResource> listServiceResources = [SELECT Id, Name, (SELECT Id, SkillId FROM ServiceResourceSkills) FROM ServiceResource WHERE IsActive =: true AND AccountId =: accountFound.Id];
        wrap.listOfServiceResource = listServiceResources;
        List<XC_CS010_SettPartnerManagementSkillWT__c> listOfAllSkill = new List<XC_CS010_SettPartnerManagementSkillWT__c>([SELECT Id, Name, XC_SkillToImport__c, XC_WorktypeNameList__c, XC_Country__c FROM XC_CS010_SettPartnerManagementSkillWT__c]);
        Map<String, Set<String>> skillToWorkTypes = new Map<String, Set<String>>();
        Map<String, Set<String>> skillToSkillIds = new Map<String, Set<String>>();
        Set<String> workTypeNames = new Set<String>();
        for(XC_CS010_SettPartnerManagementSkillWT__c sett : listOfAllSkill){
            skillToWorkTypes.put(sett.XC_SkillToImport__c, new Set<String>(sett.XC_WorktypeNameList__c.split(';')));
            workTypeNames.addAll(sett.XC_WorktypeNameList__c.split(';'));
        }
        wrap.allSkill = new List<String>(skillToWorkTypes.keySet());
        List<WorkType> listWorkType = [SELECT Id, Name, (SELECT Id, SkillId FROM SkillRequirements) FROM WorkType WHERE Name IN: workTypeNames AND XC_LegalEntity__c =: listOfUser[0].XC_LegalEntity__c AND XC_Segment__c = 'B2C'];
        for(WorkType wt : listWorkType){
            for(String skill : skillToWorkTypes.keySet()){
                if(skillToWorkTypes.get(skill).contains(wt.Name)){
                    skillToSkillIds.put(skill, new Set<String>());
                    for(SkillRequirement sr : wt.SkillRequirements){
                        skillToSkillIds.get(skill).add(sr.SkillId);
                    }
                }
            }
        }
        Map<String, List<String>> servResToSkills = new Map<String, List<String>>();
        for(ServiceResource sr : listServiceResources){
            String jsonServiceResource = JSON.serialize(sr);
            servResToSkills.put(jsonServiceResource, new List<String>());
            Set<String> skillIds = new Set<String>();
            for(ServiceResourceSkill srSkill : sr.ServiceResourceSkills){
                skillIds.add(srSkill.SkillId);
            }
            for(String skill : skillToSkillIds.keySet()){
                if(!skillToSkillIds.get(skill).isEmpty() && skillIds.containsAll(skillToSkillIds.get(skill))){
                    servResToSkills.get(jsonServiceResource).add(skill);
                }
            }
        }
        wrap.mapServiceResourceToSkills = servResToSkills;
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static NextStepWrapper  createServiceResourceSkill(Account accountFound, String mapServiceResourceSkill){
        NextStepWrapper wrap = new NextStepWrapper();
        //List<GroupMember> listFieldServiceDefault = new List<GroupMember>([SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.Name =: 'FIELD_SERVICE_Default']);
        //XC_UTIL_SObject.deleteListRecords(listFieldServiceDefault);
        List<User> listOfUser = new List<User>([SELECT Id, XC_LegalEntity__c, Country__c FROM User WHERE Id =: UserInfo.getUserId()]);
        if(mapServiceResourceSkill == null){
            wrap.errorMessage = Label.XC_CL_PartnerManagement_NoSkillSelected;
            return wrap;
        }
        List<Map<String,String>> deserializedList = (List<Map<String,String>>)JSON.deserialize(mapServiceResourceSkill, List<Map<String,String>>.class);
        Map<String, String> serviceResourceSkillMap = new Map<String, String>();
        for(Map<String,String> newMap : deserializedList){
            serviceResourceSkillMap.put(newMap.get('key'), newMap.get('value'));
        }
        Map<String, List<String>> mapServiceResourceNameListAllSkill = new Map<String, List<String>>();
        for(String nameServiceResource : serviceResourceSkillMap.keySet()){
            List<String> listAllSkillOfServiceResource = new List<String>();
            listAllSkillOfServiceResource = serviceResourceSkillMap.get(nameServiceResource).split(','); 
            mapServiceResourceNameListAllSkill.put(nameServiceResource,listAllSkillOfServiceResource);
        }
        Set<String> setOfAllSkill = new Set<String>();
        mapServiceResourceNameListAllSkill.values();
        for(List<String> listString : mapServiceResourceNameListAllSkill.values()){
            for(String valueSkill : listString){
                setOfAllSkill.add(valueSkill); 
            }
        }
        Set<String> setOfWorkTypeName = new Set<String>();
        List<XC_CS010_SettPartnerManagementSkillWT__c> listOfAllSkill = new List<XC_CS010_SettPartnerManagementSkillWT__c>([SELECT Id, Name, XC_SkillToImport__c, XC_WorktypeNameList__c, XC_Country__c FROM XC_CS010_SettPartnerManagementSkillWT__c WHERE XC_SkillToImport__c IN :setOfAllSkill]);
        Map<String, List<String>> mapSkillWorkTypeList = new  Map<String, List<String>>();
        for(XC_CS010_SettPartnerManagementSkillWT__c cs : listOfAllSkill){
            if(!(cs.XC_WorktypeNameList__c == null || cs.XC_WorktypeNameList__c == '')){
                List<String> listWorkTypeName =  cs.XC_WorktypeNameList__c.split(';');
                mapSkillWorkTypeList.put(cs.XC_SkillToImport__c , listWorkTypeName);
                setOfWorkTypeName.addAll(listWorkTypeName);
            }
           
        }
        List<WorkType> listOfWorkType = new List<WorkType>([SELECT Id, Name, (SELECT Id, SkillId FROM SkillRequirements) FROM WorkType WHERE Name IN: setOfWorkTypeName AND XC_LegalEntity__c =: listOfUser[0].XC_LegalEntity__c AND XC_Segment__c = 'B2C']);
        Map<String, List<String>> mapWorkTypeNameListSkillIdRequirements = new Map<String, List<String>>();
        for(WorkType wt : listOfWorkType){
            for(SkillRequirement skillReq : wt.SkillRequirements){
                if(!mapWorkTypeNameListSkillIdRequirements.containsKey(wt.Name)){
                    mapWorkTypeNameListSkillIdRequirements.put(wt.Name , new List<String>());
                }
                 mapWorkTypeNameListSkillIdRequirements.get(wt.Name).add(skillReq.SkillId);
            }
           
        }
        List<ServiceResource> listOfServiceResource = new List<ServiceResource>([SELECT Id, Name, (SELECT Id, SkillId FROM ServiceResourceSkills) FROM ServiceResource WHERE Name IN : mapServiceResourceNameListAllSkill.keySet() AND IsActive =: true AND AccountId =: accountFound.Id]);
        Map<Id, List<String>> mapIdServResourceListIdSkill = new Map<Id, List<String>>();
        for(ServiceResource sr : listOfServiceResource){
            for(ServiceResourceSkill srSkill : sr.ServiceResourceSkills){
                if(!mapIdServResourceListIdSkill.containsKey(sr.Id)){
                    mapIdServResourceListIdSkill.put(sr.Id , new List<String>());
                }
                 mapIdServResourceListIdSkill.get(sr.Id).add(srSkill.SkillId);
            }
        }
        Set<ServiceResourceSkill> setServiceResourceSkill = new Set<ServiceResourceSkill>();
        for(ServiceResource sr : listOfServiceResource){
            for(String skillName : mapServiceResourceNameListAllSkill.get(sr.Name)){
                if(mapSkillWorkTypeList.containsKey(skillName)){
                    for(String wtName : mapSkillWorkTypeList.get(skillName)){
                        if(mapWorkTypeNameListSkillIdRequirements.get(wtName) != null){
                            for(String skillReqId : mapWorkTypeNameListSkillIdRequirements.get(wtName)){
                                if(mapIdServResourceListIdSkill.get(sr.Id) == null || (mapIdServResourceListIdSkill.get(sr.Id) != null && !mapIdServResourceListIdSkill.get(sr.Id).contains(skillReqId))){
                                    ServiceResourceSkill srSkill = new ServiceResourceSkill();
                                    srSkill.ServiceResourceId = sr.Id;
                                    srSkill.SkillId = skillReqId;
                                    srSkill.SkillLevel = 1;
                                    srSkill.EffectiveStartDate = Datetime.newInstance(2000,01,01);
                                    srSkill.EffectiveEndDate = Datetime.newInstance(2200,01,01);
                                    setServiceResourceSkill.add(srSkill);
                                }
                            }
                        }
                    }
                }
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> wrapServiceResourceSkillList = XC_UTIL_Sobject.insertListRecords(new List<ServiceResourceSkill> (setServiceResourceSkill));
        if(!XC_UTIL_Sobject.checkDMLResults(wrapServiceResourceSkillList)){
            wrap.success = wrapServiceResourceSkillList[0].success;
            wrap.errorMessage = wrapServiceResourceSkillList[0].errorMessage;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }

    @AuraEnabled
    public static NextStepWrapper deleteUserFromFieldServiceDefault(Account accountFound){
        NextStepWrapper wrap = new NextStepWrapper();
        List<ServiceResource> listOfServiceResource = new List<ServiceResource>([SELECT Id, RelatedRecordId FROM ServiceResource WHERE IsActive =: true AND AccountId =: accountFound.Id]);
        List<String> listToFindFieldServiceDefault = new List<String>();
        for(ServiceResource servRes: listOfServiceResource){
            listToFindFieldServiceDefault.add(servRes.RelatedRecordId);
        }
        List<Group> listOfGroupPartner = new List<Group>([SELECT Id FROM Group WHERE Name =: accountFound.Name]);
        if(!listOfGroupPartner.isEmpty()){
            listToFindFieldServiceDefault.add(listOfGroupPartner[0].Id);
        }
        List<GroupMember> listOfGroupMemberFieldServiceDefault = new List<GroupMember>([SELECT Id FROM GroupMember WHERE UserOrGroupId IN: listToFindFieldServiceDefault AND Group.Name =: 'FIELD_SERVICE_Default']);
        List<XC_UTIL_Sobject.WrapperResult> wrapFieldServiceDefault = XC_UTIL_Sobject.deleteListRecords(listOfGroupMemberFieldServiceDefault);
        if(!XC_UTIL_Sobject.checkDMLResults(wrapFieldServiceDefault)){
            wrap.success = wrapFieldServiceDefault[0].success;
            wrap.errorMessage = wrapFieldServiceDefault[0].errorMessage;
            return wrap;
        }
        wrap.success = true;
        return wrap;
    }

  

}