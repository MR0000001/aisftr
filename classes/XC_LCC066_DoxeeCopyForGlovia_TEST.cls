/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date Creation  16/05/2019
* @description Test Class for XC_LCC066_Doxee / Canvas / Doxee 
*/ 
@isTest
public class XC_LCC066_DoxeeCopyForGlovia_TEST {
    static testMethod void fetchUserTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        Test.startTest();
        XC_LCC066_DoxeeCopyForGlovia.WrapperUser wr = new XC_LCC066_DoxeeCopyForGlovia.WrapperUser();
        wr.username  = 'test@test.com';
        wr.country   = 'SPAIN';
        wr.company   = 'ENDESAX-B2C';
        User u = XC_DF_User.createUserAdmin();
        insert u;
        String userid = u.Id;
        XC_LCC066_DoxeeCopyForGlovia.fetchUser(userid);
        System.assert(!String.isEmpty(userid));
        Test.stopTest();
    }
    static testMethod void getUserInformationTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        /*
        String getUser = XC_LCC066_Doxee.getUserInformation();
        System.assertEquals(true,!String.isEmpty(getUser));
        */
        Test.stopTest();
        
    }
    
  }