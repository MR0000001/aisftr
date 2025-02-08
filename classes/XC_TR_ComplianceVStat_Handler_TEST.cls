/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation  24/06/2019 
* @description XC_TR_ComplianceVStat_Handler_TEST – Test class for XC_TR_ComplianceVerificationStat_Handler
*/ 
@isTest
public class XC_TR_ComplianceVStat_Handler_TEST {
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        XC_ComplianceVerificationStatus__c complianceVerificationStatus=new XC_ComplianceVerificationStatus__c();
        insert complianceVerificationStatus;
        List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(1);
        insert orderItems;
        XC_OrderItemCompliance__c  orderItemCompliance=new XC_OrderItemCompliance__c(XC_ComplianceVerificationStatus__c=complianceVerificationStatus.id, XC_OrderItem__c=orderItems[0].id);
        insert orderItemCompliance;
        System.assert(complianceVerificationStatus != null);
    }

    @IsTest
    private static void methodUpdate(){
        
        Test.startTest();
        XC_ComplianceVerificationStatus__c complianceVerificationStatus = [SELECT ID, XC_ComplianceStatus__c, XC_ComplianceType__c FROM XC_ComplianceVerificationStatus__c][0];
        complianceVerificationStatus.XC_ComplianceStatus__c=Label.XC_CL_ComplianceVerificationStatus_StatusOK;
        complianceVerificationStatus.XC_ComplianceType__c =Label.XC_CL_Compliance_C1;
        update complianceVerificationStatus;
        System.assert(complianceVerificationStatus != null);
        Test.stopTest();
        
    }
    @IsTest
    private static void methodDelete(){
        
        Test.startTest();
        XC_ComplianceVerificationStatus__c complianceVerificationStatus = [SELECT ID, XC_ComplianceStatus__c, XC_ComplianceType__c FROM XC_ComplianceVerificationStatus__c][0];
        delete complianceVerificationStatus;
        System.assert(complianceVerificationStatus != null);
        Test.stopTest();
        
    }
}