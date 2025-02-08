/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 01/08/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_OrderItemCompl_U_UpdateStatus_TEST for XC_TR_OrderItemCompl_U_UpdateStatus     
*/
@isTest
public with sharing class XC_TR_OrderItemCompl_U_UpdateStatus_TEST {
    @TestSetup
    static void setup(){
       // OneOrg__c org = new OneOrg__c(); 
       // org.Name = 'OneOrg (User)';
       // org.XC_Spain_Triggers__c = true;
       // insert org;
        insert XC_DF_OneOrg.createOneOrg('Spain');    
    } 
    @isTest
    static void onUpdate() {       
        List<NE__OrderItem__c> listOrderItems = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItems;

        XC_ComplianceVerificationStatus__c complianceVerificationStatus = new XC_ComplianceVerificationStatus__c();
        complianceVerificationStatus.XC_ComplianceStatus__c = Label.XC_CL_OK;
        complianceVerificationStatus.XC_ComplianceType__c = Label.XC_CL_Compliance_C2;
        insert complianceVerificationStatus;
        
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Country__c = 'Spain';
        listCase[0].Status = 'ESTA001';
        insert listCase;

        XC_OrderItemCompliance__c orderItemCompliance = new XC_OrderItemCompliance__c();
        orderItemCompliance.XC_Case__c = listCase[0].Id;
        orderItemCompliance.XC_ComplianceType__c = Label.XC_CL_Compliance_C2;
        orderItemCompliance.XC_Status__c = Label.XC_CL_OK;
        orderItemCompliance.XC_OrderItem__c = listOrderItems[0].id;      
        orderItemCompliance.XC_ComplianceVerificationStatus__c = complianceVerificationStatus.id;
        insert orderItemCompliance;

        XC_OrderItemCompliance__c orderItemComplianceBrother = new XC_OrderItemCompliance__c();
        orderItemComplianceBrother.XC_ComplianceType__c = Label.XC_CL_Compliance_C3;
        orderItemComplianceBrother.XC_Status__c = Label.XC_CL_OK;
        orderItemComplianceBrother.XC_OrderItem__c = listOrderItems[0].id;
        orderItemComplianceBrother.XC_ComplianceVerificationStatus__c = complianceVerificationStatus.id;
        insert orderItemComplianceBrother;

        Test.startTest();
        orderItemCompliance.XC_Status__c = Label.XC_CL_KO;
        orderItemCompliance.XC_KoReason__c = 'Incorrect document format';
        update orderItemCompliance;
        orderItemCompliance.XC_Status__c = Label.XC_CL_OK;
        orderItemCompliance.XC_KoReason__c = null;
        update orderItemCompliance;
        orderItemCompliance.XC_Status__c = Label.XC_CL_KO;
        orderItemCompliance.XC_KoReason__c = 'Document not legible';
        update orderItemCompliance;
        delete orderItemCompliance;
        Test.stopTest();
        System.assertEquals(true, orderItemCompliance.Id != null);
    }
}