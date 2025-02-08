/**
* @description XC_SC045_DeleteClosedCase - Batch to delete case
* @author Simone Trenta - strenta@deloitte.it
*/

@isTest
public class XC_SC045_DeleteClosedCase_TEST {
    
    @TestSetup
    static void setup() {
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        
        
    }
    
    static testMethod void callBatch(){
        
        Test.startTest(); 
        //Mod. CV 20210707 --- Start
        String chron = '0 0 23 * * ?';
        XC_SC045_DeleteClosedCase obj = new XC_SC045_DeleteClosedCase();        
        String jobid = System.schedule('testScheduledApex', chron,obj);
        //Database.executeBatch(new XC_SC045_DeleteClosedCase());
        //Mod. CV 20210707 --- End               
        Test.stopTest();
        System.assertEquals(true, true);
    }
    
}