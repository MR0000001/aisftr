/**
 * The Class XC_TR_ZuoraCustomerAccountHandlerTEST
 *
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation 25/07/2019
 * @description XC_TR_ZuoraCustomerAccountHandlerTEST – Test class for  XC_TR_ZuoraCustomerAccount_Handler 
 */

@isTest
public class XC_TR_ZuoraCustomerAccountHandler_TEST {
    
    @isTest
    static void checkZuoraTest(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Test.startTest();
        Zuora__CustomerAccount__c zu = new Zuora__CustomerAccount__c(); 
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;
        zu.Zuora__Account__c = accs[0].id;
        insert zu; 
        zu.Zuora__AccountNumber__c = '3';
        update zu;
        delete zu;
        undelete zu;
        
        Test.stopTest();

}
    
}