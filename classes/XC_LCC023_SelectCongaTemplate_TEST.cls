/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  14/05/2019 
* @description XC_LCC023_SelectCongaTemplate_TEST – Test class for XC_LCC023_SelectCongaTemplateOnOrder
*/
@isTest
public class XC_LCC023_SelectCongaTemplate_TEST {
    //Test Method getPickListValuesIntoList
    static testMethod void getPickListValuesIntoList(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        NE__Order__c conf = new NE__Order__c();
        insert conf;
        XC_LCC023_SelectCongaTemplateOnOrder.ListWrapper wra = XC_LCC023_SelectCongaTemplateOnOrder.getPickListValuesIntoList(conf.Id);
        
        System.assertEquals(true, wra!=null);
    Test.stopTest();
        
}
    //Test Method getIdValueAndSetUrl
    static testMethod void getIdValueAndSetUrl(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        NE__Order__c conf = new NE__Order__c();
        insert conf;
        
        NE__OrderItem__c orderitem = new NE__OrderItem__c();
        orderitem.NE__Qty__c = 1 ;
        orderitem.NE__OrderId__c = conf.Id;
       
        NE__Catalog__c cata = new NE__Catalog__c();
        insert cata;
        
        NE__Catalog_Item__c cataItem = new NE__Catalog_Item__c();
        cataItem.NE__Catalog_Id__c = cata.Id ;
        insert cataItem;
         
        NE__Catalog_Category__c cataName = new NE__Catalog_Category__c();
        cataName.NE__CatalogId__c = cata.Id ;
        cataName.Name= 'All';
        insert cataName;
        
        cataItem.NE__Catalog_Category_Name__c = cataName.Id;
        orderitem.NE__CatalogItem__c = cataItem.Id;
        
        update cataItem;
        insert orderitem;
        
        APXTConga4__Conga_Template__c apt = new APXTConga4__Conga_Template__c();
        apt.Country__c = 'SPAIN';
        apt.APXTConga4__Template_Group__c = 'All';
        insert apt;
        
        String st = XC_LCC023_SelectCongaTemplateOnOrder.getIdValueAndSetUrl('All',conf.Id);
        
        System.assertEquals(true, st!=null);
    Test.stopTest();
}
    }