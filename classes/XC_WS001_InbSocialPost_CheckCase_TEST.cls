/**
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 08/02/2020
 * @date Modification dd/mm/yyyy
 * @description XC_WS001_InbSocialPost_CheckCase_TEST - test class for XC_WS001_InbSocialPost_CheckCase.
 */
@isTest
public class XC_WS001_InbSocialPost_CheckCase_TEST {
    
	@isTest static void findParentCaseOfChatFromPersonaAndRecipient() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        insert listAsset;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> mtd = XC_UTIL_Case.retriveCaseTypeSettings(new List<String> {Label.XC_CL_SocialPostCase});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(mtd.get(Label.XC_CL_SocialPostCase));
        caso.XC_LegalEntity__c = 'EndesaX';
        insert caso;
        
        Test.startTest();
        
        	SocialPost sPost = new SocialPost();
        	sPost.Provider = 'Facebook';
        	sPost.Name = 'My Test Post';
        	sPost.ParentId = caso.Id;
        	sPost.messageType = 'Direct';
        	insert sPost; 
        
        	SocialPersona sPersona = new SocialPersona();
        	sPersona.Name = 'MonicaC';
        	sPersona.Provider = 'Facebook';
        	sPersona.ParentId = sPost.Id;
        	insert sPersona;
        
        	sPost.PersonaId = sPersona.Id;
        	update sPost;
        
        	Case casoNew =  XC_WS001_InboundSocialPost_CheckCase.findParentCaseOfChatFromPersonaAndRecipient(sPost, sPersona);
        Test.stopTest();
        
        System.assert(true);
    }
    
	@isTest static void findParentCase1() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        insert listAsset;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> mtd = XC_UTIL_Case.retriveCaseTypeSettings(new List<String> {Label.XC_CL_SocialPostCase});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(mtd.get(Label.XC_CL_SocialPostCase));
        caso.XC_LegalEntity__c = 'EndesaX';
        insert caso;
        
        Test.startTest();
        
        	SocialPost sPostP = new SocialPost();
        	sPostP.Provider = 'Facebook';
        	sPostP.Name = 'My Test Post';
        	sPostP.messageType = 'Direct';
        	sPostP.ParentId = caso.Id;
        	sPostP.IsOutbound = false;
        	sPostP.Recipient='253107918701628';
        	insert sPostP; 
        
        	SocialPost sPost = new SocialPost();
        	sPost.Provider = 'Facebook';
        	sPost.Name = 'My Test Post Reply';
        	//sPost.ParentId = caso.Id;
        	sPost.ReplyToId = sPostP.Id;
        	sPost.ReplyTo = sPostP;
        	sPost.messageType = 'Direct';
        	insert sPost; 
        
        	SocialPersona sPersona = new SocialPersona();
        	sPersona.Name = 'MonicaC';
        	sPersona.Provider = 'Facebook';
        	sPersona.ParentId = sPost.Id;
            sPersona.ExternalId='253107918701628';
        	insert sPersona;
        
        	sPost.PersonaId = sPersona.Id;
        	update sPost;
        
        	Case casoNew =  XC_WS001_InboundSocialPost_CheckCase.findParentCase(sPost, sPersona);
        	Case caso2New =  XC_WS001_InboundSocialPost_CheckCase.findParentCaseFromPersona(sPost, sPersona);
        Test.stopTest();
        
        System.assert(true);
    }
    
	@isTest static void findParentCase2() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        insert listAsset;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> mtd = XC_UTIL_Case.retriveCaseTypeSettings(new List<String> {Label.XC_CL_SocialPostCase});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(mtd.get(Label.XC_CL_SocialPostCase));
        caso.XC_LegalEntity__c = 'EndesaX';
        insert caso;
        
        Test.startTest();
        
        	SocialPost sPostP = new SocialPost();
        	sPostP.Provider = 'Facebook';
        	sPostP.Name = 'My Test Post';
        	sPostP.messageType = 'Direct';
        	sPostP.ParentId = caso.Id;
        	sPostP.IsOutbound = false;
        	sPostP.Recipient='253107918701628';
        	insert sPostP; 
        
        	SocialPost sPost = new SocialPost();
        	sPost.Provider = 'Facebook';
        	sPost.Name = 'My Test Post Reply';
        	sPost.ReplyToId = sPostP.Id;
        	sPost.ReplyTo = sPostP;
        	sPost.messageType = 'Direct';
        	sPost.Recipient='253107918701628';
        	insert sPost; 
        
        	SocialPost sPostInb = new SocialPost();
        	sPostInb.Provider = 'Facebook';
        	sPostInb.Name = 'My Test Post Inbound';
        	sPostInb.IsOutbound = false;
        	sPostInb.messageType = 'Direct';
        	sPostInb.Recipient='253107918701628';
        	insert sPostInb; 
        
        	SocialPersona sPersona = new SocialPersona();
        	sPersona.Name = 'MonicaC';
        	sPersona.Provider = 'Facebook';
        	sPersona.ParentId = sPost.Id;
            sPersona.ExternalId='253107918701628';
        	insert sPersona;
        
        	sPost.PersonaId = sPersona.Id;
        	update sPost;
        
        	Case casoNew =  XC_WS001_InboundSocialPost_CheckCase.findParentCase(sPost, sPersona);
        	Case caso2New =  XC_WS001_InboundSocialPost_CheckCase.findParentCaseFromPersona(sPost, sPersona);
        Test.stopTest();
        
        System.assert(true);
    }
    
	@isTest static void findParentCase3() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        insert listAsset;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> mtd = XC_UTIL_Case.retriveCaseTypeSettings(new List<String> {Label.XC_CL_SocialPostCase});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(mtd.get(Label.XC_CL_SocialPostCase));
        caso.XC_LegalEntity__c = 'EndesaX';
        insert caso;
        
        Test.startTest();
        
        	SocialPost sPostP = new SocialPost();
        	sPostP.Provider = 'Facebook';
        	sPostP.Name = 'My Test Post';
        	sPostP.messageType = 'post';
        	sPostP.ParentId = caso.Id;
        	sPostP.IsOutbound = false;
        	sPostP.Recipient='1234567890';
        	insert sPostP; 
        
        	SocialPost sPost = new SocialPost();
        	sPost.Provider = 'Facebook';
        	sPost.Name = 'My Test Post Reply';
        	sPost.ParentId = caso.Id;
        	sPost.ReplyToId = sPostP.Id;
        	sPost.ReplyTo = sPostP;
        	sPost.messageType = 'post';
        	sPost.Recipient='1234567890';
        	insert sPost; 
        
        	SocialPersona sPersona = new SocialPersona();
        	sPersona.Name = 'MonicaC';
        	sPersona.Provider = 'Facebook';
        	sPersona.ParentId = sPost.Id;
            sPersona.ExternalId='253107918701628';
        	insert sPersona;
        
        	sPost.PersonaId = sPersona.Id;
        	update sPost;
        	sPostP.PersonaId = sPersona.Id;
        	update sPost;
        
        	Case casoNew =  XC_WS001_InboundSocialPost_CheckCase.findParentCase(sPost, sPersona);
        	Case caso2New =  XC_WS001_InboundSocialPost_CheckCase.findParentCaseFromPersona(sPost, sPersona);
        Test.stopTest();
        
        System.assert(true);
    }
    
	@isTest static void findParentCaseFromPostReply() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> mtd = XC_UTIL_Case.retriveCaseTypeSettings(new List<String> {Label.XC_CL_SocialPostCase});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(mtd.get(Label.XC_CL_SocialPostCase));
        caso.XC_LegalEntity__c = 'EndesaX';
        insert caso;
        Case caso2 = XC_UTIL_Case.initCaseFromCaseSettings(mtd.get(Label.XC_CL_SocialPostCase));
        caso2.XC_LegalEntity__c = 'EndesaX';
        insert caso2;
        
        Test.startTest();
        
        	SocialPost sPost = new SocialPost();
        	sPost.Provider = 'Facebook';
        	sPost.Name = 'My Test Post';
        	sPost.ParentId = caso.Id;
        	sPost.messageType = 'Direct';
        	insert sPost; 
        
        	SocialPost sPostReply = new SocialPost();
        	sPostReply.Provider = 'Facebook';
        	sPostReply.Name = 'My Test Post';
        	sPostReply.ParentId = caso2.Id;
        	sPostReply.messageType = 'Direct';
        	sPostReply.ReplyToId = sPost.Id;
        	sPostReply.ReplyTo = sPost;
        	insert sPostReply; 
        
        	SocialPersona sPersona = new SocialPersona();
        	sPersona.Name = 'MonicaC';
        	sPersona.Provider = 'Facebook';
        	sPersona.ParentId = sPost.Id;
        	insert sPersona;
        
        	SocialPersona sPersona2 = new SocialPersona();
        	sPersona2.Name = 'AnnaT';
        	sPersona2.Provider = 'Facebook';
        	sPersona2.ParentId = sPostReply.Id;
        	insert sPersona2;
        
        	sPost.PersonaId = sPersona.Id;
        	sPostReply.PersonaId = sPersona2.Id;
        	update new List<SocialPost> {sPost,sPostReply};
        
        	Case casoNew =  XC_WS001_InboundSocialPost_CheckCase.findParentCaseFromPostReply(sPostReply);
        Test.stopTest();
        
        System.assert(true);
    }
    
}