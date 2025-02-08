@istest
public class XC_UTIL_ReadGloviaInfoODA_TEST {
    static testmethod void retrivePositionInfo()
    {
        //   try{
        Test.setMock(HttpCalloutMock.class, new XC_UTIL_FSLLogistic_Mock());
        test.startTest();
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        List<Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
        contr[0].AccountId=accList[0].id;
        contr[0].XC_PurchasingOrganization__c='ITE1';
        contr[0].XC_PurchasingGroup__c='IEX';
        contr[0].XC_CompanyCode__c='IT2K';
        contr[0].XC_ContractType__c  ='SERVICE';
        contr[0].EndDate = System.today().addDays(2);
        insert contr;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        insert wo;         
        WorkOrderLineItem woli = new WorkOrderLineItem();
        Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_TA_WOLI').getRecordTypeId();
        woli.WorkOrderId= wo[0].Id;
        woli.XC_AccountId__c=accList[0].id;
        //woli.XC_ContractId__c= contr[0].id;
        woli.XC_PurchasingOrganization__c='ITE1';
        woli.XC_PurchasingGroup__c='IEL';
        woli.Status='Approved';
        insert woli;
        woli.XC_ContractId__c= contr[0].id;
        update woli;
        String recordId = woli.Id;
        system.debug('string id '+' '+ recordId);
        XC_LCC205_SendSAP.retrivePositionInfo(recordId);
        test.stopTest();  
        //      }catch(Exception e){
        //   system.debug(e.getMessage());
        //}
    }
    
    
    static testmethod void retrivePoLInformation()
    {
        try{
            test.startTest();
            List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
            insert accList;
            List<Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
            contr[0].AccountId=accList[0].id;
            contr[0].XC_PurchasingOrganization__c='ITE1';
            contr[0].XC_PurchasingGroup__c='IEX';
            contr[0].XC_CompanyCode__c='IT2K';
            contr[0].XC_ContractType__c  ='SERVICE';
            contr[0].EndDate =System.today().addDays(2);
            insert contr;
            List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
            insert wo;         
            WorkOrderLineItem woli = new WorkOrderLineItem();
            Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_TA_WOLI').getRecordTypeId();
            woli.WorkOrderId= wo[0].Id;
            woli.XC_AccountId__c=accList[0].id;
            
            woli.XC_PurchasingOrganization__c='ITE1';
            woli.XC_PurchasingGroup__c='IEL';
            woli.Status='Approved';
            insert woli;
            woli.XC_ContractId__c= contr[0].id;
            update woli;
            
            Product2 prod = new Product2();
            prod.name='test';
            insert prod;
            ProductRequired pr = new ProductRequired();
            pr.ParentRecordId=woli.id;
            pr.Product2Id=prod.Id;
            insert pr;
            
            
            
            XC_RequiredPosition__c poLine = new XC_RequiredPosition__c();
            poLine.XC_WorkOrderLineItem__c=woli.id;
            poLine.XC_UnitRequisitioner__c='ok';
            poLine.XC_Plant__c='ok';
            poLine.XC_AccountAssignmentCategory__c='o';
            poLine.XC_PositionCode__c='test';
            poLine.XC_PricebookEntry__c='TEST';
            poLine.Name='ok';
            poLine.XC_Quantity__c=0;
            poLine.XC_ProductRequired__c=pr.id;
            insert poLine;
            String recordId = woli.Id;
            XC_LCC205_SendSAP.retrivePoLInformation(recordId);
            XC_LCC205_SendSAP.checkAndSendToSAP(recordId, '1234');
            XC_UTIL_ReadGloviaInfoODA.getContractSAP(recordId);
            test.stopTest();  
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    static testmethod void getContractSAP()
    {
        try{
            test.startTest();
            List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
            insert accList;
            List<Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
            contr[0].AccountId=accList[0].id;
            contr[0].XC_PurchasingOrganization__c='ITE1';
            contr[0].XC_PurchasingGroup__c='IEX';
            contr[0].XC_CompanyCode__c='IT2K';
            contr[0].XC_ContractType__c  ='SERVICE';
            contr[0].EndDate =System.today().addDays(2);
            insert contr;
            List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
            insert wo;         
            WorkOrderLineItem woli = new WorkOrderLineItem();
            Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_TA_WOLI').getRecordTypeId();
            woli.WorkOrderId= wo[0].Id;
            woli.XC_AccountId__c=accList[0].id;
            
            woli.XC_PurchasingOrganization__c='ITE1';
            woli.XC_PurchasingGroup__c='IEL';
            woli.Status='Approved';
            insert woli;
            woli.XC_ContractId__c= contr[0].id;
            update woli;
            
            Product2 prod = new Product2();
            prod.name='test';
            insert prod;
            ProductRequired pr = new ProductRequired();
            pr.ParentRecordId=woli.id;
            pr.Product2Id=prod.Id;
            insert pr;
                 
            
            XC_RequiredPosition__c poLine = new XC_RequiredPosition__c();
            poLine.XC_WorkOrderLineItem__c=woli.id;
            poLine.XC_UnitRequisitioner__c='ok';
            poLine.XC_Plant__c='ok';
            poLine.XC_AccountAssignmentCategory__c='o';
            poLine.XC_PositionCode__c='test';
            poLine.XC_PricebookEntry__c='TEST';
            poLine.Name='ok';
            poLine.XC_Quantity__c=0;
            poLine.XC_ProductRequired__c=pr.id;
            insert poLine;
            String recordId = woli.Id;
            XC_UTIL_ReadGloviaInfoODA.getContractSAP(recordId);
            test.stopTest();  
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    
}