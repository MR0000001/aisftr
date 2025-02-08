/**
* @author Andrea Di Cicco
* @date Creation  08/05/2019
* @description XC_LCC167_NewAddressXygo_TEST – Test class for XC_LCC167_NewAddressXygo
*/
@isTest
public class XC_WS001_InboundSocialPostHand_U_TEST {
	
    static testMethod void createLinksForAttachmentsToSocialPost(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        insert post;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';
        cv.PathOnClient = 'Test';
        cv.VersionData = EncodingUtil.base64Decode('test');
        insert cv;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(cv);
        Test.startTest();
            	XC_WS001_InboundSocialPostHandlerImpl_U.createLinksForAttachmentsToSocialPost(post, cvList);
        Test.stopTest();
    }
    
    static testMethod void findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(){
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
        
        Test.startTest();
        	SocialPost  sp = XC_WS001_InboundSocialPostHandlerImpl_U.findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(post, persona);
        	System.assertEquals(null, sp);
        Test.stopTest();
    }
    
    static testMethod void populateCaseField(){
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
        
        List<Case> cases = XC_DF_Case.createCases(1);
        cases.get(0).ContactId = null;
        insert cases;
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl_U.populateCaseField(cases.get(0), persona, post);
        Test.stopTest();
    }
        static testMethod void setRelationshipsOnPost(){
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
        
        List<Case> cases = XC_DF_Case.createCases(1);
        
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl_U.setRelationshipsOnPost(post, persona, cases.get(0));
        Test.stopTest();
    }
	
	static testMethod void handleExistingPost(){
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
        
        List<Case> cases = XC_DF_Case.createCases(1);
        
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl_U.handleExistingPost(post, persona);
        Test.stopTest();
    }
	static testMethod void handlePostAttachments(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        insert post;
        
        Map<String, Object> rawData = new Map<String, Object>();
        List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment> postAtt = new List<XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment>();
        XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment att = new XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment('test', 'test');
        postAtt.add(att);
        rawData.put('mediaUrls', postAtt);
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl_U.handlePostAttachments(post, rawData);
        Test.stopTest();
    }
	
	static testMethod void updateCaseSource(){
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
        
        List<Case> cases = XC_DF_Case.createCases(1);
        
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl_U.updateCaseSource(post, cases.get(0));
        Test.stopTest();
    }
	
	static testMethod void isUnsentParent(){
        
        
        Map<String, Object> rawData = new Map<String, Object>();
        rawData.put('unsentParent', 'true');
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl_U.isUnsentParent(rawData);
        XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment pa = new XC_WS001_InboundSocialPostHandlerImpl_U.PostAttachment('test','test');
        Test.stopTest();
    }
	
	static testMethod void setModeration(){
        SocialPost post = new SocialPost();
        post.Name = 'Test';
        insert post;
        
        Map<String, Object> rawData = new Map<String, Object>();
        rawData.put('unsentParent', 'false');
        Test.startTest();
        	XC_WS001_InboundSocialPostHandlerImpl_U.setModeration(post, rawData);
        Test.stopTest();
    }
	
}