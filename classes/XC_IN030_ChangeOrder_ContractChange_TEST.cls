/**
* @author Valeria Martino - valeria.martino@nttdata.com
* *@date Creation 22/08/2019
* @description XC_IN030_ChangeOrder_ContractChange_TEST test class for XC_IN030_ChangeOrder_ContractChange
*/
@isTest
public with sharing class XC_IN030_ChangeOrder_ContractChange_TEST {

    private static void setupRunAs(XC_Address__c addressAccount, Account acc,Opportunity opport, List<Contact> listContact, List<Account> listAccount){
        opport.StageName = 'Closed Lost'; //'Closed Won';
        opport.XC_LossReason__c = 'Other';
        update opport;
        //NE__Order__c ord = XC_DF_Order.createOrderWithAddress('InOrder',addressAccount.Id,acc.Id,opport.Id);
        /*//ord.NE__OptyId__c = opport.id;
        //listOrder[0].NE__AccountId__c = acc.id;
        //listOrder[0].XC_DeliveryAddress__c = addressAccount.Id;
        //insert ord;
        //NE__Order__c order = listOrder[0];
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(ord);
        insert ordIt;*/

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'ChangeOrder';//'InOrder';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        order.XC_Status__c = 'Closed';
        order.XC_InstallationAddress__c = addressAccount.Id;
        order.XC_DeliveryAddress__c = addressAccount.Id;
        order.NE__OptyId__c = opport.Id;
        order.NE__AccountId__c = acc.id;
        order.XC_Subtype__c = Label.XC_CL_ChangeOfOwnership;
        order.XC_Type__c = Label.XC_CL_ChangeOwnerWithSubrogation;
        insert order;
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        ordIt.XC_Installation_Address__c = addressAccount.Id;
        ordIt.NE__Account__c = acc.id;
        insert ordIt; 

        
        /*List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_SiteInspection);
        listWorkOrder[0].XC_Configuration_Item__c =  ordIt.Id;
        insert listWorkOrder;*/
        
        Asset asst = new Asset();
        asst.Name = 'Test 1';
        asst.AccountId = acc.id;//listAccount[0].id;
        asst.ContactId = listContact[0].id;
        asst.XC_Configuration_Item__c = ordIt.Id; 
        asst.NE__Order_Config__c = order.id;
        asst.XC_Segment__c = 'B2C';
        asst.XC_LegalEntity__c=  'EndesaX';
        insert asst;
        //asst.NE__Order_Config__c = ord.id;
        //update asst;
      
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        
        insert provisioningStep;
    }
    
    @testSetup
    private static void setup() {

        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        org.XC_Spain_ValidationRules__c = true;
        insert org;
 
        /*List<ServiceResource> listServiceResource= XC_DF_ServiceResource.createServiceResources(1);
        listServiceResource[0].Name = Label.XC_CL_NoCandidateFound;
        List<User> usrList = [SELECT ID FROM User WHERE Profile.Name = 'System Administrator' and isActive = true LIMIT 1];
        listServiceResource[0].RelatedRecordId = usrList[0].Id;
        update listServiceResource;*/

        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        for(Account accc : listAccount){
            accc.Name = 'Test1';
        }
        insert listAccount;
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(listAccount);
        insert listContact;
        Account acc = listAccount[0];
        List<XC_Address__c> addressAccountList = XC_DF_Address.createAddress(listAccount);
        XC_Address__c addressAccount = addressAccountList[0];
        addressAccount.XC_Account__c = acc.Id;
        insert addressAccount;        
        //List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        Opportunity opport = new Opportunity();
        opport.Name = 'Test Opp';
        opport.StageName = 'Draft';//In Progress';
        opport.XC_NumberOfConfiguration__c= 1; 
        opport.CloseDate = System.today();
        opport.AccountId = acc.Id;
        opport.XC_PrincingRegion__c = addressAccount.XC_PricinRegion__c;
        opport.XC_Segment__c = 'B2C';
        opport.XC_LegalEntity__c = 'EndesaX';
        insert opport;
        //opport.XC_NumberOfConfiguration__c= 1;
        /*opport.StageName = 'In Progress';
        update opport;*/
        
        
        setupRunAs(addressAccount, acc,opport, listContact,listAccount);
    }

    @isTest
    public static void contractChangeNoAddresses() {
        Test.startTest();
        List<XC_Provisioning_Step__c> psList = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];
        XC_Provisioning_Step__c ps = psList[0];
        List<NE__Order__c> listOrder = [SELECT Id, (SELECT Id, ContactId  FROM NE__Assets__r) FROM  NE__Order__c WHERE Id = :ps.XC_Configuration_Item__r.NE__OrderId__c LIMIT 1];
        List<Asset> listAsset = new List<Asset>();
        listAsset.addAll(listOrder[0].NE__Assets__r);
        List<XC_IN030_ChangeOrder_ContractChange.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        
        insertWo(ps, listAsset);

        List<String> listIdAsset = new List<String>();
        for(Asset asset: listAsset) {
            listIdAsset.add(asset.id);
           
        }  
        
        XC_IN030_ChangeOrder_ContractChange.callContractChange(listInputWrapper);
        Test.stopTest();
        System.assertEquals(1, psList.size());
    }

    @isTest
    public static void contractChangeWOStatusNotFinal() {
        Test.startTest();
        List<XC_Provisioning_Step__c> psList = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        XC_Provisioning_Step__c ps = psList[0];
        List<NE__Order__c> listOrder = [SELECT Id, (SELECT Id, ContactId FROM NE__Assets__r) FROM  NE__Order__c WHERE Id = :ps.XC_Configuration_Item__r.NE__OrderId__c LIMIT 1];
        List<Asset> listAsset = new List<Asset>();
        List<String> listIdAsset = new List<String>();
        listAsset.addAll(listOrder[0].NE__Assets__r);
        for(Asset asset: listAsset) {
            listIdAsset.add(asset.id);
           
        }    
        
        //insertWo(ps, listAsset);

        List<Asset> listAssetChild = [SELECT Id, ContactId, (SELECT Id, Status, ContactId FROM Cases WHERE Status = 'Closed'), (SELECT Id, XC_Check_Final_Status__c FROM WorkOrders) FROM  Asset WHERE Id IN :listIdAsset];
        
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        listWorkOrder[0].Status = 'New';
        listWorkOrder[0].AssetId = listAsset[0].id; 
        insert listWorkOrder;
    
        List<XC_IN030_ChangeOrder_ContractChange.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        
        XC_IN030_ChangeOrder_ContractChange.callContractChange(listInputWrapper);
        Test.stopTest();
        System.assertEquals(1, psList.size());
    }

    @isTest
    public static void contractChangeOpportStatusNotFinal() {
        Test.startTest();
        /*List<XC_Provisioning_Step__c> psList = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];
        XC_Provisioning_Step__c ps = psList[0];
        List<XC_IN030_ChangeOrder_ContractChange.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        List<NE__Order__c> listOrder = [SELECT Id, (SELECT Id, ContactId FROM NE__Assets__r), NE__OptyId__r.Stagename, NE__OptyId__c FROM  NE__Order__c WHERE Id = :ps.XC_Configuration_Item__r.NE__OrderId__c LIMIT 1];
        List<Asset> listAsset = new List<Asset>();
        List<String> listIdAsset = new List<String>();
        listAsset.addAll(listOrder[0].NE__Assets__r);
        for(Asset asset: listAsset) {
            listIdAsset.add(asset.id);
           
        }    
        
        insertWo(ps, listAsset);
        
        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        //o[0].XC_NumberOfConfiguration__c = 1;
        o[0].StageName = 'Draft';//'In Progress';
        insert o;
        List<Opportunity> oppinserted = [SELECT Id,StageName, XC_NumberOfConfiguration__c FROM Opportunity LIMIT 1];
        system.debug('@#@#@#@#@11111 status-->'+ oppinserted[0].StageName);
        //Opportunity o = oppinserted[0];
        NE__Order__c orderToUpdate = listOrder[0];
        orderToUpdate.NE__OptyId__c = o[0].Id;
        update orderToUpdate;
        
        oppinserted[0].XC_NumberOfConfiguration__c= 1;
        oppinserted[0].StageName = 'In Progress';
        update oppinserted;
        
        XC_IN030_ChangeOrder_ContractChange.callContractChange(listInputWrapper);
        Test.stopTest();
        System.assertEquals(1, psList.size());*/
    }
     @isTest
    public static void contractChangeWithAddress() {
        Test.startTest();
        List<XC_Provisioning_Step__c> psList = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];
        XC_Provisioning_Step__c ps = psList[0];
        List<XC_IN030_ChangeOrder_ContractChange.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        List<NE__Order__c> listOrder = [SELECT Id, NE__AccountId__c, (SELECT Id, ContactId, XC_Contract__c FROM NE__Assets__r) FROM  NE__Order__c WHERE Id = :ps.XC_Configuration_Item__r.NE__OrderId__c LIMIT 1];
        List<Asset> listAsset = new List<Asset>();
        List<String> listIdAsset = new List<String>();
        listAsset.addAll(listOrder[0].NE__Assets__r);
        for(Asset asset: listAsset) {
            listIdAsset.add(asset.id);
           
        }    
        
        insertWo(ps, listAsset);

        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(2);
        listAddress[0].XC_Account__c = listOrder[0].NE__AccountId__c;
        insert listAddress;
        listAsset[0].XC_Address__c =  listAddress[1].id;
        update listAsset;
        
        XC_IN030_ChangeOrder_ContractChange.callContractChange(listInputWrapper);
        List<Asset> listAsset2 =XC_DF_Asset.createAssets(1);
        listAsset2[0].XC_Contract__c = listAsset[0].XC_Contract__c;
        insert listAsset2;
        XC_IN030_ChangeOrder_ContractChange.callContractChange(listInputWrapper);
        Test.stopTest();
        System.assertEquals(1, psList.size()); 
    }

    private static List<XC_IN030_ChangeOrder_ContractChange.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {
        
        List<XC_IN030_ChangeOrder_ContractChange.InputWrapper> listWrapperInput = new List<XC_IN030_ChangeOrder_ContractChange.InputWrapper>();
        XC_IN030_ChangeOrder_ContractChange.InputWrapper wr = new XC_IN030_ChangeOrder_ContractChange.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }
    private static void insertWo(XC_Provisioning_Step__c ps, List<Asset> listAsset) {
        
        Asset asst = listAsset[0];
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        listWorkOrder[0].Status = Label.XC_CL_Completed;
        listWorkOrder[0].AssetId = asst.id;

        insert listWorkOrder;   
    }
    

    
    @isTest
    public static void contractChangeWOStatusNotFinalSkipBlock() {
        Test.startTest();
        List<XC_Provisioning_Step__c> psList = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        XC_Provisioning_Step__c ps = psList[0];
        List<NE__Order__c> listOrder = [SELECT Id,NE__AccountId__c,  (SELECT Id,AccountId, ContactId FROM NE__Assets__r) FROM  NE__Order__c WHERE Id = :ps.XC_Configuration_Item__r.NE__OrderId__c LIMIT 1];
        List<Asset> listAsset = new List<Asset>();
        List<String> listIdAsset = new List<String>();
        listAsset.addAll(listOrder[0].NE__Assets__r);
            
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_WorkType_Repair);
        listWorkOrder[0].Status = 'New';
        listWorkOrder[0].AssetId = listAsset[0].id; 
        insert listWorkOrder;

        List<ServiceAppointment> sa = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert sa;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.XC_AccountId__c =  listOrder[0].NE__AccountId__c;
        woli.WorkOrderId = listWorkOrder[0].Id;
        insert woli; 

        List<XC_IN030_ChangeOrder_ContractChange.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        
        XC_IN030_ChangeOrder_ContractChange.callContractChange(listInputWrapper);
        Test.stopTest();
        System.assertEquals(1, psList.size());
    }

    
    @isTest
    public static void contractChangeCaseStatusNotFinalSkipBlock() {
        
        Test.startTest();
        List<XC_Provisioning_Step__c> psList = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        XC_Provisioning_Step__c ps = psList[0];
        List<NE__Order__c> listOrder = [SELECT Id,NE__AccountId__c, XC_Contact__c, (SELECT Id,AccountId, ContactId FROM NE__Assets__r) FROM  NE__Order__c WHERE Id = :ps.XC_Configuration_Item__r.NE__OrderId__c LIMIT 1];
        List<Asset> listAsset = new List<Asset>();
        List<String> listIdAsset = new List<String>();
        listAsset.addAll(listOrder[0].NE__Assets__r);

        listAsset[0].AccountId = listOrder[0].NE__AccountId__c;
        update (listAsset[0]);

        List<String> caseSettingNames = new List<String>{'XC_NewMOPAfterUnbundling'};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get('XC_NewMOPAfterUnbundling'); 
        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        c.AccountId = listAsset[0].AccountId;
        c.AssetId = listAsset[0].id; 
        c.XC_Segment__c = 'B2C';
        c.XC_LegalEntity__c = 'EndesaX';
        insert(c);

        List<XC_IN030_ChangeOrder_ContractChange.InputWrapper> listInputWrapper = generateInputWrapper(ps);
      
        XC_IN030_ChangeOrder_ContractChange.callContractChange(listInputWrapper);
        Test.stopTest();
        System.assertEquals(1, psList.size());
    }
}