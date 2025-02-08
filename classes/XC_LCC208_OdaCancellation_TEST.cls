@istest
public class XC_LCC208_OdaCancellation_TEST {
static testmethod void retrivePositionInfo()
    {
    test.startTest();
    List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
    insert accList;
    List<Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
    contr[0].AccountId=accList[0].id;
     contr[0].XC_ContractType__c ='SERVICE';
     contr[0].EndDate = date.newInstance(2030, 12, 17);
    insert contr;
	List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
    insert wo;         
    WorkOrderLineItem woli = new WorkOrderLineItem();
    Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2GEnelXItaliaPartnerPayment').getRecordTypeId();
    woli.WorkOrderId= wo[0].Id;
    woli.XC_AccountId__c=accList[0].id;
    woli.XC_ContractId__c= contr[0].id;
    woli.XC_PurchasingOrganization__c='ok';
    woli.XC_PurchasingGroup__c='ok';
    woli.Status='Completed';
    woli.XC_PartnerEngagement__c=woli.id;
    woli.XC_Oda_Cancellation_Sent__c=false;
    insert woli;
    Id recordId =woli.id;
    XC_LCC208_OdaCancellation.submit(recordId);
    woli.XC_Oda_Cancellation_Sent__c=true;
    update woli;
    XC_LCC208_OdaCancellation.submit(recordId);
    test.stopTest();  
    }

}