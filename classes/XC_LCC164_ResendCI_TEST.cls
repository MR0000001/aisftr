/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 06/02/2020
* @date Modification dd/mm/yyyy
* @description XC_LCC164_ResendCI_TEST – Test Class of XC_LCC164_ResendCI
*/ 

@isTest
public class XC_LCC164_ResendCI_TEST {
    
     @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

	static testMethod void onInsert() {
        Test.startTest();
        List<XC_Customer_Interaction__c> ciList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        insert ciList;
		XC_UTIL_ResultWrapper rw = XC_LCC164_ResendCI.resend(ciList[0].Id,'test@email.com');
        XC_LCC164_ResendCI.getEmails(ciList[0].Id);
        System.assertEquals(true, rw != null);
        Test.stopTest();
    }    

}