@istest
public class XC_TR_Case_U_CaseRepair_B2BG_TEST {
static testMethod void mapCaseRepairConfiguration()
	{
    test.startTest();
    List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c,XC_BusinessLine__c 
                                                                from XC_CM_Case_Repair_Configuration__mdt 
                                                               	where XC_B2BWONeeded__c=true
                                                              limit 1];

    Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration= new Map <string,XC_CM_Case_Repair_Configuration__mdt>();
   	mapCaseRepairConfiguration.put(caseRepairList.get(0).id,caseRepairList.get(0));
     
    test.stopTest();
    }
    static testMethod void mapCaseRepairConfiguration1()
	{
    test.startTest();
    List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id
                                                                from XC_CM_Case_Repair_Configuration__mdt 
                                                              limit 1];
    system.debug('CMDT= '+caseRepairList);        
    Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration= XC_TR_Case_U_CaseRepair_B2BG.mapCaseRepairConfiguration();
        //new Map <string,XC_CM_Case_Repair_Configuration__mdt>();
   //	mapCaseRepairConfiguration.put(caseRepairList.get(0).id,caseRepairList.get(0));
     system.debug('CMDT mappa= '+ mapCaseRepairConfiguration);
    test.stopTest();
    }
     static testMethod void findCMRecord()
	{
    test.startTest();
    List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c,XC_B2BWONeeded__c,XC_BusinessLine__c 
                                                                from XC_CM_Case_Repair_Configuration__mdt 
                                                               	where XC_B2BWONeeded__c=true
                                                              limit 1];
    Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration= new Map <string,XC_CM_Case_Repair_Configuration__mdt>();
   	mapCaseRepairConfiguration.put(caseRepairList.get(0).id,caseRepairList.get(0));
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        case c = new case();
        c.Status = 'ESTA001';
        c.XC_Subtype__c = 'XC199';
        c.reason='XCMOT002';
        c.SubCause__c='ATCL003';
		c.AccountId=accounts[0].id;
       	c.ContactId=contacts[0].id;
        insert c;
    //XC_TR_Case_U_CaseRepair_B2BG.findCMRecord(c,mapCaseRepairConfiguration);
    test.stopTest();
    }
      static testMethod void findCMRecord2()
	{
    test.startTest();
    List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c,XC_B2BWONeeded__c,XC_BusinessLine__c 
                                                                from XC_CM_Case_Repair_Configuration__mdt 
                                                               	where XC_B2BWONeeded__c=true
                                                              limit 1];

    Map<string,XC_CM_Case_Repair_Configuration__mdt> mapCaseRepairConfiguration= new Map <string,XC_CM_Case_Repair_Configuration__mdt>();
   	mapCaseRepairConfiguration.put(caseRepairList.get(0).id,caseRepairList.get(0));
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        case c = new case();
        c.Status = 'ESTA001';
        //c.XC_Subtype__c = 'XC199';
        c.reason='XCMOT002';
        c.SubCause__c='ATCL003';
		c.AccountId=accounts[0].id;
       	c.ContactId=contacts[0].id;
        insert c;
    XC_TR_Case_U_CaseRepair_B2BG.findCMRecord(c,mapCaseRepairConfiguration);
    test.stopTest();
    }
}