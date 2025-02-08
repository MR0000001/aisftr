/**
 * The Class XC_UTIL_DocComplMaster_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 24/06/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_UTIL_DocumentComplianceMaster
 **/


@isTest
public without sharing class XC_UTIL_DocComplMaster_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    }


    @isTest
    static void testGetDocComplMaster(){

        List<NE__OrderItem__c>  orderItemList = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c oi :orderItemList ){
			oi.XC_CreditAssignmentAvailable__c = false;            
        }
        insert orderItemList;
		List<NE__Order__c> orderList =  [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_Country__c = 'Spain'; 
        }
        update orderList;
        XC_DocumentComplianceMaster__c docComplMaster = new XC_DocumentComplianceMaster__c();
        docComplMaster.XC_ComplianceType__c = 'C1';
        docComplMaster.XC_ProductCategory__c = 'Boiler';
        docComplMaster.XC_Country__c = 'Spain';
        docComplMaster.XC_DocumentType__c = 'DNI;Contract to sign';
        docComplMaster.XC_HasCreditAssignment__c   = '';
        insert docComplMaster;
 
        XC_DocumentComplianceMaster__c docComplMaster2 = new XC_DocumentComplianceMaster__c();
        docComplMaster2.XC_ComplianceType__c = 'C1';
        docComplMaster2.XC_ProductCategory__c = 'Air Conditioning';
        docComplMaster2.XC_ReceivingChannel__c = '*';
        docComplMaster2.XC_PaymentMethod__c = '*';
        docComplMaster2.XC_Country__c = 'Spain';
        docComplMaster2.XC_DocumentType__c = 'DNI;Contract to sign';
        insert docComplMaster2;
        
        test.startTest();
        Map<Id, List<String>> docMasterMap = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster('C1', orderItemList);
        test.stopTest();

        System.assertEquals(true, docMasterMap!=null, 'Wrong assert result');
    }


    @isTest
    static void testGetMap(){

        List<NE__OrderItem__c>  orderItemList = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c oi :orderItemList ){
			oi.XC_CreditAssignmentAvailable__c = false;            
        }        
        insert orderItemList;

        Map<Id, List<String>> mapConfItemDocuments = new Map<Id, List<String>>();
        List<String> a = new List<String>{'DNI', 'Contract'};
        List<String> b = new List<String>{'Test'};
        mapConfItemDocuments.put(orderItemList[0].Id, a);
        mapConfItemDocuments.put(orderItemList[0].Id, b);

        test.startTest();
        Map<String, Set<String>> docMap = XC_UTIL_DocumentComplianceMaster.getMapDocumentListIdConfItem(mapConfItemDocuments);
        test.stopTest();

        System.assertEquals(true, docMap!=null, 'Wrong assert result');
    }
    
        @isTest
    static void testWildCard(){

        List<NE__OrderItem__c>  orderItemList = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c oi :orderItemList ){
			oi.XC_CreditAssignmentAvailable__c = false;            
        }        
        insert orderItemList;
        List<NE__Catalog_Category__c> catCategoryList = [SELECT Id, NE__CatalogId__c, XC_LIC_Category_Name__c FROM NE__Catalog_Category__c LIMIT 1];
        catCategoryList[0].XC_LIC_Category_Name__c = 'Air Conditioning';
		update catCategoryList[0];
        /*orderItemList[0].NE__CatalogItem__c = catCategoryList[0].NE__CatalogId__c;
        update orderItemList[0];*/
        List<NE__OrderItem__c> orItemQueried = [SELECT ID,NE__CatalogItem__r.NE__Catalog_Category_Name__r.name FROM NE__OrderItem__c LIMIT 1];
        System.debug('@@@@TEST CLASS catalog category--->' + orItemQueried[0].NE__CatalogItem__r.NE__Catalog_Category_Name__r.name);
        Map<Id, List<String>> mapConfItemDocuments = new Map<Id, List<String>>();
        List<String> a = new List<String>{'DNI'};
        List<String> b = new List<String>{'Test'};
        mapConfItemDocuments.put(orderItemList[0].Id, a);
        mapConfItemDocuments.put(orderItemList[0].Id, b);

        test.startTest();
        Map<String, Set<String>> docMap = XC_UTIL_DocumentComplianceMaster.getMapDocumentListIdConfItem(mapConfItemDocuments);
        test.stopTest();

        System.assertEquals(true, docMap!=null, 'Wrong assert result');
    }

    @isTest
    static void testGetDocComplMasterReceivingChannel(){

        List<NE__OrderItem__c>  orderItemList = XC_DF_OrderItem.createOrderItems(1);
        orderItemList[0].XC_PaymentMethod__c = 'Direct Debt';
        orderItemList[0].XC_CreditAssignmentAvailable__c = false;    
        insert orderItemList;
        
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;

        NE__Order__c ord = new NE__Order__c(Id = orderItemList[0].NE__OrderId__c);
        ord.NE__OptyId__c = listOfOpp[0].Id;
        update ord;
        XC_DocumentComplianceMaster__c docComplMaster = new XC_DocumentComplianceMaster__c();
        docComplMaster.XC_ComplianceType__c = 'C1';
        docComplMaster.XC_ProductCategory__c = 'Boiler';
        docComplMaster.XC_Country__c = 'Spain';
        docComplMaster.XC_DocumentType__c = 'DNI;Contract to sign';
        docComplMaster.XC_PaymentMethod__c = '*';
        docComplMaster.XC_ReceivingChannel__c = 'Web';
        insert docComplMaster;
 
        
        test.startTest();
        Map<Id, List<String>> docMasterMap = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster('C1', orderItemList);
        test.stopTest();

        System.assertEquals(true, docMasterMap!=null, 'Wrong assert result');
    }


    @isTest
    static void testGetDocComplMasterExactField(){

        List<NE__OrderItem__c>  orderItemList = XC_DF_OrderItem.createOrderItems(1);
        orderItemList[0].XC_PaymentMethod__c = 'Direct Debt';
        orderItemList[0].XC_CreditAssignmentAvailable__c = false;
        insert orderItemList;
        
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;

        NE__Order__c ord = new NE__Order__c(Id = orderItemList[0].NE__OrderId__c);
        ord.NE__OptyId__c = listOfOpp[0].Id;
        update ord;
        XC_DocumentComplianceMaster__c docComplMaster = new XC_DocumentComplianceMaster__c();
        docComplMaster.XC_ComplianceType__c = 'C1';
        docComplMaster.XC_ProductCategory__c = 'Boiler';
        docComplMaster.XC_Country__c = 'Spain';
        docComplMaster.XC_DocumentType__c = 'DNI;Contract to sign';
        docComplMaster.XC_PaymentMethod__c = 'Direct Debt';
        docComplMaster.XC_ReceivingChannel__c = 'Web';
        insert docComplMaster;
 
        
        test.startTest();
        Map<Id, List<String>> docMasterMap = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster('C1', orderItemList);
        test.stopTest();

        System.assertEquals(true, docMasterMap!=null, 'Wrong assert result');
    }
    
    @isTest
    static void testCheckWildCardFields(){
        XC_DocumentComplianceMaster__c docComplMaster = new XC_DocumentComplianceMaster__c();
        docComplMaster.XC_ComplianceType__c = 'C1';
        docComplMaster.XC_ProductCategory__c = 'Boiler';
        docComplMaster.XC_Country__c = 'Spain';
        docComplMaster.XC_DocumentType__c = 'DNI;Contract to sign';
        docComplMaster.XC_PaymentMethod__c = 'Direct Debt';
        docComplMaster.XC_ReceivingChannel__c = 'Web';
        insert docComplMaster;
 		XC_UTIL_DocumentComplianceMaster.DocumentComplianceWrapper wrapper = new XC_UTIL_DocumentComplianceMaster.DocumentComplianceWrapper();
        wrapper.country = 'Spain';
        wrapper.type = 'C1';
        wrapper.productCategory = 'Boiler';
        wrapper.paymentMethod = 'Direct Debt';
        wrapper.receivingChannel = 'Web';
        
        test.startTest();
        XC_UTIL_DocumentComplianceMaster.checkWildCardFields(wrapper, docComplMaster);
        test.stopTest();
    }
    
    @isTest
    static void testCheckExactReceivingChannel(){
        XC_DocumentComplianceMaster__c docComplMaster = new XC_DocumentComplianceMaster__c();
        docComplMaster.XC_ComplianceType__c = 'C1';
        docComplMaster.XC_ProductCategory__c = 'Boiler';
        docComplMaster.XC_Country__c = 'Spain';
        docComplMaster.XC_DocumentType__c = 'DNI;Contract to sign';
        docComplMaster.XC_PaymentMethod__c = 'Direct Debt';
        docComplMaster.XC_ReceivingChannel__c = 'Web';
        insert docComplMaster;
 		XC_UTIL_DocumentComplianceMaster.DocumentComplianceWrapper wrapper = new XC_UTIL_DocumentComplianceMaster.DocumentComplianceWrapper();
        wrapper.country = 'Spain';
        wrapper.type = 'C1';
        wrapper.productCategory = 'Boiler';
        wrapper.paymentMethod = 'Direct Debt';
        wrapper.receivingChannel = 'Web';
        
        test.startTest();
        XC_UTIL_DocumentComplianceMaster.checkExactReceivingChannel(wrapper, docComplMaster);
        test.stopTest();
    }
}