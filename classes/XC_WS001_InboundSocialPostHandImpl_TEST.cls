/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com - Valeria Martino
* @date Creation 21/06/2019 
* @description XC_WS001_InboundSocialPostHandImpl_TEST – Test class for XC_WS001_InboundSocialPostHandlerImpl
*/

@isTest
public class XC_WS001_InboundSocialPostHandImpl_TEST { 
    static Map<String, Object> sampleSocialData;
    static Social.InboundSocialPostHandlerImpl handler;
    static {
        handler = new Social.InboundSocialPostHandlerImpl();
        sampleSocialData = getSampleSocialData('1');
    }

   /* static testMethod void verifyNewRecordCreation() {
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);

        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();

        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId FROM Case];


        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }*/

    /*static testMethod void matchSocialPostRecord() {
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        insert existingPost;
        SocialPost post = getSocialPost(sampleSocialData);
        post.R6PostId = existingPost.R6PostId;
        SocialPersona persona = getSocialPersona(sampleSocialData);

        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();

        System.assertEquals(1, [SELECT Id FROM SocialPost].size(), 'There should be only 1 post');
    }

    static testMethod void matchSocialPersonaRecord() {
        List<Account> account = XC_DF_Account.insertPartnerAccounts(1); 
        Contact existingContact = new Contact(
            LastName = 'LastName',
            XC_MainLegalEntity__c = 'EndesaX',
            XC_CountryLegalEntity__c = 'Spain',
            Email = 'test@te.te',
            XC_GiveDataToNew__c = 'Yes',
            AccountId = account[0].Id,
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId()
            );
        insert existingContact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        persona.ExternalId = existingPersona.ExternalId;

        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();

        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }

    static testMethod void matchCaseRecord() {
        List<Account> account = XC_DF_Account.insertPartnerAccounts(1);
        Contact existingContact = new Contact(
            LastName = 'LastName',
            XC_MainLegalEntity__c = 'EndesaX',
            XC_CountryLegalEntity__c = 'Spain',
            Email = 'test@te.te',
            XC_GiveDataToNew__c = 'Yes',
            AccountId = account[0].Id,
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId()
            );
        insert existingContact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        //Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case');
        List<Case> existingCase = XC_DF_Case.createCases(1);
        existingCase.get(0).ContactId = existingContact.Id;
        existingCase.get(0).Subject = 'Test Case';
        insert existingCase;
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.get(0).Id;
        existingPost.WhoId = existingContact.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = 'scs';
        existingPost.recipient = recipient;
        insert existingPost;
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;

        test.startTest();
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();

        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost
        WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingContact.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        System.assertEquals(existingCase.get(0).Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
    }*/

/*    static testMethod void reopenClosedCase() {
        List<Account> account = XC_DF_Account.insertPartnerAccounts(1);
        Contact existingContact = new Contact(
            LastName = 'LastName',
            XC_MainLegalEntity__c = 'EndesaX',
            XC_CountryLegalEntity__c = 'Spain',
            Email = 'test@te.te',
            XC_GiveDataToNew__c = 'Yes',
            AccountId = account[0].Id,
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId()
            );
        insert existingContact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        //Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case', Status = 'Closed');
        List<Case> existingCase = XC_DF_Case.createCases(1);
        existingCase.get(0).ContactId = existingContact.Id;
        existingCase.get(0).Subject = 'Test Case';
        existingCase.get(0).Status = 'Closed';
        insert existingCase;
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.get(0).Id;
        existingPost.WhoId = existingContact.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = 'scs';
        existingPost.recipient = recipient;
        insert existingPost;
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;

        test.startTest();
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();

        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        System.assertEquals(existingContact.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        System.assertEquals(existingCase.get(0).Id, createdPost.ParentId, 'Post is not linked to the Case.');
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
        System.assertEquals(false, [SELECT Id, IsClosed FROM Case WHERE Id = :existingCase.get(0).Id].IsClosed, 'Case should be open.');
    }*/

    @isTest
    static void createFBCaseRecord() {
        List<Account> account = XC_DF_Account.insertPartnerAccounts(1);
        List<Contact> contact = XC_DF_Contact.createPartnerContacts(account);
        contact[0].Email = 'test@te.te';
        contact[0].XC_GiveDataToNew__c = 'Yes';
        contact[0].XC_Segment__c='B2C';
        /*Contact existingContact = new Contact(
            LastName = 'LastName',
            XC_MainLegalEntity__c = 'EndesaX',
            XC_CountryLegalEntity__c = 'Spain',
            Email = 'test@te.te',
            XC_GiveDataToNew__c = 'Yes',
            AccountId = account[0].Id,
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId()
            );*/
        insert contact;
        SocialPersona existingPersona = getSocialPersona(getFBSampleSocialData('2'));
        existingPersona.ParentId = contact[0].Id;
        insert existingPersona;
        String recipient = 'scs';
        SocialPost post = getSocialPost(sampleSocialData);
        post.Recipient = recipient;

        test.startTest();
        	XC_WS001_InboundSocialPost_Builder.createCase(post, existingPersona);
        test.stopTest();
		
        List<Case> newCase = [
            SELECT id, CaseNumber, RecordTypeId, RecordType.DeveloperName, XC_LegalEntity__c, Country__c, Reason, SubCause__c, XC_Subtype__c, Origin, OwnerId, Owner.Name, CreatedDate 
            FROM Case
        ];
        System.debug('newCase='+newCase);
        //System.assertEquals(1, newCase.size(), 'There should be 1 Case.');
    }

    @isTest
    static void createTWCaseRecord() {
        List<Account> account = XC_DF_Account.insertPartnerAccounts(1);
        List<Contact> contact = XC_DF_Contact.createPartnerContacts(account);
        contact[0].Email = 'test@te.te';
        contact[0].XC_GiveDataToNew__c = 'Yes';
        contact[0].XC_Segment__c='B2C';
        /*Contact existingContact = new Contact(
            LastName = 'LastName',
            XC_MainLegalEntity__c = 'EndesaX',
            XC_CountryLegalEntity__c = 'Spain',
            Email = 'test@te.te',
            XC_GiveDataToNew__c = 'Yes',
            AccountId = account[0].Id,
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId()
            );*/
        insert contact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = contact[0].Id;
        insert existingPersona;
        String recipient = 'scs';
        SocialPost post = getSocialPost(sampleSocialData);
        post.Recipient = recipient;

        test.startTest();
        	XC_WS001_InboundSocialPost_Builder.createCase(post, existingPersona);
        test.stopTest();
		
        List<Case> newCase = [
            SELECT id, CaseNumber, RecordTypeId, RecordType.DeveloperName, XC_LegalEntity__c, Country__c, Reason, SubCause__c, XC_Subtype__c, Origin, OwnerId, Owner.Name, CreatedDate 
            FROM Case
        ];
        System.debug('newCase='+newCase);
        //System.assertEquals(1, newCase.size(), 'There should be 1 Case.');
    }

    static SocialPost getSocialPost(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
        post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        return post;
    }

    static SocialPersona getSocialPersona(Map<String, Object> socialData) {
        SocialPersona persona = new SocialPersona();
        persona.Name = String.valueOf(socialData.get('author'));
        persona.RealName = String.valueOf(socialData.get('realName'));
        persona.Provider = String.valueOf(socialData.get('mediaProvider'));
        persona.MediaProvider = String.valueOf(socialData.get('mediaProvider'));
        persona.ExternalId = String.valueOf(socialData.get('externalUserId'));
        return persona;
    }

    static Map<String, Object> getSampleSocialData(String suffix) {
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postTags', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        socialData.put('content', 'Content' + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Tweet');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        return socialData;
    }

    static Map<String, Object> getFBSampleSocialData(String suffix) {
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postTags', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        socialData.put('content', 'Content' + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Facebook');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'FACEBOOK');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Post');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        return socialData;
    }
	
    @isTest
    static void getMaxNumberOfDaysClosedToReopenCase(){
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl inbound = new XC_WS001_InboundSocialPostHandlerImpl();
        	inbound.getMaxNumberOfDaysClosedToReopenCase();
               inbound.getDefaultAccountId();
                inbound.getTagCountrySpain();
        inbound.getPostTagsThatCreateCase();
        Test.stopTest();
    }
    
    @isTest
    static void handleInboundSocialPost(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        insert post;
        
        List<Account> account = XC_DF_Account.createCondominiumAccounts(1);
        insert account ;
        List<Contact> contact = XC_DF_Contact.createCondominiumContacts(account);
        insert contact;
        SocialPersona persona = new SocialPersona();
        persona.Name = 'Test';
        persona.ParentId= contact.get(0).id;
        persona.Provider = 'Facebook';
        insert persona;
        
        Map<String, Object> rawData = new Map<String, Object>();
        rawData.put('mediaUrls', new List<Object>());
        Test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl inbound = new XC_WS001_InboundSocialPostHandlerImpl();
        	inbound.handleInboundSocialPost(post, persona, rawData);
        Test.stopTest();
    }
    
    @isTest
    static void handleInboundSocialPost2(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        
        
        List<Account> account = XC_DF_Account.createCondominiumAccounts(1);
        insert account ;
        List<Contact> contact = XC_DF_Contact.createCondominiumContacts(account);
        insert contact;
        SocialPersona persona = new SocialPersona();
        persona.Name = 'Test';
        persona.ParentId= contact.get(0).id;
        persona.Provider = 'Facebook';
        insert persona;
        
        Map<String, Object> rawData = new Map<String, Object>();
        List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment> pAtt = new List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment>();
        XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment att = new XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment('Test', 'Test');
        pAtt.add(att);
        rawData.put('mediaUrls', pAtt);
        Test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl inbound = new XC_WS001_InboundSocialPostHandlerImpl();
        	inbound.handleInboundSocialPost(post, persona, rawData);
        Test.stopTest();
    }
    
    @isTest
    static void handleInboundSocialPost_WithParentCase(){
        List<Account> account = XC_DF_Account.createCondominiumAccounts(1);
        insert account ;
        List<Contact> contact = XC_DF_Contact.createCondominiumContacts(account);
        insert contact;
        SocialPersona persona = new SocialPersona();
        persona.Name = 'MC_Test';
        persona.ParentId= contact.get(0).id;
        persona.Provider = 'Facebook';
        insert persona;
        
        Map<String,XC_CM_Case_Type_Setting__mdt> caseTypeMap = XC_Util_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_SocialPostCase});
        Case newCase = XC_UTIL_Case.initCaseFromCaseSettings(caseTypeMap.get(Label.XC_CL_SocialPostCase));
        newCase.AccountId = account[0].Id;
        newCase.ContactId = contact[0].Id;
        newCase.Country__c = 'SPAIN';
        newCase.Description = 'Test MC';
        newCase.XC_Segment__c = 'B2C';
        newCase.XC_LegalEntity__c = 'EndesaX';
        insert newCase;
    	
        SocialPost post = new SocialPost();
        post.Name = 'MC_Test';
    	post.Provider = 'Facebook';
    	post.PersonaId = persona.Id;
    	post.IsOutbound = false;
        post.ParentId = newCase.Id;
        post.Recipient = 'Moni';
    	insert post;
        
        Map<String, Object> rawData = new Map<String, Object>();
        List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment> pAtt = new List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment>();
        XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment att = new XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment('MC_Test', 'MC_Test');
        pAtt.add(att);
        rawData.put('mediaUrls', pAtt);
        
        XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseWrapper buildParentCaseWrapper = new XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseWrapper();
        buildParentCaseWrapper.post = post;
        buildParentCaseWrapper.persona = persona;
        buildParentCaseWrapper.rawData = rawData;
        buildParentCaseWrapper.isNewCaseCreated = false;
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseResultWrapper buildParentCaseResultWrapper1 = XC_WS001_InboundSocialPost_Builder.buildParentCase(buildParentCaseWrapper);
        Test.stopTest();
    }
    
    @isTest
    static void handleInboundSocialPost_WithParentCaseClosed(){
        List<Account> account = XC_DF_Account.createCondominiumAccounts(1);
        insert account ;
        List<Contact> contact = XC_DF_Contact.createCondominiumContacts(account);
        insert contact;
        SocialPersona persona = new SocialPersona();
        persona.Name = 'MC_Test';
        persona.ParentId= contact.get(0).id;
        persona.Provider = 'Facebook';
        insert persona;
        
        Map<String,XC_CM_Case_Type_Setting__mdt> caseTypeMap = XC_Util_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_SocialPostCase});
        Case newCase = XC_UTIL_Case.initCaseFromCaseSettings(caseTypeMap.get(Label.XC_CL_SocialPostCase));
        newCase.AccountId = account[0].Id;
        newCase.ContactId = contact[0].Id;
        newCase.Country__c = 'SPAIN';
        newCase.Description = 'Test MC';
        newCase.XC_Segment__c = 'B2C';
        newCase.XC_LegalEntity__c = 'EndesaX';
        insert newCase;
    	
        SocialPost post = new SocialPost();
        post.Name = 'MC_Test';
    	post.Provider = 'Facebook';
    	post.PersonaId = persona.Id;
    	post.IsOutbound = false;
        post.ParentId = newCase.Id;
        post.Recipient = 'Moni';
    	insert post;
        
        newCase.XC_Result__c = 'RS003';
        newCase.XC_Resolution__c = 'R001';
        newCase.CaseRemarks__c = 'chiusura';
        update newCase;
        
        Map<String, Object> rawData = new Map<String, Object>();
        List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment> pAtt = new List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment>();
        XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment att = new XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment('MC_Test', 'MC_Test');
        pAtt.add(att);
        rawData.put('mediaUrls', pAtt);
        
        XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseWrapper buildParentCaseWrapper = new XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseWrapper();
        buildParentCaseWrapper.post = post;
        buildParentCaseWrapper.persona = persona;
        buildParentCaseWrapper.rawData = rawData;
        buildParentCaseWrapper.isNewCaseCreated = false;
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl.BuildParentCaseResultWrapper buildParentCaseResultWrapper1 = XC_WS001_InboundSocialPost_Builder.buildParentCase(buildParentCaseWrapper);
        Test.stopTest();
    }
    
    @isTest
    static void getRatingString(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        insert post;
        
        List<Account> account = XC_DF_Account.createCondominiumAccounts(1);
        insert account ;
        List<Contact> contact = XC_DF_Contact.createCondominiumContacts(account);
        insert contact;
        SocialPersona persona = new SocialPersona();
        persona.Name = 'Test';
        persona.ParentId= contact.get(0).id;
        persona.Provider = 'Facebook';
        insert persona;
        
        Map<String, Object> rawData = new Map<String, Object>();
        rawData.put('mediaUrls', 'test');
        Test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl inbound = new XC_WS001_InboundSocialPostHandlerImpl();
        	inbound.getRatingString(post);
        Test.stopTest();
    }
        
    @isTest
    static void getPersonaFirstName(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        insert post;
        
        List<Account> account = XC_DF_Account.createCondominiumAccounts(1);
        insert account ;
        List<Contact> contact = XC_DF_Contact.createCondominiumContacts(account);
        insert contact;
        SocialPersona persona = new SocialPersona();
        persona.Name = 'Test';
        persona.ParentId= contact.get(0).id;
        persona.Provider = 'Facebook';
        insert persona;
        
        Map<String, Object> rawData = new Map<String, Object>();
        rawData.put('mediaUrls', 'test');
        Test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl inbound = new XC_WS001_InboundSocialPostHandlerImpl();
        	inbound.getPersonaFirstName(persona);
        Test.stopTest();
    }
    
    @isTest
    static void getPersonaLastName(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        insert post;
        
        List<Account> account = XC_DF_Account.createCondominiumAccounts(1);
        insert account ;
        List<Contact> contact = XC_DF_Contact.createCondominiumContacts(account);
        insert contact;
        SocialPersona persona = new SocialPersona();
        persona.Name = 'Test';
        persona.ParentId= contact.get(0).id;
        persona.Provider = 'Facebook';
        insert persona;
        
        Map<String, Object> rawData = new Map<String, Object>();
        rawData.put('mediaUrls', 'test');
        Test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl inbound = new XC_WS001_InboundSocialPostHandlerImpl();
        	inbound.getPersonaLastName(persona);
        Test.stopTest();
    }
    
    @isTest
    static void getPersonaName(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        insert post;
        
        List<Account> account = XC_DF_Account.createCondominiumAccounts(1);
        insert account ;
        List<Contact> contact = XC_DF_Contact.createCondominiumContacts(account);
        insert contact;
        SocialPersona persona = new SocialPersona();
        persona.Name = 'Test';
        persona.ParentId= contact.get(0).id;
        persona.Provider = 'Facebook';
        insert persona;
        
        Map<String, Object> rawData = new Map<String, Object>();
        rawData.put('mediaUrls', 'test');
        Test.startTest();
        XC_WS001_InboundSocialPostHandlerImpl inbound = new XC_WS001_InboundSocialPostHandlerImpl();
        	inbound.getPersonaName(persona);
        Test.stopTest();
    }
}