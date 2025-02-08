@isTest 
public class XC_SC067_LoaContractStatusUpdate_Test 
{
    static testMethod void testLOAStatusUpdate() 
    {
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EnelXItalia';
        admin.XC_EnabledToSkip__c = true;
        insert admin;
        System.runAs(admin){ 
            Account acc = New Account();    
            acc.Name = 'TEST 2';
            acc.PrimaryEmail__c = 'test@test.com';
            insert acc;
            
            List<Contract> lstCon= new List<Contract>();
            Contract con = new Contract();
            con.AccountId = acc.Id;
            con.RecordTypeID = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('XC_LOA').getRecordTypeId();
            con.Status = 'New';
            con.XC_LOA_Start_Date__c = Date.today().addMonths(-5);
            con.XC_LOA_Validity__c = 1;
            lstCon.add(con);
            insert lstCon;
    
            con.XC_LOA_Signed__c = true;
            con.Status = 'Authorized';
            update con;
            /*List<Contract> enddate = [Select Id,XC_LOA_End_Date__c from Contract where Id =:lstCon[0].Id];
            System.debug('value is:'+enddate[0].XC_LOA_End_Date__c);*/
            //List<Contract> con = [Select Id,XC_LOA_End_Date__c,XC_LOA_Status__c, XC_LOA_Signed__c,RecordType.DeveloperName from Contract where Id = '8005t000003C1nPAAS'];
            System.debug('value is:'+lstCon[0]);
            Test.startTest();
                String chron = '0 0 23 * * ?';        
                System.schedule('Test_LOA', chron, new XC_SC067_LoaContractStatusUpdate());
            Test.stopTest();
        }
    }
}