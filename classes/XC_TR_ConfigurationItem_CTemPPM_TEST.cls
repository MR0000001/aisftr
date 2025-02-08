/**
* @author Raffaele Pacchiano
* @date Creation  07/09/2020 
* @description XC_TR_ConfigurationItem_CTemPPM_TEST
*/
@isTest
public class XC_TR_ConfigurationItem_CTemPPM_TEST {
    static testmethod void confItemCheckTemplateOnProjectIsFilled(){
    test.startTest();
    project_cloud__Project__c project = new project_cloud__Project__c();
    project.project_cloud__IsTemplate__c =True;
    project.project_cloud__Type__c='provisioning';
    project.XC_LegalEntity__c ='EnelX';
    project.XC_Country__c ='Chile';
    insert project; 
        
    project_cloud__Project__c project2 = new project_cloud__Project__c();
    project2.project_cloud__IsTemplate__c =True;
    project2.project_cloud__Type__c='provisioning';
    project2.XC_LegalEntity__c ='EnelX';
    project2.XC_Country__c ='Chile';
    insert project2;
        
    List<NE__OrderItem__c> ordc= XC_DF_OrderItem.createOrderItems(2);
    insert ordc;
        
    String recordId = ordc.get(0).NE__OrderId__c;
   	List<NE__Order__c> ordList = [SELECT id, NE__Type__c, NE__Configuration_Type__c, XC_LegalEntity__c from NE__Order__c];
        for(NE__Order__c o : ordList){
            o.NE__Type__c = 'InOrder';
            o.XC_LegalEntity__c = 'EnelX';
            //o.NE__Configuration_Type__c = 'Change Order'
        }
    update ordList;
    ordc.get(0).XC_IsAProduct__c = False;
    ordc.get(0).NE__Parent_Order_Item__c = NULL;
    ordc.get(0).XC_Project_Template__c= project.id;
    ordc.get(0).XC_LegalEntity__c= 'EnelX';
    ordc.get(0).XC_ConfigurationType__c= 'InOrder';
    ordc.get(1).XC_ConfigurationType__c= 'InOrder';
    ordc.get(1).XC_LegalEntity__c= 'EnelX';
    ordc.get(1).XC_IsAProduct__c = False;
    ordc.get(1).NE__Parent_Order_Item__c = NULL;
    ordc.get(1).XC_Project_Template__c= project2.id;
    update ordc; 
    Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>();
   	Map<id,NE__OrderItem__c> mapNew= new Map <id,NE__OrderItem__c>();
    mapNew.put(ordc.get(0).id,ordc.get(0));
    mapOld.put(ordc.get(0).id,ordc.get(1));
    XC_TR_ConfigurationItem_CheckTemplatePPM.confItemCheckTemplateOnProjectIsFilled(mapOld,mapNew);
    test.stopTest();
    }
    
    static testmethod void confItemCheckTemplateOnProjectIsFilled2(){
    test.startTest();
    project_cloud__Project__c project = new project_cloud__Project__c();
    project.project_cloud__IsTemplate__c =True;
    project.project_cloud__Type__c='provisioning';
    project.XC_LegalEntity__c ='EnelX';
    project.XC_Country__c ='Chile';
    insert project; 
        
    project_cloud__Project__c project2 = new project_cloud__Project__c();
    project2.project_cloud__IsTemplate__c =True;
    project2.project_cloud__Type__c='provisioning';
    project2.XC_LegalEntity__c ='EnelX';
    project2.XC_Country__c ='Chile';
    insert project2;
        
    List<NE__OrderItem__c> ordc= XC_DF_OrderItem.createOrderItems(2);
    insert ordc;
   
    String recordId = ordc.get(0).NE__OrderId__c;
    ordc.get(0).XC_IsAProduct__c = True;
    ordc.get(0).NE__Parent_Order_Item__c = NULL;
    ordc.get(0).XC_Project_Template__c= project.id;
    ordc.get(0).XC_LegalEntity__c= 'EnelX';
    ordc.get(0).XC_ConfigurationType__c= 'InOrder';
    ordc.get(1).XC_ConfigurationType__c= 'InOrder';
    ordc.get(1).XC_LegalEntity__c= 'EnelX';
    ordc.get(1).XC_IsAProduct__c = True;
    ordc.get(1).NE__Parent_Order_Item__c = NULL;
    ordc.get(1).XC_Project_Template__c= project2.id;
    update ordc;
    Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>();
   	Map<id,NE__OrderItem__c> mapNew= new Map <id,NE__OrderItem__c>();
    mapNew.put(ordc.get(0).id,ordc.get(0));
    mapOld.put(ordc.get(0).id,ordc.get(1));
    XC_TR_ConfigurationItem_CheckTemplatePPM.confItemCheckTemplateOnProjectIsFilled(mapOld,mapNew);
    test.stopTest();
    }
    
    static testmethod void confItemCheckTemplateOnProjectIsFilled1(){
    test.startTest();
   	project_cloud__Project__c project = new project_cloud__Project__c();
	project.project_cloud__IsTemplate__c =true;
    project.project_cloud__Type__c='provisioning';
    project.XC_LegalEntity__c ='EnelX';
    project.XC_Country__c ='Chile';
    insert project;
        
    project_cloud__Project__c project2 = new project_cloud__Project__c();
    project2.project_cloud__IsTemplate__c =true;
    project2.project_cloud__Type__c='provisioning';
    project2.XC_LegalEntity__c ='EnelX';
    project2.XC_Country__c ='Chile';
    insert project2;
        
   	List<NE__Order__c> ord = XC_DF_Order.createOrders(2, 'Order');
    insert ord;       
        
    ord.get(0).XC_Project_Template__c= project.id;
    ord.get(0).XC_LegalEntity__c= 'EnelX';
    ord.get(1).XC_LegalEntity__c= 'EnelX';
    ord.get(1).XC_Project_Template__c= project2.id;
    update ord;  
        
    Map<id,NE__Order__c> mapOld= new Map <id,NE__Order__c>();
   	Map<id,NE__Order__c> mapNew= new Map <id,NE__Order__c>();
    mapNew.put(ord.get(0).id,ord.get(0));
   	mapOld.put(ord.get(0).id,ord.get(1));
    XC_TR_ConfigurationItem_CheckTemplatePPM.orderCheckTemplateOnProjectIsFilled(mapOld,mapNew);
    test.stopTest();
    }
}