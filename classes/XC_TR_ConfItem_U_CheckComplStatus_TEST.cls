/**
* @author 
* @date Creation 06/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_ConfItem_U_CheckComplStatus_TEST - Test class for XC_TR_ConfItem_U_CheckComplianceStatus
*/ 
@isTest
public class XC_TR_ConfItem_U_CheckComplStatus_TEST {

   	@isTest
    static void checkComplianceStatusTest(){
        
         OneOrg__c org = new OneOrg__c();
         org.Name='OneOrg (User)';
         org.XC_Spain_Triggers__c=true;
         insert org;
         List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(1);
         insert orderItems;
         NE__OrderItem__c orderItem=orderItems.get(0);
         XC_Provisioning_Step__c provisionStep=XC_DF_ProvisioningStep.createProvisioningStep(orderItem.id);
		 provisionStep.XC_Flow_API_Name__c=Label.XC_CL_Provisioning_C2Flow;     
         insert provisionStep;                
         orderItem.XC_Compliance1_Status__c='OK';
         orderItem.XC_Compliance2_Status__c=Label.XC_CL_OK;
         orderItem.XC_Compliance3_Status__c='OK';
         update orderItem;
         System.assertEquals(true, orderItem.Id != null);
    }
    
    @isTest
    static void checkComplianceStatusTestWithCompliance4(){    
         OneOrg__c org = new OneOrg__c();
         org.Name='OneOrg (User)';
         org.XC_Spain_Triggers__c=true;
         insert org;
         List<NE__OrderItem__c> orderItems=XC_DF_OrderItem.createOrderItems(1);
         insert orderItems;
         NE__OrderItem__c orderItem=orderItems.get(0);
         XC_Provisioning_Step__c provisionStep=XC_DF_ProvisioningStep.createProvisioningStep(orderItem.id);
		 provisionStep.XC_Flow_API_Name__c=Label.XC_CL_Provisioning_C2Flow;     
         insert provisionStep;                
         orderItem.XC_Compliance1_Status__c='OK';
         orderItem.XC_Compliance2_Status__c=Label.XC_CL_OK;
         orderItem.XC_Compliance3_Status__c='OK';
         orderItem.XC_Compliance4_Status__c='KO';
         update orderItem;
         System.assertEquals(true, orderItem.Id != null);
    }
}