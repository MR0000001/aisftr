/**
 * The Class XC_AMP_LCC013_PartnerLogoView_TEST.
 *
 * @author            : Luisana Rocco - lrocco@deloitte.it
 * @date Creation     : 26/01/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_AMP_LCC013_PartnerLogoView 
 **/

@isTest
public  without sharing  class XC_AMP_LCC013_PartnerLogoView_TEST {
    
    @TestSetup
    static void setup(){
        List<Account> partnerAccountList = XC_DF_Account.insertPartnerAccounts(1, Label.XC_CL_Account_StatusActive);
        partnerAccountList[0].XC_AMP_LogoURL__c = 'test.com';
        update partnerAccountList;


        List<Contact> partnerContactList = XC_DF_Contact.createPartnerContacts(partnerAccountList);
        insert partnerContactList;

        User communityUser = XC_DF_User.createAutomotiveCommunityUsers(partnerContactList,false)[0];
        insert communityUser;
    
    }

    @isTest
    public static void getLogoUrlTest(){

        User automotivePortalUser = [SELECT id, profileId, userRoleId FROM User WHERE Contact.Account.XC_AMP_LogoURL__c  = 'test.com' LIMIT 1];
  
        Test.startTest();
        System.runAs(automotivePortalUser) {
            String result = XC_AMP_LCC013_PartnerLogoView.getLogoUrl();
            System.assert(result!=null, 'Wrong assert result');
        }
        test.stopTest();
    } 
}