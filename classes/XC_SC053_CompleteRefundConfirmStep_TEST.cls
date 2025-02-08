/**
* @author Marina Ciavarra - mciavarra@deloitte.it
* @date Creation 12/05/2021
* @description XC_SC053_CompleteRefundConfirmStep_TEST – Test class for XC_SC053_CompleteRefundConfirmationStep
*/

@isTest
public class XC_SC053_CompleteRefundConfirmStep_TEST {

    static testMethod void testBatch(){

        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        Case caseTest = new Case();
        caseTest.Status = 'ESTA001';
        caseTest.Reason = 'XCMOT010';
        caseTest.AccountId = accounts[0].Id;
        caseTest.XC_Type_Intermediary__c = 'TI001';
        insert caseTest;
        List<Account> accList = [SELECT id FROM Account LIMIT 1];
        List<Contact> contactList = [SELECT id FROM Contact LIMIT 1];
        List<Case> caseList = [SELECT id FROM Case LIMIT 1];
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(accList);
        insert addressList;

        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        subscription.Zuora__OriginalId__c = '123';
        subscription.Zuora__PreviousSubscriptionId__c = '123';
        subscription.Zuora__External_Id__c = '123';
        subscription.Zuora__SubscriptionNumber__c = '123';
        subscription.Zuora__Account__c = accList[0].Id;
        insert subscription;
        Zuora__Subscription__c sub = [SELECT id, name FROM Zuora__Subscription__c LIMIT 1 ];

        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP0000123';
        opportunityToInsert.AccountId = accList[0].Id;
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = addressList[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        opportunityToInsert.XC_PipelineStatus__c = 'Qualified potential opportunity';
        insert opportunityToInsert;
        //Opportunity opp =[SELECT id FROM Opportunity LIMIT 1];
        NE__Order__c order =  XC_DF_Order.createOrderWithAddress('In Order', addressList[0].ID, accList[0].ID, opportunityToInsert.ID);
        order.XC_CaseId__c = caseList[0].ID;
        update order;
        NE__OrderItem__c configItem = [SELECT Id FROM NE__OrderItem__c LIMIT 1];
        
        //create asset
        List<Asset> assetList = XC_DF_Asset.createAssets(accList);
        assetList[0].XC_SubscriptionName__c = sub.Name;
        assetList[0].XC_Configuration_Item__c = configItem.ID;
        insert assetList;

        Zuora__CustomerAccount__c ca1 = new Zuora__CustomerAccount__c(Zuora__Account__c = accList[0].Id, Zuora__Zuora_Id__c = '123', Zuora__External_Id__c = '123');
        insert ca1;

        Zuora__Refund__c refund = new Zuora__Refund__c();
        refund.Zuora__BillingAccount__c = ca1.Id;
        refund.Zuora__Amount__c = 123;
        refund.SubscriptionName__c = sub.Name;
        refund.Value_Date__c = Date.today();
        insert refund;

        //create provisionig step
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = configItem.ID;
        provisioningStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;



        Test.startTest();
        String chron = '0 0 23 * * ?';
        system.schedule('Test Sched053', chron,  new XC_SC053_CompleteRefundConfirmationStep());
        Test.stopTest();
    }

}