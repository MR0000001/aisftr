/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation 06/08/2019
* @description XC_LCC140_BackCompliance_TEST – Test class for XC_LCC140_BackCompliance
*/ 

@isTest
private class XC_LCC140_BackCompliance_TEST { 

    @TestSetup
    static void setup(){
        Test.startTest();
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceTerritory> servTerr = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        insert servTerr;
        User user = XC_DF_User.createUserAdmin();
        insert user;
        ServiceResource servRes = new ServiceResource(Name = Label.XC_CL_NoCandidateFound, 
                                                        XC_Account__c = accList[0].Id, 
                                                        isCapacityBased = true,
                                                        RelatedRecordId = user.Id, 
                                                        isActive = true );
        insert servRes;
        List<Case> listOfCaseFather = XC_DF_Case.createCases(1);
        listOfCaseFather[0].Status = 'ESTA001';
        insert listOfCaseFather;
        listOfCaseFather[0].Status = 'ESTA003';
        Test.stopTest();
    }
    static testMethod void backComplianceTestOk() {
        List<Case> listOfCaseFather = new List<Case> ([SELECT Id
                                                        FROM Case limit 1]);
        List<Case> listOfCaseChild = XC_DF_Case.createCases(1);
        listOfCaseChild[0].Status = 'ESTA001';
        listOfCaseChild[0].ParentId = listOfCaseFather[0].id;
        XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        listOfCaseChild[0].XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        listOfCaseChild[0].XC_OrderItem__c = listOfOrderItem[0].Id;
        insert listOfCaseChild;
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        List<ServiceResource> listOfServiceResource = [SELECT Id 
                                                        FROM ServiceResource limit 1];
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation); 
        listWo[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        listWo[0].XC_AssignedResource__c = listOfServiceResource[0].id;
        listWo[0].XC_Configuration_Item__c = listOfOrderItem[0].id;
        List<WorkType> listOfWoType = new List <WorkType>([SELECT XC_WorkTypeCategory__c
                                                    FROM WorkType
                                                    WHERE Id=:listWo[0].WorkTypeId]);
        listOfWoType[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;        
        update listOfWoType;
        insert listWo;                           
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = listOfCaseChild[0].Id;
        oic.XC_RecoveryResponsible__c = 'Sales Partner Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'Low';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        System.debug('@@@@@@child: '+listOfCaseChild[0].ParentId);
        Test.startTest();
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC140_BackCompliance.backCompliance(listOfCaseChild[0].id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }

        static testMethod void backComplianceTestOkdmlKo() {
        List<Case> listOfCaseFather = new List<Case> ([SELECT Id
                                                        FROM Case limit 1]);
        List<Case> listOfCaseChild = XC_DF_Case.createCases(1);        
        listOfCaseChild[0].Status = 'ESTA001';
        listOfCaseChild[0].ParentId = listOfCaseFather[0].id;
        XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        listOfCaseChild[0].XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        listOfCaseChild[0].XC_OrderItem__c = listOfOrderItem[0].Id;
        insert listOfCaseChild;
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        List<ServiceResource> listOfServiceResource = [SELECT Id 
                                                        FROM ServiceResource limit 1];
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation); 
        listWo[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        listWo[0].XC_AssignedResource__c = listOfServiceResource[0].id;
        listWo[0].XC_Configuration_Item__c = listOfOrderItem[0].id;
        List<WorkType> listOfWoType = new List <WorkType>([SELECT XC_WorkTypeCategory__c
                                                    FROM WorkType
                                                    WHERE Id=:listWo[0].WorkTypeId]);
        listOfWoType[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;        
        update listOfWoType;
        insert listWo;                           
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = listOfCaseChild[0].Id;
        oic.XC_RecoveryResponsible__c = 'Sales Partner Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'Low';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        System.debug('@@@@@@child: '+listOfCaseChild[0].ParentId);
        Test.startTest();
        XC_LCC140_BackCompliance.isTest = true;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC140_BackCompliance.backCompliance(listOfCaseChild[0].id);
        Test.stopTest();
        System.assertEquals(wrapper.success, false);
    }
    static testMethod void backComplianceTestOkInstallation() {
        List<Case> listOfCaseFather = new List<Case> ([SELECT Id
                                                        FROM Case limit 1]);
        List<Case> listOfCaseChild = XC_DF_Case.createCases(1);
        listOfCaseChild[0].Status = 'ESTA001';
        listOfCaseChild[0].ParentId = listOfCaseFather[0].id;
        XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        listOfCaseFather[0].XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        listOfCaseFather[0].XC_OrderItem__c = listOfOrderItem[0].Id;
        update listOfCaseFather;
        insert listOfCaseChild;
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        List<ServiceResource> listOfServiceResource = [SELECT Id 
                                                        FROM ServiceResource limit 1];
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation); 
        listWo[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        listWo[0].XC_AssignedResource__c = listOfServiceResource[0].id;
        listWo[0].XC_Configuration_Item__c = listOfOrderItem[0].id;
        List<WorkType> listOfWoType = new List <WorkType>([SELECT XC_WorkTypeCategory__c
                                                    FROM WorkType
                                                    WHERE Id=:listWo[0].WorkTypeId]);
        listOfWoType[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;        
        update listOfWoType;
        insert listWo;                           
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = listOfCaseFather[0].Id;
        oic.XC_RecoveryResponsible__c = 'Installation Partner Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'Low';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        System.debug('@@@@@@child: '+listOfCaseChild[0].ParentId);
        Test.startTest();
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC140_BackCompliance.backCompliance(listOfCaseChild[0].id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }



}