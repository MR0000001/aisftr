/**
 * @File Name          : XC_IN050_ManageMixedVATWF_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 21/4/2020, 11:26:45
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/4/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@IsTest
public class XC_IN050_ManageMixedVATWF_TEST {

    @IsTest
    static void testMethod1(){

        ZuoraWebservice_Mock_TEST mock = new ZuoraWebservice_Mock_TEST();
        Test.setMock(HttpCalloutMock.class, mock);

        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        NE__Order__c order = XC_DF_Order.createOrder('Order');
        System.debug(order.NE__Order_Items__r);
        List < NE__OrderItem__c > ListOrderItem = [select id, NE__BaseOneTimeFee__c, XC_PaymentMethod__c, XC_BillingProfileLineItem__c from NE__OrderItem__c
            where NE__OrderId__c =: order.id
        ];


        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        cat.XC_Mixed_VAT__c = true;
        insert cat;

        List < NE__Product__c > productList = XC_DF_Product.createProducts(1);
        ListOrderItem[0].NE__ProdId__c = productList[0].Id;
        ListOrderItem[0].NE__CatalogItem__c = cat.Id;

        List < Account > accList = [SELECT Id FROM Account WHERE Id =: order.NE__AccountID__c];
        List < XC_Address__c > createAddress = XC_DF_Address.createAddress(accList);
        insert createAddress;

        Zuora__CustomerAccount__c zCA = new Zuora__CustomerAccount__c();
        zCA.Zuora__Account__c = accList[0].id;
        zCa.Zuora__External_Id__c = '123456';
        zCa.Zuora__Zuora_Id__c = '123456';
        insert zCA;

        List < Contact > contactIdList = [select id from contact where AccountId =: order.NE__AccountID__c];
        List < NE__Billing_Profile__c > ListBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        ListBillingProfiles[0].NE__Payment__c = 'Cash';
        update ListBillingProfiles;

        ListOrderItem[0].NE__BaseOneTimeFee__c = 89;
        ListOrderItem[0].XC_PaymentMethod__c = ListBillingProfiles[0].NE__Payment__c;
        List < XC_BillingProfileLineItem__c > ListBPLI = [SELECT Id
            FROM XC_BillingProfileLineItem__c
            WHERE XC_BillingProfile__c =: ListBillingProfiles[0].Id
        ];
        
        ListBPLI[0].XC_LegalEntity__c = 'EndesaX';
        ListBPLI[0].XC_CustomerAccount__c = zCA.ID;
        ListBPLI[0].XC_BillToContactId__c = contactIdList[0].id;
        ListBPLI[0].XC_SoldToContactId__c = contactIdList[0].id;
        ListBPLI[0].XC_BillToAddress__c = createAddress[0].id;
        update ListBPLI;

        zqu__Quote__c quote = new zqu__Quote__c();
        insert quote;

        ListOrderItem[0].XC_BillingProfileLineItem__c = ListBPLI[0].ID;
        ListOrderItem[0].XC_ZQuoteId__c = quote.Id;
        update ListOrderItem;


        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ListOrderItem[0].id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;

        XC_IN050_ManageMixedVATWF.InputWrapper iw = new XC_IN050_ManageMixedVATWF.InputWrapper();
        iw.stepId = provisioningStep.Id;
        List<XC_IN050_ManageMixedVATWF.InputWrapper> inputs = new List<XC_IN050_ManageMixedVATWF.InputWrapper>{iw};
        Set<String> stepIds = new Set<String>{provisioningStep.Id};

        Test.startTest();
            XC_IN050_ManageMixedVATWF.manageMixedVATZuoraWF(inputs);
            XC_IN050_ManageMixedVATWF.checkMixedVAT(stepIds);
        Test.stopTest();
        
    }

    @IsTest
    static void testMethod2(){

        ZuoraWebservice_Mock_TEST mock = new ZuoraWebservice_Mock_TEST();
        Test.setMock(HttpCalloutMock.class, mock);

        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        NE__Order__c order = XC_DF_Order.createOrder('Order');
        System.debug(order.NE__Order_Items__r);
        List < NE__OrderItem__c > ListOrderItem = [select id, NE__BaseOneTimeFee__c, XC_PaymentMethod__c, XC_BillingProfileLineItem__c from NE__OrderItem__c
            where NE__OrderId__c =: order.id
        ];

        


        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        cat.XC_Mixed_VAT__c = true;
        insert cat;

        NE__Catalog_Item__c cat2 = XC_DF_CatalogItem.createCatalogItem();
        insert cat2;
        

        List < NE__Product__c > productList = XC_DF_Product.createProducts(1);
        ListOrderItem[0].NE__ProdId__c = productList[0].Id;
        ListOrderItem[0].NE__CatalogItem__c = cat2.Id;

        NE__OrderItem__c bundle = XC_DF_OrderItem.createOrderItem(order);
        bundle.NE__ProdId__c = productList[0].Id;
        bundle.NE__CatalogItem__c = cat.Id;
        insert bundle;
        ListOrderItem[0].NE__Bundle_Configuration__c = bundle.Id;

        List < Account > accList = [SELECT Id FROM Account WHERE Id =: order.NE__AccountID__c];
        List < XC_Address__c > createAddress = XC_DF_Address.createAddress(accList);
        insert createAddress;

        Zuora__CustomerAccount__c zCA = new Zuora__CustomerAccount__c();
        zCA.Zuora__Account__c = accList[0].id;
        zCa.Zuora__External_Id__c = '123456';
        zCa.Zuora__Zuora_Id__c = '123456';
        insert zCA;

        List < Contact > contactIdList = [select id from contact where AccountId =: order.NE__AccountID__c];
        List < NE__Billing_Profile__c > ListBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        ListBillingProfiles[0].NE__Payment__c = 'Cash';
        update ListBillingProfiles;

        ListOrderItem[0].NE__BaseOneTimeFee__c = 89;
        ListOrderItem[0].XC_PaymentMethod__c = ListBillingProfiles[0].NE__Payment__c;
        List < XC_BillingProfileLineItem__c > ListBPLI = [SELECT Id
            FROM XC_BillingProfileLineItem__c
            WHERE XC_BillingProfile__c =: ListBillingProfiles[0].Id
        ];
        
        ListBPLI[0].XC_LegalEntity__c = 'EndesaX';
        ListBPLI[0].XC_CustomerAccount__c = zCA.ID;
        ListBPLI[0].XC_BillToContactId__c = contactIdList[0].id;
        ListBPLI[0].XC_SoldToContactId__c = contactIdList[0].id;
        ListBPLI[0].XC_BillToAddress__c = createAddress[0].id;
        update ListBPLI;

        zqu__Quote__c quote = new zqu__Quote__c();
        insert quote;

        ListOrderItem[0].XC_BillingProfileLineItem__c = ListBPLI[0].ID;
        ListOrderItem[0].XC_ZQuoteId__c = quote.Id;
        update ListOrderItem;


        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ListOrderItem[0].id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;

        XC_IN050_ManageMixedVATWF.InputWrapper iw = new XC_IN050_ManageMixedVATWF.InputWrapper();
        iw.stepId = provisioningStep.Id;
        List<XC_IN050_ManageMixedVATWF.InputWrapper> inputs = new List<XC_IN050_ManageMixedVATWF.InputWrapper>{iw};
        Set<String> stepIds = new Set<String>{provisioningStep.Id};

        Test.startTest();
            XC_IN050_ManageMixedVATWF.manageMixedVATZuoraWF(inputs);
            XC_IN050_ManageMixedVATWF.checkMixedVAT(stepIds);
        Test.stopTest();
    }

}