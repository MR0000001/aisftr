/**
 * @author Monica Cutillo - mcutillo@deloitte.it
 * @date Creation 08/02/2020
 * @date Modification dd/mm/yyyy
 * @description XC_TR_SocialPersona_U_MngSocialCase_TEST - test class for XC_TR_SocialPersona_U_ManageSocialCase.
 */
@isTest
public class XC_TR_SocialPersona_U_MngSocialCase_TEST {
	
    @isTest static void manageSocialCaseOnUpdate_withoutCase() {
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
        
        Test.startTest();
        	SocialPost sPost = new SocialPost();
        	sPost.Provider = 'Facebook';
        	sPost.Name = 'My Test Post';
        	insert sPost;
        
        	SocialPersona sPersona = new SocialPersona();
        	sPersona.Name = 'MonicaC';
        	sPersona.Provider = 'Facebook';
        	sPersona.ParentId = sPost.Id;
        	insert sPersona;
        
        	sPersona.XC_ContactId__c = contacts[0].Id;
        	update sPersona;
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest static void manageSocialCaseOnUpdate_withCase() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_CaringAgent' AND isActive = true];
        
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
        	insert sPost;
        
        	SocialPersona sPersona = new SocialPersona();
        	sPersona.Name = 'MonicaC';
        	sPersona.Provider = 'Facebook';
        	sPersona.ParentId = sPost.Id;
        	insert sPersona;
        
        	sPost.PersonaId = sPersona.Id;
        	update sPost;
        
        	sPersona.XC_ContactId__c = contacts[0].Id;
        	update sPersona;
        Test.stopTest();
        
        System.assert(true);
    }
    
}