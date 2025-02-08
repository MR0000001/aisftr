/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 21/05/2019
* @date Modification dd/mm/yyyy
* @description  – XC_UTIL_ComplianceMaster_TEST - Class test for XC_UTIL_ComplianceMaster
*/
@isTest 
public with sharing class XC_UTIL_ComplianceMaster_TEST {
    /** 
* Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @description insert records
*/
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opport = oppList[0];
        opport.Name = 'TEST';
        opport.StageName = 'Draft';
        opport.CloseDate = Date.today();
        opport.AccountId= accounts[0].Id;
        insert opport;
        /*List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.NE__OptyId__c = opport.Id;
        insert order;
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;*/
        List<NE__OrderItem__c> confItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = confItemList[0];
        insert ordIt;
        NE__Order__c order = [SELECT Id FROM NE__Order__c LIMIT 1];
        order.NE__OptyId__c = opport.Id;
        update order;
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        Asset asst = listAsset[0];
        asst.XC_Configuration_Item__c = ordIt.Id;
        insert asst;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        
        insert provisioningStep;
        
        
    }
    
    static testMethod void complianceVerification2Test(){
        test.startTest();
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster1b = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();
        complianceMaster1.XC_Country__c = 'SPAIN';
        complianceMaster1.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1.XC_ProductCategory__c = 'Boiler';
        complianceMaster1.XC_Queue__c = 'Cola 1';
        complianceMaster1.XC_BillingModel__c = 'Recurring';
        complianceMaster1.XC_Probability__c = 100;
        complianceMaster1.XC_CommercialCode__c='abc';
        complianceMaster2.XC_Country__c = 'SPAIN';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_CommercialCode__c='abc';
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_ProductCategory__c = 'Boiler';
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster3.XC_CommercialCode__c='abc';
        complMasterList.add(complianceMaster1);
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        //complMasterList.add(complianceMaster1b);
        insert complMasterList;             
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN004_ComplianceVerification2.InputWrapper inputWr = new XC_IN004_ComplianceVerification2.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN004_ComplianceVerification2.InputWrapper> wrapperList = new List<XC_IN004_ComplianceVerification2.InputWrapper>();
        wrapperList.add(inputWr);
        
        
        XC_IN004_ComplianceVerification2.complianceVerification2(wrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 
    
    static testMethod void complianceVerification3Test(){
        test.startTest();
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        List<NE__OrderItem__c> orderItemList = [SELECT Id  FROM NE__OrderItem__c ];
        NE__OrderItem__c ordIt = orderItemList[0];

        NE__Order_Item_Attribute__c orderItemAttr = new NE__Order_Item_Attribute__c();
        orderItemAttr.Name = Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel;
        orderItemAttr.NE__Value__c = 'One Shot';
        orderItemAttr.NE__Order_Item__c = ordIt.Id;
        
        insert orderItemAttr;

        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster1b = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster4 = new XC_ComplianceMaster__c();

        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();
        Id recTypeComplianceFourId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_4).getRecordTypeId();
        complianceMaster1b.XC_Country__c = 'ITALY';
        complianceMaster1b.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1b.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1b.XC_ProductCategory__c = 'Air conditioning';
        complianceMaster1b.XC_Queue__c = 'Cola 5';
        complianceMaster1b.XC_Probability__c = 100;
        complianceMaster1b.XC_CommercialCode__c='abc';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_CommercialCode__c='abc';
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.XC_PaymentMethod__c = 'Credit Card';
        complianceMaster3.XC_BillingModel__c = 'Recurring';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_ProductCategory__c = 'Boiler';
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster3.XC_CommercialCode__c='abc';
        complianceMaster4.RecordTypeId = recTypeComplianceFourId;
        complianceMaster4.XC_ComplianceTypePicklist__c = 'C4';
        complianceMaster4.XC_ProductCategory__c = 'Boiler';
        complianceMaster4.XC_Queue__c = 'Cola 2';
        complianceMaster4.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster4.XC_Probability__c = 100;
        complianceMaster4.XC_CommercialCode__c='abc';
        //complMasterList.add(complianceMaster1);
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        complMasterList.add(complianceMaster4);

        complMasterList.add(complianceMaster1b);
        insert complMasterList;             
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN005_ComplianceVerification3.InputWrapper inputWr = new XC_IN005_ComplianceVerification3.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN005_ComplianceVerification3.InputWrapper> wrapperList = new List<XC_IN005_ComplianceVerification3.InputWrapper>();
        wrapperList.add(inputWr);
        
        
        XC_IN005_ComplianceVerification3.complianceVerification3(wrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 
    static testMethod void complianceVerification3bTest(){
        test.startTest();
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster1b = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();
        complianceMaster1b.XC_Country__c = 'ITALY';
        complianceMaster1b.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1b.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1b.XC_ProductCategory__c = 'Air conditioning';
        complianceMaster1b.XC_Queue__c = 'Cola 5';
        complianceMaster1b.XC_Probability__c = 100;
        complianceMaster1b.XC_CommercialCode__c='abc';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_CommercialCode__c='abc';
        complianceMaster2.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_ProductCategory__c = 'Boiler';
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster3.XC_CommercialCode__c='abc';
        complianceMaster1b.XC_Probability__c = 100;
        complianceMaster1b.XC_CommercialCode__c='abc';
        //complMasterList.add(complianceMaster1);
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        complMasterList.add(complianceMaster1b);
        insert complMasterList;             
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN005_ComplianceVerification3.InputWrapper inputWr = new XC_IN005_ComplianceVerification3.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN005_ComplianceVerification3.InputWrapper> wrapperList = new List<XC_IN005_ComplianceVerification3.InputWrapper>();
        wrapperList.add(inputWr);
        
        
        XC_IN005_ComplianceVerification3.complianceVerification3(wrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 
    
    static testMethod void complianceVerification2and3NoMatchTest(){
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster4 = new XC_ComplianceMaster__c();

        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();
        Id recTypeComplianceFourId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_4).getRecordTypeId(); 

        complianceMaster2.XC_Country__c = 'SPAIN';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_CommercialCode__c='abc';
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_ProductCategory__c = 'Air conditioning';
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster3.XC_CommercialCode__c='abc';
        complianceMaster4.XC_Country__c = 'SPAIN';
        complianceMaster4.RecordTypeId = recTypeComplianceFourId;
        complianceMaster4.XC_ComplianceTypePicklist__c = 'C4';
        complianceMaster4.XC_ProductCategory__c = 'Boiler';
        complianceMaster4.XC_Queue__c = 'Cola 2';
        complianceMaster4.XC_Probability__c = 100;
        complianceMaster4.XC_CommercialCode__c='abc';
        complianceMaster4.XC_ReceivingChannel__c = 'Web';
        complianceMaster4.XC_Source__c = 'BLOG';
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        complMasterList.add(complianceMaster4);

        insert complMasterList;             
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN005_ComplianceVerification3.InputWrapper inputWr = new XC_IN005_ComplianceVerification3.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN005_ComplianceVerification3.InputWrapper> wrapperList = new List<XC_IN005_ComplianceVerification3.InputWrapper>();
        wrapperList.add(inputWr);
        XC_IN004_ComplianceVerification2.InputWrapper inputWr2 = new XC_IN004_ComplianceVerification2.InputWrapper();
        inputWr2.stepId = step.Id;
        List<XC_IN004_ComplianceVerification2.InputWrapper> wrapperList2 = new List<XC_IN004_ComplianceVerification2.InputWrapper>();
        wrapperList2.add(inputWr2);
        
        XC_IN029_ComplianceVerification4.InputWrapper inputWr3 = new XC_IN029_ComplianceVerification4.InputWrapper();
        inputWr3.stepId = step.Id;
        List<XC_IN029_ComplianceVerification4.InputWrapper> wrapperList3 = new List<XC_IN029_ComplianceVerification4.InputWrapper>();
        wrapperList3.add(inputWr3);

        test.startTest();
        XC_IN004_ComplianceVerification2.complianceVerification2(wrapperList2);
        XC_IN005_ComplianceVerification3.complianceVerification3(wrapperList);
        XC_IN029_ComplianceVerification4.complianceVerification4(wrapperList3);

        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 
    
    static testMethod void complianceVerification1Test(){ 
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster1b = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster4 = new XC_ComplianceMaster__c();

        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();
        Id recTypeComplianceFourId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_4).getRecordTypeId();

        complianceMaster1.XC_Country__c = 'SPAIN';
        complianceMaster1.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1.XC_ProductCategory__c = 'Boiler';
        complianceMaster1.XC_Queue__c = 'Cola 1';
        complianceMaster1.XC_Probability__c = 100;
        complianceMaster1.XC_CommercialCode__c='abc';
        complianceMaster1.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster1.XC_ReceivingChannel__c = 'Web';
        complianceMaster1.XC_Source__c = 'BLOG';
        complianceMaster2.XC_Country__c = 'SPAIN';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_CommercialCode__c='abc';
        complianceMaster2.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_ProductCategory__c = 'Boiler';
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster3.XC_CommercialCode__c='abc';
        complianceMaster4.XC_Country__c = 'SPAIN';
        complianceMaster4.RecordTypeId = recTypeComplianceFourId;
        complianceMaster4.XC_ComplianceTypePicklist__c = 'C4';
        complianceMaster4.XC_ProductCategory__c = 'Boiler';
        complianceMaster4.XC_Queue__c = 'Cola 2';
        complianceMaster4.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster4.XC_Probability__c = 100;
        complianceMaster4.XC_CommercialCode__c='abc';
        complianceMaster4.XC_ReceivingChannel__c = 'Web';
        complianceMaster4.XC_Source__c = 'BLOG';
        complMasterList.add(complianceMaster1);
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        complMasterList.add(complianceMaster4);
        //complMasterList.add(complianceMaster1b);
        insert complMasterList;     
        
        test.startTest();
        XC_LCC069_ComplianceVerification1.checkCompliance1NeededOrToSkeep(order.Id);
        XC_LCC069_ComplianceVerification1.checkDocumentsComplianceVerification1(order.Id);
        test.stopTest();
        System.assertEquals(1, orderList.size());
    } 
    
    static testMethod void complianceVerification1bTest(){ 
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        complianceMaster1.XC_Country__c = 'SPAIN';
        complianceMaster1.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1.XC_ProductCategory__c = 'Boiler';
        complianceMaster1.XC_Queue__c = 'Cola 1';
        complianceMaster1.XC_Probability__c = 100;
        complianceMaster1.XC_CommercialCode__c='abc';
        complMasterList.add(complianceMaster1);
        insert complMasterList;     
        
        test.startTest();
        XC_LCC069_ComplianceVerification1.checkCompliance1NeededOrToSkeep(order.Id);
        XC_LCC069_ComplianceVerification1.checkDocumentsComplianceVerification1(order.Id);
        test.stopTest();
        System.assertEquals(1, orderList.size());
    } 
     
    static testMethod void complianceVerificationWithCustomerInteraction(){ 
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        XC_DocumentType__c docType = new XC_DocumentType__c();
        docType.Category__c = 'CE';
        docType.XC_Configuration__c = order.Id;
        insert docType;
        XC_DocumentComplianceMaster__c document = new XC_DocumentComplianceMaster__c();
        document.XC_ComplianceType__c = 'C1';
        document.XC_ProductCategory__c = 'Boiler';
        document.XC_DocumentType__c = 'DNI';
        document.XC_Country__c = 'SPAIN';
        insert document;
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster1b = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster4 = new XC_ComplianceMaster__c();

        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();
        Id recTypeComplianceFourId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_4).getRecordTypeId();

        complianceMaster1.XC_Country__c = 'SPAIN';
        complianceMaster1.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1.XC_ProductCategory__c = 'Boiler';
        complianceMaster1.XC_Queue__c = 'Cola 1';
        complianceMaster1.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster1.XC_Probability__c = 100;
        complianceMaster1.XC_CommercialCode__c='abc';
        complianceMaster2.XC_Country__c = 'SPAIN';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_CommercialCode__c='abc';
        complianceMaster2.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_ProductCategory__c = 'Boiler';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_CommercialCode__c='abc';
        complianceMaster4.XC_Country__c = 'SPAIN';
        complianceMaster4.XC_Probability__c = 100;
        complianceMaster4.RecordTypeId = recTypeComplianceFourId;
        complianceMaster4.XC_ComplianceTypePicklist__c = 'C4';
        complianceMaster4.XC_ProductCategory__c = 'Boiler';
        complianceMaster4.XC_Queue__c = 'Cola 2';
        complianceMaster4.XC_CommercialCode__c='abc';
        complianceMaster4.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complMasterList.add(complianceMaster1);
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        complMasterList.add(complianceMaster4);
        //complMasterList.add(complianceMaster1b);
        insert complMasterList;     
        
        test.startTest();
        XC_LCC069_ComplianceVerification1.checkCompliance1NeededOrToSkeep(order.Id);
        XC_LCC069_ComplianceVerification1.checkDocumentsComplianceVerification1(order.Id);
        test.stopTest();
        System.assertEquals(1, orderList.size());
    } 
    
    static testMethod void complianceVerification4Test(){
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster1b = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster4 = new XC_ComplianceMaster__c();

        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();
        Id recTypeComplianceFourId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_4).getRecordTypeId();

        complianceMaster1.XC_Country__c = 'SPAIN';
        complianceMaster1.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1.XC_ProductCategory__c = 'Boiler';
        complianceMaster1.XC_Queue__c = 'Cola 1';
        complianceMaster1.XC_Probability__c = 100;
        complianceMaster1.XC_BillingModel__c = 'Recurring';
        complianceMaster1.XC_CommercialCode__c='abc';
        complianceMaster2.XC_Country__c = 'SPAIN';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_CommercialCode__c='abc';
        complianceMaster2.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster3.XC_ProductCategory__c = 'Boiler';
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_CommercialCode__c='abc';
        complianceMaster4.XC_Country__c = 'SPAIN';
        complianceMaster4.RecordTypeId = recTypeComplianceFourId;
        complianceMaster4.XC_Probability__c = 100;
        complianceMaster4.XC_ComplianceTypePicklist__c = 'C4';
        complianceMaster4.XC_ProductCategory__c = 'Boiler';
        complianceMaster4.XC_Queue__c = 'Cola 2';
        complianceMaster4.XC_CommercialCode__c='abc';
        complianceMaster4.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complMasterList.add(complianceMaster1);
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        complMasterList.add(complianceMaster4);
        //complMasterList.add(complianceMaster1b);
        insert complMasterList;             
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN029_ComplianceVerification4.InputWrapper inputWr = new XC_IN029_ComplianceVerification4.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN029_ComplianceVerification4.InputWrapper> wrapperList = new List<XC_IN029_ComplianceVerification4.InputWrapper>();
        wrapperList.add(inputWr);
        
        test.startTest();
        XC_IN029_ComplianceVerification4.complianceVerification4(wrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 


    static testMethod void populateWrapperTest(){
        List <NE__OrderItem__c> listOrderItem = new List <NE__OrderItem__c>([SELECT Id 
                                                                            FROM NE__OrderItem__c]);
                                                                            
        XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwm = new XC_UTIL_ComplianceMaster.ComplianceWrapperResult();
        Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapConfItemTemplateName=  new Map <Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult>();
        XC_UTIL_ComplianceMaster.ComplianceWrapperCheck complianceWrap = new XC_UTIL_ComplianceMaster.ComplianceWrapperCheck();
        complianceWrap.mapConfItemTemplateName = mapConfItemTemplateName;
        complianceWrap.confItem = listOrderItem[0];
        XC_UTIL_ComplianceMaster.ComplianceWrapper compWrap = new XC_UTIL_ComplianceMaster.ComplianceWrapper();
        compWrap.country = 'SPAIN';
        compWrap.type = 'C1';
        compWrap.productCategory = 'Boiler';
        compWrap.salesPartner = null;
        compWrap.origin = 'SEO';
        compWrap.billingModel = 'Recurring';
        compWrap.paymentMethod = 'Credit Card';
        compWrap.probabilityChecked = true;
        XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper wrapper = new XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper();
        wrapper.wrapper = compWrap;
        
        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();

        XC_ComplianceMaster__c complianceMaster = new XC_ComplianceMaster__c (
            RecordTypeId = recTypeComplianceOneId,
            XC_ProductCategory__c = 'Boiler',
            XC_Country__c ='SPAIN',
            XC_Source__c ='SEO',
            XC_SalesPartnerId__c = null,
            XC_PaymentMethod__c = 'Credit Card',
            XC_BillingModel__c ='Recurring',
            XC_CommercialCode__c='abc'
        );
        XC_UTIL_SObject.insertRecord(complianceMaster);
        
        XC_ComplianceMaster__c compl = [SELECT id,XC_ReceivingChannel__c,XC_ExtrasCost__c, XC_ComplianceType__c, XC_ProductCategory__c, XC_Country__c, XC_Source__c, XC_SalesPartnerId__c, XC_PaymentMethod__c, XC_BillingModel__c, XC_Mandatory__c, XC_Queue__c FROM XC_ComplianceMaster__c where id =: complianceMaster.id limit 1 ];
        System.debug('@@@@---->Compliancemaster'+compl);
        wrapper.cwr = cwm;
        wrapper.complianceMaster = compl;
        wrapper.wrapperCheck = complianceWrap;

        test.startTest();
        XC_UTIL_ComplianceMaster_U_ExactMatch.populateComplianceResultWrapperC2(wrapper);
        test.stopTest();
        System.assert(!listOrderItem.isEmpty(), listOrderItem);
    } 

        static testMethod void populateWrapperTestWildCardMatch(){
        List <NE__OrderItem__c> listOrderItem = new List <NE__OrderItem__c>([SELECT Id 
                                                                            FROM NE__OrderItem__c]);
                                                                            
        XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwm = new XC_UTIL_ComplianceMaster.ComplianceWrapperResult();
        Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapConfItemTemplateName=  new Map <Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult>();
        XC_UTIL_ComplianceMaster.ComplianceWrapperCheck complianceWrap = new XC_UTIL_ComplianceMaster.ComplianceWrapperCheck();
        complianceWrap.mapConfItemTemplateName = mapConfItemTemplateName;
        complianceWrap.confItem = listOrderItem[0];
        XC_UTIL_ComplianceMaster.ComplianceWrapper compWrap = new XC_UTIL_ComplianceMaster.ComplianceWrapper();
        compWrap.country = 'SPAIN';
        compWrap.type = 'C1';
        compWrap.productCategory = 'Boiler';
        compWrap.salesPartner = null;
        compWrap.origin = 'SEO';
        compWrap.billingModel = 'Recurring';
        compWrap.paymentMethod = 'Credit Card';
        compWrap.probabilityChecked = true;
        compWrap.installerPartner= null;
        XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper wrapper = new XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper();
        wrapper.wrapper = compWrap;
        
        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();

        XC_ComplianceMaster__c complianceMaster = new XC_ComplianceMaster__c (
            RecordTypeId = recTypeComplianceOneId,
            XC_ProductCategory__c = 'Boiler',
            XC_Country__c ='SPAIN',
            XC_Source__c ='SEO',
            XC_SalesPartnerId__c = null,
            XC_PaymentMethod__c = 'Credit Card',
            XC_CommercialCode__c='abc',
            XC_BillingModel__c ='Recurring'
        );
        XC_UTIL_SObject.insertRecord(complianceMaster);
        
        XC_ComplianceMaster__c compl = [SELECT id, XC_ReceivingChannel__c, XC_ExtrasCost__c, XC_ComplianceType__c, XC_ProductCategory__c, XC_Country__c, XC_Source__c, XC_SalesPartnerId__c, XC_PaymentMethod__c, XC_BillingModel__c, XC_Mandatory__c, XC_Queue__c, XC_InstallerPartnerId__c FROM XC_ComplianceMaster__c where id =: complianceMaster.id limit 1 ];
        System.debug('@@@@---->Compliancemaster'+compl);
        wrapper.cwr = cwm;
        wrapper.complianceMaster = compl;
        wrapper.wrapperCheck = complianceWrap;

        test.startTest();
        XC_UTIL_ComplianceMaster_U_WildCardMatch.checkComplianceMasterWildCardMatchC4(wrapper);
        XC_UTIL_ComplianceMaster_U_WildCardMatch.checkComplianceMasterWildCardMatchC3(wrapper);
        test.stopTest();
        System.assert(!listOrderItem.isEmpty(), listOrderItem);
    } 

    @isTest
    static void onComplianceMasterQueried() {
        XC_UTIL_ComplianceMaster_D.ComplianceWorkOrderValidation complianceWOValidation = new XC_UTIL_ComplianceMaster_D.ComplianceWorkOrderValidation();
        Test.startTest();
        XC_UTIL_ComplianceMaster_D.getQueryComplianceMasterWOValidation(complianceWOValidation);
        Test.stopTest();
    }

}