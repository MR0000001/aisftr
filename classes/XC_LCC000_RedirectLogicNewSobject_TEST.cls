/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC000_RedirectLogicNewSobject_TEST 
*/  
@isTest
public class XC_LCC000_RedirectLogicNewSobject_TEST { 

/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test getDefaultRecordType, opportunitySegment & opportunityLegalEntity
*/
static testMethod void getDefaultRecordTypeTest(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    String oppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        
    Test.startTest();    	
        String s = XC_LCC000_RedirectLogicNewSobject.getDefaultRecordType('Account');
    	String s1 = XC_LCC000_RedirectLogicNewSobject.opportunitySegment(oppRecordType);
    	String s2 = XC_LCC000_RedirectLogicNewSobject.opportunityLegalEntity('B2B');
        System.assert(s!=null);
        System.assert(s1!=null);
        System.assert(s2!=null);
    Test.stopTest();   
    }
    
/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test retriveReceivingChannel
*/
static testMethod void retriveReceivingChannelTest(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    System.Test.startTest();
    	User u = XC_DF_User.createUserAdmin();
        insert u;
        String s = XC_LCC000_RedirectLogicNewSobject.retriveReceivingChannel(u.id);
        System.assert(s!=null);
    Test.stopTest();
    }    
}