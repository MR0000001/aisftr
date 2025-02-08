/**
 * The Class XC_TR_ZQuoteHandler_TEST
 *
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation 25/07/2019
 * @description XC_TR_ZQuoteHandler_TEST – Test class for  XC_TR_ZQuote_Handler 
 */

@isTest
public class XC_TR_ZQuoteHandler_TEST {
    
    @isTest
    static void checkZQuoteTest(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Test.startTest();
        zqu__Quote__c zu = new zqu__Quote__c(); 
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;
        zu.zqu__Account__c = accs[0].id;
        insert zu; 
        zu.zqu__Amendment_Name__c = 'Z';
        update zu;
        delete zu;
        undelete zu;
        
        Test.stopTest();

}
    
}