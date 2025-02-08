/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_ManageSubst_TEST – Test Class for XC_TR_WorkOrder_U_ManageSubstitution
*/ 

@isTest
public class XC_TR_WorkOrder_U_ManageSubst_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }

    static testMethod void onInsert(){
        insert XC_DF_WorkType.createWorkType('Return');
        insert XC_DF_WorkType.createWorkType('Delivery & Installation');
        List<WorkType> wt = [SELECT Id FROM WorkType];
        System.debug('@@@wt-->' +wt);
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
       
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Substitution);
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        //orderQueried.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        orderQueried.RecordType.DeveloperName = Label.XC_CL_Configuration_Order;
        update orderQueried;
        NE__Order__c orderQueriedAfterUpdate = [SELECT Id, XC_Status__c FROM NE__Order__c];
        System.debug('@@@orderQueriedAfterUpdate-->' +orderQueriedAfterUpdate);
        List<NE__OrderItem__c> orditemToUpdate = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id, XC_IsAProduct__c FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueriedAfterUpdate.Id];
        for(NE__OrderItem__c ordItem : orderItemInserted){
            ordItem.XC_IsAProduct__c = true;
            orditemToUpdate.add(ordItem);
        }
        update orditemToUpdate;
        List<NE__OrderItem__c> orderItemUpdated = [SELECT Id, XC_IsAProduct__c FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueriedAfterUpdate.Id];
        System.debug('@@orderItems-->'+ orderItemUpdated);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<Asset> assetToInsert = new List<Asset>(); 
        for (Asset a : assetList){
             a.XC_ActivationDate__c = System.now();
             a.XC_Configuration_Item__c = orderItemUpdated[0].Id;
             a.NE__Action__c = 'Remove';
             a.NE__Order_Config__c = orderQueriedAfterUpdate.Id;
            assetToInsert.add(a);
        }
        insert assetToInsert; 
        List<Asset> assetListInserted = [SELECT Id FROM Asset]; 
        XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c();
        provStep.XC_Configuration_Item__c = orderItemInserted[0].Id;
        provStep.XC_Flow_API_Name__c = Label.XC_CL_Provisioning_DeliveryInstallation;
        insert provStep;
        System.debug('@@@provStepInserted' + provStep);
        woList[0].XC_Provisioning_Step__c = provStep.Id;
        woList[0].XC_Configuration__c = orderQueriedAfterUpdate.Id;
        woList[0].AccountId = accList[0].Id;
        Test.startTest();
        insert woList[0];
        List<WorkOrder> listWoInserted = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listWoInserted.size());
        Test.stopTest();
    }
    
    static testMethod void onInsert2(){
        insert XC_DF_WorkType.createWorkType('Return');
        insert XC_DF_WorkType.createWorkType('Delivery & Installation');
        List<WorkType> wt = [SELECT Id FROM WorkType];
        System.debug('@@@wt-->' +wt);
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
       
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Substitution);
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        //orderQueried.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        orderQueried.RecordType.DeveloperName = Label.XC_CL_Configuration_Order;
        update orderQueried;
        NE__Order__c orderQueriedAfterUpdate = [SELECT Id, XC_Status__c FROM NE__Order__c];
        System.debug('@@@orderQueriedAfterUpdate-->' +orderQueriedAfterUpdate);
        List<NE__OrderItem__c> orditemToUpdate = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id, XC_IsAProduct__c FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueriedAfterUpdate.Id];
        for(NE__OrderItem__c ordItem : orderItemInserted){
            ordItem.XC_IsAProduct__c = true;
            orditemToUpdate.add(ordItem);
        }
        update orditemToUpdate;
        List<NE__OrderItem__c> orderItemUpdated = [SELECT Id, XC_IsAProduct__c FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueriedAfterUpdate.Id];
        System.debug('@@orderItems-->'+ orderItemUpdated);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<Asset> assetToInsert = new List<Asset>(); 
        for (Asset a : assetList){
             a.XC_ActivationDate__c = System.now();
             a.XC_Configuration_Item__c = orderItemUpdated[0].Id;
             a.NE__Action__c = 'Add';
             a.NE__Order_Config__c = orderQueriedAfterUpdate.Id;
            assetToInsert.add(a);
        }
        insert assetToInsert; 
        List<Asset> assetListInserted = [SELECT Id FROM Asset]; 
        XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c();
        provStep.XC_Configuration_Item__c = orderItemUpdated[0].Id;
        provStep.XC_Flow_API_Name__c = Label.XC_CL_Provisioning_DeliveryInstallation;
        insert provStep;
        System.debug('@@@provStepInserted' + provStep);
        woList[0].XC_Provisioning_Step__c = provStep.Id;
        woList[0].XC_Configuration__c = orderQueriedAfterUpdate.Id;
        woList[0].AccountId = accList[0].Id;
        woList[0].XC_Configuration_Item__c = orderItemUpdated[0].Id;
        Test.startTest();
        insert woList[0];
        List<WorkOrder> listWoInserted = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listWoInserted.size());
        Test.stopTest();
    }



}