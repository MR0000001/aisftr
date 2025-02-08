/**
* @author 
* @date Creation  
* @description XC_TR_Configuration_U_CountConf_TEST – Test class for XC_TR_Configuration_U_CountConf and XC_TR_Configuration_U_CountConf_D and XC_TR_Configuration_U_CountConf
*/ 
@isTest
public class XC_TR_Configuration_U_UpFinAppr_TEST {
    
    @TestSetup
    static void insertRecords(){
        Integer n = 10;
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, 'InOrder');
        insert orderList;
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        for(NE__Order__c order:orderList){
        	NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order);
            orderItemList.add(orderItem);
        }
        insert orderItemList;
        List<NE__Order_Item_Attribute__c> orItemAttrList = new List<NE__Order_Item_Attribute__c>();
        for(NE__OrderItem__c orderItem : orderItemList){
            NE__Order_Item_Attribute__c orItemAttr = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItem,'Test Class','10');
            orItemAttr.Name = Label.XC_CL_ConfigurationItemAttribute_PaymentType;
            orItemAttrList.add(orItemAttr);
        }
        insert orItemAttrList;
    }
    
    
    static testMethod void onUpdate() {
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        
        for(NE__Order__c order : orderList){
            order.NE__OrderStatus__c = 'Active';
            order.XC_Status__c = Label.XC_CL_Configuration_QuoteDraft;
        }
        update orderList;
        
        for(NE__Order__c order : orderList){
            order.XC_FinancialApproval__c = 'Not Needed';
        }
        update orderList;
    }
    
    
	static testMethod void onUpdateBis() {
        List<NE__Order_Item_Attribute__c> orderItemAttributeList = [SELECT Id FROM NE__Order_Item_Attribute__c];
        for(NE__Order_Item_Attribute__c oia : orderItemAttributeList){
            oia.Name = Label.XC_CL_ConfigurationItemAttribute_PaymentType;
            oia.NE__Value__c = Label.XC_CL_ConfigurationItemAttribute_FinancialInstitute;
        }
        update orderItemAttributeList;
        
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        
        for(NE__Order__c order : orderList){
            order.NE__OrderStatus__c = 'Active';
            order.XC_Status__c = Label.XC_CL_Configuration_QuoteDraft;
        }
        update orderList;
        
        for(NE__Order__c order : orderList){
            order.XC_FinancialApproval__c = 'Not Needed';
        }
        update orderList;
    }
}