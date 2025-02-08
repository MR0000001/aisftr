/**
* @author
* @date Creation 07/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_ComplVerifStatus_U_ParentOk_TEST - Test class for XC_TR_ComplVerifStatus_U_ParentToOk
*/ 
@isTest
public class XC_TR_ComplVerifStatus_U_ParentOk_TEST {
    
    static Testmethod void XC_TR_ComplVerifStatus_U_ParentTEST() {
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(1);
        insert orderItems;
        NE__ORDER__c order = [SELECT Id FROM NE__ORDER__c WHERE Id = :orderItems[0].NE__OrderId__c LIMIT 1];
        
        XC_ComplianceVerificationStatus__c complianceVerificationStatus=new XC_ComplianceVerificationStatus__c();
        complianceVerificationStatus.XC_Order__c = order.Id;
        insert complianceVerificationStatus;
   		XC_OrderItemCompliance__c  orderItemCompliance=new XC_OrderItemCompliance__c(XC_ComplianceVerificationStatus__c=complianceVerificationStatus.id, XC_OrderItem__c=orderItems[0].id, XC_Order__c = order.Id );
        insert orderItemCompliance;
        complianceVerificationStatus.XC_ComplianceStatus__c=Label.XC_CL_ComplianceVerificationStatus_StatusOK;
        complianceVerificationStatus.XC_ComplianceType__c =Label.XC_CL_Compliance_C1;
        update complianceVerificationStatus;
        complianceVerificationStatus.XC_ComplianceStatus__c=Label.XC_CL_ComplianceVerificationStatus_StatusKO;
        complianceVerificationStatus.XC_ComplianceType__c =Label.XC_CL_Compliance_C2;
        update complianceVerificationStatus;
        
        complianceVerificationStatus.XC_ComplianceStatus__c=Label.XC_CL_ComplianceVerificationStatus_StatusOK;
        complianceVerificationStatus.XC_ComplianceType__c =Label.XC_CL_Compliance_C3;
        update complianceVerificationStatus;       
        complianceVerificationStatus.XC_ComplianceStatus__c=Label.XC_CL_ComplianceVerificationStatus_KoFinal;
        complianceVerificationStatus.XC_ComplianceType__c = Label.XC_CL_Compliance_C1;
        update complianceVerificationStatus;
        complianceVerificationStatus.XC_ComplianceStatus__c=Label.XC_CL_ComplianceVerificationStatus_KoFinal;
        complianceVerificationStatus.XC_ComplianceType__c = Label.XC_CL_Compliance_C2;
        update complianceVerificationStatus;
        complianceVerificationStatus.XC_ComplianceStatus__c=Label.XC_CL_ComplianceVerificationStatus_KoFinal;
        complianceVerificationStatus.XC_ComplianceType__c = Label.XC_CL_Compliance_C3;
        update complianceVerificationStatus;
        //System.assertEquals(24,limits.getDmlStatements());
    }
}