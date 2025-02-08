/**
* @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
* @date Creation  30/07/2019 
* @description XC_IN029_ComplianceVerification4_TEST – Test class for XC_IN029_ComplianceVerification4
*/ 

@isTest
private class XC_IN029_ComplianceVerification4_TEST {

    @TestSetup
    static void setup(){
        
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opport = oppList[0];
        opport.Name = 'TEST';
        opport.StageName = 'Draft';
        opport.CloseDate = Date.today();
        opport.XC_LegalEntity__c = 'EndesaX';
        insert opport;
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.NE__OptyId__c = opport.Id;
        insert order;
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        Asset asst = listAsset[0];
        asst.XC_Configuration_Item__c = ordIt.Id;
        insert asst;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        
        insert provisioningStep;
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
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
        complianceMaster1.XC_SalesPartnerId__c = ordIt.NE__OrderId__r.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster1.XC_CommercialCode__c ='001';
        complianceMaster2.XC_Country__c = 'SPAIN';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_SalesPartnerId__c = ordIt.NE__OrderId__r.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster2.XC_CommercialCode__c ='002';
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_ProductCategory__c = 'Boiler';
        complianceMaster3.XC_InstallerPartnerId__c = ordIt.NE__OrderId__r.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_CommercialCode__c ='003';
        complianceMaster4.XC_Country__c = 'SPAIN';
        complianceMaster4.RecordTypeId = recTypeComplianceFourId;
        complianceMaster4.XC_ComplianceTypePicklist__c = 'C4';
        complianceMaster4.XC_ProductCategory__c = 'Boiler';
        complianceMaster4.XC_Queue__c = 'Cola 4';
        complianceMaster4.XC_SalesPartnerId__c = ordIt.NE__OrderId__r.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster4.XC_CommercialCode__c ='004';
        complMasterList.add(complianceMaster1);
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        complMasterList.add(complianceMaster4);
        insert complMasterList;      
        
    }
    
    static testMethod void complianceVerification2Test(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN004_ComplianceVerification2.InputWrapper inputWr = new XC_IN004_ComplianceVerification2.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN004_ComplianceVerification2.InputWrapper> wrapperList = new List<XC_IN004_ComplianceVerification2.InputWrapper>();
        wrapperList.add(inputWr);
        
        test.startTest();
        XC_IN004_ComplianceVerification2.complianceVerification2(wrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 
    
    static testMethod void complianceVerification3Test(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN005_ComplianceVerification3.InputWrapper inputWr = new XC_IN005_ComplianceVerification3.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN005_ComplianceVerification3.InputWrapper> wrapperList = new List<XC_IN005_ComplianceVerification3.InputWrapper>();
        wrapperList.add(inputWr);
        
        test.startTest();
        XC_IN005_ComplianceVerification3.complianceVerification3(wrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 
    static testMethod void complianceVerification1Test(){        
        List<NE__Order__c> orderList = [SELECT Id  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        
        test.startTest();
        XC_LCC069_ComplianceVerification1.checkCompliance1NeededOrToSkeep(order.Id);
        XC_LCC069_ComplianceVerification1.checkDocumentsComplianceVerification1(order.Id);
        test.stopTest();
        System.assertEquals(1, orderList.size());
    } 

    static testMethod void complianceVerification4Test(){        
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
}