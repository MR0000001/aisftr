@isTest
public class XC_TR_Configuration_Handler_TEST {
 @isTest
    static void insertTest() {
        OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        NE__Order__c z = new NE__Order__c();
        List<NE__Order__c> listZ = new List<NE__Order__c>();
        Map<Id,NE__Order__c> mapNew = new Map<id,NE__Order__c>();
        XC_TR_Configuration_Handler zu = new XC_TR_Configuration_Handler();
        //zu.onAfterUpdate();
        zu.onBeforeInsert(listZ);
        zu.onBeforeUpdate(mapNew,mapNew);
        zu.onAfterInsert(mapNew);
        zu.onAfterUpdate(mapNew,mapNew);
        zu.onAfterDelete(mapNew);
        zu.onAfterUnDelete(mapNew);
        zu.onBeforeDelete(mapNew);
        zu.executedTrigger();

    }
}