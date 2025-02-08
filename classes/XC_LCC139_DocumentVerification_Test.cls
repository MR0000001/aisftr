/**
 * The Class XC_LCC139_DocumentVerification_Test.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 06/08/2019 
 * @date Modification dd/mm/yyyy
 * @description XC_LCC139_DocumentVerification – Test class for XC_LCP139_DocumentVerification Component
 */
@isTest
public without sharing class XC_LCC139_DocumentVerification_Test {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        XC_DF_Order.createOrder('InOrder');
        List<Contact> listOfCont = XC_DF_Contact.createResidentialContacts(1);
        insert listOfCont;
        List<Account> partnerAccList = XC_DF_Account.insertPartnerAccounts(1);
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        List<ServiceTerritory> servTerr = XC_DF_ServiceTerritory.createServiceTerritories(partnerAccList);
        insert servTerr;
        User user = XC_DF_User.createUserAdmin();
        insert user;
        ServiceResource servRes = new ServiceResource(Name = Label.XC_CL_NoCandidateFound, 
                                                      XC_Account__c = accList[0].Id, 
                                                      isCapacityBased = true,
                                                      RelatedRecordId = user.Id, 
                                                      isActive = true );
        insert servRes;
        Group genericGroup = new Group();
        List<XC_CM_ComplianceMapping__mdt> listOfCmd = new List <XC_CM_ComplianceMapping__mdt>([SELECT XC_ComplianceQueue__c
                                            FROM XC_CM_ComplianceMapping__mdt
                                            WHERE   XC_RecoveryResponsible__c =: Label.XC_CL_DocumentVerification_RecoveryQueue AND XC_RecoveryResponsible__c <> null AND XC_Country__c = 'Spain' ]);
        genericGroup.Name = listOfCmd[0].XC_ComplianceQueue__c;
        insert genericGroup;
    }
    @isTest
    static void documentVerificationSalesQueue() {
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact]);
        Case caseMaster = new Case ();
        caseMaster.Status = 'ESTA001';        
        caseMaster.ContactId = listOfCont[0].Id;
        caseMaster.Country__c = 'Spain';
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster.XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster.XC_LegalEntity__c = 'EndesaX';
        insert caseMaster; 
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster.Id;
        oic.XC_RecoveryResponsible__c = 'Sales Partner Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'Low';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        Test.startTest();
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster.id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }

    @isTest
    static void documentVerificationChildCase() {
        Test.startTest();
        List<Case> listOfCaseFather = XC_DF_Case.createCases(1);
        listOfCaseFather[0].Status ='ESTA001';
        listOfCaseFather[0].Country__c = 'Spain';
        insert listOfCaseFather;

        List<Case> listOfCaseChild = XC_DF_Case.createCases(1);
        listOfCaseChild[0].Status ='ESTA001';
        listOfCaseChild[0].Country__c = 'Spain';
        listOfCaseChild[0].ParentId = listOfCaseFather[0].id;
        insert listOfCaseChild;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(listOfCaseFather[0].id);
        Test.stopTest();
        System.assertEquals(wrapper.success, false);
    }

    @isTest
    static void documentVerificationInstallationQueue() {
        Test.startTest();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact]);
        Case caseMaster = new Case ();
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster.XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster.ContactId = listOfCont[0].Id;       
        caseMaster.Country__c = 'Spain';
        caseMaster.XC_LegalEntity__c = 'EndesaX';
        insert caseMaster;
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        List<ServiceResource> listOfServiceResource = [SELECT Id 
                                                        FROM ServiceResource limit 1];
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation); 
        listWo[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        listWo[0].XC_AssignedResource__c = listOfServiceResource[0].id;
        listWo[0].XC_Configuration_Item__c = listOfOrderItem[0].id;
        /*List<WorkType> listOfWoType = new List <WorkType>([SELECT XC_WorkTypeCategory__c
                                                    FROM WorkType
                                                    WHERE Id=:listWo[0].WorkTypeId]);
        listOfWoType[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;        
        update listOfWoType;*/
        insert listWo;                            
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster.Id;
        oic.XC_RecoveryResponsible__c = 'Installation Partner Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'Low';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;                                              
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster.id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }

    @isTest
    static void documentVerificationInstallationQueueHighCriticality() {
        Test.startTest();
        List<Case> caseMaster = XC_DF_Case.createCases(1);
        caseMaster[0].Status ='ESTA001';       
        caseMaster[0].Country__c = 'Spain';
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster[0].XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster[0].XC_OrderItem__c = listOfOrderItem[0].Id;
        insert caseMaster;
        //caseMaster[0].Reason = 'XCMOT010';
        caseMaster[0].SubCause__c = 'ATCL018';
        update caseMaster;
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster[0].Id;
        oic.XC_RecoveryResponsible__c = 'Sales Partner Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'High';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster[0].id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }

    @isTest
    static void documentVerificationRecoveryData() {
        Test.startTest();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact]);
        Case caseMaster = new Case ();
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster.Country__c = 'Spain';
        caseMaster.XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster.ContactId = listOfCont[0].Id;
        caseMaster.XC_LegalEntity__c = 'EndesaX';
        insert caseMaster; 
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster.Id;
        oic.XC_RecoveryResponsible__c = 'Recovery Data Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'Low';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster.id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }

    @isTest
    static void documentVerificationFirstCheckCompliance() {
        Test.startTest();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact]);
        Case caseMaster = new Case ();
        XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster.XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster.Country__c = 'Spain';
        caseMaster.XC_FirstCheckOnCompliance__c = true;
        caseMaster.ContactId = listOfCont[0].Id;
        caseMaster.XC_LegalEntity__c = 'EndesaX';
        insert caseMaster; 
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster.Id;
        oic.XC_RecoveryResponsible__c = 'Sales Partner Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'Low';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster.id);
        Test.stopTest();
        System.assertEquals(wrapper.success, false);
    }

    @isTest
    static void documentVerificationDocumentOk() {
        Test.startTest();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact]);
        Case caseMaster = new Case ();
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster.XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster.Country__c = 'Spain';
        caseMaster.XC_FirstCheckOnCompliance__c = true;      
        caseMaster.ContactId = listOfCont[0].Id;
        caseMaster.XC_LegalEntity__c = 'EndesaX';
        insert caseMaster; 
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster.Id;
        oic.XC_RecoveryResponsible__c = '';
        oic.XC_Status__c = 'Ok';
        oic.XC_KoReason__c = '';
        oic.XC_KoCriticality__c = '';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster.id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }

    @isTest
    static void documentVerificationStatusBlank() {
        Test.startTest();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact]);
        Case caseMaster = new Case ();
        caseMaster.ContactId = listOfCont[0].Id;
        caseMaster.Country__c = 'Spain';
        caseMaster.XC_LegalEntity__c = 'EndesaX';
        caseMaster.Status = 'ESTA001';
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster.XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster.XC_FirstCheckOnCompliance__c = true;
        insert caseMaster; 
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster.Id;
        oic.XC_RecoveryResponsible__c = '';
        oic.XC_Status__c = '';
        oic.XC_KoReason__c = '';
        oic.XC_KoCriticality__c = '';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster.id);
        Test.stopTest();
        System.assertEquals(wrapper.success, false);
    }

    @isTest
    static void documentVerificationNoOrderItemCompliance() {
        Test.startTest();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact]);
        Case caseMaster = new Case ();
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster.XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster.Country__c = 'Spain';
        caseMaster.XC_FirstCheckOnCompliance__c = true;        
        caseMaster.ContactId = listOfCont[0].Id;
        caseMaster.XC_LegalEntity__c = 'EndesaX';
        insert caseMaster;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster.id);
        Test.stopTest();
        System.assertEquals(wrapper.success, false);
    }

    @isTest
    static void documentVerificationDocumentOkdmlOk() {
        Test.startTest();
        List<Case> caseMaster = XC_DF_Case.createCases(1);
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster[0].Status = 'ESTA001';
        caseMaster[0].XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster[0].Country__c = 'Spain';
        caseMaster[0].XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster[0].XC_FirstCheckOnCompliance__c = true;
        insert caseMaster; 
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster[0].Id;
        oic.XC_RecoveryResponsible__c = '';
        oic.XC_Status__c = 'Ok';
        oic.XC_KoReason__c = '';
        oic.XC_KoCriticality__c = '';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster[0].id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }

    @isTest
    static void documentVerificationInstallationQueueHighCriticalityKoDml() {
        Test.startTest();
        List<Contact> listOfCont = new List<Contact>([SELECT Id FROM Contact]);
        Case caseMaster = new Case();
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c
                                                                FROM NE__OrderItem__c limit 1]);
        caseMaster.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        caseMaster.XC_OrderItem__c = listOfOrderItem[0].Id;
        caseMaster.Country__c = 'Spain';
        caseMaster.XC_LegalEntity__c = 'EndesaX';
        caseMaster.ContactId = listOfCont[0].Id;
        insert caseMaster;
        //caseMaster.Reason = 'XCMOT010';
        caseMaster.SubCause__c = 'ATCL018';
        update caseMaster;
        XC_ComplianceVerificationStatus__c  compVerif = new XC_ComplianceVerificationStatus__c();
        insert compVerif;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_Order__c = listOfOrderItem[0].NE__OrderId__c;
        oic.XC_OrderItem__c = listOfOrderItem[0].Id;
        oic.XC_Case__c = caseMaster.Id;
        oic.XC_RecoveryResponsible__c = 'Sales Partner Queue';
        oic.XC_Status__c = 'Ko';
        oic.XC_KoReason__c = 'Incorrect document format';
        oic.XC_KoCriticality__c = 'High';
        oic.XC_ComplianceVerificationStatus__c = compVerif.id;
        insert oic;
        XC_LCC139_DocumentVerification.ResultWrapper wrapper = XC_LCC139_DocumentVerification.documentVerification(caseMaster.id);
        Test.stopTest();
        System.assertEquals(wrapper.success, true);
    }

    @isTest
    static void populateWrapperError (){
        XC_LCC139_DocumentVerification.ResultWrapper rw = new XC_LCC139_DocumentVerification.ResultWrapper();
        XC_UTIL_Sobject.WrapperResult dmlResult = new XC_UTIL_Sobject.WrapperResult ();
        List<XC_UTIL_Sobject.WrapperResult> listOfWrap = new List<XC_UTIL_Sobject.WrapperResult>();
        listOfWrap.add(dmlResult);
        XC_LCC139_DocumentVerification_U.populateWrapperError(listOfWrap, rw);
        System.assertEquals(listOfWrap.isEmpty(), false);
    }
}