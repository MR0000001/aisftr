/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC004_EmailMessageTable_TEST 
*/  
@isTest
public class XC_LCC004_EmailMessageTable_TEST {

 /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test dataQuery method
*/
static testMethod void dataQueryTest(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
    	EmailMessage e = new EmailMessage();
        e.RelatedToId=accList[0].id;
    	e.MessageDate = Date.today();
	    insert e;
        List<EmailMessage> eList = XC_LCC004_EmailMessageTable.dataQuery(accList[0].id);
        System.assert(!eList.isEmpty());
    Test.stopTest();
    
   
    }
    
    
}