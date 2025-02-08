/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  15/03/2020 
* @description XC_UTIL_Conga_TEST – Test class for XC_UTIL_Conga
*/ 
@isTest
public class XC_UTIL_Conga_TEST {
   @TestSetup
    static void insertRecords (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        APXTConga4__Conga_Template__c congaTrigger = new APXTConga4__Conga_Template__c();
        congaTrigger.APXTConga4__Name__c = 'Contrato Renting Andromeda Sin Energia1';
        congaTrigger.Country__c = 'SPAIN';
        insert congaTrigger;
        APXTConga4__Conga_Template__c congaTrigger2 = new APXTConga4__Conga_Template__c();
        congaTrigger2.APXTConga4__Name__c = 'Clausulado Contrato renting';
        congaTrigger2.Country__c = 'SPAIN';
        insert congaTrigger2;  
        APXTConga4__Conga_Template__c congaTrigger3 = new APXTConga4__Conga_Template__c();
        congaTrigger3.APXTConga4__Name__c = 'Contract SSI-One Shot';
        congaTrigger3.Country__c = 'SPAIN';
        insert congaTrigger3;             
        APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c();
        congaQuery.APXTConga4__Name__c = 'OrderItemInfo';
        insert congaQuery;
        List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(2);
        List<NE__Billing_Profile__c>  updateBPList = new List<NE__Billing_Profile__c>();
        billingProfileList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        billingProfileList[1].NE__Payment__c = Label.XC_CL_DirectDebt;
        updateBPList.add(billingProfileList[0]);
        updateBPList.add(billingProfileList[1]);
        update updateBPList;
      
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(10);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EndesaX';
        }
        update orderList;
        for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = '3 years renting'; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_DirectDebt;
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
            orItem.NE__ProdId__c = productList[0].Id;
        }
        
        insert orderItems;
    }
    static testMethod void onUpdateBpli() {
    	List<NE__OrderItem__c> orderlist = new List<NE__OrderItem__c>([SELECT Id, XC_LegalEntityFormula__c FROM NE__OrderItem__c ]);
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_DirectDebt]); 
        Test.startTest();
        orderlist[0].XC_BillingProfileLineItem__c = bpliList[0].Id;
        update orderlist;
        Test.stopTest();
        System.assertEquals(10, orderlist.size());
 	}
    
   	static testMethod void onUpdateBillingModel() {
        List<NE__Product__c> productList = [SELECT Id FROM NE__Product__c LIMIT 1];
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_DirectDebt]);
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EndesaX';
        }
        update orderList;
        for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = '3 years renting'; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_DirectDebt;
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
            orItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
            orItem.NE__ProdId__c = productList[0].Id;
        }
        insert orderItems;
        
 		for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot; 
        }
        Test.startTest();
        update orderItems;
        Test.stopTest();
        System.assertEquals(11, orderlist.size());
 	}
    
    static testMethod void italyScenario() {
        List<NE__Product__c> productList = [SELECT Id FROM NE__Product__c LIMIT 1];
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_DirectDebt]);
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_Country__c = 'Italy';
            ord.XC_LegalEntity__c = 'EnelX';
        }
        update orderList;
        for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = '3 years renting'; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_DirectDebt;
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
            orItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
            orItem.NE__ProdId__c = productList[0].Id;
        }
        insert orderItems;
        
 		for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot; 
        }
        Test.startTest();
        update orderItems;
        Test.stopTest();
        System.assertEquals(11, orderlist.size());
 	}
    
    static testMethod void woServiceReport1(){
        
        XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
        wrapper.categoryName = Label.XC_CL_Boiler;
        wrapper.workType = 'Delivery & Installation';
        wrapper.country = 'Spain';
        wrapper.legalEntity = 'EndesaX';
       	
        List<XC_CM_CongaTemplateAssociation__mdt> congaTAQueried = [SELECT Id, XC_TemplateList__c, XC_QueryList__c, 
                                                                            XC_ProductServiceCategory__c, XC_ProductServiceName__c, XC_BillingModel__c, 
                                                                            XC_LegalEntity__c, XC_Country__c, XC_Region__c, XC_WorkType__c, XC_ForAragona__c FROM XC_CM_CongaTemplateAssociation__mdt
                                                                   			WHERE XC_Category__c = 'SERVICE_REPORT' AND XC_WorkType__c != '' ];
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Info about Work Order Line Items', Country__c = 'Spain');
        insert template;
        APXTConga4__Conga_Template__c templateOKGAS = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mantenimiento OKGAS', Country__c = 'Spain');
        insert templateOKGAS;
        APXTConga4__Conga_Template__c templateOKGASReduced = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mantenimiento GAS Reducido', Country__c = 'Spain');
        insert templateOKGASReduced;
        APXTConga4__Conga_Merge_Query__c congaQuery1 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'QueryOnAccountByWorkOrder');
        insert congaQuery1;
        /*List<WorkOrder> workOrder = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Planned Maintenance - Gas', 'Planned Maintenance');
        workOrder[0].Status = 'In Progress';
        workOrder[0].XC_forSATO__c = true;
        insert workOrder;*/
        
        /*List<WorkOrder> workOrderOKLUZ = XC_DF_WorkOrder.createWorkOrdersAsset(1, 'Repair - Light', 'Repair', 'OK Luz');
        workOrderOKLUZ[0].XC_ToBeManuallyDigitalized__c = true; 
        workOrderOKLUZ[0].XC_Digitized__c = true;        
        workOrderOKLUZ[0].XC_forSATO__c = true;
        workOrderOKLUZ[0].XC_LegalEntity__c = 'EndesaX';
        workOrderOKLUZ[0].XC_Segment__c = 'B2C';
        insert workOrderOKLUZ;
        workOrderOKLUZ[0].Status = 'Completed';

        update workOrderOKLUZ;*/

        Test.startTest();
        List<WorkOrder> workOrderOKGAS = XC_DF_WorkOrder.createWorkOrdersAsset(1, 'Delivery & Installation - Boiler', 'Delivery & Installation', 'OK Gas');
        workOrderOKGAS[0].XC_ToBeManuallyDigitalized__c = true; 
        workOrderOKGAS[0].XC_Digitized__c = true;          
        workOrderOKGAS[0].XC_forSATO__c = true;
        workOrderOKGAS[0].XC_Segment__c = 'B2C';
        workOrderOKGAS[0].XC_LegalEntity__c = 'EndesaX';
        workOrderOKGAS[0].XC_Country__c = 'Spain';
        //insert workOrderOKGAS;
        workOrderOKGAS[0].XC_CreateReducedReport__c = true;
        //update workOrderOKGAS;
        XC_UTIL_Conga_U.workOrderScenario(wrapper, congaTAQueried);
        Test.stopTest();

		

        System.assert(workOrderOKGAS!= null, workOrderOKGAS );
    }
    
    static testMethod void woServiceReport2(){
        
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Info about Work Order Line Items', Country__c = 'Spain');
        insert template;
        APXTConga4__Conga_Template__c templateOKGAS = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mantenimiento OKGAS', Country__c = 'Spain');
        insert templateOKGAS;
        APXTConga4__Conga_Template__c templateOKGASReduced = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mantenimiento GAS Reducido', Country__c = 'Spain');
        insert templateOKGASReduced;
        APXTConga4__Conga_Merge_Query__c congaQuery1 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'QueryOnAccountByWorkOrder');
        insert congaQuery1;
        /*List<WorkOrder> workOrder = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Planned Maintenance - Gas', 'Planned Maintenance');
        workOrder[0].Status = 'In Progress';
        workOrder[0].XC_forSATO__c = true;
        insert workOrder;*/

	    Test.startTest();
        List<WorkOrder> workOrderOKGAS = XC_DF_WorkOrder.createWorkOrdersAsset(1, 'Repair - Gas', 'Repair', 'OK Gas');
        workOrderOKGAS[0].Status = 'In Progress';
        workOrderOKGAS[0].XC_LegalEntity__c = 'EndesaX';
        //workOrderOKGAS[0].XC_ToBeManuallyDigitalized__c = true;        
        
        insert workOrderOKGAS;
        //workOrderOKGAS[0].Status = 'Completed';
        workOrderOKGAS[0].XC_CreateReducedReport__c  = true;
        update workOrderOKGAS;
		Test.stopTest();

        System.assert(workOrderOKGAS!= null, workOrderOKGAS );
    }
    
  	static testMethod void woServiceReport3(){
        
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Info about Work Order Line Items', Country__c = 'Spain');
        insert template;
        APXTConga4__Conga_Template__c templateOKGAS = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mantenimiento OKGAS', Country__c = 'Spain');
        insert templateOKGAS;
        APXTConga4__Conga_Template__c templateOKGASReduced = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mantenimiento GAS Reducido', Country__c = 'Spain');
        insert templateOKGASReduced;
        APXTConga4__Conga_Merge_Query__c congaQuery1 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'QueryOnAccountByWorkOrder');
        insert congaQuery1;
        /*List<WorkOrder> workOrder = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Planned Maintenance - Gas', 'Planned Maintenance');
        workOrder[0].Status = 'In Progress';
        workOrder[0].XC_forSATO__c = true;
        insert workOrder;*/

	    Test.startTest();
        List<WorkOrder> workOrderOKGAS = XC_DF_WorkOrder.createWorkOrdersAsset(1, 'Repair - Gas', 'Repair', 'OK Gas');
        workOrderOKGAS[0].Status = 'In Progress';
        workOrderOKGAS[0].XC_LegalEntity__c = 'EndesaX';
        //workOrderOKGAS[0].XC_ToBeManuallyDigitalized__c = true;        
        
        insert workOrderOKGAS;
        //workOrderOKGAS[0].Status = 'Completed';
        workOrderOKGAS[0].XC_ToBeManuallyDigitalized__c = true;
        update workOrderOKGAS;
		Test.stopTest();

        System.assert(workOrderOKGAS!= null, workOrderOKGAS );
    }
    
  	static testMethod void sepaMandate(){
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mandato_SEPA', Country__c = 'Spain');
        insert template;
        APXTConga4__Conga_Template__c template2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'QueryOnBillingPLI', Country__c = 'Spain');
        insert template2;
      
        APXTConga4__Conga_Merge_Query__c congaQuery1 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'QueryOnBillingProfil');
        insert congaQuery1;
      
        APXTConga4__Conga_Merge_Query__c congaQuery2 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'QueryOnBillingPLI');
        insert congaQuery2;

        List<WorkOrder> workOrder = XC_DF_WorkOrder.createWorkOrders (1, 'Planned Maintenance');

        List<NE__Billing_Profile__c> bpliList = XC_DF_BillingProfile.createBillingProfile(1);
        NE__Billing_Profile__c billingProf=  bpliList[0];
        billingProf.NE__Payment__c = Label.XC_CL_DirectDebt;
        billingProf.XC_SepaMandate__c = 'A1234';
        billingProf.NE__Iban__c = 'AA481481';
        billingProf.XC_BIC__c = 'ABC123';
        billingProf.XC_CreateMandate__c = true;
        update billingProf;
    }
}