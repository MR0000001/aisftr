@istest
public class XC_TR_U_WOChangePartnerPreferred_test {
static testmethod void WOChangePartnerPreferred()
{
    test.startTest();
    User u = XC_DF_User.createUserAdmin();
    insert u;
    List<Account> accList = XC_DF_Account.insertPartnerAccounts(2,'Active');
    ServiceResource Servu=new ServiceResource();
    Servu.XC_IsManager__c=false;
    Servu.RelatedRecordId=u.id;
    Servu.Name='test';
    insert Servu;
    List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
    wo[0].XC_PreferredPartner__c=accList[0].id;   
    wo[0].XC_AssignedResource__c=Servu.id;
    insert wo; 
    WorkOrder wor=wo[0].clone(true,false,false,false);   
    wo[0].XC_PreferredPartner__c=accList[1].id;
    update wo;
    ServiceAppointment saList= new ServiceAppointment();
    saList.ParentRecordId=wo[0].id;
    saList.XC_AssignToPartner__c=true;
    insert saList;
    Map<id,WorkOrder> mapOld= new Map <id,WorkOrder>();
    mapOld.put(wo.get(0).id,wo.get(0));
    Map<id,WorkOrder> mapNew= new Map <id,WorkOrder>();
    mapNew.put(wor.id,wor);
	System.assert(wo!=null);
    XC_TR_U_WOChangePartnerPreferred.WOChangePartnerPreferred(mapNew,mapOld);
    test.stopTest();
    
}
}