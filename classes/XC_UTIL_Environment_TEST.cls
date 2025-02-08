/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  21/05/2019 
* @description XC_UTIL_Environment_TEST – Test class for XC_UTIL_Environment  
*/
@istest
public class XC_UTIL_Environment_TEST{
    
    //Test Method isMobileOrCommunityExperience
    static testMethod void isMobileOrCommunityExperience(){ 
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();        
        
        string st = XC_UTIL_Environment.isMobileOrCommunityExperience();
        
        System.assertEquals(true, st!=null);
        Test.stopTest();
        
    }
    
    
    //Test Method isMobileExperience
    static testMethod void isMobileExperience(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();        
        
        boolean bl = XC_UTIL_Environment.isMobileExperience();
        
        System.assertEquals(true, bl!=null);
        Test.stopTest();
        
    }
    
    //Test Method isSystemAdmin
    static testMethod void isSystemAdmin(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();        
        
        boolean bln = XC_UTIL_Environment.isSystemAdmin();
        
        System.assertEquals(true, bln!=null);
        Test.stopTest();
        
    }
    
    //Test Method isCommunity
    static testMethod void isCommunity(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();        
        
        boolean bln = XC_UTIL_Environment.isCommunity();
        
        System.assert(!bln);
        Test.stopTest();
        
    }
}