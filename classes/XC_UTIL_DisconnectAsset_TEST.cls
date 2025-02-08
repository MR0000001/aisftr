/**
*@author Riccardo Cossu - riccardo.cossu@nttdata.com
*@description Test Class for XC_UTIL_DisconnectAsset
*/
@isTest
private without sharing class XC_UTIL_DisconnectAsset_TEST {
    
    @isTest static void disconnectATest(){
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList; 
        Asset asst = new Asset();
        asst.Name = 'Test ';
        asst.AccountId = accountList[0].Id;
        insert asst; 
        NE__Order__c nO = XC_DF_Order.createOrder('InOrder');
        
        List<WorkOrder> wO = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        wO[0].AssetId = asst.Id;
        insert wO;
        
        XC_OrderSubtypeByCase__mdt oS = [SELECT OrderSubtype__c,Reason__c,SubCause__c FROM XC_OrderSubtypeByCase__mdt limit 1];
        String reason = oS.Reason__c;
        String subCause= oS.SubCause__c;
        String idorder = nO.Id;
        String subtype = 'InOrder';
        
        WorkOrder w = [SELECT id,AssetId FROM WorkOrder LIMIT 1];
        System.debug(LoggingLevel.FINEST,'## WorkOrder ##'+w);
        
        Id aId = w.AssetId;
        String assetId = String.valueOf(aId);
        System.debug(LoggingLevel.WARN,'@AssetID-->@'+assetId + '####### ASSET ID FORMAT ID #### '+aId);
        
        XC_UTIL_ResultWrapper pError = XC_UTIL_DisconnectAsset.populateError(asst);
        //XC_UTIL_ResultWrapper eV     = XC_UTIL_DisconnectAsset.evaluateIdOrder(idorder,subtype);
        //String gAsset                = XC_UTIL_DisconnectAsset.getAssetSubtypeByCaseSubtype(reason,subCause);
        String mReq =                  XC_UTIL_DisconnectAsset.manageRequestByClient(assetId);
        String mC   =                  XC_UTIL_DisconnectAsset.manageComplaint(assetId);
        
        System.assert(pError != null);
        //System.assert(eV !=  null);
        //System.assert(!String.isBlank(gAsset));
        //System.assert(!String.isBlank(mReq));
        System.assert(!String.isBlank(mC));
        
        Test.stopTest();
    }
    
    @isTest static void manageRequestByClientTEST() {

        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        insert listAsset;

        List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_Repair);
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);
        System.debug('### ' + listWO);

        update listAsset;

        System.debug([SELECT Id, (SELECT id, WorkTypeId, XC_WorkTypeCategory__c FROM WorkOrders) FROM Asset where id =: listAsset[0].Id]);

        Test.startTest();
            XC_UTIL_DisconnectAsset.manageRequestByClient(listAsset[0].Id);
        Test.stopTest();

    }

    @isTest static void manageRequestByClient2TEST() {

        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        insert listAsset;

        List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_PlannedMaintenance);
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);
        System.debug('### ' + listWO);
        
        update listAsset;
        
        listWO[0].Status = 'Assigned';
        update listWO;
        listWO[0].Status = 'In Progress';
        update listWO;

        System.debug([SELECT Id, (SELECT id, WorkTypeId, XC_WorkTypeCategory__c FROM WorkOrders) FROM Asset where id =: listAsset[0].Id]);

        Test.startTest();
            XC_UTIL_DisconnectAsset.manageRequestByClient(listAsset[0].Id);
        Test.stopTest();

    }
    
    @isTest static void manageComplaintTEST() {

        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        insert listAsset;

        List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);
        System.debug('### ' + listWO);

        update listAsset;

        System.debug([SELECT Id, (SELECT id, WorkTypeId, XC_WorkTypeCategory__c FROM WorkOrders) FROM Asset where id =: listAsset[0].Id]);

        Test.startTest();
            XC_UTIL_DisconnectAsset.manageComplaint(listAsset[0].Id);

            List<Case> listCase = XC_DF_Case.createCases(1);
            listCase[0].AccountId = listAsset[0].AccountId;
            listCase[0].ContactId = XC_DF_Contact.createCondominiumContacts(accountList)[0].Id;
            listCase[0].AssetId = listAsset[0].Id;
            insert listCase;
            XC_UTIL_DisconnectAsset.manageComplaint(listAsset[0].Id);
        Test.stopTest();

    }
    
    @isTest static void manageComplaintClaimApplicableTEST() {

        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accountList);
        insert contacts;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accountList);
        listAsset[0].ContactId = contacts[0].Id;
        insert listAsset;

        List<WorkOrder> listWO = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWO[0].AssetId = listAsset[0].Id;
        XC_UTIL_SObject.insertListRecords(listWO);
        System.debug('### ' + listWO);

        update listAsset;

        System.debug([SELECT Id, (SELECT id, WorkTypeId, XC_WorkTypeCategory__c FROM WorkOrders) FROM Asset where id =: listAsset[0].Id]);

        Test.startTest();
            XC_UTIL_DisconnectAsset.manageComplaint(listAsset[0].Id);

            Case caso = new Case();
        	caso.Reason = Label.XC_CL_CaseReason_ComplaintValue;
        	caso.SubCause__c = 'ATCL030';
        	//caso.Status = Label.XC_CL_Case_Status007;
            caso.AccountId = listAsset[0].AccountId;
            caso.ContactId = contacts[0].Id;
            caso.AssetId = listAsset[0].Id;
            insert caso;
        
        	Case casoToUpd = [SELECT Id FROM Case WHERE Id =: caso.Id];
        	casoToUpd.XC_Resolution__c = 'R019';
        	casoToUpd.XC_Result__c = 'RS001';
        	casoToUpd.CaseRemarks__c = 'test MC';
        	update casoToUpd;
        
            XC_UTIL_DisconnectAsset.manageComplaint(listAsset[0].Id);
        Test.stopTest();

    }
}