@istest
public class XC_TR_WO_MaintenancePlan_test {
static testMethod void createWO() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
    	User u = XC_DF_User.createUserAdmin();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
    	accList[0].XC_NDADocumentNeeded__c=true;
    	List<Contact> cont =XC_DF_Contact.createResidentialContacts(1);
    	accList[0].XC_ContactToNotify__c=cont[0].id;
    	insert cont;
        insert accList;	
    	List<XC_Address__c> addr= XC_DF_Address.createAddress(1);
        insert addr;
    	WorkType work= XC_DF_WorkType.createWorkType('Planned Maintenance');
    	insert work;
        MaintenancePlan mai = new MaintenancePlan();
    	mai.Frequency=1;
    	mai.StartDate=date.today();
    	mai.NextSuggestedMaintenanceDate=date.today();
    	mai.GenerationTimeframe=1;
    	mai.XC_LegalEntity__c='EnelXItalia';
    	mai.XC_Segment__c='B2B';
    	mai.XC_Address__c=addr[0].id;
    	mai.WorkTypeId=work.id;
    	insert mai;
    	List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1,'Planned Maintenance');
    	wo[0].SuggestedMaintenanceDate=date.today();
    	wo[0].MaintenancePlanId= mai.id;
    	insert wo;    
    	insert u;
    	System.assert(wo!=null);
    	Test.stopTest();
}
}