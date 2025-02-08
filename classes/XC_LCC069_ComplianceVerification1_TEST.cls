/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation 20/05/2019 
* @date Modification 25/06/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC069_ComplianceVerification1_TEST – Test class for XC_LCC069_ComplianceVerification1
*/

@isTest
public class XC_LCC069_ComplianceVerification1_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        for(Account acc : accounts){
            acc.XC_Segment__c = 'B2C';
        }
        insert accounts;
        //List<XC_Address__c> addressList = XC_DF_Address.createAddress(accounts);
        //insert addressList;
		NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        insert catalogItem;
        /*List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opport = oppList[0];
        opport.Name = 'TEST';
        opport.StageName = 'Draft';
        opport.CloseDate = Date.today();
        opport.XC_LegalEntity__c = 'EndesaX';
        opport.XC_SkipRisk__c = true;
        opport.XC_Segment__c = 'B2C';
        opport.AccountId = accounts[0].Id;
        insert opport;*/

        /*List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.NE__OptyId__c = opport.Id;
        order.XC_DeliveryAddress__c = addressList[0].Id;
        insert order;*/
        Id recTypeOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EndesaX';
            ord.recordTypeId = recTypeOrder;
        }
        update orderList;
        for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
            //orItem.NE__Catalog__c = catalog.Id;
            orItem.NE__CatalogItem__c = catalogItem.Id;
        }
        
        insert orderItems;

        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        Asset asst = listAsset[0];
        asst.XC_Configuration_Item__c = orderItems[0].Id;
        insert asst;

        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = orderItems[0].id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
    }

    //Test Method checkDocumentsComplianceVerification1
    static testMethod void checkDocumentsComplianceVerification1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        NE__Order__c o = [SELECT ID FROM NE__Order__c][0];
        /*NE__Order__c o = new NE__Order__c ();
        insert o;*/
        //NE__Order__c o = XC_DF_Order.createOrder('test');
        
        XC_UTIL_ResultWrapper rw = XC_LCC069_ComplianceVerification1.checkDocumentsComplianceVerification1(o.Id);
        System.assertEquals(true, rw!=null);
        string str = o.id;
        Boolean res = XC_LCC069_ComplianceVerification1.checkCompliance1Needed(str);
        System.assertEquals(true, res!=null);
        delete o;
        res = XC_LCC069_ComplianceVerification1.checkCompliance1Needed(str);
        System.assertEquals(true, res!=null);
        Test.stopTest();
    }
    
  //Test Method getWrapperJuctionObject
    static testMethod void getWrapperJuctionObject(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        Set<Id> setid = new Set<Id>();
        for(NE__OrderItem__c ord : oi) {
            setid.add(ord.Id);
        }
        XC_ComplianceVerificationStatus__c cvs = new XC_ComplianceVerificationStatus__c();
        insert cvs;
        XC_OrderItemCompliance__c oic = new XC_OrderItemCompliance__c();
        oic.XC_OrderItem__c=oi[0].Id; 
        oic.XC_ComplianceVerificationStatus__c=cvs.Id;
        insert oic;
        XC_LCC069_ComplianceVerification1.OrderItemCVSwrapper oiw = XC_LCC069_ComplianceVerification1.getWrapperJuctionObject(setid);
        System.assertEquals(true, oiw!=null); 
        Test.stopTest();
    }

    //Test Method createComplianceVerificationStatus
    static testMethod void complianceVerification2and3NoMatchTest(){
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        XC_DocumentComplianceMaster__c document = new XC_DocumentComplianceMaster__c();
        document.XC_ComplianceType__c = 'C1';
        document.XC_ProductCategory__c = 'Boiler';
        document.XC_DocumentType__c = 'DNI';
        document.XC_Country__c = 'SPAIN';
        document.XC_PaymentMethod__c ='*';
        document.XC_ReceivingChannel__c = '*';
        insert document;
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();	
		complianceMaster2.XC_Country__c = 'SPAIN';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_CommercialCode__c= 'def';
        //complianceMaster2.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_ProductCategory__c = 'Air conditioning';
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster3.XC_CommercialCode__c= 'abc';
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        insert complMasterList;             
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN005_ComplianceVerification3.InputWrapper inputWr = new XC_IN005_ComplianceVerification3.InputWrapper();
        inputWr.stepId = step.Id;
        List<XC_IN005_ComplianceVerification3.InputWrapper> wrapperList = new List<XC_IN005_ComplianceVerification3.InputWrapper>();
        wrapperList.add(inputWr);
        XC_IN004_ComplianceVerification2.InputWrapper inputWr2 = new XC_IN004_ComplianceVerification2.InputWrapper();
        inputWr2.stepId = step.Id;
        List<XC_IN004_ComplianceVerification2.InputWrapper> wrapperList2 = new List<XC_IN004_ComplianceVerification2.InputWrapper>();
        wrapperList2.add(inputWr2);
        
        test.startTest();
        XC_IN004_ComplianceVerification2.complianceVerification2(wrapperList2);
        XC_IN005_ComplianceVerification3.complianceVerification3(wrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 

    static testMethod void onComplianceNeededOrToSkeep(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Test.startTest();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        XC_LCC069_ComplianceVerification1.checkCompliance1Needed(order.Id);
        order.XC_Compliance_Approval__c = 'Not Needed';
        update order;
        XC_LCC069_ComplianceVerification1.checkCompliance1Needed(order.Id);
        Test.stopTest();

        System.assertNotEquals(order, null);
    } 
    
    static testMethod void test1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Test.startTest();
        NE__OrderItem__c ordIt = [SELECT ID FROM NE__OrderItem__c][0];
        XC_LCC069_ComplianceVerification1.checkCompliance1Needed(ordIt.id);
        System.assert(ordIt != null);
        Test.stopTest();
    } 

    static testMethod void test2(){ 
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        XC_DocumentType__c docType = new XC_DocumentType__c();
        docType.Category__c = 'DNI';
        docType.XC_Configuration__c = order.Id;
        insert docType;
        XC_DocumentComplianceMaster__c document = new XC_DocumentComplianceMaster__c();
        document.XC_ComplianceType__c = 'C1';
        document.XC_ProductCategory__c = 'Boiler';
        document.XC_DocumentType__c = 'DNI';
        document.XC_Country__c = 'SPAIN';
        document.XC_PaymentMethod__c ='*';
        document.XC_ReceivingChannel__c = '*';
        insert document;
        List<XC_ComplianceMaster__c> complMasterList = new List<XC_ComplianceMaster__c>();
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster1b = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster2 = new XC_ComplianceMaster__c();
        XC_ComplianceMaster__c complianceMaster3 = new XC_ComplianceMaster__c();
        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        Id recTypeComplianceTwoId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_2).getRecordTypeId();
        Id recTypeComplianceThreeId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_3).getRecordTypeId();
        complianceMaster1.XC_Country__c = 'SPAIN';
        complianceMaster1.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1.XC_ProductCategory__c = 'Boiler';
        complianceMaster1.XC_Queue__c = 'Cola 1';
        complianceMaster1.XC_CommercialCode__c= 'lmn';
        complianceMaster1.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster1.XC_Probability__c = 100;
        complianceMaster2.XC_Probability__c = 100;
        complianceMaster2.XC_CommercialCode__c= 'hee';
        complianceMaster2.XC_Country__c = 'SPAIN';
        complianceMaster2.RecordTypeId = recTypeComplianceTwoId;
        complianceMaster2.XC_ComplianceTypePicklist__c = 'C2';
        complianceMaster2.XC_ProductCategory__c = 'Boiler';
        complianceMaster2.XC_Queue__c = 'Cola 2';
        complianceMaster2.XC_SalesPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Country__c = 'SPAIN';
        complianceMaster3.RecordTypeId = recTypeComplianceThreeId;
        complianceMaster3.XC_ComplianceTypePicklist__c = 'C3';
        complianceMaster3.XC_CommercialCode__c= 'ghi';
        complianceMaster3.XC_ProductCategory__c = 'Boiler';
        complianceMaster3.XC_InstallerPartnerId__c = order.NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c;
        complianceMaster3.XC_Queue__c = 'Cola 3';
        complianceMaster3.XC_Probability__c = 100;
        complianceMaster1b.XC_CommercialCode__c= 'poi';
        complMasterList.add(complianceMaster1);
        complMasterList.add(complianceMaster2);
        complMasterList.add(complianceMaster3);
        complMasterList.add(complianceMaster1b);
        insert complMasterList;     
        
        test.startTest();
        XC_LCC069_ComplianceVerification1.checkCompliance1NeededOrToSkeep(order.Id);
        XC_LCC069_ComplianceVerification1.checkDocumentsComplianceVerification1(order.Id);
        test.stopTest();
        System.assertEquals(1, orderList.size());
    }
    
 	static testMethod void test3(){ 
        List<NE__Order__c> orderList = [SELECT Id,NE__OptyId__r.XC_CommercialVisitAssignedResource__r.XC_Account__c  FROM NE__Order__c ];
        NE__Order__c order = orderList[0];
        XC_DocumentType__c docType = new XC_DocumentType__c();
        docType.Category__c = 'SF_DNI';
        docType.XC_Configuration__c = order.Id;
        insert docType;
        XC_DocumentComplianceMaster__c document = new XC_DocumentComplianceMaster__c();
        document.XC_ComplianceType__c = 'C1';
        document.XC_ProductCategory__c = 'Boiler';
        document.XC_DocumentType__c = 'SF_DNI';
        document.XC_Country__c = 'SPAIN';
        document.XC_PaymentMethod__c ='*';
        insert document;
        XC_ComplianceMaster__c complianceMaster1 = new XC_ComplianceMaster__c();
        Id recTypeComplianceOneId = Schema.SObjectType.XC_ComplianceMaster__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Compliance_1).getRecordTypeId();
        complianceMaster1.XC_Country__c = 'SPAIN';
        complianceMaster1.RecordTypeId = recTypeComplianceOneId;
        complianceMaster1.XC_ComplianceTypePicklist__c = 'C1';
        complianceMaster1.XC_ProductCategory__c = 'Boiler';
        complianceMaster1.XC_Queue__c = 'Cola 1';
        complianceMaster1.XC_Probability__c = 100;
        insert complianceMaster1;     
        
        test.startTest();
        XC_LCC069_ComplianceVerification1.checkCompliance1NeededOrToSkeep(order.Id);
        XC_LCC069_ComplianceVerification1.checkDocumentsComplianceVerification1(order.Id);
        test.stopTest();
        System.assertEquals(1, orderList.size());
    }
}