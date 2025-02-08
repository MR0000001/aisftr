@isTest
public with sharing class XC_Constants_TEST {

    @isTest
    static void test_method(){
        Map<String,String> mapisocode;
        User contextuser = [SELECT Id FROM USer WHERE Id =: UserInfo.getuserId()];
        Test.startTest();
        System.runAs(contextuser){
           mapisocode=Constants.COUNTRY_ISO_CODES;
           String ISO=mapisocode.get(Constants.CHILE);
           User myUser=Constants.userInContext;
          Map<String,XC_CM_OneOrgFW__mdt> mapStrinOne=Constants.coreSkipTrigger;

        }
        Test.stopTest();
        
    } {

    }

}