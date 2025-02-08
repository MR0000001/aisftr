@istest
public class XC_TR_ProductRequired_TEST {
    static testmethod void testHandler(){
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        List<Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
        contr[0].AccountId=accList[0].id;
        contr[0].XC_PurchasingOrganization__c='ok';
        contr[0].XC_CompanyCode__c='7777';
        insert contr;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        insert wo;         
        WorkOrderLineItem woli = new WorkOrderLineItem();
        Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_TA_WOLI').getRecordTypeId();
        woli.WorkOrderId= wo[0].Id;
        woli.XC_AccountId__c=accList[0].id;
        woli.XC_ContractId__c= contr[0].id;
        woli.XC_PurchasingOrganization__c='ok';
        woli.XC_PurchasingGroup__c='ok';
        insert woli;
        
        Product2 prod = new Product2();
        prod.name='test';
        insert prod;
        ProductRequired pr = new ProductRequired();
        pr.ParentRecordId=woli.id;
        pr.Product2Id=prod.Id;
        insert pr;
        update pr;
        delete pr;
        Map<Id, SObject> mapNew = new Map<Id, SObject>();
        mapNew.put(pr.id,pr);
        (new XC_TR_ProductRequired_Handler()).onAfterUnDelete(mapNew);
    }
}