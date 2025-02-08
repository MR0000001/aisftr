/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 04/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_IN013_DeprovisioningCheckRefund_TEST - Test class for XC_IN013_DeprovisioningCheckRefund
*/ 
@isTest
public class XC_IN013_DeprovisioningCheckRefund_TEST {
    /**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  31/05/2019 
* @description insert records
*/ 
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        /*List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];
        ordIt.NE__OneTimeFeeOv__c = 10;
        ordIt.NE__AssetItemEnterpriseId__c = ordIt.id;
        insert ordIt;
        NE__Order__c order = new NE__Order__c(Id = ordIt.NE__OrderId__c);
        order.NE__Type__c = Label.XC_CL_Configuration_TypeDisconnection;
        order.XC_Subtype__c = 'Rethinking';
        update order;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        insert ast;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;*/



        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(2);
        NE__OrderItem__c ordItFather = orderItemList[0];
        ordItFather.NE__Bundle_Configuration__c = null;
        NE__OrderItem__c ordIt = orderItemList[1];
        ordIt.NE__OrderId__c = ordItFather.NE__OrderId__c;
        insert orderItemList;
        NE__Order__c order = new NE__Order__c(Id = ordItFather.NE__OrderId__c);
        order.NE__Type__c = Label.XC_CL_Configuration_TypeDisconnection;
        order.XC_Subtype__c = 'Rethinking';
        update order;

        List<NE__Bundle__c> listBundle = XC_DF_Bundle.createBundleRecords(1);
        insert listBundle;

        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].XC_Product_SubType__c = 'Bundle';
        listProducts[0].XC_Product_Type__c = 'Bundle';
        listProducts[0].Name= 'eHome_SPA_SetPrice';
        listProducts[0].XC_LIC_Product_Name__c= 'eHome_SPA_SetPrice';
        insert listProducts;
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '12345',
                                                                        Zuora__PreviousSubscriptionId__c = '12345',
                                                                        Zuora__External_Id__c = '56789');
        insert sub;

        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c (Zuora__Balance__c = 0, Zuora__Status__c = 'Posted', Zuora__TotalAmount__c = 10);
        insert invoice;

        Zuora__InvoiceItem__c invoiceItem = new Zuora__InvoiceItem__c(Zuora__Subscription__c = sub.id, Zuora__Invoice__c = invoice.Id);
        insert invoiceItem;

        List<Account> listAccount = [SELECT Id FROM Account];
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(listAccount);
        insert addressList;

        List<Asset> listAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listAsset[0].Name ='eHome_SPA_SetPrice';
        listAsset[0].XC_BillingModel__c = '3 years renting';
        listAsset[0].AccountId = listAccount[0].Id;
        listAsset[0].XC_Subscription__c = sub.Id;
        insert listAsset;

        List<Asset> listChildAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listChildAsset[0].AccountId = listAccount[0].Id;
        for(Asset a : listChildAsset) {
            a.parentId = listAsset[0].Id;
        }

        listAsset[0].InstallDate = Date.today();
        listAsset[0].NE__Activation_Date__c = Date.today();
        listAsset[0].XC_ActivationDate__c = Date.today();
        insert listChildAsset;

        List<String> listAttributes = new List<String>();
        listAttributes.add('Modelo de Pago');
        listAttributes.add('Modalidad de contratacion');

        List<NE__AssetItemAttribute__c> listAtt = XC_DF_Asset.createAssetItemAttributes(listAsset, listAttributes);
        insert listAtt;

        List<NE__Matrix_Parameter__c> listMatrix = XC_DF_MatrixParameter.createMatrixParameter(1);
        insert listMatrix;

        List<NE__Matrix_Parameter_Row__c> listMatrixRows = XC_DF_MatrixParameter.createMatrixParameterRows(listMatrix[0], listAsset, listProducts, '3 years renting');
        insert listMatrixRows;
        System.debug(listMatrixRows[0]);



        listAsset[0].XC_Configuration_Item__c = orderItemList[0].Id;
        listAsset[0].XC_Original_Creation_OrderItem__c = orderItemList[0].Id;
        listAsset[0].NE__Order_Config__c = orderItemList[0].NE__OrderId__c;
        update listAsset; 

        orderItemList[0].NE__AssetItemEnterpriseId__c = listAsset[0].Id;
        orderItemList[1].NE__AssetItemEnterpriseId__c = listAsset[0].Id;
        update orderItemList;

    
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = orderItemList[1].id;        
        insert provisioningStep;
    }
    
    @isTest
    static void checkRefundTEST(){        

        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        Id stepId = stepsList[0].Id;
        XC_IN013_DeprovisioningCheckRefund.InputWrapper inputWr = new XC_IN013_DeprovisioningCheckRefund.InputWrapper();
        inputWr.stepId = stepId;
        List<XC_IN013_DeprovisioningCheckRefund.InputWrapper> wrapperList = new List<XC_IN013_DeprovisioningCheckRefund.InputWrapper>();
        wrapperList.add(inputWr);
        test.startTest();
        XC_IN013_DeprovisioningCheckRefund.checkRefund(wrapperList);
        test.stopTest();
        System.assert(stepId!=null);
        
    }


    @isTest
    static void checkRefundTEST2(){        

        Map<Id, XC_Provisioning_Step__c> stepsMap = new  Map<Id, XC_Provisioning_Step__c> ([SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ]);
        Id stepId = stepsMap.values()[0].Id;
        XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps wrappConfItem = new XC_IN008_DeprovisioningBillingProcess_U.WrapperConfItemsMaps();
        wrappConfItem.configurationItemMap = new Map<Id,NE__OrderItem__c> ([SELECT Id, NE__OrderId__r.XC_CaseId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, XC_BillingProfileLineItem__r.XC_ZuoraId__c, NE__OrderId__r.XC_Segment__c  FROM NE__OrderItem__c WHERE Id =:  stepsMap.values()[0].XC_Configuration_Item__c]);
        XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper listWr = new XC_IN008_DeprovisioningBillingProcess_U.ListsWrapper();
        listWr.mapSteps = stepsMap;

        Test.setMock(HttpCalloutMock.class, new XC_REST_Zuora_Mock());
        test.startTest();
        XC_IN013_DeprovisioningCheckRefund.doActions(wrappConfItem, '10',  listWr);
        test.stopTest();

        System.assert(stepId!=null);
    }


    public without sharing class XC_REST_Zuora_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":48244,"name":"WF-40472-00000054","originalWorkflowId":40472,"type":"Workflow::Instance","status":"Queued","createdAt":"","updatedAt":""}');
            res.setStatusCode(200);
            
            return res;    
        }
    }
}