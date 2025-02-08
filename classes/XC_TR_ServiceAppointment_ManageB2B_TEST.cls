@Istest
public class XC_TR_ServiceAppointment_ManageB2B_TEST {
static testMethod  void manageForAutoschedule (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    	test.startTest();
    	User u = XC_DF_User.createUserAdmin();
    	insert u;
    	List<WorkOrder> workOrderList = new List<WorkOrder>();
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Malfunctioning');
        insert workTypeToInsert;
        insert XC_DF_Address.createAddress(1);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        WorkOrder workOrderToInsert = new WorkOrder();
    	workOrderToInsert.XC_Segment__c ='B2B';
        workOrderToInsert.XC_WorkTypeCategory__c = 'Malfunctioning';
        workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
        workOrderToInsert.XC_LegalEntity__c = 'Cogenio';
        workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        workOrderToInsert.XC_Address__c = address.Id;
        workOrderToInsert.Street = address.XC_Address__c;
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderList.add(workOrderToInsert);
		insert workOrderList;
    	ServiceAppointment sa = new ServiceAppointment();
    	sa.ParentRecordId=workOrderToInsert.id;
    	sa.FSL__Auto_Schedule__c = true;
    	sa.EarliestStartTime=Datetime.now().addMinutes(10);
    	List<ServiceAppointment> sal = new list<ServiceAppointment>();
    	sal.add(sa);
    	insert sal;
    	
    	system.runAs(u){
       	XC_TR_ServiceAppointment_ManageB2B.manageForAutoschedule(sal);
        }
    	test.stopTest();
}
}